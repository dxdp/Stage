//
//  UIEnumScan.swift
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

public extension StageRuleScanner {
    //MARK: MKMapType
    private static let enumMap_MKMapType =
        [ "standard": MKMapType.Standard,
          "satellite": MKMapType.Satellite,
          "hybrid": MKMapType.Hybrid ]
    public func scanMKMapType() throws -> MKMapType {
        return try EnumScanner(map: StageRuleScanner.enumMap_MKMapType).scan(using: self)
    }

    //MARK: NSLayoutAttribute
    private static let enumMap_NSLayoutAttribute =
        [ "left": NSLayoutAttribute.Left,
          "right": NSLayoutAttribute.Right,
          "top": NSLayoutAttribute.Top,
          "bottom": NSLayoutAttribute.Bottom,
          "leading": NSLayoutAttribute.Leading,
          "trailing": NSLayoutAttribute.Trailing,
          "width": NSLayoutAttribute.Width,
          "height": NSLayoutAttribute.Height,
          "centerx": NSLayoutAttribute.CenterX,
          "centery": NSLayoutAttribute.CenterY,
          "baseline": NSLayoutAttribute.Baseline,
          "firstbaseline": NSLayoutAttribute.FirstBaseline,
          "leftmargin": NSLayoutAttribute.LeftMargin,
          "rightmargin": NSLayoutAttribute.RightMargin,
          "topmargin": NSLayoutAttribute.TopMargin,
          "bottommargin": NSLayoutAttribute.BottomMargin,
          "leadingmargin": NSLayoutAttribute.LeadingMargin,
          "trailingmargin": NSLayoutAttribute.TrailingMargin,
          "centerxwithinmargins": NSLayoutAttribute.CenterXWithinMargins,
          "centerywithinmargins": NSLayoutAttribute.CenterYWithinMargins ]
    public func scanNSLayoutAttribute() throws -> NSLayoutAttribute {
        return try EnumScanner(map: StageRuleScanner.enumMap_NSLayoutAttribute).scan(using: self)
    }

    //MARK: NSLayoutRelation
    private static let enumMap_NSLayoutRelation =
        [ "==": NSLayoutRelation.Equal,
          "<=": NSLayoutRelation.LessThanOrEqual,
          ">=": NSLayoutRelation.GreaterThanOrEqual ]
    public func scanNSLayoutRelation() throws -> NSLayoutRelation {
        let characterSet = NSCharacterSet(charactersInString: "<=>")
        return try EnumScanner(map: StageRuleScanner.enumMap_NSLayoutRelation, characterSet: characterSet).scan(using: self)
    }

    //MARK: NSLineBreakMode
    private static let enumMap_NSLineBreakMode =
        [ "wordwrapping": NSLineBreakMode.ByWordWrapping,
          "charwrapping": NSLineBreakMode.ByCharWrapping,
          "clipping": NSLineBreakMode.ByClipping,
          "truncatinghead": NSLineBreakMode.ByTruncatingHead,
          "truncatingtail": NSLineBreakMode.ByTruncatingTail,
          "truncatingmiddle": NSLineBreakMode.ByTruncatingMiddle]
    public func scanNSLineBreakMode() throws -> NSLineBreakMode {
        return try EnumScanner(map: StageRuleScanner.enumMap_NSLineBreakMode).scan(using: self)
    }

    //MARK: NSTextAlignment
    private static let enumMap_NSTextAlignment =
        [ "left": NSTextAlignment.Left,
          "center": NSTextAlignment.Center,
          "right": NSTextAlignment.Right,
          "justified": NSTextAlignment.Justified,
          "natural": NSTextAlignment.Natural ]
    public func scanNSTextAlignment() throws -> NSTextAlignment {
        return try EnumScanner(map: StageRuleScanner.enumMap_NSTextAlignment).scan(using: self)
    }

