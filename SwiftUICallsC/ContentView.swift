import SwiftUI

struct ContentView: View {
    private static let defaultColor = "black"

    @Binding var luaFile: LuaFile

    @State private var color = defaultColor
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
        var text = luaFile.code

        // These are NOT the same!
        let openDouble = "“"
        let closeDouble = "”"
        text = text.replacingOccurrences(of: openDouble, with: "\"")
        text = text.replacingOccurrences(of: closeDouble, with: "\"")

        // These are NOT the same!
        let openSingle = "‘"
        let closeSingle = "’"
        text = text.replacingOccurrences(of: openSingle, with: "'")
        text = text.replacingOccurrences(of: closeSingle, with: "'")

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
                TextEditor(text: $luaFile.code)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .lineLimit(lines)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: CGFloat(lines * lineHeight)
                    )
                    .border(.gray)
            }

            Button("Execute") {
                let luaCode = cleanCode(luaFile.code)

                // This set when there is an error
                // loading or executing a file of Lua code.
                // See callFunction in lua-helpers.c.
                message = String(cString: doString(luaCode))

                // These are set by the Lua code in "code" String above.
                if let cString = getGlobalString("color") {
                    color = String(cString: cString)
                    if color.isEmpty { color = Self.defaultColor }
                } else {
                    color = Self.defaultColor
                }

                if let cString = getGlobalString("greeting") {
                    greeting = String(cString: cString)
                } else {
                    greeting = ""
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(luaFile.code.isEmpty)

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
