//
//  IdentifiableImage.swift
//  PhotosPickerDemo
//
//  Created by Ty Janik on 4/27/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import SwiftUICore
import UIKit

class IdentifiableImage: Identifiable {
    var img: UIImage?
    
    init(img: UIImage? = nil) {
        self.img = img
    }
}
