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

struct PickerLaunchButton: View {
    @ObservedObject var viewModel: ProfileModel
    
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
