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
    let propertyRegistrar: PropertyRegistrar
    let errorListener: StageDefinitionErrorListener?
    init(propertyRegistrar: PropertyRegistrar, errorListener: StageDefinitionErrorListener?) {
        self.propertyRegistrar = propertyRegistrar
        self.errorListener = errorListener
    }

    class Context {
        let lines: [String]
        var currentPosition: Int = 0
        var currentLine: Int { return currentPosition+1 }

        init(lines: [String]) {
            self.lines = lines
        }

        func peekLine() -> String? { return lines[safe: currentPosition] }
        func nextLine() -> String? {
            guard let next = peekLine() else { return nil }
            forward()
            return next
        }
        func forward() {
            currentPosition += 1
        }
    }

    static var CommentRemovalRegularExpression = {
        return try! NSRegularExpression(pattern: "(?:[ \t]*#--.*$|[ \t]+$)", options: .anchorsMatchLines)
    }()
    func preprocessLine(_ text: String) -> String {
        let regex = StageParser.CommentRemovalRegularExpression
        return regex.stringByReplacingMatches(in: text, options: .anchored, range: text.entireRange, withTemplate: "")
    }

    func parse(_ lines: [String], identifier: String? = nil) throws -> StageDefinition {
        let parseContext = Context(lines: lines.map { preprocessLine($0) })
        let stageDefinition = StageDefinition(propertyRegistrar: propertyRegistrar, errorListener: errorListener)
        stageDefinition.debugIdentifier = identifier ?? ""
        while let line = parseContext.nextLine() {
            if line.isEmpty { continue }
            if line.hasSuffix(":") {
                let lineNumber = parseContext.currentPosition
                do {
                    try parse(declaration: line, into: stageDefinition, context: parseContext)
                } catch let ex as StageException {
                    throw ex.withBacktraceMessage("while parsing declaration on line \(lineNumber)")
                }
            } else {
                throw StageException.unrecognizedContent(
                    message: "Unrecognized plain text. Add ':' to the end to make a declaration",
                    line: parseContext.currentLine,
                    backtrace: [])
            }
        }
        return stageDefinition
    }

    func parse(declaration line: String, into stageDefinition: StageDefinition, context: Context) throws {
        let declarationNames = line.substring(to: line.index(before: line.endIndex))
        let allNames = declarationNames.components(separatedBy: ",").map { $0.trimmed() }
        var rules = [(String, Int)]()
        while let nextRule = context.peekLine(), !nextRule.hasSuffix(":") {
            let lineNumber = context.currentLine
            context.forward()
            if case let trimmed = nextRule.trimmed() , trimmed.isEmpty { continue }
            rules.append((nextRule, lineNumber))
        }
        try allNames.forEach { name in
            do {
                try parse(rules: rules, into: stageDefinition, name: name)
            } catch let ex as StageException {
                throw ex.withBacktraceMessage("while parsing declarations for \(name)")
            }
        }
    }

    func parse(rules: [(String, Int)], into stageDefinition: StageDefinition, name: String) throws {
        guard rules.count > 0 else { return }

        let interpreter: StageDeclarationInterpreter
        if let x = rules.first?.0.trimmed() , x.hasPrefix(".") {
            interpreter = PropertySettersInterpreter()
        } else {
            interpreter = ViewHierarchyInterpreter()
        }

        try rules.forEach { text, lineNumber in
            do {
                try interpreter.next(text: text, lineNumber: lineNumber)
            } catch let ex as StageException {
                throw ex.withBacktraceMessage("while parsing rule for declaration \(name)")
            }
        }
        interpreter.amend(declaration: stageDefinition[name])
    }
}
