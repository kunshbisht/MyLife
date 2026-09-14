//
//  Profile.swift
//  MyLife
//
//  Created by kunsh macbook on 14/9/26.
//

import Foundation

struct Profile: Codable, Identifiable {
    let id: UUID
    let username: String
}

struct Friendship: Codable {
    let id: UUID
    let userID: UUID
    let friendID: UUID
    let status: String

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case friendID = "friend_id"
        case status
    }
}

struct FriendshipInsert: Codable {
    let userID: UUID
    let friendID: UUID
    let status: String

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case friendID = "friend_id"
        case status
    }
}

struct FriendRequest: Codable, Identifiable {
    let id: UUID
    let userID: UUID
    let friendID: UUID
    let status: String
    let profiles: RequestProfile

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case friendID = "friend_id"
        case status
        case profiles
    }

    var username: String {
        profiles.username
    }
}

struct RequestProfile: Codable {
    let username: String
}
