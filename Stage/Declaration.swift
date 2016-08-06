//
//  Declaration.swift
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

class StageDeclaration {
    let name: String
    var propertyMap: [String: (String, Int)] = [:]
    var viewHierarchy: StageViewHierarchyNode?

    init(name: String) {
        self.name = name
    }
}

protocol StageDeclarationInterpreter {
    func next(text: String, lineNumber: Int) throws
    func amend(declaration: StageDeclaration)
}

class PropertySettersInterpreter: StageDeclarationInterpreter {
    var currentName: String?
    var currentValue: String?
    var currentLineNumber: Int = 0
    var mapping: [String: (String, Int)] = [:]

    func next(text: String, lineNumber: Int) throws {
        let unrecognizedException = StageException.UnrecognizedContent(
            message: "Expected a property setter statement on line \(lineNumber)\nsaw '\(text)'",
            line: lineNumber,
            backtrace: [])

        if case let leftTrimmed = text.leftTrimmed() where leftTrimmed.hasPrefix(".") {
            commitCurrent()

            var propertyName: NSString?
            let scanner = NSScanner(string: leftTrimmed)
            scanner.charactersToBeSkipped = .whitespaceCharacterSet()
            let scan1 = scanner.scanString(".", intoString: nil)
            let scan2 = scanner.scanCharactersFromSet(.alphanumericCharacterSet(), intoString: &propertyName)
            let scan3 = scanner.scanString("=", intoString: nil)

            if !(scan1 && scan2 && scan3 && propertyName?.length > 0) { throw unrecognizedException }

            let scannedToIndex = scanner.string.startIndex.advancedBy(scanner.scanLocation)
            currentName = propertyName as? String
            currentValue = leftTrimmed.substringFromIndex(scannedToIndex).trimmed()
            currentLineNumber = lineNumber
        } else {
            if currentName == nil { throw unrecognizedException }
            currentValue!.appendContentsOf("\n\(text.trimmed())")
        }
    }
    func amend(declaration: StageDeclaration) {
        commitCurrent()
        mapping.forEach { key, value in
            declaration.propertyMap[key] = value
        }
    }

    func commitCurrent() {
        guard let propertyName = currentName else { return }
        if mapping.keys.contains(propertyName) {
            print("Warning. Overriding previously set value for property '\(propertyName)'\n\(mapping[propertyName])\nwith new value:\n\(currentValue!)")
        }

        mapping[propertyName] = (String(currentValue!), currentLineNumber)
        currentName = nil
        currentValue = nil
        currentLineNumber = 0
    }
}

class ViewHierarchyInterpreter: StageDeclarationInterpreter {
    var parentStack: [StageViewHierarchyNode]
    var nodeMemo: [String: StageViewHierarchyNode]
    var firstLine: Bool = true
    var definitionLineNumber: Int = 0

    init() {
        let rootNode = StageViewHierarchyNode(name: "$root", indentLevel: 0)
        parentStack = [rootNode]
        nodeMemo = [rootNode.name: rootNode]
    }

    func next(text: String, lineNumber: Int) throws {
        guard case let viewName = text.trimmed() where !viewName.isEmpty else { return }
        let indent = text.leadingIndent
        if firstLine {
            definitionLineNumber = lineNumber
            firstLine = false
        }

        if nodeMemo.keys.contains(viewName) {
            print("Warning. Existing node name \(viewName) specified within the same view hierarchy on line \(lineNumber). Clobbering")
        }

        while parentStack.count > 1 && parentStack.last!.indentLevel >= indent {
            parentStack.removeLast()
        }

        let node = parentStack.last!.addChild(viewName, indentLevel: indent)
        nodeMemo[viewName] = node
        parentStack.append(node)
    }

    func amend(declaration: StageDeclaration) {
        if declaration.viewHierarchy != nil {
            print("Warning. Declaration \(declaration.name) already has a view hierarchy defined. Clobbering")
        }
        declaration.viewHierarchy = parentStack.first
    }
}

