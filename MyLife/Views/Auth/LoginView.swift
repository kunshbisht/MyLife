//
//  LoginView.swift
//  MyLife
//
//  Created by kunsh macbook on 13/9/26.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthManager
    @Binding var showLogin: Bool

    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // MARK: - Header
                VStack(spacing: 10) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 56))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.primary)

                    Text("Welcome back")
                        .font(.system(size: 32, weight: .bold))

                    Text("Log in to continue to MyLife")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 60)
                .padding(.bottom, 40)

                // MARK: - Form
                VStack(spacing: 16) {
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

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        HStack(spacing: 12) {
                            Image(systemName: "lock")
                                .foregroundStyle(.secondary)

                            SecureField("Your password", text: $password)
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 52)
                        .background(.quaternary.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
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
                    .padding(.top, 12)
                }

                // MARK: - Login Button
                Button {
                    Task {
                        isLoading = true
                        errorMessage = ""

                        do {
                            try await auth.signIn(
                                email: email,
                                password: password
                            )
                        } catch {
                            errorMessage = error.localizedDescription
                        }

                        isLoading = false
                    }
                } label: {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Log In")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 28)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(email.isEmpty || password.isEmpty || isLoading)
                .padding(.top, 24)

                Spacer()

                // MARK: - Footer
                Button {
                    showLogin = false
                } label: {
                    Text("Don't have an account? \(Text("Sign Up").foregroundStyle(.primary).bold())")
                        .foregroundStyle(.secondary)
                }
                .font(.footnote)
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 24)
            .navigationBarHidden(true)
        }
    }
}
