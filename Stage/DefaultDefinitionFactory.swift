//
//  DefaultDefinitionFactory.swift
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

class StageDefinitionIndex {
    var dict: [String:String]
    init(bundles: [NSBundle]) {
        dict = [:]
        for bundle in bundles {
            let paths = bundle.pathsForResourcesOfType("stage", inDirectory: "")
            paths.forEach { path in
                dict[(path as NSString).lastPathComponent.lowercaseString] = path
            }
        }
    }
}

public class DefaultDefinitionFactory : StageDefinitionFactory {
    let index: StageDefinitionIndex
    public init(bundles: [NSBundle] = [.mainBundle()] + NSBundle.allFrameworks()) {
        index = StageDefinitionIndex(bundles: bundles)
    }
    public func build(data data: NSData) throws -> StageDefinition {
        return try self.build(data: data, encoding: NSUTF8StringEncoding)
    }
    public func build(contentsOfFile file: String) throws -> StageDefinition {
        return try self.build(contentsOfFile: file, encoding: NSUTF8StringEncoding)
    }

    public func build(data data: NSData, encoding: NSStringEncoding) throws -> StageDefinition {
        guard let string = String(data: data, encoding: encoding) else {
            throw StageException.InvalidDataEncoding
        }
        let lines = string.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "\r\n"))
        return try StageParser().parse(lines)
    }

    public func build(contentsOfFile file: String, encoding: NSStringEncoding) throws -> StageDefinition {
        let inputFile = file
        var file = inputFile
        if !file.hasPrefix("/") { file = try fullPathInBundle(file) }
        // TODO: caching of definitions
        if let data = NSData(contentsOfFile: file) { return try build(data: data, encoding: encoding) }
        throw StageException.ResourceNotAvailable(name: inputFile,
                                                  message: "File could not be found in the main or framework bundles")
    }

    func fullPathInBundle(file: String) throws -> String {
        if let str = index.dict[file] { return str }
        throw StageException.ResourceNotAvailable(name: file,
                                                  message: "File could not be found in the main or framework bundles")
    }
}
