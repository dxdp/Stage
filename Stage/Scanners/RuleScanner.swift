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

public class StageRuleScanner: NSScanner {
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
    var _charactersToBeSkipped: NSCharacterSet?
    public override var charactersToBeSkipped: NSCharacterSet? {
        get { return _charactersToBeSkipped }
        set { _charactersToBeSkipped = newValue }
    }
    var _locale: AnyObject?
    public override var locale: AnyObject? {
        get { return _locale }
        set { _locale = newValue }
    }

    override init(string: String) {
        _string = string
        super.init(string: string)
    }

    public func scanBool() throws -> Bool {
        var next: NSString? = nil
        guard scanUpToCharactersFromSet(.whitespaceCharacterSet(), intoString: &next) && next != nil else {
            throw StageException.UnrecognizedContent(message: "Expecting Bool but received \(string)", line: startingLine, backtrace: [])
        }
        return next!.boolValue
    }

    static let nsNumberSet = NSCharacterSet(charactersInString: "0123456789.-")
    static let nsNumberMatch = try! NSRegularExpression(pattern: "-?(?:\\d*\\.\\d+|\\d+\\.?\\d*)",
                                                        options: .init(rawValue: 0))
    static let nsNumberFormatter = NSNumberFormatter()
    public func scanNSNumber() throws -> NSNumber {
        var numberText: NSString?
        guard scanCharactersFromSet(StageRuleScanner.nsNumberSet, intoString: &numberText)
            && numberText != nil
            && StageRuleScanner.nsNumberMatch.numberOfMatchesInString(numberText as! String, options: .init(rawValue: 0), range: (numberText as! String).entireRange) == 1
            else {
                throw StageException.UnrecognizedContent(message: "Expected number but received \(string)", line: startingLine, backtrace: [])
        }
        guard let number = StageRuleScanner.nsNumberFormatter.numberFromString(numberText! as String) else {
            throw StageException.UnrecognizedContent(message: "Expected number but received \(string)", line: startingLine, backtrace: [])
        }
        return number
    }

    public func scanInt() throws -> Int {
        var out: Int32 = 0
        guard scanInt(&out) else { throw StageException.UnrecognizedContent(message: "Expected integer but saw \(string)",
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

    public func scanList<T>(@autoclosure itemScan: () throws -> T) throws -> [T] {
        var output = [T]()
        while !atEnd {
            output.append(try itemScan())
            scanString(",", intoString: nil)
        }
        return output
    }
    public func scanBracedList<T>(open open: String = "{", close: String = "}",
                               @autoclosure itemScan: () throws -> T) throws -> [T] {
        if !open.isEmpty && !scanString(open, intoString: nil) {
            throw StageException.UnrecognizedContent(message: "Expected \(open) to open list but saw \(string)",
                                                     line: startingLine,
                                                     backtrace: [])
        }
        var output = [T](), gotRightBrace = close.isEmpty
        while !atEnd {
            if !close.isEmpty && scanString(close, intoString: nil) {
                gotRightBrace = true
                break
            }
            output.append(try itemScan())
            scanString(",", intoString: nil)
        }

        if !gotRightBrace {
            throw StageException.UnrecognizedContent(message: "Expected \(close) to close list but saw \(string)",
                                                     line: startingLine,
                                                     backtrace: [])
        }
        return output
    }

    public func scanUpToCharactersFromSet(set: NSCharacterSet) throws -> String {
        var string: NSString?
        guard scanUpToCharactersFromSet(set, intoString: &string) && string != nil else {
            throw StageException.UnrecognizedContent(message: "Unable to scan to characters in set", line: startingLine, backtrace: [])
        }
        return string as! String
    }

    public func scanUpToString(string: String) throws -> String {
        var value: NSString?
        guard scanUpToString(string, intoString: &value) && value != nil else {
            throw StageException.UnrecognizedContent(message: "Unable to scan up through \(string)", line: startingLine, backtrace: [])
        }
        return value as! String
    }

    public func scanLinesTrimmed() -> [String] {
        return string.componentsSeparatedByString("\n").map { $0.trimmed() }
    }
}

