//
//  UIButtonBindings.swift
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

private var propertyTable = {
    return tap(StagePropertyRegistration()) {
        // Insets
        $0.register("contentEdgeInsets") { scanner in try UIEdgeInsets.create(using: scanner) }
            .apply { (view: UIButton, value) in view.contentEdgeInsets = value }
        $0.register("titleEdgeInsets") { scanner in try UIEdgeInsets.create(using: scanner) }
            .apply { (view: UIButton, value) in view.titleEdgeInsets = value }
        $0.register("imageEdgeInsets") { scanner in try UIEdgeInsets.create(using: scanner) }
            .apply { (view: UIButton, value) in view.imageEdgeInsets = value }

        // State -> Drawing behavior flags
        $0.register("adjustsImageWhenDisabled") { scanner in try scanner.scanBool() }
            .apply { (view: UIButton, value) in view.adjustsImageWhenDisabled = value }
        $0.register("adjustsImageWhenHighlighted") { scanner in try scanner.scanBool() }
            .apply { (view: UIButton, value) in view.adjustsImageWhenHighlighted = value }
        $0.register("reversesTitleShadowWhenHighlighted") { scanner in try scanner.scanBool() }
            .apply { (view: UIButton, value) in view.reversesTitleShadowWhenHighlighted = value }
        $0.register("showsTouchWhenHighlighted") { scanner in try scanner.scanBool() }
            .apply { (view: UIButton, value) in view.showsTouchWhenHighlighted = value }

        // State images
        $0.register("normalImage") { scanner in scanner.string.trimmed() }
            .apply { (view: UIButton, value) in view.stageState.normalImage = UIImage(named: value) }
        $0.register("highlightImage") { scanner in scanner.string.trimmed() }
            .apply { (view: UIButton, value) in view.stageState.highlightImage = UIImage(named: value) }

        // Background
        $0.register("highlightBackgroundColor") { scanner in try UIColor.create(using: scanner) }
            .apply { (view: UIButton, value) in view.stageState.highlightBackgroundColor = value }

        // Tint colors
        $0.register("normalImageTintColor") { scanner in try UIColor.create(using: scanner) }
            .apply { (view: UIButton, value) in view.stageState.normalImageTintColor = value }
        $0.register("highlightImageTintColor") { scanner in try UIColor.create(using: scanner) }
            .apply { (view: UIButton, value) in view.stageState.highlightImageTintColor = value }

        // Label
        $0.register("font") { scanner in try UIFont.create(using: scanner, defaultPointSize: 14) }
            .apply { (view: UIButton, value) in view.titleLabel?.font = value }
        $0.register("textAlignment") { scanner in try UIControlContentHorizontalAlignment.create(using: scanner) }
            .apply { (view: UIButton, value) in view.contentHorizontalAlignment = value }

        $0.register("text") { scanner in scanner.string.trimmed() }
            .apply { (view: UIButton, value) in view.stageState.text = value }
        $0.register("highlightText") { scanner in scanner.string.trimmed() }
            .apply { (view: UIButton, value) in view.stageState.highlightText = value }

        $0.register("textColor") { scanner in try UIColor.create(using: scanner) }
            .apply { (view: UIButton, value) in view.stageState.textColor = value }
        $0.register("highlightTextColor") { scanner in try UIColor.create(using: scanner) }
            .apply { (view: UIButton, value) in view.stageState.highlightTextColor = value }

        $0.register("underlineText") { scanner in try scanner.scanBool() }
            .apply { (view: UIButton, value) in view.stageState.underlineText = value }

    }
}()
public extension UIButton {
    @objc class UIButtonStageState: NSObject {
        static var AssociationKey = 0
        weak var owner: UIButton?

