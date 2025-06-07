//
//  PhotoPickerLaunchButton.swift
//  PhotosPickerDemo
//
//  Created by Ty Janik on 6/1/25.
//  Copyright © 2025 Apple. All rights reserved.
//


import SwiftUI
import PhotosUI

struct PhotoPickerLaunchButton: View {
    @Bindable var viewModel: DataModel
    
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
