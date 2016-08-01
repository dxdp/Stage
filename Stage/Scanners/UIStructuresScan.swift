//
//  UIStructuresScan.swift
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

public extension StageRuleScanner {
    public func scanCGPoint() throws -> CGPoint {
        let dims = try scanBracedList(open: "{", close: "}", itemScan: scanCGFloat())
        guard dims.count == 2 else {
            throw StageException.UnrecognizedContent(message: "Expected point to be in format: {x, y}, but saw \(string)", line: startingLine)
        }
        return CGPointMake(dims[0], dims[1])
    }

    public func scanCGSize() throws -> CGSize {
        let dims = try scanBracedList(open: "{", close: "}", itemScan: scanCGFloat())
        guard dims.count == 2 else {
            throw StageException.UnrecognizedContent(message: "Expected size to be in format: {width, height}, but saw \(string)", line: startingLine)
        }
        return CGSizeMake(dims[0], dims[1])
    }

    public func scanUIEdgeInsets() throws -> UIEdgeInsets {
        let dims = try scanBracedList(open: "{", close: "}", itemScan: scanCGFloat())
        guard dims.count == 4 else {
            throw StageException.UnrecognizedContent(message: "Expected edge insets to be in format: {top, left, bottom, right}, but saw \(string)", line: startingLine)
        }
        return UIEdgeInsetsMake(dims[0], dims[1], dims[2], dims[3])
    }
}