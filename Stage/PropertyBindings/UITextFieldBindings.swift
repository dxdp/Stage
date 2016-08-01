//
//  UITextFieldBindings.swift
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
        $0.register("adjustsFontSizeToFitWidth") { scanner -> Bool in try scanner.scanBool() }
            .apply { (view: UITextField, value) in view.adjustsFontSizeToFitWidth = value }
        $0.register("font") { scanner -> UIFont in try scanner.scanUIFont(defaultPointSize: 14) }
            .apply { (view: UITextField, value) in view.font = value }
        $0.register("minimumFontSize") { scanner -> CGFloat in try scanner.scanCGFloat() }
            .apply { (view: UITextField, value) in view.minimumFontSize = value }

        $0.register("clearsOnBeginEditing") { scanner -> Bool in try scanner.scanBool() }
            .apply { (view: UITextField, value) in view.clearsOnBeginEditing = value }

        $0.register("keyboardType") { scanner -> UIKeyboardType in try scanner.scanUIKeyboardType() }
            .apply { (view: UITextField, value) in view.keyboardType = value }

        $0.register("placeholder") { scanner -> String in scanner.scanLinesTrimmed().joinWithSeparator("\n") }
            .apply { (view: UITextField, value) in view.placeholder = value }

        $0.register("secureTextEntry") { scanner -> Bool in try scanner.scanBool() }
            .apply { (view: UITextField, value) in view.secureTextEntry = value }

        $0.register("text") { scanner -> String in scanner.scanLinesTrimmed().joinWithSeparator("\n") }
            .apply { (view: UITextField, value) in view.text = value }
        $0.register("textAlignment") { scanner -> NSTextAlignment in try scanner.scanNSTextAlignment() }
            .apply { (view: UITextField, value) in view.textAlignment = value }
        $0.register("textColor") { scanner -> UIColor in try scanner.scanUIColor() }
            .apply { (view: UITextField, value) in view.textColor = value }

        $0.register("clearButtonMode") { scanner -> UITextFieldViewMode in try scanner.scanUITextFieldViewMode() }
            .apply { (view: UITextField, value) in view.clearButtonMode = value }
        $0.register("leftViewMode") { scanner -> UITextFieldViewMode in try scanner.scanUITextFieldViewMode() }
            .apply { (view: UITextField, value) in view.leftViewMode = value }
        $0.register("rightViewMode") { scanner -> UITextFieldViewMode in try scanner.scanUITextFieldViewMode() }
            .apply { (view: UITextField, value) in view.rightViewMode = value }


        $0.register("inputAccessoryView") { scanner -> String in scanner.string.trimmed() }
            .apply { (view: UITextField, value, context) in
                guard let accessoryView = try? context.view(named: value) else {
                    print("Warning. inputAccessoryView '\(value)' for UITextField not present in the StageLiveContext")
                    return
                }
                if let superview = accessoryView.superview {
                    accessoryView.removeFromSuperview()
                    superview.setNeedsUpdateConstraints()
                }
                view.inputAccessoryView = accessoryView
                dispatch_async(dispatch_get_main_queue()) {
                    let size = accessoryView.systemLayoutSizeFittingSize(UIScreen.mainScreen().bounds.size)
                    let frame = accessoryView.frame
                    accessoryView.frame = CGRect(origin: frame.origin, size: size)
                }
        }

    }

}()
public extension UITextField {
    public override dynamic class func stagePropertyRegistration() -> StagePropertyRegistration { return propertyTable }
}
