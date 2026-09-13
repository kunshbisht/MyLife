//
//  AuthView.swift
//  MyLife
//
//  Created by kunsh macbook on 13/9/26.
//


import SwiftUI

struct EmailAuthView: View {
    @State private var showLogin = false

    var body: some View {
        if showLogin {
            LoginView(showLogin: $showLogin)
        } else {
            SignUpView(showLogin: $showLogin)
        }
    }
}

#Preview {
    EmailAuthView()
}
