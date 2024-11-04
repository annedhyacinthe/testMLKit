//
//  CameraPreviewView.swift
//  testtest
//
//  Created by Anne Hyacinthe on 11/3/24.
//

import SwiftUI

struct CameraPreviewView: UIViewRepresentable {
    let viewModel: CameraViewModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        if let previewLayer = viewModel.getPreviewLayer() {
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
