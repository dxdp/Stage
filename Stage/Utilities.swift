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
