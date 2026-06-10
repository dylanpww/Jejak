//
//  CameraService.swift
//  journal cam
//
//  Created by Dylan on 06/06/26.
//

import AVFoundation
import UIKit

@Observable
class CameraService: NSObject {
    var capturedImage: UIImage?
    var errorMessage: String?
    var isSessionReady = false

    private let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    var previewLayer: AVCaptureVideoPreviewLayer?

    func start() async {
            guard await checkPermission() else {
                errorMessage = "Camera access denied."
                return
            }

            session.beginConfiguration()
            session.sessionPreset = .photo

            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                        for: .video,
                                                        position: .front),
                  let input = try? AVCaptureDeviceInput(device: device)
            else {
                errorMessage = "Could not access front camera"
                return
            }

            if session.canAddInput(input) { session.addInput(input) }
            if session.canAddOutput(output) { session.addOutput(output) }
            session.commitConfiguration()

            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer?.videoGravity = .resizeAspectFill

            await Task.detached { self.session.startRunning() }.value
            
            await MainActor.run {
                self.isSessionReady = true
            }
        }

    func capture() {
        guard session.isRunning else {
            print("❌ Session not running yet")
            return
        }
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }

    func stop() {
        session.stopRunning()
    }

    private func checkPermission() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: return true
        case .notDetermined: return await AVCaptureDevice.requestAccess(for: .video)
        default: return false
        }
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        Task { @MainActor in
            self.capturedImage = image
        }
    }
}
