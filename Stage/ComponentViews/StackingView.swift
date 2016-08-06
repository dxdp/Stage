//
//  StackingView.swift
//  Stage
//
//  Created by David Parton on 8/3/16.
//  Copyright © 2016 deep. All rights reserved.
//

import Foundation
import UIKit

public enum StackingDirection {
    case Horizontal
    case Vertical

    private var stackingAttributes: (NSLayoutAttribute, NSLayoutAttribute) {
        switch self {
        case .Horizontal: return (.Leading, .Trailing)
        case .Vertical: return (.Top, .Bottom)
        }
    }
}

public enum StackingAlignment {
    case AlignFirst
    case AlignLast
    case AlignBoth
    case AlignNeither

    private func aligningAttributes(for direction: StackingDirection) -> (NSLayoutAttribute, NSLayoutAttribute) {
        switch direction {
        case .Horizontal: return (.Top, .Bottom)
        case .Vertical: return (.Leading, .Trailing)
        }
    }
}

public class StackingView: UIView {
    public var stackingAlignment: StackingAlignment = .AlignBoth {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    public var stackingDirection: StackingDirection = .Vertical {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    public var contentInset = UIEdgeInsetsZero {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    public var spacing: CGFloat = 0 {
        didSet {
            setNeedsUpdateConstraints()
        }
    }

    var activeStackingConstraints: [NSLayoutConstraint] = []
    public override func updateConstraints() {
        if !activeStackingConstraints.isEmpty {
            NSLayoutConstraint.deactivateConstraints(activeStackingConstraints)
            activeStackingConstraints.removeAll()
        }

        let (stackFirst, stackSecond) = stackingDirection.stackingAttributes
        let (alignFirst, alignSecond) = stackingAlignment.aligningAttributes(for: stackingDirection)
        let viewsToStack = subviews.flatMap { $0.hidden ? nil : $0 }
        if !viewsToStack.isEmpty {
            var previous: UIView = viewsToStack.first!
            for view in viewsToStack[1..<viewsToStack.count] {
                activeStackingConstraints.append(view.constrain(attribute: stackFirst, to: previous, attribute: stackSecond, constant: spacing))
                previous = view
            }
            for view in viewsToStack {
                switch stackingAlignment {
                case .AlignFirst:
                    activeStackingConstraints.append(view.constrain(attribute: alignFirst, to: self, attribute: alignFirst, constant: insetForAttribute(alignFirst)))
                case .AlignLast:
                    activeStackingConstraints.append(view.constrain(attribute: alignSecond, to: self, attribute: alignSecond, constant: -insetForAttribute(alignSecond)))
                case .AlignBoth:
                    activeStackingConstraints.append(view.constrain(attribute: alignFirst, to: self, attribute: alignFirst, constant: insetForAttribute(alignFirst)))
                    activeStackingConstraints.append(view.constrain(attribute: alignSecond, to: self, attribute: alignSecond, constant: -insetForAttribute(alignSecond)))
                default:
                    break
                }
            }
            let firstView = viewsToStack[0], lastView = viewsToStack[viewsToStack.count-1]
            activeStackingConstraints.append(constrain(attribute: stackFirst, to: firstView, attribute: stackFirst, constant: -insetForAttribute(stackFirst)))
            activeStackingConstraints.append(constrain(attribute: stackSecond, to: lastView, attribute: stackSecond, constant: insetForAttribute(stackSecond)))
        }
        super.updateConstraints()
    }

    private func insetForAttribute(attribute: NSLayoutAttribute) -> CGFloat {
        switch attribute {
        case .Top: return contentInset.top
        case .Bottom: return contentInset.bottom
        case .Leading, .Left: return contentInset.left
        case .Trailing, .Right: return contentInset.right
        default: return 0
        }
    }

    public override func didAddSubview(subview: UIView) {
        super.didAddSubview(subview)
        setNeedsUpdateConstraints()
    }

    public override func willRemoveSubview(subview: UIView) {
        super.willRemoveSubview(subview)
        setNeedsUpdateConstraints()
    }


}