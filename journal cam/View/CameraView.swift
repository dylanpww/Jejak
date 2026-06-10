//
//  CameraView.swift
//  journal cam
//
//  Created by Dylan on 07/06/26.
//


import SwiftUI

struct CameraView: View {
    let userId: String
    let onSaved: () -> Void

    @State private var cameraService = CameraService()
    @State private var note = ""
    @State private var isSaving = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss
    private let firestoreService = FirestoreService()

    var body: some View {
        ZStack {
                if let captured = cameraService.capturedImage {
                    previewView(image: captured)
                } else {
                    liveCamera
                }
            }
            .task {
                await cameraService.start()
            }
            .onDisappear {
                cameraService.stop()
            }
    }

    private var liveCamera: some View {
        ZStack(alignment: .bottom) {
            CameraPreview(service: cameraService)
                .ignoresSafeArea()

            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .padding(12)
                            .background(.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding()
                Spacer()

                if cameraService.isSessionReady {
                                Button {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    cameraService.capture()
                                } label: {
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 72, height: 72)
                                        .overlay(
                                            Circle()
                                                .stroke(.white.opacity(0.4), lineWidth: 4)
                                                .frame(width: 84, height: 84)
                                        )
                                }
                                .padding(.bottom, 48)
                            } else {
                                ProgressView()
                                    .tint(.white)
                                    .padding(.bottom, 48)
                            }
            }
        }
    }

    private func previewView(image: UIImage) -> some View {
        ZStack(alignment: .bottom) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 16) {
                if let error = errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }

                TextField("Add a note...", text: $note, axis: .vertical)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)

                HStack(spacing: 16) {
                    Button {
                        cameraService.capturedImage = nil
                    } label: {
                        Text("Retake")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    Button {
                        Task { await save(image: image) }
                    } label: {
                        Group {
                            if isSaving {
                                ProgressView()
                            } else {
                                Text("Save")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.white)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(isSaving)
                }
                .padding(.horizontal)
                .padding(.bottom, 48)
            }
        }
    }

    private func save(image: UIImage) async {
        isSaving = true
        errorMessage = nil
        do {
            try await firestoreService.saveEntry(image: image, note: note, userId: userId)
            onSaved()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isSaving = false
    }
}
