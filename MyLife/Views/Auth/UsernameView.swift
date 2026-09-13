//
//  UsernameView.swift
//  MyLife
//
//  Created by kunsh macbook on 13/9/26.
//


import SwiftUI
import Supabase

struct UsernameView: View {
    @EnvironmentObject var auth: AuthManager

    @State private var username = ""
    @State private var errorMessage: String?
    @State private var isSaving = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Choose a username")
                .font(.largeTitle.bold())

            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }

            Button {
                saveUsername()
            } label: {
                if isSaving {
                    ProgressView()
                } else {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(username.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
        }
        .padding(24)
    }

    private func saveUsername() {
        let username = username.trimmingCharacters(in: .whitespacesAndNewlines)

        // Validate BEFORE loading
        guard username.count >= 3 else {
            errorMessage = "Username must be at least 3 characters."
            return
        }

        guard username.count <= 20 else {
            errorMessage = "Username must be 20 characters or less."
            return
        }

        let pattern = "^[A-Za-z][A-Za-z0-9_]*$"

        guard username.range(of: pattern, options: .regularExpression) != nil else {
            errorMessage = "Use only letters, numbers, and underscores."
            return
        }

        Task {
            isSaving = true
            errorMessage = nil

            do {
                guard let user = auth.user else {
                    errorMessage = "You are not signed in."
                    isSaving = false
                    return
                }

                try await supabase
                    .from("profiles")
                    .insert([
                        "id": user.id.uuidString,
                        "username": username.lowercased()
                    ])
                    .execute()

                auth.hasUsername = true

            } catch {
                print("USERNAME ERROR:", error)

                if error.localizedDescription.contains("duplicate") {
                    errorMessage = "Username is already taken."
                } else {
                    errorMessage = "Couldn't save username. Please try again."
                }
            }

            isSaving = false
        }
    }
}
