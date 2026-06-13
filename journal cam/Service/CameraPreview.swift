//
//  CameraPreview.swift
//  journal cam
//
//  Created by Dylan on 06/06/26.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer?

    class PreviewView: UIView {
        var previewLayer: AVCaptureVideoPreviewLayer?

        override func layoutSubviews() {
            super.layoutSubviews()
            previewLayer?.frame = bounds
        }
    }

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.backgroundColor = .black
        if let layer = previewLayer {
            layer.videoGravity = .resizeAspectFill
            view.previewLayer = layer
            view.layer.addSublayer(layer)
        }
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        if let layer = previewLayer, uiView.previewLayer == nil {
            layer.videoGravity = .resizeAspectFill
            uiView.previewLayer = layer
            uiView.layer.addSublayer(layer)
        }
    }
}
