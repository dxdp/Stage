//
//  Definition.swift
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

public class StageDefinition {
    var declarations: [String: StageDeclaration] = [:]
    var debugIdentifier = ""
    subscript(name: String) -> StageDeclaration {
        guard let some = declarations[name] else {
            let value = StageDeclaration(name: name)
            declarations[name] = value
            return value
        }
        return some
    }

    // TODO: Templated data bindings
    public func load<ViewMapping: StageViewMapping>(viewHierarchy name: String, @noescape handler: ViewMapping -> ()) throws -> StageLiveContext {
        let liveContext = try load(viewHierarchy: name)
        let mapper = Mapper(context: liveContext)
        let mapping = try ViewMapping(map: mapper)
        handler(mapping)
        return liveContext
    }
    public func load(viewHierarchy name: String) throws -> StageLiveContext {
        guard let declaration = declarations[name] where declaration.viewHierarchy != nil else {
            throw StageException.UnknownViewHierarchy(message: "Attempt to load unknown view hierarchy: \(name)")
        }
        return try StageLiveContext(definition: self, root: declaration)
    }
}

public protocol StageDefinitionFactory {
    func build(data data: NSData) throws -> StageDefinition
    func build(data data: NSData, encoding: NSStringEncoding) throws -> StageDefinition
    func build(contentsOfFile file: String) throws -> StageDefinition
    func build(contentsOfFile file: String, encoding: NSStringEncoding) throws -> StageDefinition
}
