import SwiftUI

struct ContentView: View {
    @Binding var document: TextFile

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
    @State private var number = 0

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
                /*
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
                 */
                TextEditor(text: $document.text)
            }

            Button("Execute") {
                // This set when there is an error
                // loading or executing a file of Lua code.
                // See callFunction in lua-helpers.c.
                // message = String(cString: doString(code))
                message = String(cString: doString(document.text))

                // These are set by the Lua code in "code" String above.
                color = String(cString: getGlobalString("color"))
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
