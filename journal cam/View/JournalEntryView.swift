//
//  JournalEntryView.swift
//  journal cam
//
//  Created by Dylan on 10/06/26.
//


import SwiftUI

struct JournalEntryView: View {
    let image: UIImage
    let userId: String
    let onSaved: () -> Void

    @State private var viewModel = JournalViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack{
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(
                                width: UIScreen.main.bounds.width,
                                height: UIScreen.main.bounds.width * 4 / 3
                            )
                            .clipped()
                        
                        VStack(alignment: .leading, spacing: 20) {
                            
                            Text(Date().formatted(date: .long, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            TextField("Title", text: $viewModel.title)
                                .font(.title2.bold())
                            
                            Divider()
                            
                            TextField("Write your thoughts...", text: $viewModel.content, axis: .vertical)
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
                .ignoresSafeArea(edges: .top)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button { dismiss() } label: {
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
                                do {
                                    try await viewModel.save(image: image, userId: userId)
                                    onSaved()
                                    dismiss()
                                } catch {
                                    viewModel.errorMessage = error.localizedDescription
                                }
                            }
                        } label: {
                            if viewModel.isSaving {
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
                        .disabled(viewModel.isSaving || viewModel.title.isEmpty)
                    }
                }
            }
        }
    }
}
