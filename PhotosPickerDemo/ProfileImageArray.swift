/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The profile image that reflects the selected item state.
*/

import SwiftUI
import PhotosUI

struct ProfileImageArray: View {
    let imageState: ProfileModelArray.ImageState
    
    var body: some View { // Keep in mind that since this is a view we don't need a return statement, simply instantiating the Image() is enough for it to display
        switch imageState { // This is not where the enum is defined; it is where it is evaluated for the cirular profile pic (only considers first img in array)
        case .success(let image):
            let img = Image(uiImage: image)
            img.resizable()
        case .loading:
            ProgressView()
        case .empty:
            Image(systemName: "person.fill")
                .font(.system(size: 40))
                .foregroundColor(.white)
        case .failure:
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.white)
        }
    }
}

struct CircularProfileImageArray: View {
    let imageState: ProfileModelArray.ImageState
    
    var body: some View {
        ProfileImageArray(imageState: imageState)
            .scaledToFill()
            .clipShape(Circle())
            .frame(width: 100, height: 100)
            .background {
                Circle().fill(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
    }
}



struct SquareImage: View {
    let imgWrapper: ImageWrapper
    
    var body: some View {
        let image = Image(uiImage: imgWrapper.img!)
        image.resizable()
            .frame(width: 100, height: 100)
    }
}

struct EditableCircularProfileImageArray: View {
    @ObservedObject var viewModel: ProfileModelArray
    
    var body: some View {
        //CircularProfileImageArray(imageState: viewModel.imageState)
        CircularProfileImageArray(imageState: viewModel.imageStateArray.count > 0 ? viewModel.imageStateArray[0] : .empty)
            .overlay(alignment: .bottomTrailing) {
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
}
