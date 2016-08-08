//
//  NSLayoutScan.swift
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

public extension NSLayoutAttribute {
    private static let nameMap : [String: NSLayoutAttribute] = {
        [ "left": .Left,
          "right": .Right,
          "top": .Top,
          "bottom": .Bottom,
          "leading": .Leading,
          "trailing": .Trailing,
          "width": .Width,
          "height": .Height,
          "centerx": .CenterX,
          "centery": .CenterY,
          "baseline": .Baseline,
          "firstbaseline": .FirstBaseline,
          "leftmargin": .LeftMargin,
          "rightmargin": .RightMargin,
          "topmargin": .TopMargin,
          "bottommargin": .BottomMargin,
          "leadingmargin": .LeadingMargin,
          "trailingmargin": .TrailingMargin,
          "centerxwithinmargins": .CenterXWithinMargins,
          "centerywithinmargins": .CenterYWithinMargins ]
    }()
    public static func create(using scanner: StageRuleScanner) throws -> NSLayoutAttribute {
        return try EnumScanner(map: nameMap, lineNumber: scanner.startingLine).scan(using: scanner)
    }
}

public extension NSLayoutRelation {
    private static let nameMap : [String: NSLayoutRelation] = {
        [ "==": .Equal,
          "<=": .LessThanOrEqual,
          ">=": .GreaterThanOrEqual ]
    }()
    private static let nameCharacterSet: NSCharacterSet = { NSCharacterSet(charactersInString: "<=>") }()
    public static func create(using scanner: StageRuleScanner) throws -> NSLayoutRelation {
        return try EnumScanner(map: nameMap, lineNumber: scanner.startingLine, characterSet: nameCharacterSet).scan(using: scanner)
    }
}