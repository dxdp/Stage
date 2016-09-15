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

public extension StageRegister {
    public class func View(_ registration: StagePropertyRegistration) {
        tap(registration) {
            $0.register("alpha") { scanner in try scanner.scanCGFloat() }
                .apply { (view: UIView, value) in view.alpha = min(max(value, 0), 1) }

            $0.register("backgroundColor") { scanner in try UIColor.create(using: scanner) }
                .apply { (view: UIView, value) in view.backgroundColor = value }

            $0.register("borderColor") { scanner in try UIColor.create(using: scanner) }
                .apply { (view: UIView, value) in view.layer.borderColor = value.cgColor }
            $0.register("borderRadius") { scanner in try scanner.scanCGFloat() }
                .apply { (view: UIView, value) in view.layer.cornerRadius = value }
            $0.register("borderWidth") { scanner in try scanner.scanCGFloat() }
                .apply { (view: UIView, value) in view.layer.borderWidth = value }

            $0.register("clipsToBounds") { scanner in try scanner.scanBool() }
                .apply { (view: UIView, value) in view.clipsToBounds = value }
            $0.register("contentMode") { scanner in try UIViewContentMode.create(using: scanner) }
                .apply { (view: UIView, value) in view.contentMode = value }

            $0.register("hidden") { scanner in try scanner.scanBool() }
                .apply { (view: UIView, value) in view.isHidden = value }

            $0.register("masksToBounds") { scanner in try scanner.scanBool() }
                .apply { (view: UIView, value) in view.layer.masksToBounds = value }

            $0.register("opacity") { scanner in try scanner.scanCGFloat() }
                .apply { (view: UIView, value) in view.alpha = min(max(value, 0), 1) }
            $0.register("opaque") { scanner in try scanner.scanBool() }
                .apply { (view: UIView, value) in view.isOpaque = value }

            $0.register("shadowColor") { scanner in try UIColor.create(using: scanner) }
                .apply { (view: UIView, value) in view.layer.shadowColor = value.cgColor }
            $0.register("shadowOffset") { scanner in try CGSize.create(using: scanner) }
                .apply { (view: UIView, value) in view.layer.shadowOffset = value }
            $0.register("shadowOpacity") { scanner in try scanner.scanCGFloat() }
                .apply { (view: UIView, value) in view.stage_setShadowOpacity(value) }
            $0.register("shadowRadius") { scanner in try scanner.scanCGFloat() }
                .apply { (view: UIView, value) in view.stage_setShadowRadius(value) }

            $0.register("tintColor") { scanner in try UIColor.create(using: scanner) }
                .apply { (view: UIView, value) in view.tintColor = value }

            $0.register("userInteractionEnabled") { scanner in try scanner.scanBool() }
                .apply { (view: UIView, value) in view.isHidden = value }

            // Layout properties
            $0.register("autoresize") { scanner in try UIViewAutoresizing.create(using: scanner) }
                .apply { (view: UIView, value) in view.autoresizingMask = value }

            $0.register("constrainToSuperviewEdges") { scanner in try scanner.scanBool() }
                .apply { (view: UIView, value) in view.translatesAutoresizingMaskIntoConstraints = false }
                .apply { (view: UIView, value, context) in if (value) { view.constrainToSuperviewEdges() } }

            $0.register("horizontalCompressionResistance") { scanner in try scanner.scanFloat() }
                .apply { (view: UIView, value) in view.setContentCompressionResistancePriority(value, for: .horizontal) }
            $0.register("horizontalContentHuggingPriority") { scanner in try scanner.scanFloat() }
                .apply { (view: UIView, value) in view.setContentHuggingPriority(value, for: .horizontal) }

            $0.register("layoutAttributes") { scanner in try scanner.scanStageLayoutConstraints() }
                .apply { (view: UIView, value) in view.translatesAutoresizingMaskIntoConstraints = false }
                .apply { (view: UIView, value, context) in
                    let autoLayoutConstraints = value.flatMap { constraint -> NSLayoutConstraint? in
                        guard let targetText = constraint.target , !targetText.isEmpty else {
                            return NSLayoutConstraint(item: view, attribute: constraint.attribute, relatedBy: constraint.relation, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: constraint.constant)
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
                    NSLayoutConstraint.activate(autoLayoutConstraints)
            }

            $0.register("layoutMargins") { scanner in try UIEdgeInsets.create(using: scanner) }
                .apply { (view: UIView, value) in
                    view.layoutMargins = value
                    view.superview?.setNeedsUpdateConstraints()
            }

            $0.register("translatesAutoresizingMaskIntoConstraints") { scanner in try scanner.scanBool() }
                .apply { (view: UIView, value) in view.translatesAutoresizingMaskIntoConstraints = value }

            $0.register("verticalCompressionResistance") { scanner in try scanner.scanFloat() }
                .apply { (view: UIView, value) in view.setContentCompressionResistancePriority(value, for: .vertical) }
            $0.register("verticalContentHuggingPriority") { scanner in try scanner.scanFloat() }
                .apply { (view: UIView, value) in view.setContentHuggingPriority(value, for: .vertical) }
        }
    }
}
