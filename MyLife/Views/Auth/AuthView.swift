//
//  AuthView.swift
//  MyLife
//
//  Created by kunsh macbook on 13/9/26.
//

import SwiftUI
import Supabase

struct AuthView: View {
    @EnvironmentObject var auth: AuthManager
    @Environment(\.openURL) private var openURL
    @State private var showEmailAuth = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // MARK: - Header
                    VStack(spacing: 12) {
                        Text("MyLife")
                            .font(.system(size: 42, weight: .bold, design: .rounded))

                        Text("Your life, all in one place.")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    // MARK: - Auth buttons
                    VStack(spacing: 12) {

                        // Google
                        Button {
                            do {
                                let url = try auth.googleSignInURL()
                                openURL(url)
                            } catch {
                                print(error)
                            }

                        } label: {
                            HStack(spacing: 12) {
                                Image("GoogleLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)

                                Text("Continue with Google")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay {
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.black.opacity(0.12), lineWidth: 1)
                            }
                        }

                        // Email
                        Button {
                            showEmailAuth = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "envelope.fill")
                                    .font(.system(size: 18))

                                Text("Continue with Email")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }

                    Text("You need to sign in before using the app")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 18)

                    Spacer()
                        .frame(height: 32)
                }
                .padding(.horizontal, 24)
            }
            .navigationDestination(isPresented: $showEmailAuth) {
                EmailAuthView()
            }
        }
    }
}

#Preview {
    AuthView()
}
