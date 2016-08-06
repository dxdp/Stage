//
//  UIViewBindings.swift
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

private var UIView_propertyTable = {
    return tap(StagePropertyRegistration()) {
        $0.register("alpha") { scanner -> CGFloat in try scanner.scanCGFloat() }
            .apply { (view: UIView, value) in view.alpha = min(max(value, 0), 1) }

        $0.register("backgroundColor") { scanner -> UIColor in try scanner.scanUIColor() }
            .apply { (view: UIView, value) in view.backgroundColor = value }

        $0.register("borderColor") { scanner -> UIColor in try scanner.scanUIColor() }
            .apply { (view: UIView, value) in view.layer.borderColor = value.CGColor }
        $0.register("borderRadius") { scanner -> CGFloat in try scanner.scanCGFloat() }
            .apply { (view: UIView, value) in view.layer.cornerRadius = value }
        $0.register("borderWidth") { scanner -> CGFloat in try scanner.scanCGFloat() }
            .apply { (view: UIView, value) in view.layer.borderWidth = value }

        $0.register("clipsToBounds") { scanner -> Bool in try scanner.scanBool() }
            .apply { (view: UIView, value) in view.clipsToBounds = value }
        $0.register("contentMode") { scanner -> UIViewContentMode in try scanner.scanUIViewContentMode() }
            .apply { (view: UIView, value) in view.contentMode = value }

        $0.register("hidden") { scanner -> Bool in try scanner.scanBool() }
            .apply { (view: UIView, value) in view.hidden = value }

        $0.register("masksToBounds") { scanner -> Bool in try scanner.scanBool() }
            .apply { (view: UIView, value) in view.layer.masksToBounds = value }

        $0.register("opacity") { scanner -> CGFloat in try scanner.scanCGFloat() }
            .apply { (view: UIView, value) in view.alpha = min(max(value, 0), 1) }
        $0.register("opaque") { scanner -> Bool in try scanner.scanBool() }
            .apply { (view: UIView, value) in view.opaque = value }

        $0.register("shadowColor") { scanner -> UIColor in try scanner.scanUIColor() }
            .apply { (view: UIView, value) in view.layer.shadowColor = value.CGColor }
        $0.register("shadowOffset") { scanner -> CGSize in try scanner.scanCGSize() }
            .apply { (view: UIView, value) in view.layer.shadowOffset = value }
        $0.register("shadowOpacity") { scanner -> CGFloat in try scanner.scanCGFloat() }
            .apply { (view: UIView, value) in view.stage_setShadowOpacity(value) }
        $0.register("shadowRadius") { scanner -> CGFloat in try scanner.scanCGFloat() }
            .apply { (view: UIView, value) in view.stage_setShadowRadius(value) }

        $0.register("tintColor") { scanner -> UIColor in try scanner.scanUIColor() }
            .apply { (view: UIView, value) in view.tintColor = value }

        $0.register("userInteractionEnabled") { scanner -> Bool in try scanner.scanBool() }
            .apply { (view: UIView, value) in view.hidden = value }

        // Layout properties
        $0.register("autoresize") { scanner -> UIViewAutoresizing in try scanner.scanUIViewAutoresizing() }
            .apply { (view: UIView, value) in view.autoresizingMask = value }

        $0.register("constrainToSuperviewEdges") { scanner -> Bool in try scanner.scanBool() }
            .apply { (view: UIView, value) in view.translatesAutoresizingMaskIntoConstraints = false }
            .apply { (view: UIView, value, context) in if (value) { view.constrainToSuperviewEdges() } }

        $0.register("horizontalCompressionResistance") { scanner -> UILayoutPriority in try scanner.scanFloat() }
            .apply { (view: UIView, value) in view.setContentCompressionResistancePriority(value, forAxis:.Vertical) }
        $0.register("horizontalContentHuggingPriority") { scanner -> UILayoutPriority in try scanner.scanFloat() }
            .apply { (view: UIView, value) in view.setContentHuggingPriority(value, forAxis:.Horizontal) }

        $0.register("layoutAttributes") { scanner -> [StageLayoutConstraint] in try scanner.scanStageLayoutConstraints() }
            .apply { (view: UIView, value) in view.translatesAutoresizingMaskIntoConstraints = false }
            .apply { (view: UIView, value, context) in
                let autoLayoutConstraints = value.flatMap { constraint -> NSLayoutConstraint? in
                    guard let targetText = constraint.target where !targetText.isEmpty else {
                        return NSLayoutConstraint(item: view, attribute: constraint.attribute, relatedBy: constraint.relation, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: constraint.constant)
                    }
                    var target = try? context.view(named: targetText) as UIView
                    if target == nil {
                        switch targetText {
                        case "superview": target = view.superview
                        case "self": target = view
                        default: break
                        }
                    }
                    if target == nil {
                        print("Ignoring layout constraint, because \(targetText) is not a valid target name")
                        return nil
                    } else if view.commonSuperview(with: target!) == nil {
                        print("Ignoring layout constraint, because \(targetText) does not have a common superview")
                        return nil
                    }
                    return NSLayoutConstraint(item: view, attribute: constraint.attribute,
                        relatedBy: constraint.relation,
                        toItem: target!, attribute: constraint.targetAttribute,
                        multiplier: constraint.multiplier, constant: constraint.constant)
                }
                NSLayoutConstraint.activateConstraints(autoLayoutConstraints)
        }

        $0.register("translatesAutoresizingMaskIntoConstraints") { scanner -> Bool in try scanner.scanBool() }
            .apply { (view: UIView, value) in view.translatesAutoresizingMaskIntoConstraints = value }

        $0.register("verticalCompressionResistance") { scanner -> UILayoutPriority in try scanner.scanFloat() }
            .apply { (view: UIView, value) in view.setContentCompressionResistancePriority(value, forAxis:.Vertical) }
        $0.register("verticalContentHuggingPriority") { scanner -> UILayoutPriority in try scanner.scanFloat() }
            .apply { (view: UIView, value) in view.setContentHuggingPriority(value, forAxis:.Horizontal) }
    }
}()
public extension UIView {
    public dynamic class func stagePropertyRegistration() -> StagePropertyRegistration { return UIView_propertyTable }
}
