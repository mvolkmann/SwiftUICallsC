import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Factorial of 5 is \(factorial(5)).")
        }
        .padding()
        .onAppear {
            createLuaVM()
            doFile(
                "/Users/volkmannm/Documents/dev/swiftui/SwiftUICallsC/SwiftUICallsC/config.lua"
            )
            let score = getGlobalInt("score")
            print("score =", score)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
