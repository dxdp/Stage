//
//  UIViewScan.swift
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

public extension UIViewAutoresizing {
    fileprivate static let nameMap : [String: UIViewAutoresizing] = {
        [ "width": .flexibleWidth,
          "height": .flexibleHeight,
          "top": .flexibleTopMargin,
          "left": .flexibleLeftMargin,
          "right": .flexibleRightMargin,
          "bottom": .flexibleBottomMargin,
          "none": UIViewAutoresizing() ]
    }()
    public static func create(using scanner: StageRuleScanner) throws -> UIViewAutoresizing {
        return try EnumScanner(map: nameMap, lineNumber: scanner.startingLine).scan(using: scanner)
    }
}

public extension UIViewContentMode {
    fileprivate static let nameMap : [String: UIViewContentMode] = {
        [ "scaletofill": .scaleToFill,
          "scaleaspectfit": .scaleAspectFit,
          "scaleaspectfill": .scaleAspectFill,
          "redraw": .redraw,
          "center": .center,
          "top": .top,
          "bottom": .bottom,
          "left": .left,
          "right": .right,
          "topleft": .topLeft,
          "topright": .topRight,
          "bottomleft": .bottomLeft,
          "bottomright": .bottomRight ]
    }()
    public static func create(using scanner: StageRuleScanner) throws -> UIViewContentMode {
        return try EnumScanner(map: nameMap, lineNumber: scanner.startingLine).scan(using: scanner)
    }
}
