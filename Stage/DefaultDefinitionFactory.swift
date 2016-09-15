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
    init(bundles: [Bundle]) {
        dict = [:]
        for bundle in bundles {
            let paths = bundle.paths(forResourcesOfType: "stage", inDirectory: "")
            paths.forEach { path in
                dict[(path as NSString).lastPathComponent.lowercased()] = path
            }
        }
    }
}

open class DefaultDefinitionFactory : StageDefinitionFactory {
    let index: StageDefinitionIndex
    var errorListener: StageDefinitionErrorListener?
    let propertyRegistrar: PropertyRegistrar

    public init(bundles: [Bundle] = [.main] + Bundle.allFrameworks) {
        index = StageDefinitionIndex(bundles: bundles)
        propertyRegistrar = tap(PropertyRegistrar()) { StageRegister.LoadDefaults($0) }
    }
    open func registerTypes(_ block: (PropertyRegistrar) -> ()) -> Void {
        block(propertyRegistrar)
    }
    
    open func build(data: Data) throws -> StageDefinition {
        do {
            return try self.build(data: data, encoding: String.Encoding.utf8)
        } catch let ex as StageException {
            errorListener?.error(ex)
            throw ex
        }

    }
    open func build(contentsOfFile file: String) throws -> StageDefinition {
        do {
            return try self.build(contentsOfFile: file, encoding: String.Encoding.utf8)
        } catch let ex as StageException {
            errorListener?.error(ex)
            throw ex
        }
    }

    open func build(data: Data, encoding: String.Encoding) throws -> StageDefinition {
        return try build(data: data, encoding: encoding, identifier: "")
    }

    fileprivate func build(data: Data, encoding: String.Encoding, identifier: String) throws -> StageDefinition {
        do {
            guard let string = String(data: data, encoding: encoding) else {
                throw StageException.invalidDataEncoding(backtrace: [])
            }
            let lines = string.components(separatedBy: CharacterSet(charactersIn: "\r\n"))
            let definition = try StageParser(propertyRegistrar: propertyRegistrar, errorListener: errorListener).parse(lines, identifier: identifier)
            return definition
        } catch let ex as StageException {
            errorListener?.error(ex)
            throw ex
        }
    }

    open func use(_ errorListener: StageDefinitionErrorListener) {
        self.errorListener = errorListener
    }

    open func build(contentsOfFile file: String, encoding: String.Encoding) throws -> StageDefinition {
        do {
            let inputFile = file
            var file = inputFile
            if !file.hasPrefix("/") { file = try fullPathInBundle(file) }
            // TODO: caching of definitions
            if let data = try? Data(contentsOf: URL(fileURLWithPath: file)) { return try build(data: data, encoding: encoding, identifier: file) }
            throw StageException.resourceNotAvailable(name: inputFile,
                                                      message: "File could not be found in the main or framework bundles",
                                                      backtrace: [])
        } catch var ex as StageException {
            ex = ex.withBacktraceMessage("while building StageDefinition from contents of file \(file)")
            errorListener?.error(ex)
            throw ex
        }
    }

    func fullPathInBundle(_ file: String) throws -> String {
        if let str = index.dict[file.lowercased()] { return str }
        throw StageException.resourceNotAvailable(name: file,
                                                  message: "File could not be found in the main or framework bundles",
                                                  backtrace: [])
    }
}
