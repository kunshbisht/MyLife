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
    @Published var hasUsername = false

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

            // Verify that the user still exists
            let user = try await supabase.auth.user()

            self.session = session
            self.user = user

            await checkUsername()

        } catch {
            self.session = nil
            self.user = nil
            self.hasUsername = false

            try? await supabase.auth.signOut()
        }

        isLoading = false
    }

    func refreshUser() async {
        do {
            let session = try await supabase.auth.refreshSession()

            self.session = session
            self.user = session.user

            await checkUsername()
        } catch {
            print("Failed to refresh session:", error)
        }
    }

    func signUp(email: String, password: String) async throws {
        let response = try await supabase.auth.signUp(
            email: email,
            password: password
        )

        self.session = response.session
        self.user = response.user

        await checkUsername()
    }

    func signIn(email: String, password: String) async throws {
        let response = try await supabase.auth.signIn(
            email: email,
            password: password
        )

        self.session = response
        self.user = response.user

        await checkUsername()
    }

    func signOut() async throws {
        try await supabase.auth.signOut()

        self.session = nil
        self.user = nil
        self.hasUsername = false
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

        await checkUsername()

        self.isLoading = false
    }

    func checkUsername() async {
        guard let user else {
            hasUsername = false
            return
        }

        do {
            let profile: [String: String]? = try await supabase
                .from("profiles")
                .select("username")
                .eq("id", value: user.id.uuidString)
                .single()
                .execute()
                .value

            hasUsername = profile?["username"] != nil
        } catch {
            hasUsername = false
        }
    }
}
