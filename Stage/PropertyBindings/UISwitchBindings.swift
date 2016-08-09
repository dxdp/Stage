//
//  UISwitchBindings.swift
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
        $0.register("on") { scanner in try scanner.scanBool() }
            .apply { (view: UISwitch, value) in view.on = value }

        // Images
        $0.register("onImage") { scanner in scanner.string.trimmed() }
            .apply { (view: UISwitch, value) in
                guard let url = NSURL(string: value) else {
                    view.onImage = UIImage(named: value)
                    return
                }
                let task = NSURLSession.sharedSession().dataTaskWithRequest(NSURLRequest(URL: url)) { [weak view] data, _, _ in
                    if let data = data {
                        view?.onImage = UIImage(data: data, scale: 0)
                    }
                }
                task.resume()
                view.onDeallocation { [weak task] in
                    if let state = task?.state where state == .Suspended || state == .Running {
                        task?.cancel()
                    }
                }
        }
        $0.register("offImage") { scanner in scanner.string.trimmed() }
            .apply { (view: UISwitch, value) in
                guard let url = NSURL(string: value) else {
                    view.onImage = UIImage(named: value)
                    return
                }
                let task = NSURLSession.sharedSession().dataTaskWithRequest(NSURLRequest(URL: url)) { [weak view] data, response, error in
                    if let data = data {
                        view?.onImage = UIImage(data: data, scale: 0)
                    }
                }
                task.resume()
                view.onDeallocation { [weak task] in
                    if let state = task?.state where state == .Suspended || state == .Running {
                        task?.cancel()
                    }
                }
        }

        // Tint Colors
        $0.register("tintColor") { scanner in try UIColor.create(using: scanner) }
            .apply { (view: UISwitch, value) in view.tintColor = value }
        $0.register("onTintColor") { scanner in try UIColor.create(using: scanner) }
            .apply { (view: UISwitch, value) in view.onTintColor = value }
        $0.register("thumbTintColor") { scanner in try UIColor.create(using: scanner) }
            .apply { (view: UISwitch, value) in view.thumbTintColor = value }
    }
}()
public extension UISwitch {
    public override dynamic class func stagePropertyRegistration() -> StagePropertyRegistration { return propertyTable }
}
