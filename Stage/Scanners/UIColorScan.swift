//
//  UIColorScan.swift
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
import Swift

public extension StageRuleScanner {
    public func scanUIColor() throws -> UIColor {
        var leading: NSString?
        let location = scanLocation
        if scanCharactersFromSet(NSCharacterSet(charactersInString: "rgba#"), intoString: &leading) && leading != nil {
            switch leading as! String {
            case "rgba": return try scanUIColor_rgba()
            case "rgb": return try scanUIColor_rgb()
            case let x where x.hasPrefix("#"):
                scanLocation -= leading!.length - 1
                return try scanUIColor_webHex()
            default: break
            }
        }

        scanLocation = location
        var colorName: NSString?
        guard scanUpToString(" ", intoString: &colorName) && colorName != nil else {
            throw StageException.UnrecognizedContent(message: "\(string) is not recognized as a valid value for UIColor", line: startingLine)
        }
        return try UIColor(name: colorName as! String)
    }

    private func scanUIColor_rgba() throws -> UIColor {
        let dims = try scanBracedList(open: "(", close: ")", itemScan: scanNSNumber())
        guard case let (r, g, b, a) = (dims[0].intValue, dims[1].intValue, dims[2].intValue, dims[3].floatValue)
        where dims.count == 4 && (0..<256) ~= r && (0..<256) ~= g && (0..<256) ~= b && (0.0...1.0) ~= a else {
            throw StageException.UnrecognizedContent(message: "Expected color format rgba(R, G, B, A) but saw \(string)",
                                                     line: startingLine)
        }
        return UIColor(colorLiteralRed: Float(r)/255,
                       green: Float(g)/255,
                       blue: Float(b)/255,
                       alpha: a)
    }

    private func scanUIColor_rgb() throws -> UIColor {
        let dims = try scanBracedList(open: "(", close: ")", itemScan: scanNSNumber())
        guard case let (r, g, b) = (dims[0].intValue, dims[1].intValue, dims[2].intValue)
            where dims.count == 3 && (0..<256) ~= r && (0..<256) ~= g && (0..<256) ~= b else {
            throw StageException.UnrecognizedContent(message: "Expected color format rgb(R, G, B) but saw \(string)",
                                                     line: startingLine)
        }
        return UIColor(colorLiteralRed: Float(r)/255,
                       green: Float(g)/255,
                       blue: Float(b)/255,
                       alpha: 1)
    }

    private func scanUIColor_webHex() throws -> UIColor {
        var colorString: NSString?
        guard scanCharactersFromSet(.hexnumericCharacterSet(), intoString: &colorString) && colorString != nil else {
            throw StageException.UnrecognizedContent(message: "Expected web hex-numeric color specification",
                                                     line: startingLine)
        }
        return try UIColor(webHex: colorString as! String)
    }
}

typealias ColorTuple = (r: Float, g: Float, b: Float, a: Float)
func decompose(packedARGB value: UInt32) -> ColorTuple {
    return (r: Float((value >> 16) & 0xFF)/255.0,
            g: Float((value >> 8) & 0xFF)/255.0,
            b: Float((value) & 0xFF)/255.0,
            a: Float((value >> 24) & 0xFF)/255.0)
}

public enum WebColors: String {
    case pink
    case lightpink
    case hotpink
    case deeppink
    case palevioletred
    case mediumvioletred
    case lightsalmon
    case salmon
    case darksalmon
    case lightcoral
    case indianred
    case crimson
    case firebrick
    case darkred
    case red
    case orangered
    case tomato
    case coral
    case darkorange
    case orange
    case yellow
    case lightyellow
    case lemonchiffon
    case lightgoldenrodyellow
    case papayawhip
    case moccasin
    case peachpuff
    case palegoldenrod
    case khaki
    case darkkhaki
    case gold
    case cornsilk
    case blanchedalmond
    case bisque
    case navajowhite
    case wheat
    case burlywood
    case tan
    case rosybrown
    case sandybrown
    case goldenrod
    case darkgoldenrod
    case peru
    case chocolate
    case saddlebrown
    case sienna
    case brown
    case maroon
    case darkolivegreen
    case olive
    case olivedrab
    case yellowgreen
    case limegreen
    case lime
    case lawngreen
    case chartreuse
    case greenyellow
    case springgreen
    case mediumspringgreen
    case lightgreen
    case palegreen
    case darkseagreen
    case mediumseagreen
    case seagreen
    case forestgreen
    case green
    case darkgreen
    case mediumaquamarine
    case aqua
    case cyan
    case lightcyan
    case paleturquoise
    case aquamarine
    case turquoise
    case mediumturquoise
    case darkturquoise
    case lightseagreen
    case cadetblue
    case darkcyan
    case teal
    case lightsteelblue
    case powderblue
    case lightblue
    case skyblue
    case lightskyblue
    case deepskyblue
    case dodgerblue
    case cornflowerblue
    case steelblue
    case royalblue
    case blue
    case mediumblue
    case darkblue
    case navy
    case midnightblue
    case lavender
    case thistle
    case plum
    case violet
    case orchid
    case fuchsia
    case magenta
    case mediumorchid
    case mediumpurple
    case blueviolet
    case darkviolet
    case darkorchid
    case darkmagenta
    case purple
    case indigo
    case darkslateblue
    case rebeccapurple
    case slateblue
    case mediumslateblue
    case white
    case snow
    case honeydew
    case mintcream
    case azure
    case aliceblue
    case ghostwhite
    case whitesmoke
    case seashell
    case beige
    case oldlace
    case floralwhite
    case ivory
    case antiquewhite
    case linen
    case lavenderblush
    case mistyrose
    case gainsboro
    case lightgrey
    case silver
    case darkgray
    case gray
    case dimgray
    case lightslategray
    case slategray
    case darkslategray
    case black
    case transparent

