//
//  JournalListView.swift
//  journal cam
//
//  Created by Selena Cheryl Willyam on 07/06/26.
//


import SwiftUI

struct JournalListView: View {
    let userId: String
    @State private var entries: [JournalEntry] = []
    @State private var showCamera = false
    @State private var isLoading = false
    private let firestoreService = FirestoreService()

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                } else if entries.isEmpty {
                    ContentUnavailableView(
                        "No entries yet",
                        systemImage: "camera.fill",
                        description: Text("Tap + to add your first journal entry")
                    )
                } else {
                    List(entries) { entry in
                        NavigationLink(destination: EntryDetailView(entry: entry)) {
                            EntryRowView(entry: entry)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Journal Cam")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCamera = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraView(userId: userId) {
                    Task { await loadEntries() }
                }
            }
            .task { await loadEntries() }
        }
    }

    private func loadEntries() async {
        isLoading = true
        entries = (try? await firestoreService.fetchEntries(userId: userId)) ?? []
        isLoading = false
    }
}

struct EntryRowView: View {
    let entry: JournalEntry

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: entry.photoURL)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.note.isEmpty ? "No note" : entry.note)
                    .lineLimit(2)
                Text(entry.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
