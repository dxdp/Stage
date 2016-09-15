//
//  UIScrollViewBindings.swift
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
    public class func ScrollView(_ registration: StagePropertyRegistration) {
        tap(registration) {
            $0.register("alwaysBounceHorizontal") { scanner in try scanner.scanBool() }
                .apply { (view: UIScrollView, value) in view.alwaysBounceHorizontal = value }
            $0.register("alwaysBounceVertical") { scanner in try scanner.scanBool() }
                .apply { (view: UIScrollView, value) in view.alwaysBounceVertical = value }
            $0.register("bounces") { scanner in try scanner.scanBool() }
                .apply { (view: UIScrollView, value) in view.bounces = value }
            $0.register("bouncesZoom") { scanner in try scanner.scanBool() }
                .apply { (view: UIScrollView, value) in view.bouncesZoom = value }
            
            $0.register("minimumZoomScale") { scanner in try scanner.scanCGFloat() }
                .apply { (view: UIScrollView, value) in view.minimumZoomScale = value }
            $0.register("maximumZoomScale") { scanner in try scanner.scanCGFloat() }
                .apply { (view: UIScrollView, value) in view.maximumZoomScale = value }
            $0.register("zoomScale") { scanner in try scanner.scanCGFloat() }
                .apply { (view: UIScrollView, value) in view.zoomScale = value }
            
            $0.register("pagingEnabled") { scanner in try scanner.scanBool() }
                .apply { (view: UIScrollView, value) in view.isPagingEnabled = value }
            $0.register("scrollEnabled") { scanner in try scanner.scanBool() }
                .apply { (view: UIScrollView, value) in view.isScrollEnabled = value }
            
            $0.register("scrollsToTop") { scanner in try scanner.scanBool() }
                .apply { (view: UIScrollView, value) in view.scrollsToTop = value }
            
            $0.register("showsHorizontalScrollIndicator") { scanner in try scanner.scanBool() }
                .apply { (view: UIScrollView, value) in view.showsHorizontalScrollIndicator = value }
            $0.register("showsVerticalScrollIndicator") { scanner in try scanner.scanBool() }
                .apply { (view: UIScrollView, value) in view.showsVerticalScrollIndicator = value }
        }
    }
}
