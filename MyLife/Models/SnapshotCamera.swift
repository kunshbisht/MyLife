//
//  SnapshotCamera.swift
//  MyLife
//
//  Created by kunsh macbook on 12/9/26.
//

import SwiftUI
import AVFoundation

struct SnapshotCamera: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    @Binding var captureRequest: Int

    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()

        controller.onPhotoCaptured = { image in
            capturedImage = image
        }

        return controller
    }

    func updateUIViewController(
        _ uiViewController: CameraViewController,
        context: Context
    ) {
        if captureRequest != context.coordinator.lastCaptureRequest {
            context.coordinator.lastCaptureRequest = captureRequest
            uiViewController.takePhoto()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var lastCaptureRequest = 0
    }
}

final class CameraViewController: UIViewController {

    private let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()

    private var previewLayer: AVCaptureVideoPreviewLayer!

    var onPhotoCaptured: ((UIImage) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        checkCameraPermission()
    }

    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {

        case .authorized:
            setupCamera()

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.setupCamera()
                    }
                }
            }

        default:
            break
        }
    }

    private func setupCamera() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let camera = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ) else {
            session.commitConfiguration()
            return
        }

        guard let input = try? AVCaptureDeviceInput(device: camera) else {
            session.commitConfiguration()
            return
        }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }

        session.commitConfiguration()

        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill

        view.layer.addSublayer(previewLayer)

        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        previewLayer?.frame = view.bounds
    }

    func takePhoto() {
        guard session.isRunning else { return }

        let settings = AVCapturePhotoSettings()

        photoOutput.capturePhoto(
            with: settings,
            delegate: self
        )
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard
            error == nil,
            let data = photo.fileDataRepresentation(),
            let image = UIImage(data: data)
        else {
            return
        }

        DispatchQueue.main.async {
            self.onPhotoCaptured?(image)
        }
    }
}
