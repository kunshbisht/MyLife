//
//  AddFriendsView.swift
//  MyLife
//
//  Created by kunsh macbook on 14/9/26.
//

import SwiftUI
internal import Auth

struct AddFriendsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var auth: AuthManager

    @StateObject private var viewModel = AddFriendsViewModel()
    @State private var searchText = ""

    private var filteredUsers: [Profile] {
        if searchText.isEmpty {
            return viewModel.users
        }

        return viewModel.users.filter {
            $0.username.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List(filteredUsers) { user in
                userRow(user)
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .navigationTitle("Add Friends")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(
                    displayMode: .always
                ),
                prompt: "Search username"
            )
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                guard let userID = auth.user?.id else {
                    return
                }

                await viewModel.loadData(for: userID)
            }
        }
    }

    // MARK: - User Row

    @ViewBuilder
    private func userRow(_ user: Profile) -> some View {
        HStack(spacing: 12) {

            Circle()
                .fill(.gray.opacity(0.2))
                .frame(width: 48, height: 48)
                .overlay {
                    Image(systemName: "person.fill")
                        .foregroundStyle(.secondary)
                }

            Text("@\(user.username)")
                .fontWeight(.semibold)

            Spacer()

            if viewModel.friendIDs.contains(user.id) {
                Text("Friends")
                    .foregroundStyle(.secondary)

            } else if viewModel.pendingIDs.contains(user.id) {
                Text("Pending")
                    .foregroundStyle(.secondary)

            } else if viewModel.incomingRequestIDs.contains(user.id) {
                Button("Accept") {
                    Task {
                        guard let userID = auth.user?.id else {
                            return
                        }

                        await viewModel.acceptFriendRequest(
                            for: userID,
                            from: user
                        )
                    }
                }
                .buttonStyle(.borderedProminent)

            } else {
                Button("Add") {
                    Task {
                        guard let userID = auth.user?.id else {
                            return
                        }

                        await viewModel.addFriend(
                            from: userID,
                            to: user
                        )
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    AddFriendsView()
        .environmentObject(AuthManager())
}
