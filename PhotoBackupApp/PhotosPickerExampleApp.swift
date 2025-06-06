/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The entry point into the app.
*/

import SwiftUI

@main
struct PhotoBackupApp: App {
    var body: some Scene {
        let _ = print("=========== App has started ===========\n\n")
        WindowGroup {
            PhotoSelectorView()
        }
    }
}
