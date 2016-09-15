//
//  LiveContext.swift
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

public protocol LiveContextMutator {
    init(context: StageLiveContext)
    func bind(_ key: String, value: String?)
    func finalize() throws


}

open class BasicLiveContextMutator: LiveContextMutator {
    let context: StageLiveContext
    var mutatedKeys: [String:String?] = [:]
    open let updateChangedKeys: (Set<String>) throws -> ()
    public required init(context: StageLiveContext) {
        self.context = context
        self.updateChangedKeys = context.updateChangedKeys
    }

    open func bind(_ key: String, value: String?) {
        mutatedKeys[key] = value
    }
    open func bind<T: RawRepresentable>(_ key: T, value: String?) where T.RawValue == String {
        mutatedKeys[key.rawValue] = value
    }

    open func finalize() throws {
        var keysChanged: Set<String> = Set()
        mutatedKeys.forEach { key, value in
            if value != context.dataBindings[key] {
                keysChanged.insert(key)
                if value == nil { context.dataBindings.removeValue(forKey: key) }
                else { context.dataBindings[key] = value }
            }
        }

        try updateChangedKeys(keysChanged)
    }
}

open class StageLiveContext {
    let stage: StageDefinition
    let rootDefinition: StageDeclaration
    var dataBindings: [String: String]
    var viewBindings: [String: StageViewBinding] = [:]
    var childQueue: [StageViewHierarchyNode] = []

    init(definition: StageDefinition, root: StageDeclaration, templateData: [String:String]? = nil, initialViews: [String: UIView]? = nil) throws {
        stage = definition
        rootDefinition = root
        dataBindings = templateData ?? [:]
        initialViews?.forEach { name, view in viewBindings[name] = .specificView(view: view) }

        if rootDefinition.viewHierarchy == nil {
            throw StageException.unknownViewHierarchy(message: "Attempt to load unknown view hierarchy: \(root.name)", backtrace: [])
        }
        try buildViewBindings()
    }

    open func addAsSubview(of container: UIView) throws {
        guard let root = rootDefinition.viewHierarchy,
            let currentBinding = viewBindings[root.name] else {
                return
        }
        viewBindings[root.name] = .specificView(view: container)
        viewBindings[rootDefinition.name] = .specificView(view: container)

        if let (declaration, keys) = rootDeclarationProperties {
            try applyDeclarations(declaration, keys: keys, pass: .viewConstruction)
        }

        if currentBinding == .containerSurrogate {
            try buildAncestory()
            try setProperties(.treeConstruction(context: self))
        }
    }

    open func view<T:UIView>(named name: String) throws -> T {
        switch viewBindings[name] {
        case .specificView(let view as T)?: return view
        case .specificView(let view)? where !(view is T):
            throw StageException.invalidViewType(message: "Unexpected type \(T.self) for view named \(name). Expecting type \(type(of: view))", backtrace: [])
        default:
            throw StageException.unknownView(message: "Unknown view \(name) in view hierarchy", backtrace: [])
        }
    }

    open func update<T: LiveContextMutator>(_ function: (T) -> ()) throws {
        let mutator = T(context: self)
        function(mutator)
        try mutator.finalize()
    }

    fileprivate func updateChangedKeys(_ keys: Set<String>) throws {
        try stage.declarations.forEach { _, declaration in
            let intersectingKeys = keys.intersection(declaration.interpolants.keys)
            try intersectingKeys.forEach { updatedKey in
                let propertiesUpdated = declaration.interpolants[updatedKey]!
                do {
                    try applyDeclarations(declaration, keys: Array(propertiesUpdated), pass: .viewConstruction)
                    try applyDeclarations(declaration, keys: Array(propertiesUpdated), pass: .treeConstruction(context: self))
                } catch let ex as StageException {
                    throw ex.withBacktraceMessage("while resetting properties in \(declaration.name)")
                }
            }
        }
    }

