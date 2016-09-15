//
//  ViewHierarchyNode.swift
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

class StageViewHierarchyNode {
    let name: String
    let indentLevel: Int
    var children: [StageViewHierarchyNode] = []
    weak var parent: StageViewHierarchyNode?

    init(name: String, indentLevel: Int) {
        self.name = name
        self.indentLevel = indentLevel
    }

    func addChild(_ name: String, indentLevel: Int) -> StageViewHierarchyNode {
        assert(indentLevel > self.indentLevel)
        let subnode = StageViewHierarchyNode(name: name, indentLevel: indentLevel)
        subnode.parent = self
        children.append(subnode)
        return subnode
    }
}
