import SwiftUI

@main
struct SwiftUICallsCApp: App {
    var body: some Scene {
        /*
         WindowGroup {
             ContentView()
         }
         */
        DocumentGroup(newDocument: TextFile()) { file in
            ContentView(document: file.$document)
        }
    }
}
