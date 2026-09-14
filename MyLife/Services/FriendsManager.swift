//
//  FriendsManager.swift
//  MyLife
//
//  Created by kunsh macbook on 14/9/26.
//

import Foundation
import Supabase

final class FriendsManager {

    private let client = supabase

    // MARK: - Users

    func loadUsers(excluding userID: UUID) async throws -> [Profile] {
        try await client
            .from("profiles")
            .select()
            .neq("id", value: userID.uuidString)
            .order("username")
            .execute()
            .value
    }

    // MARK: - Profiles

    func loadProfiles(withIDs ids: Set<UUID>) async throws -> [Profile] {
        try await client
            .from("profiles")
            .select()
            .in(
                "id",
                values: ids.map { $0.uuidString }
            )
            .order("username")
            .execute()
            .value
    }

    // MARK: - Friends

    func loadFriends(for userID: UUID) async throws -> Set<UUID> {
        let friendships: [Friendship] = try await client
            .from("friendships")
            .select()
            .or(
                "user_id.eq.\(userID.uuidString),friend_id.eq.\(userID.uuidString)"
            )
            .eq("status", value: "accepted")
            .execute()
            .value

        return Set(
            friendships.map { friendship in
                friendship.userID == userID
                    ? friendship.friendID
                    : friendship.userID
            }
        )
    }

    // MARK: - Pending Requests

    func loadPendingRequests(for userID: UUID) async throws -> [Friendship] {
        try await client
            .from("friendships")
            .select()
            .eq("user_id", value: userID.uuidString)
            .eq("status", value: "pending")
            .execute()
            .value
    }

    // MARK: - Send Friend Request

    func sendFriendRequest(
        from userID: UUID,
        to friendID: UUID
    ) async throws {

        let existing: [Friendship] = try await client
            .from("friendships")
            .select()
            .or(
                "and(user_id.eq.\(userID.uuidString),friend_id.eq.\(friendID.uuidString)),and(user_id.eq.\(friendID.uuidString),friend_id.eq.\(userID.uuidString))"
            )
            .execute()
            .value

        guard existing.isEmpty else {
            return
        }

        let request = FriendshipInsert(
            userID: userID,
            friendID: friendID,
            status: "pending"
        )

        try await client
            .from("friendships")
            .insert(request)
            .execute()
    }

    // MARK: - Friend Requests

    func loadFriendRequests(for userID: UUID) async throws -> [FriendRequest] {
        try await client
            .from("friendships")
            .select("""
                id,
                user_id,
                friend_id,
                status,
                profiles!friendships_user_id_fkey (
                    username
                )
            """)
            .eq("friend_id", value: userID.uuidString)
            .eq("status", value: "pending")
            .execute()
            .value
    }

    // MARK: - Accept Friend Request

    func acceptFriendRequest(requestID: UUID) async throws {
        try await client
            .from("friendships")
            .update([
                "status": "accepted"
            ])
            .eq("id", value: requestID.uuidString)
            .execute()
    }
}
