//
//  PropertyRegistrar.swift
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

import UIKit

open class PropertyRegistrar {
    var table: [String: StagePropertyRegistration] = [:]

    public typealias RegistrationFunction = (StagePropertyRegistration) -> ()
    open func register<ViewType: UIView>(type: ViewType.Type = ViewType.self, registration: @escaping RegistrationFunction) {
        let key = "\(type.self)"
        if let existing = table[key] {
            registration(existing)
        } else {
            let new = StagePropertyRegistration()
            registration(new)
            table[key] = new
        }
    }
    
    open func registry<ViewType: UIView>(for view: ViewType) -> [StagePropertyRegistration] {
        var type: AnyClass? = type(of: view)//ViewType.self
        var registry = [StagePropertyRegistration]()
        while type != nil {
            let key = "\(type!.self)"
            if let existing = table[key] {
                registry.append(existing)
            }
            type = type!.superclass()
        }
        return registry
    }
}
