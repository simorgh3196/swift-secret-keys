// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import Foundation

enum PropertiesFileDecodingError: Error {
    case internalError(Error)
    case cannotDecodeContent(content: String)
}

struct PropertiesFileDecoder {
    // use regular expressions used in dotenv
    // https://github.com/motdotla/dotenv/blob/463952012640a919a82be0de11f473c1224b498a/lib/main.js#L8
    // swiftlint:disable:next line_length
    private let regexPattern = #"(?:^|^)\s*(?:export\s+)?([\w.-]+)(?:\s*=\s*?|:\s+?)(\s*'(?:\\'|[^'])*'|\s*"(?:\\"|[^"])*"|\s*`(?:\\`|[^`])*`|[^#\r\n]+)?\s*(?:#.*)?(?:$|$)"#

    func decode(content: String) throws -> [EnvironmentKey] {
        let formatedContents = content
            .split(separator: "\n")
            .filter { !$0.trimmingCharacters(in: .whitespaces).hasPrefix("#") } // remove comment lines
            .joined(separator: "\n")

        let regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: regexPattern, options: [.anchorsMatchLines,
                                                                             .dotMatchesLineSeparators,
                                                                             .useUnixLineSeparators])
        } catch {
            throw PropertiesFileDecodingError.internalError(error)
        }

        let matches = regex.matches(in: formatedContents, range: NSRange(0..<formatedContents.count))

        return try matches.map { match in
            let start = formatedContents.index(formatedContents.startIndex, offsetBy: match.range.location)
            let end = formatedContents.index(start, offsetBy: match.range.length)
            let substring = String(formatedContents[start..<end])

            let keyAndValue = substring.split(separator: "=")
            guard keyAndValue.count >= 2 else {
                throw PropertiesFileDecodingError.cannotDecodeContent(content: substring)
            }

            let key = keyAndValue[0].trimmingCharacters(in: .whitespaces)

            // if the string contains `=`, it has been split, so join and restore
            let mergedValue = keyAndValue[1...].joined(separator: "=")
            let value = mergedValue
                .trimmingCharacters(in: .whitespaces)
                .trimmingCharacters(in: .init(charactersIn: "\"'`"))

            return EnvironmentKey(name: key, stringValue: value)
        }
    }
}
