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

public extension StageRegister {
    public class func TextField(_ registration: StagePropertyRegistration) {
        tap(registration) {
            $0.registerBool("adjustsFontSizeToFitWidth") 
                .apply { (view: UITextField, value) in view.adjustsFontSizeToFitWidth = value }
            $0.register("font") { scanner in try UIFont.create(using: scanner, defaultPointSize: 14) }
                .apply { (view: UITextField, value) in view.font = value }
            $0.registerCGFloat("minimumFontSize") 
                .apply { (view: UITextField, value) in view.minimumFontSize = value }
            
            $0.registerBool("clearsOnBeginEditing") 
                .apply { (view: UITextField, value) in view.clearsOnBeginEditing = value }
            
            $0.register("keyboardType") { scanner in try UIKeyboardType.create(using: scanner) }
                .apply { (view: UITextField, value) in view.keyboardType = value }
            
            $0.register("placeholder") { scanner in scanner.scanLinesTrimmed().joined(separator: "\n") }
                .apply { (view: UITextField, value) in view.placeholder = value }
            
            $0.registerBool("secureTextEntry") 
                .apply { (view: UITextField, value) in view.isSecureTextEntry = value }
            
            $0.register("text") { scanner in scanner.scanLinesTrimmed().joined(separator: "\n") }
                .apply { (view: UITextField, value) in view.text = value }
            $0.register("textAlignment") { scanner in try NSTextAlignment.create(using: scanner) }
                .apply { (view: UITextField, value) in view.textAlignment = value }
            $0.registerColor("textColor") 
                .apply { (view: UITextField, value) in view.textColor = value }
            
            $0.register("clearButtonMode") { scanner in try UITextFieldViewMode.create(using: scanner) }
                .apply { (view: UITextField, value) in view.clearButtonMode = value }
            $0.register("leftViewMode") { scanner in try UITextFieldViewMode.create(using: scanner) }
                .apply { (view: UITextField, value) in view.leftViewMode = value }
            $0.register("rightViewMode") { scanner in try UITextFieldViewMode.create(using: scanner) }
                .apply { (view: UITextField, value) in view.rightViewMode = value }
            
            
            $0.register("inputAccessoryView") { scanner in scanner.string.trimmed() }
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
                    DispatchQueue.main.async {
                        let size = accessoryView.systemLayoutSizeFitting(UIScreen.main.bounds.size)
                        let frame = accessoryView.frame
                        accessoryView.frame = CGRect(origin: frame.origin, size: size)
                    }
            }
            
        }
    }
}
