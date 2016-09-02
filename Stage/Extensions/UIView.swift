//
//  UIView.swift
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

public extension UIView {
    func commonSuperview(with view: UIView) -> UIView? {
        var witnessed = Set<UIView>([self, view])
        var viter1: UIView? = self, viter2: UIView? = view
        while viter1 != nil || viter2 != nil {
            if let super1 = viter1?.superview {
                if witnessed.contains(super1) { return super1 }
                witnessed.insert(super1)
            }
            viter1 = viter1?.superview
            if let super2 = viter2?.superview {
                if witnessed.contains(super2) { return super2 }
                witnessed.insert(super2)
            }
            viter2 = viter2?.superview
        }
        return nil
    }

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

    public func constrain(attribute myAttribute: NSLayoutAttribute, to constant: CGFloat) -> NSLayoutConstraint {
        let constraint = constraints.filter { ($0.firstItem as! NSObject) == self && $0.firstAttribute == myAttribute && $0.secondItem == nil }.first ??
            tap(NSLayoutConstraint(item: self, attribute: myAttribute, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: constant)) {
                $0.active = true
        }
        constraint.constant = constant
        return constraint
    }

    public func removeAllSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }

}