        var underlineText: Bool = false {
            didSet {
                updateAttributedString()
            }
        }
        var normalImageTintColor: UIColor? {
            didSet {
                guard let button = owner, let color = normalImageTintColor else { return }
                button.setImage(normalImage.copyWithTint(color), forState: .Normal)
                button.setNeedsLayout()
            }
        }
        var highlightImageTintColor: UIColor? {
            didSet {
                guard let button = owner, let color = highlightImageTintColor else { return }
                let image = highlightImage ?? normalImage
                let tintedImage = image?.copyWithTint(color)
                button.setImage(tintedImage, forState: .Highlighted)
                button.setImage(tintedImage, forState: .Selected)
            }
        }
        private var _normalImage: UIImage?
        var normalImage: UIImage! {
            get {
                if _normalImage == nil { _normalImage = UIImage() }
                return _normalImage
            }
            set {
                guard let button = owner else { return }
                _normalImage = newValue
                var image = normalImage
                if let normalTint = normalImageTintColor {
                    image = image?.copyWithTint(normalTint)
                }
                button.setImage(image, forState: .Normal)
                if highlightImage == nil && highlightImageTintColor != nil {
                    image = normalImage?.copyWithTint(highlightImageTintColor!)
                    button.setImage(image, forState: .Highlighted)
                    button.setImage(image, forState: .Selected)
                }
                button.setNeedsLayout()
            }
        }
        var highlightImage: UIImage? {
            didSet {
                guard let button = owner else { return }
                if _normalImage == nil {
                    let clearImage = UIImage(color: .clearColor(), size: CGSizeMake(1,1))
                    normalImage = clearImage
                    button.setImage(clearImage, forState: .Normal)
                }

                var image = highlightImage
                if let highlightTint = highlightImageTintColor {
                    image = image?.copyWithTint(highlightTint)
                }
                button.setImage(image, forState: .Highlighted)
                button.setImage(image, forState: .Selected)
                button.setNeedsLayout()
            }
        }
        var text: String = "" {
            didSet {
                guard let button = owner else { return }
                button.setTitle(text, forState: .Normal)
                updateAttributedString()
                button.setNeedsLayout()
            }
        }
        var highlightText: String? {
            didSet {
                guard let button = owner, let text = highlightText else { return }
                button.setTitle(text, forState: .Highlighted)
                button.setTitle(text, forState: .Selected)
                updateAttributedString()
                button.setNeedsLayout()
            }
        }
        var textColor: UIColor? {
            didSet {
                guard let button = owner else { return }
                button.setTitleColor(textColor, forState: .Normal)
                updateAttributedString()
            }
        }
        var highlightTextColor: UIColor? {
            didSet {
                guard let button = owner else { return }
                button.setTitleColor(highlightTextColor, forState: .Highlighted)
                button.setTitleColor(highlightTextColor, forState: .Selected)
                updateAttributedString()
            }
        }
        var highlightBackgroundColor: UIColor? {
            didSet {
                guard let button = owner, let color = highlightBackgroundColor else { return }
                let image = UIImage(color: color, size: CGSizeMake(1,1))
                button.setBackgroundImage(image, forState: .Highlighted)
                button.setBackgroundImage(image, forState: .Selected)
            }
        }

        init(owner: UIButton) {
            super.init()
            self.owner = owner
        }

        private func updateAttributedString() {
            guard let button = owner else { return }
            let states: [UIControlState] = [.Normal, .Highlighted, .Selected]
            for state in states {
                if let title = button.titleForState(state) {
                    let color = button.titleColorForState(state) ?? .whiteColor()
                    let style = underlineText ? NSUnderlineStyle.StyleSingle : NSUnderlineStyle.StyleNone
                    let attributes: [String: AnyObject] = [
                        NSUnderlineStyleAttributeName: style.rawValue,
                        NSUnderlineColorAttributeName: color,
                        NSForegroundColorAttributeName: color ]
                    let attributedString = NSAttributedString(string: title, attributes: attributes)
                    button.setAttributedTitle(attributedString, forState: state)
                }
            }
        }
    }

    public override dynamic class func stagePropertyRegistration() -> StagePropertyRegistration { return propertyTable }
    var stageState : UIButtonStageState {
        if let state = associatedObject(key: &UIButtonStageState.AssociationKey) as? UIButtonStageState { return state }
        let state = UIButtonStageState(owner: self)
        associateObject(state, key: &UIButtonStageState.AssociationKey, policy: .RetainNonatomic)
        return state
    }
}
