//
//  JournalListView.swift
//  journal cam
//
//  Created by Dylan on 07/06/26.
//


import SwiftUI
import PhotosUI

struct JournalListView: View {
    let userId: String

    @State private var viewModel = JournalViewModel()
    @State private var showCamera = false
    @State private var showPhotosPicker = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var pickedImage: UIImage?
    @State private var showEntryFromPicker = false

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

                Group {
                    if viewModel.isLoading {
                        ProgressView()
                    } else if viewModel.entries.isEmpty {
                        ContentUnavailableView(
                            "No entries yet",
                            systemImage: "camera.fill",
                            description: Text("Tap + to add your first journal entry")
                        )
                    } else {
                        List(viewModel.entries) { entry in
                            NavigationLink(destination: EntryDetailView(entry: entry, userId: userId, onDeleted: {
                                Task { await viewModel.loadEntries(userId: userId) }
                            })) {
                                EntryRowView(entry: entry)
                            }
                            .listRowBackground(Color.clear)
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Jejak")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showCamera = true
                        } label: {
                            Label("Take Selfie", systemImage: "camera")
                        }

                        Button {
                            showPhotosPicker = true
                        } label: {
                            Label("Upload from Library", systemImage: "photo")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .photosPicker(isPresented: $showPhotosPicker, selection: $selectedItem, matching: .images)
            .fullScreenCover(isPresented: $showCamera) {
                CameraView(userId: userId) {
                    Task { await viewModel.loadEntries(userId: userId) }
                }
            }
            .fullScreenCover(isPresented: $showEntryFromPicker) {
                if let image = pickedImage {
                    JournalEntryView(image: image, userId: userId) {
                        Task { await viewModel.loadEntries(userId: userId) }
                    }
                }
            }
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        pickedImage = image
                        showEntryFromPicker = true
                        selectedItem = nil
                    }
                }
            }
        }
        .task { await viewModel.loadEntries(userId: userId) }
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
                Text(entry.title.isEmpty ? "Untitled" : entry.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(entry.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    JournalListView(userId: "preview_user")
}
