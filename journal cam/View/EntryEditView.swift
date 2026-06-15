//
//  EntryEditView.swift
//  journal cam
//
//  Created by Dylan on 13/06/26.
//


import SwiftUI

struct EntryEditView: View {
    let entry: JournalEntry
    let userId: String
    let onSaved: () -> Void

    @State private var viewModel = JournalViewModel()
    @State private var title: String
    @State private var content: String
    @State private var isSaving = false
    @Environment(\.dismiss) private var dismiss

    init(entry: JournalEntry, userId: String, onSaved: @escaping () -> Void) {
        self.entry = entry
        self.userId = userId
        self.onSaved = onSaved
        _title = State(initialValue: entry.title)
        _content = State(initialValue: entry.note)
    }

    var body: some View {
        NavigationStack {
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
                    VStack(spacing: 0) {
                        AsyncImage(url: URL(string: entry.photoURL)) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                        .frame(
                            width: UIScreen.main.bounds.width,
                            height: UIScreen.main.bounds.width * 4 / 3
                        )
                        .clipped()

                        VStack(alignment: .leading, spacing: 20) {
                            Text(entry.createdAt.formatted(date: .long, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            TextField("Title", text: $title)
                                .font(.title2.bold())

                            Divider()

                            TextField("Write your thoughts...", text: $content, axis: .vertical)
                                .font(.body)
                                .frame(minHeight: 200, alignment: .topLeading)

                            if let error = viewModel.errorMessage {
                                Text(error)
                                    .foregroundStyle(.red)
                                    .font(.caption)
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            isSaving = true
                            await viewModel.updateEntry(entry, title: title, note: content, userId: userId)
                            isSaving = false
                            onSaved()
                            dismiss()
                        }
                    } label: {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Save")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(.black.opacity(0.4))
                                .clipShape(Capsule())
                        }
                    }
                    .disabled(isSaving || title.isEmpty)
                }
            }
        }
    }
}
