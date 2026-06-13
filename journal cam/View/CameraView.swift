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

    @State private var viewModel = CameraViewModel()
    @State private var showEntryView = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            liveCamera
        }
        .task { await viewModel.startCamera() }
        .onDisappear { viewModel.stopCamera() }
        .fullScreenCover(isPresented: $showEntryView) {
            if let image = viewModel.capturedImage {
                JournalEntryView(image: image, userId: userId, onSaved: {
                    onSaved()
                    dismiss()
                })
            }
        }
        .onChange(of: viewModel.capturedImage) { _, newImage in
            if newImage != nil {
                showEntryView = true
            }
        }
    }

    private var liveCamera: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(.black.opacity(0.5))
                        .clipShape(Circle())
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            Spacer()

            GeometryReader { geo in
                CameraPreview(previewLayer: viewModel.previewLayer)
                    .frame(width: geo.size.width, height: geo.size.width * 4 / 3)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            }
            .frame(height: UIScreen.main.bounds.width * 4 / 3)
            .padding(.horizontal, 16)

            Spacer()

            if viewModel.isSessionReady {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    viewModel.capture()
                } label: {
                    ZStack {
                        Circle()
                            .stroke(.white.opacity(0.5), lineWidth: 4)
                            .frame(width: 84, height: 84)
                        Circle()
                            .fill(.white)
                            .frame(width: 72, height: 72)
                    }
                }
            } else {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.5)
            }

            Spacer()
        }
    }
}
