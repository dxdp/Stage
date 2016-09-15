//
//  EnumScanner.swift
//  Stage
//
//  Copyright © 2016 David Parton
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
//  associated documentation files (the "Software"), to deal in the Software without restriction,
//  including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies
//  or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
//  AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
//  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation

open class EnumScanner<EnumType> {
    fileprivate let map: [String: EnumType]
    fileprivate let lineNumber: Int
    fileprivate let characterSet: CharacterSet
    public init(map: [String: EnumType], lineNumber: Int, characterSet: CharacterSet = .alphanumerics) {
        map.keys.forEach { key in
            assert(key.trimmed().lowercased() == key, "All keys in the enum value map should be lowercase and trimmed. Failing for '\(key)'")
        }
        self.map = map
        self.lineNumber = lineNumber
        self.characterSet = characterSet
    }

    open func scan(using scanner: Scanner) throws -> EnumType {
        var word: NSString?
        guard scanner.scanCharacters(from: characterSet, into: &word) && word != nil else {
            throw StageException.unrecognizedContent(
                message: "Unrecognized value \(scanner.string) for \(EnumType.self). Possible values: \(Array(map.keys))",
                line: lineNumber,
                backtrace: [])
        }
        guard let value = map[word as! String] else {
            throw StageException.unrecognizedContent(
                message: "Unrecognized value \(scanner.string) for \(EnumType.self). Possible values: \(Array(map.keys))",
                line: lineNumber,
                backtrace: [])
        }
        return value
    }
}
