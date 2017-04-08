//  Created by Wang Liang on 2017/4/8.
//  Copyright © 2017年 Wang Liang. All rights reserved.

import Foundation
import CoreGraphics

private let colorSpace = CGColorSpaceCreateDeviceRGB()

public func Color(_ str: String?) -> CGColor? {
    guard let str = str?.trimmingCharacters(in: .whitespaces).lowercased() else {
        return nil
    }
    if str.hasPrefix("#") {
        return Color(hex: str)
    }else if str.hasPrefix("rgb") {
        return Color(rgb: str)
    }else {
        switch str {
        case "none", "clear", "transparent":
            return .clear
        case "black":
            return .black
        case "white":
            return .white
        case "blue":
            return .blue
        case "red":
            return .red
        case "green":
            return .green
        case "yellow":
            return .yellow
        case "magenta":
            return .magenta
        case "orange":
            return .orange
        case "purple":
            return .purple
        case "brown":
            return .brown
        case "cyan":
            return .cyan
        case "gray":
            return .gray
        case "darkgray":
            return .darkGray
        case "lightgray":
            return .lightGray
        default:
            return nil
        }
    }
}

public func Color(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> CGColor {
    guard let c = CGColor(colorSpace: colorSpace, components: [red/255, green/255, blue/255 ,alpha]) else {
        fatalError("SwiftyBox.Color (\(red), \(green), \(blue), \(alpha)) params error")
    }
    return c
}

public func Color(hex: String) -> CGColor {
    var hex = hex.hasPrefix("#") ? hex.slice(start: 1) : hex
    var hexValue: UInt32 = 0
    guard Scanner(string: hex).scanHexInt32(&hexValue) else {
        fatalError("SwiftyBox.Color (hex: \(hex)) params error")
    }
    switch hex.characters.count {
    case 3:
        hexValue = (hexValue << 4)+0xF
        fallthrough
    case 4:
        return Color(hex: hexValue, short: true)
    case 6:
        hexValue = (hexValue << 8)+0xFF
        fallthrough
    default:
        return Color(hex: hexValue)
    }
}

public func Color(hex: UInt32, short: Bool = false) -> CGColor {
    if short {
        let red     = CGFloat((hex & 0xF000) >> 12) * 17
        let green   = CGFloat((hex & 0x0F00) >>  8) * 17
        let blue    = CGFloat((hex & 0x00F0) >>  4) * 17
        let alpha   = CGFloat( hex & 0x000F       ) / 15
        return Color(red, green, blue, alpha)
    }else {
        let red     = CGFloat((hex & 0xFF000000) >> 24)
        let green   = CGFloat((hex & 0x00FF0000) >> 16)
        let blue    = CGFloat((hex & 0x0000FF00) >>  8)
        let alpha   = CGFloat( hex & 0x000000FF       ) / 255
        return Color(red, green, blue, alpha)
    }
}

public func Color(rgb: String) -> CGColor {
    var rgb = rgb.replacingOccurrences(of: " ", with: "").lowercased()
    if rgb.hasPrefix("rgb(") {
        rgb = rgb[4, -1]
    }else if rgb.hasPrefix("rgba("){
        rgb = rgb[5, -1]
    }else{
        fatalError("UIColor init(rgb:) params error: \(rgb)")
    }
    var list = [CGFloat]()
    for v in rgb.components(separatedBy: ",") {
        list.append( CGFloat(v) ?? 0 )
    }
    if list.count < 3 {
        fatalError("UIColor init(rgb:) params error: \(rgb)")
    }
    return Color(list[0], list[1], list[2], list.count >= 4 ? list[3] : 1)
}

extension CGColor {
    
    public static let clear = Color(hex: 0)
    public static let black = Color(hex: 255)
    public static let white = Color(hex: 4294967295)
    public static let blue = Color(hex: 65535)
    public static let red = Color(hex: 4278190335)
    public static let green = Color(hex: 16711935)
    public static let yellow = Color(hex: 4294902015)
    public static let magenta = Color(hex: 4278255615)
    public static let orange = Color(hex: 4286513407)
    public static let purple = Color(hex: 2130739199)
    public static let brown = Color(hex: 2573612031)
    public static let cyan = Color(hex: 16777215)
    public static let gray = Color(hex: 2139062271)
    public static let darkGray = Color(hex: 1431655935)
    public static let lightGray = Color(hex: 2863311615)
    
    public var hex:UInt32 {
        let count = self.numberOfComponents
        let u = CGFloat(255)
        var a = CGFloat(0)
        var r = a
        var g = a
        var b = a
        if count == 2 {
            a = self.components![1]
            r = self.components![0]
            g = r
            b = r
        }else if count == 4{
            a = self.components![3]
            r = self.components![0]
            g = self.components![1]
            b = self.components![2]
        }

        return UInt32(r*u) << 24 + UInt32(g*u) << 16 + UInt32(b*u) << 8 + UInt32(a*u)
    }
    
    public var hexString: String {
        let h = self.hex
        let r   = NSString(format:"%02lX", (h & 0xFF000000) >> 24) as String
        let g   = NSString(format:"%02lX", (h & 0x00FF0000) >> 16) as String
        let b   = NSString(format:"%02lX", (h & 0x0000FF00) >> 8) as String
        let a   = NSString(format:"%02lX",  h & 0x000000FF ) as String
        return "#"+r+g+b + (a == "FF" ? "" : a)
    }
}

