//
//  Parser.swift
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
import UIKit

// MARK: - Stage Begin

class StageParser {
    class Context {
        let lines: [String]
        var currentPosition: Int = 0
        var currentLine: Int { return currentPosition+1 }

        init(lines: [String]) {
            self.lines = lines
        }

        @warn_unused_result func peekLine() -> String? { return lines[safe: currentPosition] }
        @warn_unused_result func nextLine() -> String? {
            guard let next = peekLine() else { return nil }
            forward()
            return next
        }
        func forward() {
            currentPosition += 1
        }
    }

    static var CommentRemovalRegularExpression = {
        return try! NSRegularExpression(pattern: "(?:[ \t]*#--.*$|[ \t]+$)", options: .AnchorsMatchLines)
    }()
    func preprocessLine(text: String) -> String {
        let regex = StageParser.CommentRemovalRegularExpression
        return regex.stringByReplacingMatchesInString(text, options: .Anchored, range: text.entireRange, withTemplate: "")
    }

    func parse(lines: [String]) throws -> StageDefinition {
        let parseContext = Context(lines: lines.map { preprocessLine($0) })
        let stageDefinition = StageDefinition()
        while let line = parseContext.nextLine() {
            if line.isEmpty { continue }
            if line.hasSuffix(":") {
                try parse(declaration: line, into: stageDefinition, context: parseContext)
            } else {
                throw StageException.UnrecognizedContent(message: "Unrecognized plain text. Add ':' to the end to make a declaration", line: parseContext.currentLine)
            }
        }
        return stageDefinition
    }

    func parse(declaration line: String, into stageDefinition: StageDefinition, context: Context) throws {
        let declarationNames = line.substringToIndex(line.endIndex.predecessor())
        let allNames = declarationNames.componentsSeparatedByString(",").map { $0.trimmed() }
        var rules = [String]()
        while let nextRule = context.peekLine() where !nextRule.hasSuffix(":") {
            context.forward()
            if case let trimmed = nextRule.trimmed() where trimmed.isEmpty { continue }
            rules.append(nextRule)
        }
        try allNames.forEach { name in
            try parse(rules: rules, into: stageDefinition, name: name)
        }
    }

    func parse(rules rules: [String], into stageDefinition: StageDefinition, name: String) throws {
        guard rules.count > 0 else { return }

        let interpreter: StageDeclarationInterpreter
        if let x = rules.first?.trimmed() where x.hasPrefix(".") {
            interpreter = PropertySettersInterpreter()
        } else {
            interpreter = ViewHierarchyInterpreter()
        }

        try rules.enumerate().forEach { index, text in try interpreter.next(text, lineNumber: index + 0 /*TODO:line#*/) }
        interpreter.amend(stageDefinition[name])
    }
}
