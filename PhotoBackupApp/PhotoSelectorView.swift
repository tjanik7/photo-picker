/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The main content view of the app.
*/

import SwiftUI
import PhotosUI

struct PhotoSelectorView: View {
    
    @State var dataModel = DataModel()
    
    var body: some View {
        Form {
            Section { // My new picker in select multiple mode
                HStack {
                    Spacer()
                    Text(dataModel.statusText)
                    PhotoPickerLaunchButton(viewModel: dataModel)
                    Spacer()
                }
            }
            Section { // Display each of the selected images
                ForEach(dataModel.loadedImages) { img in
                    SquareImageView(wrappedImage: img)
                }
            }
            .listRowBackground(Color.clear)
        }
    }
}
