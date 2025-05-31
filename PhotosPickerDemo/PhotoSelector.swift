/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The main content view of the app.
*/

import SwiftUI
import PhotosUI

struct PhotoSelector: View { // TODO: refactor code so that names actually make sense - update status of HTTP requests in some sort of text area
    
    @State var status = "Select some photos" // Need @State to be able to use this as a binding
    @StateObject var profileModel = ProfileModel()
    var photoApiView = PhotoApiView()
    
    var body: some View {
        Form {
            Section {
                photoApiView
            }
            Section { // My new picker in select multiple mode
                HStack {
                    Spacer()
                    Text(status)
                    PickerLaunchButton(viewModel: profileModel)
                    Spacer()
                }
            }
            Section { // Display each of the selected images
                ForEach(profileModel.loadedImages) { img in
                    SquareImage(imgWrapper: img)
                }
            }
            .listRowBackground(Color.clear)
        }
    }
}
