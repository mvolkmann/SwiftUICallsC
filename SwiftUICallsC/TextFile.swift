import SwiftUI
import UniformTypeIdentifiers

struct TextFile: FileDocument {
    // We only support plain text.
    static var readableContentTypes = [UTType.plainText]

    // Documents begin empty.
    var text = ""

    static let defaultText = """
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

    // This creates a document containing the given text.
    init(initialText: String = defaultText) {
        text = initialText
    }

    // This creates a document containing previously saved text.
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }

    // This is called when the system wants to save text in a file.
    // TODO: How can the file name be specified?
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}
