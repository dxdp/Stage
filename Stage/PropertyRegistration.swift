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

typealias TypelessScanFunction = (StageRuleScanner) throws -> Any
typealias TypelessApplyFunction = (_ view: UIView, _ value: Any) throws -> ()
typealias TypelessApplyWithContextFunction = (_ view: UIView, _ value: Any, _ context: StageLiveContext) throws -> ()
struct Handlers {
    let scan: TypelessScanFunction
    let apply: TypelessApplyFunction?
    let applyWithContext: TypelessApplyWithContextFunction?

    func with(apply handler: @escaping TypelessApplyFunction) -> Handlers {
        return Handlers(scan: scan, apply: handler, applyWithContext: applyWithContext)
    }
    func with(applyWithContext handler: @escaping TypelessApplyWithContextFunction) -> Handlers {
        return Handlers(scan: scan, apply: apply, applyWithContext: handler)
    }
    var asTuple: (TypelessScanFunction, TypelessApplyFunction?, TypelessApplyWithContextFunction?) {
        return (scan, apply, applyWithContext)
    }
}

public enum PropertySetPass {
    case viewConstruction
    case treeConstruction(context: StageLiveContext)
}

public protocol StageConversionExecutor {
    func execute(_ scanner: StageRuleScanner, view: UIView, pass: PropertySetPass) throws
}
public protocol StageConverter : StageConversionExecutor {
    associatedtype SelfType
    associatedtype ApplyFunction
    associatedtype ApplyWithContextFunction
    func apply(_ function: ApplyFunction) -> SelfType
    func apply(_ function: ApplyWithContextFunction) -> SelfType
}

open class StagePropertyConverter<T: Any, ViewType: UIView>: StageConverter {
    public typealias SelfType = StagePropertyConverter<T, ViewType>
    typealias ScanFunction = (StageRuleScanner) throws -> T
    public typealias ApplyFunction = (_ view: ViewType, _ value: T) throws -> ()
    public typealias ApplyWithContextFunction = (_ view: ViewType, _ value: T, _ context: StageLiveContext) throws -> ()
    
    let name: String
    let scanFunction: ScanFunction
    weak var registration: StagePropertyRegistration?
    var handlers: Handlers
    init(registration: StagePropertyRegistration, name: String, scan: @escaping ScanFunction) {
        self.name = name
        self.scanFunction = scan
        self.registration = registration
        self.handlers = Handlers(scan: scan, apply: nil, applyWithContext: nil)
    }

    lazy var boxingScan: TypelessScanFunction = {
        let boxingScan: TypelessScanFunction = { scanner -> Any in
            return try self.scanFunction(scanner)
        }
        return boxingScan
    }()
    
    @discardableResult
    open func apply(_ function: @escaping ApplyFunction) -> SelfType {
        let boxingApply: TypelessApplyFunction = { view, value in
            if let view = view as? ViewType, let value = value as? T {
                try function(view, value)
            }
        }
        handlers = handlers.with(apply: boxingApply)
        registration?.converters[name] = self
        return self
    }

    @discardableResult
    open func apply(_ function: @escaping ApplyWithContextFunction) -> SelfType {
        let boxingApplyWithContext: TypelessApplyWithContextFunction = { view, value, context in
            if let view = view as? ViewType, let value = value as? T {
                try function(view, value, context)
            }
        }
        handlers = handlers.with(applyWithContext: boxingApplyWithContext)
        registration?.converters[name] = self
        return self
    }

    open func execute(_ scanner: StageRuleScanner, view: UIView, pass: PropertySetPass) throws {
        let (scan, apply, applyWithContext) = handlers.asTuple
        let value = try scan(scanner)
        switch pass {
        case .viewConstruction:
            try apply?(view, value)
        case .treeConstruction(let context):
            try applyWithContext?(view, value, context)
        }
    }
}

open class StagePropertyRegistration {
    var converters = [String: StageConversionExecutor]()

    open func register<T, ViewType:UIView>(_ name: String, block: @escaping (StageRuleScanner) throws -> T) -> StagePropertyConverter<T, ViewType> {
        return StagePropertyConverter<T, ViewType>(registration: self, name: name, scan: block)
    }

    func receive(property name: String, scanner: StageRuleScanner, view: UIView, pass: PropertySetPass) throws {
        guard let converter = converters[name] else {
            throw StageException.unhandledProperty(
                message: "No setter defined for property '\(name)' on type \(type(of: view))",
                line: 0,
                backtrace: [])
        }
        try converter.execute(scanner, view: view, pass: pass)
    }
}

public extension StagePropertyRegistration {
    public func registerBool<ViewType: UIView>(_ name: String) -> StagePropertyConverter<Bool, ViewType> {
        return StagePropertyConverter(registration: self, name: name) { scanner in try scanner.scanBool() }
    }
    public func registerColor<ViewType: UIView>(_ name: String) -> StagePropertyConverter<UIColor, ViewType> {
        return StagePropertyConverter(registration: self, name: name) { scanner in try UIColor.create(using: scanner) }
    }
    public func registerCGFloat<ViewType: UIView>(_ name: String) -> StagePropertyConverter<CGFloat, ViewType> {
        return StagePropertyConverter(registration: self, name: name) { scanner in try scanner.scanCGFloat() }
    }
}
