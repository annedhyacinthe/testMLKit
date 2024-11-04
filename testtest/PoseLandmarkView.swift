//
//  PoseLandmarkView.swift
//  testtest
//
//  Created by Anne Hyacinthe on 11/3/24.
//

import SwiftUI
import MLKit
import MLKitVision
import MLKitPoseDetectionAccurate
struct PoseLandmarkView: View {
    let landmarks: [PoseLandmark]
    let videoDimensions: CGSize
    
    var body: some View {
        let t = print("hi anne")
        GeometryReader { geometry in
            Text("GeometryReader")
                      .font(.title)
            Canvas { context, size in
                
//                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color.red))//filled in background
                for landmark in landmarks {
                    if(landmark.type.rawValue == "RightEye"){
                        print("TYPE",landmark.type.rawValue)
                        // Convert normalized coordinates to view coordinates
                        //                    print("LANDMARK",landmark)
                        print("LANDMARK x",landmark.position.x," Y ",landmark.position.y)
                        let normalizedX = CGFloat(landmark.position.x) / videoDimensions.width
                        let normalizedY = CGFloat(landmark.position.y) / videoDimensions.height
                        
                        let x = normalizedX * size.width
                        let y = normalizedY * size.height
                        
                        print("LANDMARK x",landmark.position.x," Y ",landmark.position.y)
                        print("NORMALIZED"," x ",normalizedX," y ",normalizedY)
                        print("SIZE",size," x ",x," y ",y)
                        print("VIDEODIMENSION",videoDimensions)
                        
                        let point = Path(ellipseIn: CGRect(x: x - 5, y: y - 5, width: 10, height: 10))
                        //                    print("CGRECT",CGRect(x: x - 5, y: y - 5, width: 10, height: 10)," X ",x," Y ",y)
                        context.stroke(point, with: .color(.green), lineWidth: 2)
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}
