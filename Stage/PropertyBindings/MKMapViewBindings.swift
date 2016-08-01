//
//  MKMapViewBindings.swift
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
import MapKit

private var propertyTable = {
    return tap(StagePropertyRegistration()) {
        $0.register("pitchEnabled") { scanner -> Bool in try scanner.scanBool() }
            .apply { (view: MKMapView, value) in view.pitchEnabled = value }
        $0.register("rotateEnabled") { scanner -> Bool in try scanner.scanBool() }
            .apply { (view: MKMapView, value) in view.rotateEnabled = value }
        $0.register("scrollEnabled") { scanner -> Bool in try scanner.scanBool() }
            .apply { (view: MKMapView, value) in view.scrollEnabled = value }
        $0.register("zoomEnabled") { scanner -> Bool in try scanner.scanBool() }
            .apply { (view: MKMapView, value) in view.zoomEnabled = value }

        $0.register("showsPointsOfInterest") { scanner -> Bool in try scanner.scanBool() }
            .apply { (view: MKMapView, value) in view.showsPointsOfInterest = value }
        $0.register("showsBuildings") { scanner -> Bool in try scanner.scanBool() }
            .apply { (view: MKMapView, value) in view.showsBuildings = value }
        $0.register("showsUserLocation") { scanner -> Bool in try scanner.scanBool() }
            .apply { (view: MKMapView, value) in view.showsUserLocation = value }

        $0.register("mapType") { scanner -> MKMapType in try scanner.scanMKMapType() }
            .apply { (view: MKMapView, value) in view.mapType = value }
    }
}()
public extension MKMapView {
    public override dynamic class func stagePropertyRegistration() -> StagePropertyRegistration { return propertyTable }
}
