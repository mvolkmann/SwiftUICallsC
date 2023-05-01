import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Factorial of 5 is \(factorial(5)).")
        }
        .padding()
        .onAppear {
            createLuaVM();
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
