//
//  Exception.swift
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

public enum StageException: Error {
    case invalidDataEncoding(backtrace: [String])
    case invalidViewType(message: String, backtrace: [String])
    case resourceNotAvailable(name: String, message: String, backtrace: [String])
    case unhandledProperty(message: String, line: Int, backtrace: [String])
    case unknownView(message: String, backtrace: [String])
    case unknownViewHierarchy(message: String, backtrace: [String])
    case unrecognizedContent(message: String, line: Int, backtrace: [String])

    func withBacktraceMessage(_ backtraceMessage: String) -> StageException {
        switch self {
        case .invalidDataEncoding(let bt):
            return .invalidDataEncoding(backtrace: bt + [backtraceMessage])
        case .invalidViewType(let message, let bt):
            return .invalidViewType(message: message, backtrace: bt + [backtraceMessage])
        case .resourceNotAvailable(let name, let message, let bt):
            return .resourceNotAvailable(name: name, message: message, backtrace: bt + [backtraceMessage])
        case .unknownView(let message, let bt):
            return .unknownView(message: message, backtrace: bt + [backtraceMessage])
        case .unknownViewHierarchy(let message, let bt):
            return .unknownViewHierarchy(message: message, backtrace: bt + [backtraceMessage])
        case .unhandledProperty(let message, let line, let bt):
            return .unhandledProperty(message: message, line: line, backtrace: bt + [backtraceMessage])
        case .unrecognizedContent(let message, let line, let bt):
            return .unrecognizedContent(message: message, line: line, backtrace: bt + [backtraceMessage])
        }
    }
}

