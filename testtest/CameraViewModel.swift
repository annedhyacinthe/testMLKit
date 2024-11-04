//
//  CameraViewModel.swift
//  testtest
//
//  Created by Anne Hyacinthe on 11/3/24.
//

import Foundation
import AVFoundation
import MLKitVision
import MLKitPoseDetectionAccurate
import UIKit

class CameraViewModel: NSObject, ObservableObject {
    @Published var currentPoseLandmarks: [PoseLandmark]?
    @Published var videoDimensions: CGSize = CGSize(width: 1920, height: 1080)
    @Published var isAuthorized = false
    
    private let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let videoOutput = AVCaptureVideoDataOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var photoCaptureCompletion: ((UIImage?) -> Void)?
    
    private lazy var poseDetector: PoseDetector = {
        let options = AccuratePoseDetectorOptions()
        options.detectorMode = .stream
        return PoseDetector.poseDetector(options: options)
    }()
    
    override init() {
        super.init()
        setupSession()
    }
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.isAuthorized = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                }
            }
        default:
            self.isAuthorized = false
        }
    }
    
    private func setupSession() {
        session.beginConfiguration()
        
        // Add video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            return
        }
        
        if let videoConnection = videoOutput.connection(with: .video) {
                    let dimensions = CMVideoFormatDescriptionGetDimensions(videoDevice.activeFormat.formatDescription)
                        DispatchQueue.main.async {
                            self.videoDimensions = CGSize(width: CGFloat(dimensions.width),
                                                        height: CGFloat(dimensions.height))
                        }
                    
                }
        
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        }
        
        // Add photo output
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        
        // Add video output
        if session.canAddOutput(videoOutput) {
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            session.addOutput(videoOutput)
        }
        
        session.commitConfiguration()
        
        // Create preview layer
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        self.previewLayer = previewLayer
        
        // Start the session
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        return previewLayer
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        photoCaptureCompletion = completion
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

// Camera delegate extensions
extension CameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("hit")
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        print("hit 1")
        let image = VisionImage(buffer: sampleBuffer)
        image.orientation = .leftMirrored // For front camera
        
        do {
            print("hit 2")
            let poses = try poseDetector.results(in: image)
//            print("hit 3",poses)
//            print("land",self.currentPoseLandmarks)
            if let pose = poses.first {
                DispatchQueue.main.async {
                    self.currentPoseLandmarks = Array(pose.landmarks)
                }
            }
        } catch {
            print("Failed to detect poses: \(error.localizedDescription)")
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            photoCaptureCompletion?(nil)
            return
        }
        
        photoCaptureCompletion?(image)
    }
}