    //MARK: UIActivityIndicatorViewStyle
    private static let enumMap_UIActivityIndicatorViewStyle =
        [ "white": UIActivityIndicatorViewStyle.White,
          "whitelarge": UIActivityIndicatorViewStyle.WhiteLarge,
          "gray": UIActivityIndicatorViewStyle.Gray ]
    public func scanUIActivityIndicatorViewStyle() throws -> UIActivityIndicatorViewStyle {
        return try EnumScanner(map: StageRuleScanner.enumMap_UIActivityIndicatorViewStyle).scan(using: self)
    }

    //MARK: UIBlurEffectStyle
    private static let enumMap_UIBlurEffectStyle =
        [ "extralight": UIBlurEffectStyle.ExtraLight,
          "light": UIBlurEffectStyle.Light,
          "dark": UIBlurEffectStyle.Dark ]
    public func scanUIBlurEffectStyle() throws -> UIBlurEffectStyle {
        return try EnumScanner(map: StageRuleScanner.enumMap_UIBlurEffectStyle).scan(using: self)
    }

    // MARK: UIKeyboardType
    private static let enumMap_UIKeyboardType =
        ["default": UIKeyboardType.Default,
         "asciicapable": UIKeyboardType.ASCIICapable,
         "numbersandpunctuation": UIKeyboardType.NumbersAndPunctuation,
         "url": UIKeyboardType.URL,
         "numberpad": UIKeyboardType.NumberPad,
         "phonepad": UIKeyboardType.PhonePad,
         "namephonepad": UIKeyboardType.NamePhonePad,
         "emailaddress": UIKeyboardType.EmailAddress,
         "decimalpad": UIKeyboardType.DecimalPad,
         "twitter": UIKeyboardType.Twitter,
         "websearch": UIKeyboardType.WebSearch ]
    public func scanUIKeyboardType() throws -> UIKeyboardType {
        return try EnumScanner(map: StageRuleScanner.enumMap_UIKeyboardType).scan(using: self)
    }

    //MARK: UIViewAutoresizing
    private static let enumMap_UIViewAutoresizing =
        [ "width": UIViewAutoresizing.FlexibleWidth,
          "height": UIViewAutoresizing.FlexibleHeight,
          "top": UIViewAutoresizing.FlexibleTopMargin,
          "left": UIViewAutoresizing.FlexibleLeftMargin,
          "right": UIViewAutoresizing.FlexibleRightMargin,
          "bottom": UIViewAutoresizing.FlexibleBottomMargin,
          "none": UIViewAutoresizing.None ]
    public func scanUIViewAutoresizing() throws -> UIViewAutoresizing {
        return try EnumScanner(map: StageRuleScanner.enumMap_UIViewAutoresizing).scan(using: self)
    }

    //MARK: UIViewContentMode
    private static let enumMap_UIViewContentMode =
        [ "scaletofill": UIViewContentMode.ScaleToFill,
          "scaleaspectfit": UIViewContentMode.ScaleAspectFit,
          "scaleaspectfill": UIViewContentMode.ScaleAspectFill,
          "redraw": UIViewContentMode.Redraw,
          "center": UIViewContentMode.Center,
          "top": UIViewContentMode.Top,
          "bottom": UIViewContentMode.Bottom,
          "left": UIViewContentMode.Left,
          "right": UIViewContentMode.Right,
          "topleft": UIViewContentMode.TopLeft,
          "topright": UIViewContentMode.TopRight,
          "bottomleft": UIViewContentMode.BottomLeft,
          "bottomright": UIViewContentMode.BottomRight ]
    public func scanUIViewContentMode() throws -> UIViewContentMode {
        return try EnumScanner(map: StageRuleScanner.enumMap_UIViewContentMode).scan(using: self)
    }

    //MARK: UITextFieldViewMode
    private static let enumMap_UITextFieldViewMode =
        [ "never": UITextFieldViewMode.Never,
          "whileediting": UITextFieldViewMode.WhileEditing,
          "unlessediting": UITextFieldViewMode.UnlessEditing,
          "always": UITextFieldViewMode.Always ]
    public func scanUITextFieldViewMode() throws -> UITextFieldViewMode {
        return try EnumScanner(map: StageRuleScanner.enumMap_UITextFieldViewMode).scan(using: self)
    }
}