//
//  ImageWrapper.swift
//  PhotosPickerDemo
//
//  Created by Ty Janik on 4/27/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import SwiftUICore

class ImageWrapper: Identifiable {
    var img: Image?
    
    init(img: Image? = nil) {
        self.img = img
    }
}
