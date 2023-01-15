// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import Foundation

enum FileIOError: Error {
    case fileNotFound(filePath: String)
    case cannotReadFile(filePath: String, error: Error)
    case cannotCreateDirectory(directoryPath: String, error: Error)
}

struct FileIO {
    static var shared = FileIO(fileManager: .default)

    var rootPath = "."
    let fileManager: FileManager

    static func changeCurrentDirectory(path: String) {
        shared.rootPath = path
    }

    static func readFileContents(for filePath: String) throws -> String {
        let path = "\(shared.rootPath)/\(filePath)"
        Logger.log(.debug, "Reading file from \(path)")

        guard shared.fileManager.fileExists(atPath: path) else {
            throw FileIOError.fileNotFound(filePath: path)
        }

        do {
            return try String(contentsOfFile: path, encoding: .utf8)
        } catch {
            throw FileIOError.cannotReadFile(filePath: path, error: error)
        }
    }

    static func writeFile(content: String, toDirectoryPath directoryPath: String, fileName: String) throws {
        let path = "\(shared.rootPath)/\(directoryPath)/\(fileName)"

        Logger.log(.debug, "Writing file to \(path)")

        if !fileExists(atPath: directoryPath, isDirectory: true) {
            do {
                try shared.fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true)
            } catch {
                throw FileIOError.cannotCreateDirectory(directoryPath: directoryPath, error: error)
            }
        }

        shared.fileManager.createFile(atPath: path, contents: content.data(using: .utf8))
    }

    static func cleanDirectory(path directoryPath: String) throws {
        let path = "\(shared.rootPath)/\(directoryPath)"
        Logger.log(.debug, "Cleaning directory \(path)")

        if fileExists(atPath: path, isDirectory: true) {
            do {
                try shared.fileManager.removeItem(atPath: path)
                try shared.fileManager.createDirectory(atPath: path, withIntermediateDirectories: true)
            } catch {
                throw FileIOError.cannotCreateDirectory(directoryPath: path, error: error)
            }
        }
    }

    static func fileExists(atPath path: String, isDirectory: Bool) -> Bool {
        var isDirectory = ObjCBool(isDirectory)
        return shared.fileManager.fileExists(atPath: "\(shared.rootPath)/\(path)", isDirectory: &isDirectory)
    }
}
