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

public extension StageRegister {
    public class func Switch(_ registration: StagePropertyRegistration) {
        tap(registration) {
            $0.registerBool("on") 
                .apply { (view: UISwitch, value) in view.isOn = value }

            // Images
            $0.register("onImage") { scanner in scanner.string.trimmed() }
                .apply { (view: UISwitch, value) in
                    guard let url = URL(string: value) else {
                        view.onImage = UIImage(named: value)
                        return
                    }
                    let task = URLSession.shared.dataTask(with: URLRequest(url: url), completionHandler: { [weak view] data, _, _ in
                        if let data = data {
                            view?.onImage = UIImage(data: data, scale: 0)
                        }
                    }) 
                    task.resume()
                    view.onDeallocation { [weak task] in
                        if let state = task?.state , state == .suspended || state == .running {
                            task?.cancel()
                        }
                    }
            }
            $0.register("offImage") { scanner in scanner.string.trimmed() }
                .apply { (view: UISwitch, value) in
                    guard let url = URL(string: value) else {
                        view.offImage = UIImage(named: value)
                        return
                    }
                    let task = URLSession.shared.dataTask(with: URLRequest(url: url), completionHandler: { [weak view] data, response, error in
                        if let data = data {
                            view?.offImage = UIImage(data: data, scale: 0)
                        }
                    }) 
                    task.resume()
                    view.onDeallocation { [weak task] in
                        if let state = task?.state , state == .suspended || state == .running {
                            task?.cancel()
                        }
                    }
            }

            // Tint Colors
            $0.registerColor("tintColor") 
                .apply { (view: UISwitch, value) in view.tintColor = value }
            $0.registerColor("onTintColor") 
                .apply { (view: UISwitch, value) in view.onTintColor = value }
            $0.registerColor("thumbTintColor") 
                .apply { (view: UISwitch, value) in view.thumbTintColor = value }
        }
    }
}
