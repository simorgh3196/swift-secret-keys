// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import Foundation

enum PropertiesFileDecodingError: Error {
    case internalError(Error)
    case cannotDecodeContent(content: String)
}

struct PropertiesFileDecoder {
    func decode(content: String) throws -> [Secret] {
        let formatedContents = content
            .split(separator: "\n")
            .filter { !$0.trimmingCharacters(in: .whitespaces).hasPrefix("#") } // remove comment lines
            .joined(separator: "\n")

        let regex: NSRegularExpression
        do {
            // use regular expressions used in dotenv
            // https://github.com/motdotla/dotenv/blob/463952012640a919a82be0de11f473c1224b498a/lib/main.js#L8
            regex = try NSRegularExpression(
                pattern: #"(?:^|^)\s*(?:export\s+)?([\w.-]+)(?:\s*=\s*?|:\s+?)(\s*'(?:\\'|[^'])*'|\s*"(?:\\"|[^"])*"|\s*`(?:\\`|[^`])*`|[^#\r\n]+)?\s*(?:#.*)?(?:$|$)"#,
                options: [
                    .anchorsMatchLines,
                    .dotMatchesLineSeparators,
                    .useUnixLineSeparators,
                ]
            )
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
            let value = removeSurroundedQuartsIfNeeded(mergedValue.trimmingCharacters(in: .whitespaces))

            return Secret(key: key, stringValue: value)
        }
    }

    @inline(__always)
    private func removeSurroundedQuartsIfNeeded(_ text: String) -> String {
        var result = text
        let isSurroundedByDoubleQuarts = result.hasPrefix("\"") && result.hasSuffix("\"")
        let isSurroundedBySingleQuarts = result.hasPrefix("'") && result.hasSuffix("'")
        let isSurroundedByBackQuarts = result.hasPrefix("`") && result.hasSuffix("`")
        if isSurroundedByDoubleQuarts || isSurroundedBySingleQuarts || isSurroundedByBackQuarts {
            // remove quarts
            result.removeFirst(1)
            result.removeLast(1)
        }

        return result
    }
}
