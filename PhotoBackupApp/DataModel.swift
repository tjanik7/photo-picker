import SwiftUI
import PhotosUI
import CoreTransferable

@MainActor
@Observable
public class DataModel {
    public var statusText: String = "Select some photos"
    
    var photoServerApi: PhotoServerApi
    var updateClosure: (String) -> Void
    
    enum ImageState { // These enum states are referenced with .<state value>
        case empty
        case loading(Progress)
        case success(UIImage)
        case failure(Error)
    }
    
    var numSelected = 0  // Number of images user selected in picker
    
    init() {
        photoServerApi = PhotoServerApi()
        
        updateClosure = { newStatus in
            self.statusText = newStatus
        }
    }
    
    enum TransferError: Error {
        case importFailed
    }
    
    struct TransferableImage: Transferable {
        let image: UIImage
        
        static var transferRepresentation: some TransferRepresentation {
            DataRepresentation(importedContentType: .image) { data in
            #if canImport(UIKit)
                guard let uiImage = UIImage(data: data) else {
                    throw TransferError.importFailed
                }
                
                return TransferableImage(image: uiImage)
                
            #else
                throw TransferError.importFailed
            #endif
            }
        }
    }
    
    // Images that were successfully retrieved
    private(set) var loadedImages: [IdentifiableImage] = [] {
        didSet { // Main body of this runs when all selected images have finished loading
            
            print("loaded " + String(loadedImages.count) + " images (of " + String(numSelected) + ")")
            
            if loadedImages.count > 0 && loadedImages.count == numSelected {
                print("Sending request:")
                photoServerApi.uploadImages(images: loadedImages, statusUpdateHandler: updateClosure)
            }
        }
    }
    
    
    private(set) var imageStateArray: [ImageState] = []
    
    var selectedIds: Set<String> = []
    
    var selectedItems: [PhotosPickerItem] = [] {
        didSet { // Runs when user hits "Done" in photo picker
            
            selectedIds = []  // TODO: see if there is a better implementation
            
            if selectedItems.count > 0 {
                statusText = "Loading selected photos"
                
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
        // Method is called (for each item) when selectedItems changes
        return imageSelection.loadTransferable(type: TransferableImage.self) { result in
            DispatchQueue.main.async {
                
                switch result { // Type is Result<TransferableImage>
                    
                case .success(let transferableImage?): // Here is where the selected image is set if state is successful
                    self.imageStateArray[index] = .success(transferableImage.image)
                    
                    // Need to use wrapper to make Image identifiable as required by "for each" loop in PhotoSelectorView
                    let wrappedImage = IdentifiableImage(img: transferableImage.image)
                    self.loadedImages.append(wrappedImage)
                    
                case .success(nil):
                    self.imageStateArray[index] = .empty
                    
                case .failure(let error):
                    self.imageStateArray[index] = .failure(error)
                    
                }
            }
        }
    }
}