    var webHex: String {
        switch self {
        case .pink: return "#FFC0CB"
        case .lightpink: return "#FFB6C1"
        case .hotpink: return "#FF69B4"
        case .deeppink: return "#FF1493"
        case .palevioletred: return "#DB7093"
        case .mediumvioletred: return "#C71585"
        case .lightsalmon: return "#FFA07A"
        case .salmon: return "#FA8072"
        case .darksalmon: return "#E9967A"
        case .lightcoral: return "#F08080"
        case .indianred: return "#CD5C5C"
        case .crimson: return "#DC143C"
        case .firebrick: return "#B22222"
        case .darkred: return "#8B0000"
        case .red: return "#FF0000"
        case .orangered: return "#FF4500"
        case .tomato: return "#FF6347"
        case .coral: return "#FF7F50"
        case .darkorange: return "#FF8C00"
        case .orange: return "#FFA500"
        case .yellow: return "#FFFF00"
        case .lightyellow: return "#FFFFE0"
        case .lemonchiffon: return "#FFFACD"
        case .lightgoldenrodyellow: return "#FAFAD2"
        case .papayawhip: return "#FFEFD5"
        case .moccasin: return "#FFE4B5"
        case .peachpuff: return "#FFDAB9"
        case .palegoldenrod: return "#EEE8AA"
        case .khaki: return "#F0E68C"
        case .darkkhaki: return "#BDB76B"
        case .gold: return "#FFD700"
        case .cornsilk: return "#FFF8DC"
        case .blanchedalmond: return "#FFEBCD"
        case .bisque: return "#FFE4C4"
        case .navajowhite: return "#FFDEAD"
        case .wheat: return "#F5DEB3"
        case .burlywood: return "#DEB887"
        case .tan: return "#D2B48C"
        case .rosybrown: return "#BC8F8F"
        case .sandybrown: return "#F4A460"
        case .goldenrod: return "#DAA520"
        case .darkgoldenrod: return "#B8860B"
        case .peru: return "#CD853F"
        case .chocolate: return "#D2691E"
        case .saddlebrown: return "#8B4513"
        case .sienna: return "#A0522D"
        case .brown: return "#A52A2A"
        case .maroon: return "#800000"
        case .darkolivegreen: return "#556B2F"
        case .olive: return "#808000"
        case .olivedrab: return "#6B8E23"
        case .yellowgreen: return "#9ACD32"
        case .limegreen: return "#32CD32"
        case .lime: return "#00FF00"
        case .lawngreen: return "#7CFC00"
        case .chartreuse: return "#7FFF00"
        case .greenyellow: return "#ADFF2F"
        case .springgreen: return "#00FF7F"
        case .mediumspringgreen: return "#00FA9A"
        case .lightgreen: return "#90EE90"
        case .palegreen: return "#98FB98"
        case .darkseagreen: return "#8FBC8F"
        case .mediumseagreen: return "#3CB371"
        case .seagreen: return "#2E8B57"
        case .forestgreen: return "#228B22"
        case .green: return "#008000"
        case .darkgreen: return "#006400"
        case .mediumaquamarine: return "#66CDAA"
        case .aqua: return "#00FFFF"
        case .cyan: return "#00FFFF"
        case .lightcyan: return "#E0FFFF"
        case .paleturquoise: return "#AFEEEE"
        case .aquamarine: return "#7FFFD4"
        case .turquoise: return "#40E0D0"
        case .mediumturquoise: return "#48D1CC"
        case .darkturquoise: return "#00CED1"
        case .lightseagreen: return "#20B2AA"
        case .cadetblue: return "#5F9EA0"
        case .darkcyan: return "#008B8B"
        case .teal: return "#008080"
        case .lightsteelblue: return "#B0C4DE"
        case .powderblue: return "#B0E0E6"
        case .lightblue: return "#ADD8E6"
        case .skyblue: return "#87CEEB"
        case .lightskyblue: return "#87CEFA"
        case .deepskyblue: return "#00BFFF"
        case .dodgerblue: return "#1E90FF"
        case .cornflowerblue: return "#6495ED"
        case .steelblue: return "#4682B4"
        case .royalblue: return "#4169E1"
        case .blue: return "#0000FF"
        case .mediumblue: return "#0000CD"
        case .darkblue: return "#00008B"
        case .navy: return "#000080"
        case .midnightblue: return "#191970"
        case .lavender: return "#E6E6FA"
        case .thistle: return "#D8BFD8"
        case .plum: return "#DDA0DD"
        case .violet: return "#EE82EE"
        case .orchid: return "#DA70D6"
        case .fuchsia: return "#FF00FF"
        case .magenta: return "#FF00FF"
        case .mediumorchid: return "#BA55D3"
        case .mediumpurple: return "#9370DB"
        case .blueviolet: return "#8A2BE2"
        case .darkviolet: return "#9400D3"
        case .darkorchid: return "#9932CC"
        case .darkmagenta: return "#8B008B"
        case .purple: return "#800080"
        case .indigo: return "#4B0082"
        case .darkslateblue: return "#483D8B"
        case .rebeccapurple: return "#663399"
        case .slateblue: return "#6A5ACD"
        case .mediumslateblue: return "#7B68EE"
        case .white: return "#FFFFFF"
        case .snow: return "#FFFAFA"
        case .honeydew: return "#F0FFF0"
        case .mintcream: return "#F5FFFA"
        case .azure: return "#F0FFFF"
        case .aliceblue: return "#F0F8FF"
        case .ghostwhite: return "#F8F8FF"
        case .whitesmoke: return "#F5F5F5"
        case .seashell: return "#FFF5EE"
        case .beige: return "#F5F5DC"
        case .oldlace: return "#FDF5E6"
        case .floralwhite: return "#FFFAF0"
        case .ivory: return "#FFFFF0"
        case .antiquewhite: return "#FAEBD7"
        case .linen: return "#FAF0E6"
        case .lavenderblush: return "#FFF0F5"
        case .mistyrose: return "#FFE4E1"
        case .gainsboro: return "#DCDCDC"
        case .lightgrey: return "#D3D3D3"
        case .silver: return "#C0C0C0"
        case .darkgray: return "#A9A9A9"
        case .gray: return "#808080"
        case .dimgray: return "#696969"
        case .lightslategray: return "#778899"
        case .slategray: return "#708090"
        case .darkslategray: return "#2F4F4F"
        case .black: return "#000000"
        case .transparent: return "#00000000"
        }
    }
}
public extension UIColor {
    convenience init(webHex string: String) throws {
        var string = string
        if string.hasPrefix("#") { string.removeAtIndex(string.startIndex) }

        let compute: (shift: UInt32, mult: UInt32)
        var alphaMask: UInt32 = 0xff000000
        switch string.characters.count {
        case 3: compute = (shift: 8, mult: 16)
        case let x where x == 6 || x == 8:
            compute = (shift: 4, mult: 1)
            alphaMask = x == 8 ? 0 : alphaMask
        default:
            throw StageException.UnrecognizedContent(message: "Unrecognized content \(string) for UIColor", line: 0)
        }

        let values: [UInt32] = try string.characters.map { character throws -> UInt32 in
            let scalar = String(character).unicodeScalars.first!.value
            let add: UInt32
            switch character {
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                add = scalar - "0".unicodeScalars.first!.value
            case "a", "b", "c", "d", "e", "f":
                add = 10 + scalar - "a".unicodeScalars.first!.value
            case "A", "B", "C", "D", "E", "F":
                add = 10 + scalar - "A".unicodeScalars.first!.value
            default:
                throw StageException.UnrecognizedContent(message: "Unrecognized content \(string) for UIColor", line: 0)
            }
            return add
        }
        let value = values.reduce(0) { value, add in (value << compute.shift) + add * compute.mult }
        let (r, g, b, a) = decompose(packedARGB: value | alphaMask)
        self.init(colorLiteralRed: r, green: g, blue: b, alpha: a)
    }

    convenience init(packedARGB value: UInt32) throws {
        let (r, g, b, a) = decompose(packedARGB: value)
        self.init(colorLiteralRed: r, green: g, blue: b, alpha: a)
    }

    convenience init(name: String) throws {
        guard let webColor = WebColors.init(rawValue: name.trimmed().lowercaseString) else {
            throw StageException.UnrecognizedContent(message: "Unrecognized content \(name) for UIColor", line: 0)
        }
        try self.init(webColor: webColor)
    }

    convenience init(webColor: WebColors) throws {
        try self.init(webHex: webColor.webHex)
    }
}
