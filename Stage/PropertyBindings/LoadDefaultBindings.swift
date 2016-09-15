//
//  LoadDefaultBindings.swift
//  Stage
//
//  Created by David Parton on 9/15/16.
//  Copyright © 2016 deep. All rights reserved.
//

import Foundation
import MapKit

public class StageRegister {
}

public extension StageRegister {
    public final class func LoadDefaults(_ types: PropertyRegistrar) {
        let defaults = [(StageRegister.View,            UIView.self),
                        (StageRegister.TextView,        UITextView.self),
                        (StageRegister.TextField,       UITextField.self),
                        (StageRegister.Switch,          UISwitch.self),
                        (StageRegister.SegmentControl,  UISegmentedControl.self),
                        (StageRegister.ScrollView,      UIScrollView.self),
                        (StageRegister.Label,           UILabel.self),
                        (StageRegister.Image,           UIImageView.self),
                        (StageRegister.Button,          UIButton.self),
                        (StageRegister.ActivityIndicatorView, UIActivityIndicatorView.self),
                        (StageRegister.MapView,         MKMapView.self),
                        //
                        (StageRegister.stgStackingView, StackingView.self)]
        
        defaults.forEach { types.register(type: $0.1, registration: $0.0) }
    }
}
