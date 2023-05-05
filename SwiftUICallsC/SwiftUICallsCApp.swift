import SwiftUI

@main
struct SwiftUICallsCApp: App {
    var body: some Scene {
        /*
         WindowGroup {
             ContentView()
         }
         */
        DocumentGroup(newDocument: LuaFile()) { file in
            ContentView(luaFile: file.$document)
        }
    }
}
