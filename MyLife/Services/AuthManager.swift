//
//  AuthManager.swift
//  MyLife
//
//  Created by kunsh macbook on 13/9/26.
//


import Foundation
import Combine
import Supabase

@MainActor
final class AuthManager: ObservableObject {
    @Published var user: User?
    @Published var session: Session?
    @Published var isLoading = true

    var isGoogleUser: Bool {
        user?.appMetadata["provider"] as? String == "google"
    }

    init() {
        Task {
            await loadSession()
        }
    }

    func loadSession() async {
        do {
            let session = try await supabase.auth.session

            self.session = session
            self.user = session.user
        } catch {
            self.session = nil
            self.user = nil
        }

        isLoading = false
    }

    func refreshUser() async {
        do {
            let session = try await supabase.auth.refreshSession()

            self.session = session
            self.user = session.user
        } catch {
            print("Failed to refresh session:", error)
        }
    }

    func signUp(email: String, password: String) async throws {
        let response = try await supabase.auth.signUp(
            email: email,
            password: password
        )

        self.user = response.user
    }

    func signIn(email: String, password: String) async throws {
        let response = try await supabase.auth.signIn(
            email: email,
            password: password
        )

        self.user = response.user
    }

    func signOut() async throws {
        try await supabase.auth.signOut()

        self.session = nil
        self.user = nil
    }

    func googleSignInURL() throws -> URL {
        try supabase.auth.getOAuthSignInURL(
            provider: .google,
            redirectTo: URL(string: "mylife://login-callback")!
        )
    }

    func handleOAuthCallback(_ url: URL) async throws {
        let session = try await supabase.auth.session(from: url)

        self.session = session
        self.user = session.user
        self.isLoading = false
    }
}
