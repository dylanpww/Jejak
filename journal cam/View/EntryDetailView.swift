//
//  EntryDetailView.swift
//  journal cam
//
//  Created by Dylan on 07/06/26.
//


import SwiftUI

struct EntryDetailView: View {
    let entry: JournalEntry
    let userId: String
    var onDeleted: (() -> Void)? = nil

    @State private var viewModel = JournalViewModel()
    @State private var showEditView = false
    @State private var showDeleteConfirm = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.08, blue: 0.18),
                    Color(red: 0.10, green: 0.16, blue: 0.32)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    AsyncImage(url: URL(string: entry.photoURL)) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.gray.opacity(0.3))
                            .frame(height: 300)
                            .overlay(ProgressView())
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    if !entry.note.isEmpty {
                        Text(entry.note)
                            .font(.body)
                            .padding(.horizontal)
                    }

                    Text(entry.createdAt.formatted(date: .long, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }
                .padding()
            }
        }
        .navigationTitle(entry.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showEditView = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .confirmationDialog(
            "Delete this journal entry?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteEntry(entry, userId: userId)
                    onDeleted?()
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .fullScreenCover(isPresented: $showEditView) {
            EntryEditView(entry: entry, userId: userId) {
                onDeleted?()
            }
        }
    }
}

#Preview {
    NavigationStack {
        EntryDetailView(
            entry: JournalEntry(
                userId: "preview_user",
                title: "A walk in the park",
                note: "Today was a really calm day. I went for a walk around the park near campus and just enjoyed the quiet for a bit.",
                photoURL: "https://picsum.photos/800/1000",
                createdAt: .now
            ),
            userId: "preview_user"
        )
    }
}
