//
//  CameraViewModel.swift
//  journal cam
//
//  Created by Dylan on 10/06/26.
//


import AVFoundation
import UIKit

@Observable
class CameraViewModel {
    var capturedImage: UIImage?
    var errorMessage: String?
    var isSessionReady = false
    var isSaving = false
    var note = ""

    private let cameraService = CameraService()
    private let firestoreService = FirestoreService()

    var previewLayer: AVCaptureVideoPreviewLayer? {
        cameraService.previewLayer
    }

    init() {
        cameraService.onPhotoCaptured = { [weak self] image in
            self?.capturedImage = image
        }
    }

    func startCamera() async {
        await cameraService.start()
        isSessionReady = cameraService.isSessionReady
    }

    func stopCamera() {
        cameraService.stop()
    }

    func capture() {
        cameraService.capture()
    }

    func retake() {
        capturedImage = nil
        cameraService.capturedImage = nil
    }
}
