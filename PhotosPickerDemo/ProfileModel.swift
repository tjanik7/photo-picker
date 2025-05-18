/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An observable state object that contains profile details.
*/

import SwiftUI
import PhotosUI
import CoreTransferable

@MainActor
class ProfileModel: ObservableObject { // Only class defined in this file
    
	// MARK: - Profile Details
    
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var aboutMe: String = ""
    
    // MARK: - Profile Image
    
    enum ImageState { // These enum states are referenced with .<state value>
        case empty
		case loading(Progress) // "Progress" is the associated type; a Progress is instantiated when a variable of type .loading is initialized
		case success(Image)
		case failure(Error)
    }
    
    enum TransferError: Error {
        case importFailed
    }
    
    struct ProfileImage: Transferable { // Here we define ProfileImage as inner struct of ProfileModel class
        let image: Image
        
        static var transferRepresentation: some TransferRepresentation {
            // First param is the type of data we are representing
            // Second param to the DataRepresentation constructor is a closure with types (Data -> Item); Specifies how to go from binary data to our data type (i.e. ProfileImage)
            DataRepresentation(importedContentType: .image) { data in
            #if canImport(AppKit)
                guard let nsImage = NSImage(data: data) else {
                    throw TransferError.importFailed
                }
                let image = Image(nsImage: nsImage)
                return ProfileImage(image: image)
            #elseif canImport(UIKit)
                guard let uiImage = UIImage(data: data) else {
                    throw TransferError.importFailed
                }
                let image = Image(uiImage: uiImage)
                return ProfileImage(image: image)
            #else
                throw TransferError.importFailed
            #endif
            }
        }
    }
    
    @Published private(set) var imageState: ImageState = .empty // Init imageState to empty
    
    @Published var imageSelection: PhotosPickerItem? = nil { // Init to nil value (type is Optional<PhotosPickerItem>)
        didSet { // This is a property observer; it runs immediately after "imageSelection" is set to a new value
            if let imageSelection { // If the imageSelection optional contains an actual value
                let progress = loadTransferable(from: imageSelection)
                imageState = .loading(progress)
                let _ = print("imageSelection has a value")
            } else {
                imageState = .empty
                let _ = print("imageSelection is nil")
            }
        }
    }
    
	// MARK: - Private Methods
	
    private func loadTransferable(from imageSelection: PhotosPickerItem) -> Progress { // Return type is "Progress"
        return imageSelection.loadTransferable(type: ProfileImage.self) { result in
            DispatchQueue.main.async {
                guard imageSelection == self.imageSelection else {
                    print("Failed to get the selected item.")
                    return
                }
                switch result {
                case .success(let profileImage?): // Here is where the selected image is set if state is successful
                    self.imageState = .success(profileImage.image)
                case .success(nil):
                    self.imageState = .empty
                case .failure(let error):
                    self.imageState = .failure(error)
                }
            }
        }
    }
}
