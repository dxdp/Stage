//
//  StackingViewBindings.swift
//  Stage
//
//  Created by David Parton on 8/4/16.
//  Copyright © 2016 deep. All rights reserved.
//

import Foundation

private var propertyTable = {
    tap(StagePropertyRegistration()) {
        $0.register("contentInset") { scanner -> UIEdgeInsets in try scanner.scanUIEdgeInsets() }
            .apply { (view: StackingView, value) in view.contentInset = value }

        $0.register("spacing") { scanner -> CGFloat in try scanner.scanCGFloat() }
            .apply { (view: StackingView, value) in view.spacing = value }


        $0.register("stackingDirection") { scanner -> () in }
            .apply { (view: StackingView, value) in }
    }
}()
public extension StackingView {
    public override dynamic class func stagePropertyRegistration() -> StagePropertyRegistration { return propertyTable }
}
