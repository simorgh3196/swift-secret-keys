// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import Foundation

struct Logger {
    enum Level {
        case debug // print only when in development
        case info // print only when in verbose mode
        case warning // always print
        case error // always print
    }

    static var shared = Logger(isVerbose: false)

    var isVerbose: Bool

    static func log(file: StringLiteralType = #file,
                    line: Int = #line,
                    function: StringLiteralType = #function,
                    _ level: Level,
                    _ item: Any) {
        switch level {
        case .debug:
            #if DEBUG
            let fileName = file.split(separator: "/").last!
            print("> 🔧 [\(fileName)#L\(line) - \(function)] \(item)")
            #endif

            if shared.isVerbose {
                print("> \(item)")
            }
        case .info:
            print("> \(item)")
        case .warning:
            print("> Warning: \(item)")
        case .error:
            print("> Error: \(item)")
        }
    }
}
