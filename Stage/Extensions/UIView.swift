//
//  UIView.swift
//  Stage
//
//  Created by David Parton on 8/3/16.
//  Copyright © 2016 deep. All rights reserved.
//

import Foundation

public extension UIView {
    public func constrain(attribute myAttribute: NSLayoutAttribute, to view: UIView, attribute: NSLayoutAttribute, multiplier: CGFloat = 1, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: myAttribute, relatedBy: .Equal, toItem: view, attribute: attribute, multiplier: multiplier, constant: constant)
        constraint.active = true
        return constraint
    }

    public func constrainToSuperviewEdges() -> [NSLayoutConstraint] {
        guard let superview = superview else { return [] }
        let edges: [NSLayoutAttribute] = [.Left, .Right, .Top, .Bottom]
        return edges.map { constrain(attribute: $0, to: superview, attribute: $0) }
    }

    public func removeAllSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }

}