import SwiftUI

struct ContentView: View {
    @Binding var document: TextFile

    @State private var color = "black"
    @State private var greeting = ""
    @State private var message = ""
    @State private var number = 0

    let lineHeight = 24
    let lines = 20

    func header(_ text: String) -> some View {
        return Text(text + ":")
            .font(.headline)
            // See colors defined in Assets.xcassets.
            .foregroundColor(Color(color))
    }

    func cleanCode(_: String) -> String {
        var text = document.text
        // TODO: Why do I need to call this twice for each quote type?
        text = text
            .replacingOccurrences(
                of: "“",
                with: "\""
            ) // replaces smart quotes
        text = text.replacingOccurrences(of: "”", with: "\"")
        text = text.replacingOccurrences(of: "‘", with: "'")
        text = text.replacingOccurrences(of: "’", with: "'")
        return text
    }

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                Stepper(
                    "Number: \(number)",
                    value: $number,
                    in: 0 ... 10
                )
                Text(
                    "The factorial of \(number) is \(factorial(Int32(number)))."
                )
            }

            Spacer()

            VStack(alignment: .leading, spacing: 0) {
                header("Lua code")
                TextEditor(text: $document.text)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
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
                let text = cleanCode(document.text)

                // This set when there is an error
                // loading or executing a file of Lua code.
                // See callFunction in lua-helpers.c.
                // message = String(cString: doString(code))
                message = String(cString: doString(text))

                // These are set by the Lua code in "code" String above.
                if let cString = getGlobalString("color") {
                    color = String(cString: cString)
                } else {
                    color = "black"
                }

                if let cString = getGlobalString("greeting") {
                    greeting = String(cString: cString)
                } else {
                    greeting = ""
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(document.text.isEmpty)

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
