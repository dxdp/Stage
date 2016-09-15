//
//  UIImageBindings.swift
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
    public class func Image(_ registration: StagePropertyRegistration) {
        tap(registration) {
            $0.register("image") { scanner in scanner.string.trimmed() }
                .apply { (view: UIImageView, value) in view.stageState.image = UIImage(named: value) }
            $0.registerColor("tintColor") 
                .apply { (view: UIImageView, value) in view.stageState.tintColor = value }
        }
    }
}
public extension UIImageView {
    @objc class UIImageViewStageState: NSObject {
        static var AssociationKey = 0
        weak var owner: UIImageView?

        var tintColor: UIColor? {
            didSet {
                updateImage()
            }
        }
        var image: UIImage? {
            didSet {
                updateImage()
            }
        }

        init(owner: UIImageView) {
            super.init()
            self.owner = owner
        }

        fileprivate func updateImage() {
            guard let view = owner else { return }
            var effectiveImage: UIImage? = image
            if let tint = tintColor {
                effectiveImage = effectiveImage?.copyWithTint(tint)
            }
            view.image = effectiveImage
        }
    }

    var stageState : UIImageViewStageState {
        if let state = associatedObject(key: &UIImageViewStageState.AssociationKey) as? UIImageViewStageState { return state }
        let state = UIImageViewStageState(owner: self)
        associateObject(state, key: &UIImageViewStageState.AssociationKey, policy: .RetainNonatomic)
        return state
    }
}
