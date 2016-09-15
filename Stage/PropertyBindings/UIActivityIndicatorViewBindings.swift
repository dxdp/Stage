//
//  UIActivityIndicatorViewBindings.swift
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
    public class func ActivityIndicatorView(_ registration: StagePropertyRegistration) {
        tap(registration) {
            $0.register("activityIndicatorViewStyle") { scanner in try UIActivityIndicatorViewStyle.create(using: scanner) }
                .apply { (view: UIActivityIndicatorView, value) in view.activityIndicatorViewStyle = value }
            $0.register("color") { scanner in try UIColor.create(using: scanner) }
                .apply { (view: UIActivityIndicatorView, value) in view.color = value }
            
            $0.register("hidesWhenStopped") { scanner in try scanner.scanBool() }
                .apply { (view: UIActivityIndicatorView, value) in view.hidesWhenStopped = value }
            $0.register("startsWhenShown") { scanner in try scanner.scanBool() }
                .apply { (view: UIActivityIndicatorView, value) in
                    view.stageState.startsWhenShown = value
                    if !view.isHidden && !view.isAnimating { view.startAnimating() }
            }
        }
    }
}
public extension UIActivityIndicatorView {
    @objc class UIActivityIndicatorViewStageState: NSObject {
        static var AssociationKey = 0
        weak var owner: UIActivityIndicatorView?
        var startsWhenShown: Bool = false
        
        init(owner: UIActivityIndicatorView) {
            super.init()
            self.owner = owner
            StageSafeKVO.observer(self, watchKey: "hidden", in: owner) { [weak self] _, _, _ in
                guard let this = self, let owner = this.owner else { return }
                if !owner.isHidden && !owner.isAnimating && this.startsWhenShown {
                    owner.startAnimating()
                }
            }
        }
    }
    
    var stageState : UIActivityIndicatorViewStageState {
        if let state = associatedObject(key: &UIActivityIndicatorViewStageState.AssociationKey) as? UIActivityIndicatorViewStageState { return state }
        let state = UIActivityIndicatorViewStageState(owner: self)
        associateObject(state, key: &UIActivityIndicatorViewStageState.AssociationKey, policy: .RetainNonatomic)
        return state
    }
}