    fileprivate func buildViewBindings() throws {
        do {
            let root = rootDefinition.viewHierarchy!
            viewBindings[root.name] = .containerSurrogate
            viewBindings[rootDefinition.name] = .containerSurrogate

            childQueue.removeAll()
            childQueue.append(contentsOf: root.children)
            var i = 0; while i < childQueue.count {
                let child = childQueue[i]
                childQueue.append(contentsOf: child.children)
                i += 1

                if viewBindings[child.name]?.view != nil { continue }
                let childDefinition = stage.declarations[child.name]
                let childViewClassName = childDefinition?.propertyMap["class"]?.0 ?? "UIView"

                var childViewType: AnyClass? = NSClassFromString(childViewClassName)
                if childViewType == nil {
                    print("Warning. Unable to use class \(childViewClassName) while building view hierarchy. Using UIView")
                    childViewType = UIView.self
                }
                if !childViewType!.isSubclass(of: UIView.self) {
                    print("Error. Stage can only build types descending from UIView.",
                          "Refusing to build instance of \(childViewType!)")
                    continue
                }
                
                //TODO:
                // Inject view factories
                if let childView = StageRuntimeHelpers.makeView(with: childViewType!) {
                    viewBindings[child.name] = .specificView(view: childView)
                }
            }

            try setProperties(.viewConstruction)
        } catch let ex as StageException {
            throw ex.withBacktraceMessage("while building views")
        }
    }

    fileprivate func buildAncestory() throws {
        for child in childQueue where child.parent != nil {
            let parent = child.parent!
            if let parentView = viewBindings[parent.name]?.view,
                let childView = viewBindings[child.name]?.view {
                parentView.addSubview(childView)
            } else {

            }
        }
    }

    fileprivate typealias PropertyDeclarationKeysTuple = (StageDeclaration, [String])
    fileprivate var childDeclarationsWithProperties: [PropertyDeclarationKeysTuple] {
        return childQueue.flatMap { child in
            if let childDeclaration = self.stage.declarations[child.name],
                case let keys = Set(childDeclaration.propertyMap.keys) - Set(["class"])
                , keys.count > 0 {
                return (childDeclaration, Array(keys))
            }
            return nil
        }
    }
    fileprivate var rootDeclarationProperties: PropertyDeclarationKeysTuple? {
        guard case let keys = Set(rootDefinition.propertyMap.keys) - Set(["class"])
            , keys.count > 0 else { return nil }
        return (rootDefinition, Array(keys))
    }

    fileprivate func setProperties(_ pass: PropertySetPass) throws {
        var declarationsWithProperties = childDeclarationsWithProperties
        if let rootDeclarationProperties = rootDeclarationProperties {
            declarationsWithProperties.append(rootDeclarationProperties)
        }
        for (declaration, keys) in declarationsWithProperties {
            try applyDeclarations(declaration, keys: keys, pass: pass)
        }
    }
    fileprivate func applyDeclarations(_ declaration: StageDeclaration, keys: [String], pass: PropertySetPass) throws {
        guard let view = self.viewBindings[declaration.name]?.view else {
            return
        }
        let chain = stage.propertyRegistrar.registry(for: view)
        try keys.forEach { key in
            if let (propertyText, startingLine) = declaration.interpolatedProperty(key: key, dataBinding: dataBindings) {
                let scanner = StageRuleScanner(string: propertyText)
                scanner.charactersToBeSkipped = .whitespaces
                scanner.startingLine = startingLine

                var handled = false
                for registration in chain where !handled {
                    let registration = registration
                    do {
                        try registration.receive(property: key, scanner: scanner, view: view, pass: pass)
                        handled = true
                    } catch StageException.unhandledProperty {
                    }
                }
                if !handled {
                    throw StageException.unhandledProperty(
                        message: "Property '\(key)' has no setter registered in any superclass of \(type(of: view))",
                        line: startingLine,
                        backtrace: ["while setting properties for \(declaration.name)"])
                }
            }
        }
    }
}
