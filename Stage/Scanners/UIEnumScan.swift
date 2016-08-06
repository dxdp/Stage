import Foundation
import MapKit

public extension StageRuleScanner {
    //MARK: MKMapType
    private static let enumMap_MKMapType : [String: MKMapType] = {
        [ "standard": .Standard,
          "satellite": .Satellite,
          "hybrid": .Hybrid ]
    }()
    public func scanMKMapType() throws -> MKMapType {
        return try EnumScanner(map: StageRuleScanner.enumMap_MKMapType, lineNumber: startingLine).scan(using: self)
    }

    //MARK: NSLayoutAttribute
    private static let enumMap_NSLayoutAttribute : [String: NSLayoutAttribute] = {
        [ "left": .Left,
          "right": .Right,
          "top": .Top,
          "bottom": .Bottom,
          "leading": .Leading,
          "trailing": .Trailing,
          "width": .Width,
          "height": .Height,
          "centerx": .CenterX,
          "centery": .CenterY,
          "baseline": .Baseline,
          "firstbaseline": .FirstBaseline,
          "leftmargin": .LeftMargin,
          "rightmargin": .RightMargin,
          "topmargin": .TopMargin,
          "bottommargin": .BottomMargin,
          "leadingmargin": .LeadingMargin,
          "trailingmargin": .TrailingMargin,
          "centerxwithinmargins": .CenterXWithinMargins,
          "centerywithinmargins": .CenterYWithinMargins ]
    }()
    public func scanNSLayoutAttribute() throws -> NSLayoutAttribute {
        return try EnumScanner(map: StageRuleScanner.enumMap_NSLayoutAttribute, lineNumber: startingLine).scan(using: self)
    }

    //MARK: NSLayoutRelation
    private static let enumMap_NSLayoutRelation : [String: NSLayoutRelation] = {
        [ "==": .Equal,
          "<=": .LessThanOrEqual,
          ">=": .GreaterThanOrEqual ]
    }()
    public func scanNSLayoutRelation() throws -> NSLayoutRelation {
        let characterSet = NSCharacterSet(charactersInString: "<=>")
        return try EnumScanner(map: StageRuleScanner.enumMap_NSLayoutRelation, lineNumber: startingLine, characterSet: characterSet).scan(using: self)
    }

    //MARK: NSLineBreakMode
    private static let enumMap_NSLineBreakMode : [String: NSLineBreakMode] = {
        [ "wordwrapping": .ByWordWrapping,
          "charwrapping": .ByCharWrapping,
          "clipping": .ByClipping,
          "truncatinghead": .ByTruncatingHead,
          "truncatingtail": .ByTruncatingTail,
          "truncatingmiddle": NSLineBreakMode.ByTruncatingMiddle]
    }()
    public func scanNSLineBreakMode() throws -> NSLineBreakMode {
        return try EnumScanner(map: StageRuleScanner.enumMap_NSLineBreakMode, lineNumber: startingLine).scan(using: self)
    }

    //MARK: NSTextAlignment
    private static let enumMap_NSTextAlignment : [String: NSTextAlignment] = {
        [ "left": .Left,
          "center": .Center,
          "right": .Right,
          "justified": .Justified,
          "natural": .Natural ]
    }()
    public func scanNSTextAlignment() throws -> NSTextAlignment {
        return try EnumScanner(map: StageRuleScanner.enumMap_NSTextAlignment, lineNumber: startingLine).scan(using: self)
    }

    //MARK: UIActivityIndicatorViewStyle
    private static let enumMap_UIActivityIndicatorViewStyle : [String: UIActivityIndicatorViewStyle] = {
        [ "white": .White,
          "whitelarge": .WhiteLarge,
          "gray": .Gray ]
    }()
    public func scanUIActivityIndicatorViewStyle() throws -> UIActivityIndicatorViewStyle {
        return try EnumScanner(map: StageRuleScanner.enumMap_UIActivityIndicatorViewStyle, lineNumber: startingLine).scan(using: self)
    }

    //MARK: UIBlurEffectStyle
    private static let enumMap_UIBlurEffectStyle : [String: UIBlurEffectStyle] = {
        [ "extralight": .ExtraLight,
          "light": .Light,
          "dark": .Dark ]
    }()
    public func scanUIBlurEffectStyle() throws -> UIBlurEffectStyle {
        return try EnumScanner(map: StageRuleScanner.enumMap_UIBlurEffectStyle, lineNumber: startingLine).scan(using: self)
    }

    // MARK: UIKeyboardType
    private static let enumMap_UIKeyboardType : [String: UIKeyboardType] = {
        [ "default": .Default,
          "asciicapable": .ASCIICapable,
          "numbersandpunctuation": .NumbersAndPunctuation,
          "url": .URL,
          "numberpad": .NumberPad,
          "phonepad": .PhonePad,
          "namephonepad": .NamePhonePad,
          "emailaddress": .EmailAddress,
          "decimalpad": .DecimalPad,
          "twitter": .Twitter,
          "websearch": .WebSearch ]
    }()
    public func scanUIKeyboardType() throws -> UIKeyboardType {
        return try EnumScanner(map: StageRuleScanner.enumMap_UIKeyboardType, lineNumber: startingLine).scan(using: self)
    }

    //MARK: UIViewAutoresizing
    private static let enumMap_UIViewAutoresizing : [String: UIViewAutoresizing] = {
        [ "width": .FlexibleWidth,
          "height": .FlexibleHeight,
          "top": .FlexibleTopMargin,
          "left": .FlexibleLeftMargin,
          "right": .FlexibleRightMargin,
          "bottom": .FlexibleBottomMargin,
          "none": .None ]
    }()
    public func scanUIViewAutoresizing() throws -> UIViewAutoresizing {
        return try EnumScanner(map: StageRuleScanner.enumMap_UIViewAutoresizing, lineNumber: startingLine).scan(using: self)
    }

    //MARK: UIViewContentMode
    private static let enumMap_UIViewContentMode : [String: UIViewContentMode] = {
        [ "scaletofill": .ScaleToFill,
          "scaleaspectfit": .ScaleAspectFit,
          "scaleaspectfill": .ScaleAspectFill,
          "redraw": .Redraw,
          "center": .Center,
          "top": .Top,
          "bottom": .Bottom,
          "left": .Left,
          "right": .Right,
          "topleft": .TopLeft,
          "topright": .TopRight,
          "bottomleft": .BottomLeft,
          "bottomright": .BottomRight ]
    }()
    public func scanUIViewContentMode() throws -> UIViewContentMode {
        return try EnumScanner(map: StageRuleScanner.enumMap_UIViewContentMode, lineNumber: startingLine).scan(using: self)
    }

    //MARK: UITextFieldViewMode
    private static let enumMap_UITextFieldViewMode : [String: UITextFieldViewMode] = {
        [ "never": .Never,
          "whileediting": .WhileEditing,
          "unlessediting": .UnlessEditing,
          "always": .Always ]
    }()
    public func scanUITextFieldViewMode() throws -> UITextFieldViewMode {
        return try EnumScanner(map: StageRuleScanner.enumMap_UITextFieldViewMode, lineNumber: startingLine).scan(using: self)
    }
}