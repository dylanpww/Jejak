//
//  EntryDetailView.swift
//  journal cam
//
//  Created by Dylan on 07/06/26.
//


import SwiftUI

struct EntryDetailView: View {
    let entry: JournalEntry

    var body: some View {
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
        .navigationTitle("Entry")
        .navigationBarTitleDisplayMode(.inline)
    }
}
