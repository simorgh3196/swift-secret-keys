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

    let fileManager: FileManager

    static func readFileContents(for filePath: String) throws -> String {
        Logger.log(.debug, "Reading file from \(filePath)")

        guard shared.fileManager.fileExists(atPath: filePath) else {
            throw FileIOError.fileNotFound(filePath: filePath)
        }

        do {
            return try String(contentsOfFile: filePath, encoding: .utf8)
        } catch {
            throw FileIOError.cannotReadFile(filePath: filePath, error: error)
        }
    }

    static func writeFile(content: String, toDirectoryPath directoryPath: String, fileName: String) throws {
        let filePath = directoryPath + "/" + fileName

        Logger.log(.debug, "Writing file to \(filePath)")

        if !fileExists(atPath: directoryPath, isDirectory: true) {
            do {
                try shared.fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true)
            } catch {
                throw FileIOError.cannotCreateDirectory(directoryPath: directoryPath, error: error)
            }
        }

        shared.fileManager.createFile(atPath: filePath, contents: content.data(using: .utf8))
    }

    static func cleanDirectory(path directoryPath: String) throws {
        Logger.log(.debug, "Cleaning directory \(directoryPath)")

        if fileExists(atPath: directoryPath, isDirectory: true) {
            do {
                try shared.fileManager.removeItem(atPath: directoryPath)
                try shared.fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true)
            } catch {
                throw FileIOError.cannotCreateDirectory(directoryPath: directoryPath, error: error)
            }
        }
    }

    static func fileExists(atPath path: String, isDirectory: Bool) -> Bool {
        var isDirectory = ObjCBool(isDirectory)
        return shared.fileManager.fileExists(atPath: path, isDirectory: &isDirectory)
    }
}
