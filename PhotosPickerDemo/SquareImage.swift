//
//  SquareImage.swift
//  PhotosPickerDemo
//
//  Created by Ty Janik on 5/31/25.
//  Copyright © 2025 Apple. All rights reserved.
//


/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The profile image that reflects the selected item state.
*/

import SwiftUI
import PhotosUI

struct SquareImage: View {
    let imgWrapper: ImageWrapper
    
    var body: some View {
        let image = Image(uiImage: imgWrapper.img!)
        image.resizable()
            .frame(width: 100, height: 100)
    }
}

struct PhotoPickerLaunchButton: View {
    @Bindable var viewModel: ProfileModel
    
    var body: some View {
        PhotosPicker(selection: $viewModel.selectedItems,
                     matching: .images,
                     photoLibrary: .shared()) {
            Image(systemName: "pencil.circle.fill")
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 30))
                .foregroundColor(.accentColor)
        }
        .buttonStyle(.borderless)
    }
}
