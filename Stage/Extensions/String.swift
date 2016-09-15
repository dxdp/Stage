//
//  String.swift
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

extension String {
    var leadingIndent: Int {
        if let range = rangeOfCharacter(from: .nonwhitespaceCharacterSet()) {
            return characters.distance(from: characters.startIndex, to: range.lowerBound)
        }
        return characters.count
    }

    var trailingIndent: Int {
        if let range = rangeOfCharacter(from: .nonwhitespaceCharacterSet(), options: .backwards) {
            return characters.distance(from: range.lowerBound, to: endIndex)
        }
        return characters.count
    }

    var entireRange: NSRange {
        return NSMakeRange(0, characters.count)
    }

    func trimmed() -> String {
        return trimmingCharacters(in: .whitespaces)
    }

    func leftTrimmed() -> String {
        let indent = leadingIndent
        return indent < characters.count ? substring(from: characters.index(startIndex, offsetBy: indent)) : ""
    }

    func rightTrimmed() -> String {
        let indent = trailingIndent
        return indent < characters.count ? substring(to: characters.index(endIndex, offsetBy: -indent)) : ""
    }
}
