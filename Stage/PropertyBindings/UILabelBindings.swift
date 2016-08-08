//
//  UILabelBindings.swift
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
        let LongLived = $0
        $0.register("font") { scanner in try UIFont.create(using: scanner, defaultPointSize: 14) }
            .apply { (view: UILabel, value) in view.font = value }
        $0.register("lineBreakMode") { scanner in try NSLineBreakMode.create(using: scanner) }
            .apply { (view: UILabel, value) in view.lineBreakMode = value }
        $0.register("numberOfLines") { scanner in try scanner.scanInt() }
            .apply { (view: UILabel, value) in view.numberOfLines = value }
        $0.register("text") { scanner in scanner.string.trimmed() }
            .apply { (view: UILabel, value) in view.text = value }
        $0.register("textAlignment") { scanner in try NSTextAlignment.create(using: scanner) }
            .apply { (view: UILabel, value) in
                guard value == .Justified else {
                    view.textAlignment = value
                    return
                }
                StageSafeKVO.observer(LongLived, watchKey: "text", inObject: view) { object, _, _ in
                    var paragraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
                    paragraphStyle.alignment = value
                    let attributes = [ NSParagraphStyleAttributeName: paragraphStyle,
                        NSBaselineOffsetAttributeName: 0]
                    let attributedText = NSAttributedString(string: view.text ?? "", attributes: attributes)
                    view.attributedText = attributedText
                }
        }
        $0.register("textColor") { scanner in try UIColor.create(using: scanner) }
            .apply { (view: UILabel, value) in view.textColor = value }
    }
}()
public extension UILabel {
    public override dynamic class func stagePropertyRegistration() -> StagePropertyRegistration { return propertyTable }
}
