//
//  MyLifeApp.swift
//  MyLife
//
//  Created by kunsh macbook on 12/9/26.
//

import SwiftUI

@main
struct MyLifeApp: App {
    @StateObject private var auth = AuthManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(auth)
                .onOpenURL { url in
                    Task {
                        try? await auth.handleOAuthCallback(url)
                    }
                }
        }
    }
}
