//
//  SnapshotView.swift
//  MyLife
//
//  Created by kunsh macbook on 12/9/26.
//


import SwiftUI
internal import Auth

struct ContentView: View {
    @EnvironmentObject var auth: AuthManager

    var body: some View {
        Group {
            if auth.isLoading {
                ProgressView()

            } else if let user = auth.user {

                if !auth.isGoogleUser && user.emailConfirmedAt == nil {
                    EmailConfirmationView()

                } else if !auth.hasUsername {
                    UsernameView()

                } else {
                    MainAppView()
                }

            } else {
                AuthView()
            }
        }
    }
}

#Preview {
    ContentView()
}
