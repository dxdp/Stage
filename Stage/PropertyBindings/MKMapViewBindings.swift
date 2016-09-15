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

public extension StageRegister {
    public class func MapView(_ registration: StagePropertyRegistration) {
        tap(registration) {
            $0.registerBool("pitchEnabled")
                .apply { (view: MKMapView, value) in view.isPitchEnabled = value }
            $0.registerBool("rotateEnabled")
                .apply { (view: MKMapView, value) in view.isRotateEnabled = value }
            $0.registerBool("scrollEnabled")
                .apply { (view: MKMapView, value) in view.isScrollEnabled = value }
            $0.registerBool("zoomEnabled")
                .apply { (view: MKMapView, value) in view.isZoomEnabled = value }
            
            $0.registerBool("showsPointsOfInterest")
                .apply { (view: MKMapView, value) in view.showsPointsOfInterest = value }
            $0.registerBool("showsBuildings")
                .apply { (view: MKMapView, value) in view.showsBuildings = value }
            $0.registerBool("showsUserLocation")
                .apply { (view: MKMapView, value) in view.showsUserLocation = value }
            
            $0.register("mapType") { scanner in try MKMapType.create(using: scanner) }
                .apply { (view: MKMapView, value) in view.mapType = value }
        }
    }
}
