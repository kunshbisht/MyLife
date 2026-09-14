//
//  FriendsView.swift
//  MyLife
//
//  Created by kunsh macbook on 12/9/26.
//

import SwiftUI
internal import Auth

struct FriendsView: View {
    @EnvironmentObject var auth: AuthManager

    @StateObject private var viewModel = FriendsViewModel()

    @State private var showingAddFriends = false

    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.friends.isEmpty && !viewModel.isLoading {
                    ContentUnavailableView(
                        "No Friends Yet",
                        systemImage: "person.2",
                        description: Text(
                            "Add some friends to see them here."
                        )
                    )
                    .padding(.top, 100)
                } else {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: 28
                    ) {
                        ForEach(viewModel.friends) { friend in
                            friendView(friend)
                        }
                    }
                    .padding(20)
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .navigationTitle("Friends")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        showingAddFriends = true
                    } label: {
                        Image(systemName: "person.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddFriends) {
                AddFriendsView()
            }
            .task {
                guard let userID = auth.user?.id else {
                    return
                }

                await viewModel.loadFriends(for: userID)
            }
        }
    }

    // MARK: - Friend

    private func friendView(_ friend: Profile) -> some View {
        VStack(spacing: 8) {
            Circle()
                .fill(.gray.opacity(0.2))
                .frame(width: 72, height: 72)
                .overlay {
                    Image(systemName: "person.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }

            Text("@\(friend.username)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    FriendsView()
        .environmentObject(AuthManager())
}
