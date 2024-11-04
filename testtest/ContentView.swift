//
//  ContentView.swift
//  testtest
//
//  Created by Anne Hyacinthe on 11/3/24.
//

import SwiftUI
import AVFoundation
import MLKitVision
import MLKitPoseDetectionAccurate

struct ContentView: View {
    @StateObject private var cameraViewModel = CameraViewModel()
    @State private var showingPhotoPreview = false
    @State private var capturedImage: UIImage?
    
    var body: some View {
        ZStack {
            // Camera preview
            CameraPreviewView(viewModel: cameraViewModel)
                .edgesIgnoringSafeArea(.all)
            
            // Overlay for pose detection landmarks
            if let landmarks = cameraViewModel.currentPoseLandmarks {
                PoseLandmarkView(landmarks: landmarks,videoDimensions: cameraViewModel.videoDimensions)
            }
            
            // Camera controls
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        cameraViewModel.capturePhoto { image in
                            self.capturedImage = image
                            self.showingPhotoPreview = true
                        }
                    }) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Circle()
                                    .stroke(Color.black.opacity(0.8), lineWidth: 2)
                            )
                            .padding(.bottom, 30)
                    }
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showingPhotoPreview) {
            if let image = capturedImage {
                PhotoPreviewView(image: image)
            }
        }
        .onAppear {
            cameraViewModel.checkPermissions()
        }
    }
}
