//
//  EmailConfirmationView.swift
//  MyLife
//
//  Created by kunsh macbook on 13/9/26.
//

import SwiftUI
internal import Auth

struct EmailConfirmationView: View {
    @EnvironmentObject var auth: AuthManager
    @Environment(\.scenePhase) private var scenePhase

    @State private var isRefreshing = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Header
            VStack(spacing: 10) {
                Image(systemName: "envelope.badge")
                    .font(.system(size: 56))
                    .symbolRenderingMode(.hierarchical)

                Text("Check your email")
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)

                Text("We've sent you a confirmation link. Confirm your email to start using MyLife.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 60)

            Spacer()

            // MARK: - Refresh
            VStack(spacing: 12) {
                Button {
                    Task {
                        await refresh()
                    }
                } label: {
                    HStack {
                        if isRefreshing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("I've confirmed my email")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(isRefreshing)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            Spacer()

            // MARK: - Logout
            Button {
                Task {
                    try? await auth.signOut()
                }
            } label: {
                Text("Log Out")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 24)
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                Task {
                    await refresh()
                }
            }
        }
    }

    private func refresh() async {
        isRefreshing = true
        errorMessage = ""

        await auth.refreshUser()

        if auth.user?.emailConfirmedAt == nil {
            errorMessage = "Your email hasn't been confirmed yet."
        }

        isRefreshing = false
    }
}
