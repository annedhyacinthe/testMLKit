//
//  PhotoPreviewView.swift
//  testtest
//
//  Created by Anne Hyacinthe on 11/3/24.
//

import SwiftUI

struct PhotoPreviewView: View {
    let image: UIImage
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .navigationBarItems(
                    trailing: Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
        }
    }
}
