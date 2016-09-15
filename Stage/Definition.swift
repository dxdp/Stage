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

public protocol StageDefinitionErrorListener {
    func error(_ exception: StageException)
}

public protocol StageDefinitionFactory {
    func build(data: Data) throws -> StageDefinition
    func build(data: Data, encoding: String.Encoding) throws -> StageDefinition
    func build(contentsOfFile file: String) throws -> StageDefinition
    func build(contentsOfFile file: String, encoding: String.Encoding) throws -> StageDefinition
    func use(_ errorListener: StageDefinitionErrorListener)
    func registerTypes(_ block: (PropertyRegistrar) -> ())
}

open class StageDefinition {
    let propertyRegistrar: PropertyRegistrar
    let errorListener: StageDefinitionErrorListener?
    var declarations: [String: StageDeclaration] = [:]
    var debugIdentifier = ""
    init(propertyRegistrar: PropertyRegistrar, errorListener: StageDefinitionErrorListener?) {
        self.propertyRegistrar = propertyRegistrar
        self.errorListener = errorListener
    }

    subscript(name: String) -> StageDeclaration {
        guard let some = declarations[name] else {
            let value = StageDeclaration(name: name)
            declarations[name] = value
            return value
        }
        return some
    }

    // TODO: Templated data bindings
    open func load<ViewMapping: StageViewMapping>(viewHierarchy name: String, handler: (ViewMapping) -> ()) throws -> StageLiveContext {
        do {
            let liveContext = try load(viewHierarchy: name)
            let mapper = Mapper(context: liveContext)
            do {
                let mapping = try ViewMapping(map: mapper)
                handler(mapping)
            } catch let ex as StageException {
                throw ex.withBacktraceMessage("while binding views to native ViewMapping \(ViewMapping.self)")
            }
            return liveContext
        } catch let ex as StageException {
            errorListener?.error(ex)
            throw ex
        }
    }
    open func load(viewHierarchy name: String) throws -> StageLiveContext {
        do {
            guard let declaration = declarations[name] , declaration.viewHierarchy != nil else {
                throw StageException.unknownViewHierarchy(message: "Attempt to load unknown view hierarchy: \(name)", backtrace: [])
            }
            return try StageLiveContext(definition: self, root: declaration)
        } catch var ex as StageException {
            ex = ex.withBacktraceMessage("while attempting to load view hierarchy \(name)")
            if !debugIdentifier.isEmpty { ex = ex.withBacktraceMessage("from StageDefinition: \(debugIdentifier)") }
            errorListener?.error(ex)
            throw ex
        }
    }
}
