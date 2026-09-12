import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // Locket-style tab for quick photos
            Tab("Snapshot", systemImage: "camera.fill") {
                SnapshotView()
            }

            // Life feed, friend circles and mini chat
            Tab("Friends", systemImage: "person.2.fill") {
                FriendsView()
            }

            // Memories, yearly memories, recaps, collages, etc.
            Tab("Memories", systemImage: "photo.stack.fill") {
                MemoriesView()
            }

            Tab("Profile", systemImage: "person.fill") {
                ProfileView()
            }
        }
    }
}

#Preview {
    ContentView()
}
