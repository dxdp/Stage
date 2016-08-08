//
//  UILayoutScan.swift
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

public struct StageLayoutConstraint {
    let attribute: NSLayoutAttribute
    let relation: NSLayoutRelation
    let target: String?
    let targetAttribute: NSLayoutAttribute
    let multiplier: CGFloat
    let constant: CGFloat
}


private var constraintParseExpression = { () -> NSRegularExpression in
    let attribute = "([a-zA-Z]+)"
    let relation = "(>=|<=|==)"
    let item = "([a-zA-Z0-9_]+)"
    let multiOp = "(\\*|/)"
    let constOp = "(\\+|-)"
    let skipSpace = "\\s*"
    let number = "(-?\\d+\\.\\d*|-?\\.?\\d+)"

    let pattern = ["^", skipSpace, attribute, skipSpace, relation, skipSpace,       // 1 = attribute, 2 = relation
                   "(?:", item, "\\.", attribute, skipSpace, ")?",                  // 3 = item, 4 = attribute
                   "(?:", multiOp, skipSpace, number, skipSpace, ")?",              // 5 = multiOp, 6 = number
                   "(?:", constOp, skipSpace, ")?", number, "?", skipSpace, "$"]    // 7 = constOpt, 8 = number
        .joinWithSeparator("")
    return try! NSRegularExpression(pattern: pattern, options: .init(rawValue: 0))
}()

public extension StageRuleScanner {

    public func scanStageLayoutConstraints() throws -> [StageLayoutConstraint] {
        let constraints = string.componentsSeparatedByString("\n").enumerate().flatMap { lineNumber, line -> StageLayoutConstraint? in
            let currentLine = startingLine + lineNumber
            if line.isEmpty { return nil }
            let matches = constraintParseExpression.matchesInString(line, options: .init(rawValue: 0), range: line.entireRange)
            guard case let match = matches[0] where matches.count == 1 else {
                print("Skipping layout attribute line '\(line)'",
                    "It does not appear to be in the required format. Did you use '=' instead of '=='?",
                    separator: "\n")
                return nil
            }

            func captureGroup(n: Int) -> String? {
                guard n < match.numberOfRanges else { return nil }
                guard case let range = match.rangeAtIndex(n) where range.location != NSNotFound else { return nil }
                let start = line.startIndex.advancedBy(range.location)
                let end = start.advancedBy(range.length)
                return line.substringWithRange(start..<end)
            }

            // The first two groups are not optional, so to match they must also exist. This implies we can unwrap them immediately
            let selfAttributeText   = captureGroup(1)!
            let relationText        = captureGroup(2)!
            let targetText          = captureGroup(3)
            let targetAttributeText = captureGroup(4)
            let multiplyOpText      = captureGroup(5)
            let multiplyFactorText  = captureGroup(6)
            let addOpText           = captureGroup(7)
            let addendText          = captureGroup(8)

            func scanner(text: String) -> StageRuleScanner { return StageRuleScanner(string: text) }
            func selfAttribute() throws -> NSLayoutAttribute { return try NSLayoutAttribute.create(using: scanner(selfAttributeText)) }
            func relation() throws -> NSLayoutRelation { return try NSLayoutRelation.create(using: scanner(relationText)) }
            func targetAttribute() throws -> NSLayoutAttribute {
                switch (targetText, targetAttributeText) {
                case (let x, let y) where x == nil && y == nil: return .NotAnAttribute
                case (let x, let y) where x != nil && y != nil: return try NSLayoutAttribute.create(using: scanner(targetAttributeText!))
                default: throw StageException.UnrecognizedContent(
                    message: "Failed to parse target and attribute",
                    line: currentLine,
                    backtrace: [])
                }
            }
            func multiplier() throws -> CGFloat {
                guard let multiplyOpText = multiplyOpText else { return 1 }
                guard let multiplyFactorText = multiplyFactorText else {
                    throw StageException.UnrecognizedContent(
                        message: "Layout attribute multiplication specified without a factor",
                        line: currentLine,
                        backtrace: [])
                }
                var factor = try scanner(multiplyFactorText).scanCGFloat()
                if multiplyOpText == "/" {
                    if abs(factor) < 0.00001 {
                        throw StageException.UnrecognizedContent(
                            message: "Ignoring layout due to division of zero",
                            line: currentLine,
                            backtrace: [])
                    }
                    factor = 1 / factor
                }
                return factor
            }
            func constant() throws -> CGFloat {
                guard let addendText = addendText else { return 0 }
                if addOpText == nil && targetText != nil {
                    throw StageException.UnrecognizedContent(
                        message: "Missing add operator (+ or -) between target and constant",
                        line: currentLine,
                        backtrace: [])
                }
                var value = try scanner(addendText).scanCGFloat()
                if let addOpText = addOpText where addOpText == "-" {
                    value = -value
                }
                return value
            }
            do {
                return StageLayoutConstraint(
                    attribute: try selfAttribute(),
                    relation: try relation(),
                    target: targetText,
                    targetAttribute: try targetAttribute(),
                    multiplier: try multiplier(),
                    constant: try constant())
            } catch let ex {
                print("Skipping layout attribute line '\(line)'",
                    "\(ex)",
                    separator: "\n")
                return nil
            }
        }
        return constraints
    }
}