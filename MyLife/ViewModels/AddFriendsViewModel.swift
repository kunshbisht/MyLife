//
//  AddFriendsViewModel.swift
//  MyLife
//
//  Created by kunsh macbook on 14/9/26.
//

import Foundation
import Combine

@MainActor
final class AddFriendsViewModel: ObservableObject {

    private let friendsManager = FriendsManager()

    @Published var users: [Profile] = []
    @Published var friendIDs: Set<UUID> = []
    @Published var pendingIDs: Set<UUID> = []
    @Published var incomingRequestIDs: Set<UUID> = []
    @Published var isLoading = false

    // MARK: - Load Data

    func loadData(for userID: UUID) async {
        isLoading = true
        defer {
            isLoading = false
        }

        do {
            async let users = friendsManager.loadUsers(
                excluding: userID
            )

            async let friends = friendsManager.loadFriends(
                for: userID
            )

            async let pending = friendsManager.loadPendingRequests(
                for: userID
            )

            async let requests = friendsManager.loadFriendRequests(
                for: userID
            )

            let (
                loadedUsers,
                loadedFriends,
                loadedPending,
                loadedRequests
            ) = try await (
                users,
                friends,
                pending,
                requests
            )

            self.users = loadedUsers
            self.friendIDs = loadedFriends

            self.pendingIDs = Set(
                loadedPending.map { $0.friendID }
            )

            self.incomingRequestIDs = Set(
                loadedRequests.map { $0.userID }
            )

        } catch {
            print("Failed to load friends data: \(error)")
        }
    }

    // MARK: - Add Friend

    func addFriend(
        from userID: UUID,
        to friend: Profile
    ) async {
        do {
            try await friendsManager.sendFriendRequest(
                from: userID,
                to: friend.id
            )

            pendingIDs.insert(friend.id)

        } catch {
            print("Failed to send friend request: \(error)")
        }
    }

    // MARK: - Accept Friend Request

    func acceptFriendRequest(
        for userID: UUID,
        from friend: Profile
    ) async {
        do {
            let requests = try await friendsManager.loadFriendRequests(
                for: userID
            )

            guard let request = requests.first(where: {
                $0.userID == friend.id
            }) else {
                return
            }

            try await friendsManager.acceptFriendRequest(
                requestID: request.id
            )

            incomingRequestIDs.remove(friend.id)
            friendIDs.insert(friend.id)

        } catch {
            print("Failed to accept friend request: \(error)")
        }
    }
}
