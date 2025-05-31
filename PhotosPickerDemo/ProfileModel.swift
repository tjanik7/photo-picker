/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An observable state object that contains profile details.
*/

import SwiftUI
import PhotosUI
import CoreTransferable

@MainActor
class ProfileModel: ObservableObject {
    @Binding var statusText: String
    
    enum ImageState { // These enum states are referenced with .<state value>
        case empty
        case loading(Progress)
        case success(UIImage)
        case failure(Error)
    }
    
    var numSelected = 0  // Number of images user selected in picker
    
    enum TransferError: Error {
        case importFailed
    }
    
    struct ProfileImage: Transferable {
        let image: UIImage
        
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
                
                return ProfileImage(image: uiImage)
                
            #else
                throw TransferError.importFailed
            #endif
            }
        }
    }
    
    // Images that were successfully retrieved
    @Published private(set) var loadedImages: [ImageWrapper] = [] {
        didSet {
            print("loaded " + String(loadedImages.count) + " images (of " + String(numSelected) + ")")
            
            if loadedImages.count > 0 && loadedImages.count == numSelected {
                print("Sending request:")
                PhotoServerApi().uploadImages(images: loadedImages)
            }
        }
    }
    
    
    @Published private(set) var imageStateArray: [ImageState] = []
    
    var selectedIds: Set<String> = []
    
    @Published var selectedItems: [PhotosPickerItem] = [] {
        didSet {
            selectedIds = []  // TODO: see if there is a better implementation
            
            if selectedItems.count > 0 {
                let _ = print("User selected " + String(selectedItems.count) + " items; setting numSelected var")
                numSelected = selectedItems.count
                
                imageStateArray = [] // Full reset each time for now
                loadedImages = []
                
                for (ind, selectedImg) in selectedItems.enumerated() {
                    if let currId = selectedImg.itemIdentifier {
                        selectedIds.insert(currId)
                    }
                    
                    imageStateArray.append(
                        .loading(loadTransferable(from: selectedImg, index: ind))
                    )
                }
                
            }
            print("selected IDs are:")
            print(selectedIds)
        }
    }
    
    // MARK: - Private Methods
    
    private func loadTransferable(from imageSelection: PhotosPickerItem, index: Int) -> Progress { // Return type is "Progress"
        return imageSelection.loadTransferable(type: ProfileImage.self) { result in
            DispatchQueue.main.async {
//                guard imageSelection == self.selectedItems[0] else {
//                    print("Failed to get the selected item.")
//                    return
//                }
                switch result { // Note that I don't think this is a value defined anywhere in this code; this is simply the result of the loaded image
                case .success(let profileImageArray?): // Here is where the selected image is set if state is successful
                    self.imageStateArray[index] = .success(profileImageArray.image)
                    
                    let imgWrap = ImageWrapper(img: profileImageArray.image)
                    
                    self.loadedImages.append(imgWrap)
                case .success(nil):
                    self.imageStateArray[index] = .empty
                case .failure(let error):
                    self.imageStateArray[index] = .failure(error)
                }
            }
        }
    }
}
