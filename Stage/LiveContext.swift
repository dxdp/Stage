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

public class StageLiveContext {
    let stage: StageDefinition
    let rootDefinition: StageDeclaration
    let dataBindings: [String: String]
    var viewBindings: [String: StageViewBinding] = [:]
    var childQueue: [StageViewHierarchyNode] = []

    init(definition: StageDefinition, root: StageDeclaration, templateData: [String:String]? = nil, initialViews: [String: UIView]? = nil) throws {
        stage = definition
        rootDefinition = root
        dataBindings = templateData ?? [:]
        initialViews?.forEach { name, view in viewBindings[name] = .SpecificView(view: view) }

        if rootDefinition.viewHierarchy == nil {
            throw StageException.UnknownViewHierarchy(message: "Attempt to load unknown view hierarchy: \(root.name)", backtrace: [])
        }
        try buildViewBindings()
    }

    public func addAsSubview(of container: UIView) throws {
        guard let root = rootDefinition.viewHierarchy,
            let currentBinding = viewBindings[root.name] else {
                return
        }
        viewBindings[root.name] = .SpecificView(view: container)
        viewBindings[rootDefinition.name] = .SpecificView(view: container)

        if let (declaration, keys) = rootDeclarationProperties {
            try applyDeclarations(declaration, keys: keys, pass: .ViewConstruction)
        }

        if currentBinding == .ContainerSurrogate {
            try buildAncestory()
            try setProperties(.TreeConstruction(context: self))
        }
    }

    public func view<T:UIView>(named name: String) throws -> T {
        switch viewBindings[name] {
        case .SpecificView(let view as T)?: return view
        case .SpecificView(let view)? where !(view is T):
            throw StageException.InvalidViewType(message: "Unexpected type \(T.self) for view named \(name). Expecting type \(view.dynamicType)", backtrace: [])
        default:
            throw StageException.UnknownView(message: "Unknown view \(name) in view hierarchy", backtrace: [])
        }
    }

    private func buildViewBindings() throws {
        do {
            let root = rootDefinition.viewHierarchy!
            viewBindings[root.name] = .ContainerSurrogate
            viewBindings[rootDefinition.name] = .ContainerSurrogate

            childQueue.removeAll()
            childQueue.appendContentsOf(root.children)
            var i = 0; while i < childQueue.count {
                let child = childQueue[i]
                childQueue.appendContentsOf(child.children)
                i += 1

                if viewBindings[child.name]?.view != nil { continue }
                let childDefinition = stage.declarations[child.name]
                let childViewClassName = childDefinition?.propertyMap["class"]?.0 ?? "UIView"
                // UIViews are Objective-C, so even public Swift implementations will have a value that can be loaded.
                // As of writing, they can be loaded using a FQN (e.g. MyModule.MyAwesomeView) or via the mangled name.
                var childViewType: AnyClass? = NSClassFromString(childViewClassName)
                if childViewType == nil {
                    print("Warning. Unable to use class \(childViewClassName) while building view hierarchy. Using UIView")
                    childViewType = UIView.self
                }

                if !childViewType!.isSubclassOfClass(UIView.self) {
                    print("Error. Stage can only build types descending from UIView.",
                          "Refusing to build instance of \(childViewType!)")
                    continue
                }

                if let childView = StageRuntimeHelpers.makeViewWithClass(childViewType!) {
                    viewBindings[child.name] = .SpecificView(view: childView)
                }
            }

            try setProperties(.ViewConstruction)
        } catch let ex as StageException {
            throw ex.withBacktraceMessage("while building views")
        }
    }

    private func buildAncestory() throws {
        for child in childQueue where child.parent != nil {
            let parent = child.parent!
            if let parentView = viewBindings[parent.name]?.view,
                let childView = viewBindings[child.name]?.view {
                parentView.addSubview(childView)
            } else {

            }
        }
    }

    private typealias PropertyDeclarationKeysTuple = (StageDeclaration, [String])
    private var childDeclarationsWithProperties: [PropertyDeclarationKeysTuple] {
        return childQueue.flatMap { child in
            if let childDeclaration = self.stage.declarations[child.name],
                case let keys = Set(childDeclaration.propertyMap.keys) - Set(["class"])
                where keys.count > 0 {
                return (childDeclaration, Array(keys))
            }
            return nil
        }
    }
    private var rootDeclarationProperties: PropertyDeclarationKeysTuple? {
        guard case let keys = Set(rootDefinition.propertyMap.keys) - Set(["class"])
            where keys.count > 0 else { return nil }
        return (rootDefinition, Array(keys))
    }

    private func setProperties(pass: PropertySetPass) throws {
        var declarationsWithProperties = childDeclarationsWithProperties
        if let rootDeclarationProperties = rootDeclarationProperties {
            declarationsWithProperties.append(rootDeclarationProperties)
        }
        for (declaration, keys) in declarationsWithProperties {
            try applyDeclarations(declaration, keys: keys, pass: pass)
        }
    }
    private func applyDeclarations(declaration: StageDeclaration, keys: [String], pass: PropertySetPass) throws {
        guard let view = self.viewBindings[declaration.name]?.view else {
            return
        }
        let chain = StageRuntimeHelpers.inheritanceChainRegistries(for: view)
        try keys.forEach { key in
            if let (propertyText, startingLine) = declaration.propertyMap[key] {
                let scanner = StageRuleScanner(string: propertyText)
                scanner.charactersToBeSkipped = .whitespaceCharacterSet()
                scanner.startingLine = startingLine

                var handled = false
                for registration in chain where registration is StagePropertyRegistration && !handled {
                    let registration = registration as! StagePropertyRegistration
                    do {
                        try registration.receive(property: key, scanner: scanner, view: view, pass: pass)
                        handled = true
                    } catch StageException.UnhandledProperty {
                    }
                }
                if !handled {
                    throw StageException.UnhandledProperty(
                        message: "Property '\(key)' has no setter registered in any superclass of \(view.dynamicType)",
                        line: startingLine,
                        backtrace: ["while setting properties for \(declaration.name)"])
                }
            }
        }
    }
}
