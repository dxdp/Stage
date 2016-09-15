//
//  RuleScanner.swift
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

public class StageRuleScanner: Scanner {
    public internal(set) var startingLine: Int = 0

    let _string: String
    public override var string: String { return _string }

    var _scanLocation: Int = 0
    public override var scanLocation: Int {
        get { return _scanLocation }
        set { _scanLocation = newValue }
    }

    var _caseSensitive: Bool = false
    public override var caseSensitive: Bool {
        get { return _caseSensitive }
        set { _caseSensitive = newValue }
    }
    var _charactersToBeSkipped: CharacterSet?
    public override var charactersToBeSkipped: CharacterSet? {
        get { return _charactersToBeSkipped }
        set { _charactersToBeSkipped = newValue }
    }
    var _locale: Any?
    public override var locale: Any? {
        get { return _locale }
        set { _locale = newValue }
    }

    override init(string: String) {
        _string = string
        super.init(string: string)
    }

    public func scanBool() throws -> Bool {
        var next: NSString? = nil
        guard scanCharacters(from: .nonwhitespaceCharacterSet(), into: &next) && next != nil else {
            throw StageException.unrecognizedContent(message: "Expecting Bool but received \(string)", line: startingLine, backtrace: [])
        }
        return next!.boolValue
    }

    static let nsNumberSet = CharacterSet(charactersIn: "0123456789.-")
    static let nsNumberMatch = try! NSRegularExpression(pattern: "-?(?:\\d*\\.\\d+|\\d+\\.?\\d*)",
                                                        options: .init(rawValue: 0))
    static let nsNumberFormatter = NumberFormatter()
    public func scanNSNumber() throws -> NSNumber {
        var numberText: NSString?
        guard scanCharacters(from: StageRuleScanner.nsNumberSet, into: &numberText)
            && numberText != nil
            && StageRuleScanner.nsNumberMatch.numberOfMatches(in: numberText as! String, options: .init(rawValue: 0), range: (numberText as! String).entireRange) == 1
            else {
                throw StageException.unrecognizedContent(message: "Expected number but received \(string)", line: startingLine, backtrace: [])
        }
        guard let number = StageRuleScanner.nsNumberFormatter.number(from: numberText! as String) else {
            throw StageException.unrecognizedContent(message: "Expected number but received \(string)", line: startingLine, backtrace: [])
        }
        return number
    }

    public func scanInt() throws -> Int {
        var out: Int32 = 0
        guard scanInt32(&out) else { throw StageException.unrecognizedContent(message: "Expected integer but saw \(string)",
            line: startingLine,
            backtrace: []) }
        return Int(out)
    }

    public func scanFloat() throws -> Float {
        return try scanNSNumber().floatValue
    }
    public func scanCGFloat() throws -> CGFloat {
        return CGFloat(try scanFloat())
    }

    public func scanList<T>( itemScan: @autoclosure () throws -> T) throws -> [T] {
        var output = [T]()
        while !isAtEnd {
            output.append(try itemScan())
            scanString(",", into: nil)
        }
        return output
    }
    public func scanBracedList<T>(open: String = "{", close: String = "}",
                               itemScan: @autoclosure () throws -> T) throws -> [T] {
        if !open.isEmpty && !scanString(open, into: nil) {
            throw StageException.unrecognizedContent(message: "Expected \(open) to open list but saw \(string)",
                                                     line: startingLine,
                                                     backtrace: [])
        }
        var output = [T](), gotRightBrace = close.isEmpty
        while !isAtEnd {
            if !close.isEmpty && scanString(close, into: nil) {
                gotRightBrace = true
                break
            }
            output.append(try itemScan())
            scanString(",", into: nil)
        }

        if !gotRightBrace {
            throw StageException.unrecognizedContent(message: "Expected \(close) to close list but saw \(string)",
                                                     line: startingLine,
                                                     backtrace: [])
        }
        return output
    }

    public func scanCharacters(from set: CharacterSet) throws -> String {
        var string: NSString?
        guard scanCharacters(from: set, into: &string) && string != nil else {
            throw StageException.unrecognizedContent(message: "Unable to scan to characters in set", line: startingLine, backtrace: [])
        }
        return string as! String
    }

    public func scanUpTo(string: String) throws -> String {
        var value: NSString?
        guard scanUpTo(string, into: &value) && value != nil else {
            throw StageException.unrecognizedContent(message: "Unable to scan up through \(string)", line: startingLine, backtrace: [])
        }
        return value as! String
    }

    public func scanLinesTrimmed() -> [String] {
        return string.components(separatedBy: "\n").map { $0.trimmed() }
    }
}

