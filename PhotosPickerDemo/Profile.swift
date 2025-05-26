/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The main content view of the app.
*/

import SwiftUI
import PhotosUI

struct Profile: View {
    var body: some View {
        NavigationView {
            ProfileForm()
        }
    }
}

struct ProfileForm: View {

    @StateObject var multiSelectViewModel = ProfileModelArray()
    
    var body: some View {
        Form {
            Section {
                PhotoApiView()
            }
            Section { // My new picker in select multiple mode
                HStack {
                    Spacer()
                    EditableCircularProfileImageArray(viewModel: multiSelectViewModel)
                    Spacer()
                }
            }
            Section {
                ForEach(multiSelectViewModel.loadedImages) { img in
                    SquareImage(imgWrapper: img)
                }
            }
            .listRowBackground(Color.clear)
            Section {
                TextField("First Name",
						  text: $multiSelectViewModel.firstName,
						  prompt: Text("First Name"))
                TextField("Last Name",
						  text: $multiSelectViewModel.lastName,
						  prompt: Text("Last Name"))
            }
            Section {
                TextField("About Me",
						  text: $multiSelectViewModel.aboutMe,
						  prompt: Text("About Me"))
            }
        }
        .navigationTitle("Account Profile")
    }
}
