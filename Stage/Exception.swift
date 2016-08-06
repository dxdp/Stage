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

public enum StageException: ErrorType {
    case InvalidDataEncoding(backtrace: [String])
    case InvalidViewType(message: String, backtrace: [String])
    case ResourceNotAvailable(name: String, message: String, backtrace: [String])
    case UnhandledProperty(message: String, line: Int, backtrace: [String])
    case UnknownView(message: String, backtrace: [String])
    case UnknownViewHierarchy(message: String, backtrace: [String])
    case UnrecognizedContent(message: String, line: Int, backtrace: [String])

    func withBacktraceMessage(backtraceMessage: String) -> StageException {
        switch self {
        case .InvalidDataEncoding(let bt):
            return .InvalidDataEncoding(backtrace: bt + [backtraceMessage])
        case .InvalidViewType(let message, let bt):
            return .InvalidViewType(message: message, backtrace: bt + [backtraceMessage])
        case .ResourceNotAvailable(let name, let message, let bt):
            return .ResourceNotAvailable(name: name, message: message, backtrace: bt + [backtraceMessage])
        case .UnknownView(let message, let bt):
            return .UnknownView(message: message, backtrace: bt + [backtraceMessage])
        case .UnknownViewHierarchy(let message, let bt):
            return .UnknownViewHierarchy(message: message, backtrace: bt + [backtraceMessage])
        case .UnhandledProperty(let message, let line, let bt):
            return .UnhandledProperty(message: message, line: line, backtrace: bt + [backtraceMessage])
        case .UnrecognizedContent(let message, let line, let bt):
            return .UnrecognizedContent(message: message, line: line, backtrace: bt + [backtraceMessage])
        }
    }
}

