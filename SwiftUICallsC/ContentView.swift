import SwiftUI

struct ContentView: View {
    @State private var code = """
    x = 3
    y = 4
    if x >= y then
      color = "green"
    else
      color = "red"
    end
    -- color = x >= y and "red" or "green"

    greeting = "Hello!"
    """
    @State private var color = "black"
    @State private var greeting = ""
    @State private var message = ""

    let lineHeight = 24
    let lines = 20

    func header(_ text: String) -> some View {
        print("header: text = \(text)")
        return Text(text + ":")
            .font(.headline)
            // See colors defined in Assets.xcassets.
            .foregroundColor(Color(color))
    }

    var body: some View {
        VStack {
            Text("Factorial of 5 is \(factorial(5)).")
            Spacer()

            VStack(alignment: .leading, spacing: 0) {
                header("Lua code")
                TextEditor(text: $code)
                    .lineLimit(lines)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: CGFloat(lines * lineHeight)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color(UIColor.lightGray))
                    )
            }

            Button("Execute") {
                message = String(cString: doString(code))
                color = String(cString: getGlobalString("color"))
                print("\(#fileID) \(#function) color =", color)
                greeting = String(cString: getGlobalString("greeting"))
            }
            .buttonStyle(.borderedProminent)
            .disabled(code.isEmpty)

            if !message.isEmpty {
                Text(message).foregroundColor(.red)
            }

            VStack(alignment: .leading, spacing: 0) {
                header("Greeting")
                Text(greeting)
                    .padding(5)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: CGFloat(lineHeight + 10),
                        alignment: .leading
                    )
                    .border(.gray)
            }
        }
        .padding()
        .onAppear {
            createLuaVM()
            /*
             // TODO: What is the path to a file in the iOS Files app?
             doFile(
                 // "/Users/volkmannm/Documents/dev/swiftui/SwiftUICallsC/SwiftUICallsC/config.lua"
                 "/Users/volkmannm/demo.lua"
             )
             let score = getGlobalInt("score")
             print("score =", score)
             */
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
