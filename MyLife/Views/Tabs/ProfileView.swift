//
//  Profileview.swift
//  MyLife
//
//  Created by kunsh macbook on 12/9/26.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var auth: AuthManager

    var body: some View {
        Button(role: .destructive) {
            Task {
                do {
                    try await auth.signOut()
                } catch {
                    print("Sign out failed:", error)
                }
            }
        } label: {
            Text("Sign Out")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.red)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 20)
        }
    }
}

#Preview {
    ProfileView()
}
