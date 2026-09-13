//
//  SignUpView.swift
//  MyLife
//
//  Created by kunsh macbook on 13/9/26.
//


import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var auth: AuthManager
    @Binding var showLogin: Bool

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    @State private var errorMessage = ""
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // MARK: - Header
                VStack(spacing: 10) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 56))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.primary)

                    Text("Create your account")
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)

                    Text("Join MyLife and start your journey")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)
                .padding(.bottom, 32)

                // MARK: - Form
                ScrollView {
                    VStack(spacing: 16) {

                        // Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            HStack(spacing: 12) {
                                Image(systemName: "person")
                                    .foregroundStyle(.secondary)

                                TextField("Your name", text: $name)
                                    .textInputAutocapitalization(.words)
                                    .autocorrectionDisabled()
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 52)
                            .background(.quaternary.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        // Email
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            HStack(spacing: 12) {
                                Image(systemName: "envelope")
                                    .foregroundStyle(.secondary)

                                TextField("you@example.com", text: $email)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .keyboardType(.emailAddress)
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 52)
                            .background(.quaternary.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        // Password
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            HStack(spacing: 12) {
                                Image(systemName: "lock")
                                    .foregroundStyle(.secondary)

                                SecureField("Create a password", text: $password)
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 52)
                            .background(.quaternary.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        // Confirm Password
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm password")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            HStack(spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(.secondary)

                                SecureField(
                                    "Repeat your password",
                                    text: $confirmPassword
                                )
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 52)
                            .background(.quaternary.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        // MARK: - Error
                        if !errorMessage.isEmpty {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")

                                Text(errorMessage)
                                    .font(.caption)
                            }
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // MARK: - Sign Up Button
                        Button {
                            Task {
                                await signUp()
                            }
                        } label: {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Create Account")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 28)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .disabled(
                            name.isEmpty ||
                            email.isEmpty ||
                            password.isEmpty ||
                            confirmPassword.isEmpty ||
                            isLoading
                        )
                    }
                }

                Spacer(minLength: 16)

                // MARK: - Login
                Button {
                    showLogin = true
                } label: {
                    Text("Already have an account? \(Text("Log In").foregroundStyle(.primary).fontWeight(.semibold))")
                        .foregroundStyle(.secondary)
                }
                .font(.footnote)
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 24)
            .navigationBarBackButtonHidden()
        }
    }

    // MARK: - Sign Up

    private func signUp() async {
        errorMessage = ""

        guard password == confirmPassword else {
            errorMessage = "Passwords don't match."
            return
        }

        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }

        isLoading = true

        do {
            try await auth.signUp(
                email: email,
                password: password
            )

            // Profile creation can be added here.
            // For example:
            // try await createProfile(name: name)

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
