/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The main content view of the app.
*/

import SwiftUI
import PhotosUI

struct PhotoSelectorView: View {
    
    @State var profileModel = ProfileModel()
    
    var body: some View {
        Form {
            Section { // My new picker in select multiple mode
                HStack {
                    Spacer()
                    Text(profileModel.statusText)
                    PhotoPickerLaunchButton(viewModel: profileModel)
                    Spacer()
                }
            }
            Section { // Display each of the selected images
                ForEach(profileModel.loadedImages) { img in
                    SquareImageView(imgWrapper: img)
                }
            }
            .listRowBackground(Color.clear)
        }
    }
}
