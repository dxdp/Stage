//
//  StackingView.swift
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
import UIKit

public enum StackingDirection {
    case horizontal
    case vertical

    fileprivate var stackingAttributes: (NSLayoutAttribute, NSLayoutAttribute) {
        switch self {
        case .horizontal: return (.leading, .trailing)
        case .vertical: return (.top, .bottom)
        }
    }
}

public enum StackingAlignment {
    case alignFirst
    case alignLast
    case alignBoth
    case alignNeither

    fileprivate func aligningAttributes(for direction: StackingDirection) -> (NSLayoutAttribute, NSLayoutAttribute) {
        switch direction {
        case .horizontal: return (.top, .bottom)
        case .vertical: return (.leading, .trailing)
        }
    }
}

open class StackingView: UIView {
    open var stackingAlignment: StackingAlignment = .alignBoth {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    open var stackingDirection: StackingDirection = .vertical {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    open var contentInset = UIEdgeInsets.zero {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    open var spacing: CGFloat = 0 {
        didSet {
            setNeedsUpdateConstraints()
        }
    }

    var activeStackingConstraints: [NSLayoutConstraint] = []
    open override func updateConstraints() {
        if !activeStackingConstraints.isEmpty {
            NSLayoutConstraint.deactivate(activeStackingConstraints)
            activeStackingConstraints.removeAll()
        }

        let (stackFirst, stackSecond) = stackingDirection.stackingAttributes
        let (alignFirst, alignSecond) = stackingAlignment.aligningAttributes(for: stackingDirection)
        let viewsToStack = subviews.flatMap { $0.isHidden ? nil : $0 }
        if !viewsToStack.isEmpty {
            var previous: UIView = viewsToStack.first!
            for view in viewsToStack[1..<viewsToStack.count] {
                activeStackingConstraints.append(view.constrain(attribute: stackFirst, to: previous, attribute: stackSecond, constant: spacing))
                previous = view
            }
            for view in viewsToStack {
                switch stackingAlignment {
                case .alignFirst:
                    activeStackingConstraints.append(view.constrain(attribute: alignFirst, to: self, attribute: alignFirst, constant: insetForAttribute(alignFirst)))
                case .alignLast:
                    activeStackingConstraints.append(view.constrain(attribute: alignSecond, to: self, attribute: alignSecond, constant: -insetForAttribute(alignSecond)))
                case .alignBoth:
                    activeStackingConstraints.append(view.constrain(attribute: alignFirst, to: self, attribute: alignFirst, constant: insetForAttribute(alignFirst)))
                    activeStackingConstraints.append(view.constrain(attribute: alignSecond, to: self, attribute: alignSecond, constant: -insetForAttribute(alignSecond)))
                case .alignNeither:
                    break
                }
            }
            let firstView = viewsToStack[0], lastView = viewsToStack[viewsToStack.count-1]
            activeStackingConstraints.append(constrain(attribute: stackFirst, to: firstView, attribute: stackFirst, constant: -insetForAttribute(stackFirst)))
            activeStackingConstraints.append(constrain(attribute: stackSecond, to: lastView, attribute: stackSecond, constant: insetForAttribute(stackSecond)))
        }
        super.updateConstraints()
    }

    fileprivate func insetForAttribute(_ attribute: NSLayoutAttribute) -> CGFloat {
        switch attribute {
        case .top: return contentInset.top
        case .bottom: return contentInset.bottom
        case .leading, .left: return contentInset.left
        case .trailing, .right: return contentInset.right
        default: return 0
        }
    }

    open override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        setNeedsUpdateConstraints()
    }

    open override func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        setNeedsUpdateConstraints()
    }


}
