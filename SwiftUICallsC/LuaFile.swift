import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    // Use exportedAs for file types invented by you.
    // This "Uniform Type Identifier" was found at
    // https://gist.github.com/rmorey/b8d1b848086bdce026a9f57732a3b858.
    static let luaSource = UTType(importedAs: "org.lua.lua-source")
}

struct LuaFile: FileDocument {
    static let fileExtension = "lua"
    static var readableContentTypes = [UTType.luaSource]
    static let defaultCode = """
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

    var code = ""

    // This creates a document containing the given code.
    init(initialCode: String = defaultCode) {
        code = initialCode
    }

    // This creates a document containing previously saved code.
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            code = String(decoding: data, as: UTF8.self)
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }

    // This is called when the system wants to save code in a file.
    // TODO: How can the file name be specified?
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(code.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}
