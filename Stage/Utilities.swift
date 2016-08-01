//
//  Utilities.swift
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

public func tap<T>(some: T, @noescape function: T -> ()) -> T {
    function(some)
    return some
}

public extension CollectionType {
    subscript (safe index: Index) -> Generator.Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}

func -<T> (left: Set<T>, right: Set<T>) -> Set<T> {
    return Set(left.flatMap { right.contains($0) ? nil : $0 })
}

private let _nwscs = { NSCharacterSet.whitespaceCharacterSet().invertedSet }()
private let _hexnumericcs = { NSCharacterSet(charactersInString: "0123456789abcdefABCDEF") }()
extension NSCharacterSet {
    class func nonwhitespaceCharacterSet() -> NSCharacterSet { return _nwscs }
    class func hexnumericCharacterSet() -> NSCharacterSet { return _hexnumericcs }
}

extension String {
    var leadingIndent: Int {
        if let range = rangeOfCharacterFromSet(.nonwhitespaceCharacterSet()) {
            return characters.startIndex.distanceTo(range.startIndex)
        }
        return characters.count
    }

    var trailingIndent: Int {
        if let range = rangeOfCharacterFromSet(.nonwhitespaceCharacterSet(), options: .BackwardsSearch) {
            return range.startIndex.distanceTo(endIndex)
        }
        return characters.count
    }

    var entireRange: NSRange {
        return NSMakeRange(0, characters.count)
    }

    func trimmed() -> String {
        return stringByTrimmingCharactersInSet(.whitespaceCharacterSet())
    }

    func leftTrimmed() -> String {
        let indent = leadingIndent
        return indent < characters.count ? substringFromIndex(startIndex.advancedBy(indent)) : ""
    }

    func rightTrimmed() -> String {
        let indent = trailingIndent
        return indent < characters.count ? substringToIndex(endIndex.advancedBy(-indent)) : ""
    }
}

extension UIView {
    func commonSuperview(with view: UIView) -> UIView? {
        var witnessed = Set<UIView>([self, view])
        var viter1: UIView? = self, viter2: UIView? = view
        while viter1 != nil || viter2 != nil {
            if let super1 = viter1?.superview {
                if witnessed.contains(super1) { return super1 }
                witnessed.insert(super1)
            }
            viter1 = viter1?.superview
            if let super2 = viter2?.superview {
                if witnessed.contains(super2) { return super2 }
                witnessed.insert(super2)
            }
            viter2 = viter2?.superview
        }
        return nil
    }
}
