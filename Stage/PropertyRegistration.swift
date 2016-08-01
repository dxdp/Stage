//
//  PropertyRegistration.swift
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

typealias TypelessScanFunction = StageRuleScanner throws -> Any
typealias TypelessApplyFunction = (view: UIView, value: Any) throws -> ()
typealias TypelessApplyWithContextFunction = (view: UIView, value: Any, context: StageLiveContext) throws -> ()

enum PropertySetPass {
    case ViewConstruction
    case TreeConstruction(context: StageLiveContext)
}

protocol StageConverter {
    func execute(scanner: StageRuleScanner, view: UIView, pass: PropertySetPass) throws
}

class StagePropertyConverter<T: Any, ViewType: UIView>: StageConverter {
    typealias SelfType = StagePropertyConverter<T, ViewType>
    typealias ScanFunction = StageRuleScanner throws -> T
    typealias ApplyFunction = (view: ViewType, value: T) throws -> ()
    typealias ApplyWithContextFunction = (view: ViewType, value: T, context: StageLiveContext) throws -> ()

    let name: String
    let scanFunction: ScanFunction
    weak var registration: StagePropertyRegistration?
    var handlers: (
        scan: TypelessScanFunction,
        apply: TypelessApplyFunction,
        applyWithContext: TypelessApplyWithContextFunction
    )?
    init(registration: StagePropertyRegistration, name: String, scan: ScanFunction) {
        self.name = name
        self.scanFunction = scan
        self.registration = registration
    }

    lazy var boxingScan: TypelessScanFunction = {
        let boxingScan: TypelessScanFunction = { scanner -> Any in
            return try self.scanFunction(scanner)
        }
        return boxingScan
    }()
    func apply(function: ApplyFunction) -> SelfType {
        let boxingApply: TypelessApplyFunction = { view, value in
            if let view = view as? ViewType, let value = value as? T {
                try function(view: view, value: value)
            }
        }
        let boxingApplyWithContext: TypelessApplyWithContextFunction = { view, value, context in }
        let applyWithContext = handlers != nil ? handlers!.applyWithContext : boxingApplyWithContext
        handlers = (
            scan: boxingScan,
            apply: boxingApply,
            applyWithContext: applyWithContext)
        registration?.converters[name] = self
        return self
    }
    func apply(function: ApplyWithContextFunction) -> SelfType {
        let boxingApplyWithContext: TypelessApplyWithContextFunction = { view, value, context in
            if let view = view as? ViewType, let value = value as? T {
                try function(view: view, value: value, context: context)
            }
        }
        let boxingApply: TypelessApplyFunction = { view, value in }
        let apply = handlers != nil ? handlers!.apply : boxingApply
        handlers = (
            scan: boxingScan,
            apply: apply,
            applyWithContext: boxingApplyWithContext
        )
        registration?.converters[name] = self
        return self
    }

    func execute(scanner: StageRuleScanner, view: UIView, pass: PropertySetPass) throws {
        if let (scan, apply, applyWithContext) = handlers {
            let value = try scan(scanner)
            switch pass {
            case .ViewConstruction:
                try apply(view: view, value: value)
            case .TreeConstruction(let context):
                try applyWithContext(view: view, value: value, context: context)
            }
        }
    }
}

@objc public class StagePropertyRegistration: NSObject {
    var converters = [String: StageConverter]()

    @nonobjc func register<T: Any, ViewType: UIView>(name: String, block: StageRuleScanner throws -> T) -> StagePropertyConverter<T, ViewType> {
        return StagePropertyConverter(registration: self, name: name, scan: block)
    }

    @nonobjc func receive(property name: String, scanner: StageRuleScanner, view: UIView, pass: PropertySetPass) throws {
        guard let converter = converters[name] else {
            throw StageException.UnhandledProperty(message: "No setter defined for property '\(name)' on type \(view.dynamicType)")
        }
        try converter.execute(scanner, view: view, pass: pass)
    }
}
