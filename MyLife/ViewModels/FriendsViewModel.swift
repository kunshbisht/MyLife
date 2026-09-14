//
//  FriendsViewModel.swift
//  MyLife
//
//  Created by kunsh macbook on 14/9/26.
//

import Foundation
import Combine

@MainActor
final class FriendsViewModel: ObservableObject {

    private let friendsManager = FriendsManager()

    @Published var friends: [Profile] = []
    @Published var isLoading = false

    // MARK: - Load Friends

    func loadFriends(for userID: UUID) async {
        isLoading = true
        defer {
            isLoading = false
        }

        do {
            let friendIDs = try await friendsManager.loadFriends(
                for: userID
            )

            guard !friendIDs.isEmpty else {
                friends = []
                return
            }

            let profiles = try await friendsManager.loadProfiles(
                withIDs: friendIDs
            )

            friends = profiles

        } catch {
            print("Failed to load friends: \(error)")
        }
    }
}
