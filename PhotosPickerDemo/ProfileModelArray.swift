/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An observable state object that contains profile details.
*/

import SwiftUI
import PhotosUI
import CoreTransferable

@MainActor
class ProfileModelArray: ObservableObject {
    
    // MARK: - Profile Details
    
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var aboutMe: String = ""
    
    // MARK: - Profile Image
    
    enum ImageState { // These enum states are referenced with .<state value>
        case empty
        case loading(Progress)
        case success(Image)
        case failure(Error)
    }
    
    enum TransferError: Error {
        case importFailed
    }
    
    struct ProfileImageArray: Transferable {
        let image: Image
        
        static var transferRepresentation: some TransferRepresentation {
            DataRepresentation(importedContentType: .image) { data in
            #if canImport(AppKit)
                guard let nsImage = NSImage(data: data) else {
                    throw TransferError.importFailed
                }
                let image = Image(nsImage: nsImage)
                return ProfileImageArray(image: image)
            #elseif canImport(UIKit)
                guard let uiImage = UIImage(data: data) else {
                    throw TransferError.importFailed
                }
                let image = Image(uiImage: uiImage)
                return ProfileImageArray(image: image)
            #else
                throw TransferError.importFailed
            #endif
            }
        }
    }
    // Images that were successfully retrieved
    @Published private(set) var loadedImages: [ImageWrapper] = []
    
    //@Published private(set) var imageState: ImageState = .empty // Init imageState to empty
    
    @Published private(set) var imageStateArray: [ImageState] = [] {
        didSet {
            loadedImages = [] // For now, do a full recompute everytime; will use ID/hash to avoid recomputation in the future
            
            for imgState in imageStateArray {
                if case .success(let profileImg) = imgState {
                    loadedImages.append(ImageWrapper(img: profileImg))
                }
            }
            print("Successfully got " + String(loadedImages.count) + " images")
        }
    }
    
    
    @Published var selectedItems: [PhotosPickerItem] = [] {
        didSet {
            if selectedItems.count > 0 {
                let _ = print("User selected " + String(selectedItems.count) + " items")
                
//                let progress = loadTransferable(from: selectedItems[0])
//                imageState = .loading(progress)
                
                imageStateArray = [] // Full reset each time for now
                
                for (ind, selectedImg) in selectedItems.enumerated() {
                    imageStateArray.append(
                        .loading(loadTransferable(from: selectedImg, index: ind))
                    )
                }
                
            }
//            else {
//                let _ = print("No items have been selected")
//                imageState = .empty
//            }
        }
    }
    
    // MARK: - Private Methods
    
    private func loadTransferable(from imageSelection: PhotosPickerItem, index: Int) -> Progress { // Return type is "Progress"
        return imageSelection.loadTransferable(type: ProfileImageArray.self) { result in
            DispatchQueue.main.async {
//                guard imageSelection == self.selectedItems[0] else {
//                    print("Failed to get the selected item.")
//                    return
//                }
                switch result { // Note that I don't think this is a value defined anywhere in this code; this is simply the result of the loaded image
                case .success(let profileImageArray?): // Here is where the selected image is set if state is successful
                    self.imageStateArray[index] = .success(profileImageArray.image)
                case .success(nil):
                    self.imageStateArray[index] = .empty
                case .failure(let error):
                    self.imageStateArray[index] = .failure(error)
                }
            }
        }
    }
}
