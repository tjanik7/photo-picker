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

struct SquareImageView: View {
    let imgWrapper: ImageWrapper
    
    var body: some View {
        let image = Image(uiImage: imgWrapper.img!)
        image.resizable()
            .frame(width: 100, height: 100)
    }
}


