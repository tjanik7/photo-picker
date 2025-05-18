/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The profile image that reflects the selected item state.
*/

import SwiftUI
import PhotosUI

struct ProfileImage: View {
	let imageState: ProfileModel.ImageState
	
	var body: some View { // Switch block below simply checks value of imageState (enum) field; note that this enum is updated automatically in the ProfileModel via the didSet{} block
		switch imageState { // Here is where it is decided what to put in the profile pic (either default person pic or what we selected in the picker)
        case .success(let image):
			image.resizable()
            let _ = print("========== ProfileImage state is success ===========")
		case .loading:
            let _ = print("=== State is loading ===")
			ProgressView()
		case .empty:
            let _ = print("=== State is empty ===")
			Image(systemName: "person.fill")
				.font(.system(size: 40))
				.foregroundColor(.white)
		case .failure:
            let _ = print("=== State is failure ===")
			Image(systemName: "exclamationmark.triangle.fill")
				.font(.system(size: 40))
				.foregroundColor(.white)
		}
	}
}

struct CircularProfileImage: View {
	let imageState: ProfileModel.ImageState
	
	var body: some View {
		ProfileImage(imageState: imageState)
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

struct EditableCircularProfileImage: View {
	@ObservedObject var profileModel: ProfileModel
	
	var body: some View {
        // Construct a new CircularProfileImage and pass in the image state
		CircularProfileImage(imageState: profileModel.imageState)
			.overlay(alignment: .bottomTrailing) { // Bottom trailing sets this to appear in the bottom right hand side
				PhotosPicker(selection: $profileModel.imageSelection,
							 matching: .images,
							 photoLibrary: .shared()) { // This trailing closure (below) defines the button we use to open the PhotosPicker
					Image(systemName: "pencil.circle.fill")
						.symbolRenderingMode(.multicolor)
						.font(.system(size: 30))
						.foregroundColor(.green)
				}
				.buttonStyle(.borderless)
			}
	}
}
