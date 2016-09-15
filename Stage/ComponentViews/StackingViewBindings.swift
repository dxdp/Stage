//
//  StackingViewBindings.swift
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

extension StackingDirection {
    static var nameMap: [String: StackingDirection] = {
        [ "horizontal": .horizontal,
          "vertical": .vertical ]
    }()
    static func create(using scanner: StageRuleScanner) throws -> StackingDirection {
        return try EnumScanner(map: nameMap, lineNumber: scanner.startingLine).scan(using: scanner)
    }
}

extension StackingAlignment {
    static var nameMap: [String: StackingAlignment] = {
        [ "first": .alignFirst,
          "last": .alignLast,
          "both": .alignBoth,
          "neither": .alignNeither]
    }()
    static func create(using scanner: StageRuleScanner) throws -> StackingAlignment {
        return try EnumScanner(map: nameMap, lineNumber: scanner.startingLine).scan(using: scanner)
    }
}

public extension StageRegister {
    public class func stgStackingView(_ registration: StagePropertyRegistration) {
        tap(registration) {
            $0.register("contentInset") { scanner in try UIEdgeInsets.create(using: scanner) }
                .apply { (view: StackingView, value) in view.contentInset = value }

            $0.registerCGFloat("spacing") 
                .apply { (view: StackingView, value) in view.spacing = value }

            $0.register("stackingAlignment") { scanner in try StackingAlignment.create(using: scanner) }
                .apply { (view: StackingView, value) in view.stackingAlignment = value }

            $0.register("stackingDirection") { scanner in try StackingDirection.create(using: scanner) }
                .apply { (view: StackingView, value) in view.stackingDirection = value }
        }
    }
}
