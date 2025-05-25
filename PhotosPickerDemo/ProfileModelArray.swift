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
        case success(UIImage)
        case failure(Error)
    }
    
    var numSelected = 0  // Number of images user selected in picker
    
    enum TransferError: Error {
        case importFailed
    }
    
    struct ProfileImageArray: Transferable {
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
                
                return ProfileImageArray(image: uiImage)
                
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
            if loadedImages.count == numSelected {
                print("\nlet us sling it here me boy")
            }
            
//            if loadedImages.count > 0 {
//                
//                print("Sending request:")
//                
//                PhotoServerApi().uploadImages(paramName: "thisIsParamName", fileName: "testFilename", image: imageToSend.img!)
//                PhotoServerApi().uploadImages(images: loadedImages)
//            }
        }
    }
    
    
    @Published private(set) var imageStateArray: [ImageState] = [] {
        didSet {
//            if imageStateArray.count > 0 && (imageStateArray.count == numSelected) {
//                loadedImages = [] // For now, do a full recompute everytime; will use ID/hash to avoid recomputation in the future
//                
//                for imgState in imageStateArray {
////                    if case .success(let profileImg) = imgState {
////                        loadedImages.append(ImageWrapper(img: profileImg))
////                    }
//                    
//                    // Use this block to count how many images have finished loading at this point (including both success and failure)
//                    switch imgState {
//                    case .success(let loadedImage):
//                        loadedImages.append(ImageWrapper(img: loadedImage))
//                    default:
//                        break
//                    }
//                }
//                print("numCompleted is " + String(numCompleted) + " (of " + String(numSelected) + ")")
//                
//                if numCompleted == numSelected {
////                    PhotoServerApi().uploadImages(images: loadedImages)
//                    print("WOULD SEND THAT THANG HERE")
//                }
//                
//            }
        }
    }
    
    
    @Published var selectedItems: [PhotosPickerItem] = [] {
        didSet {
            if selectedItems.count > 0 {
                let _ = print("User selected " + String(selectedItems.count) + " items; setting numSelected var")
                numSelected = selectedItems.count
                
                imageStateArray = [] // Full reset each time for now
                
                for (ind, selectedImg) in selectedItems.enumerated() {
                    imageStateArray.append(
                        .loading(loadTransferable(from: selectedImg, index: ind))
                    )
                }
                
            }
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
                    self.loadedImages.append(ImageWrapper(img: profileImageArray.image))
                case .success(nil):
                    self.imageStateArray[index] = .empty
                case .failure(let error):
                    self.imageStateArray[index] = .failure(error)
                }
            }
        }
    }
}
