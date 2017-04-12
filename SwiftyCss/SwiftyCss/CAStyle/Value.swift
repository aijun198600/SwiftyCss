//  Created by Wang Liang on 2017/4/8.
//  Copyright © 2017年 Wang Liang. All rights reserved.

import UIKit
import SwiftyNode
import SwiftyBox

extension CAStyler {
    
    final func getValue(attribute name: String) -> Any? {
        guard let layer = self.layer else {
            return nil
        }
        if self.status.contains( .inactive ) {
            self.refresh()
        }
        switch name {
        case "screenWidth":
            return UIScreen.main.bounds.width
        case "screenHeight":
            return UIScreen.main.bounds.height
        case "id":
            return self.id
        case "class":
            return self.clas.joined(separator:" ")
        case "tag":
            return self.tag
        case "width":
            return layer.bounds.size.width
        case "height":
            return layer.bounds.size.height
        case "top":
            return layer.frame.origin.y
        case "left":
            return layer.frame.origin.x
        case "right":
            return layer.superlayer != nil ? layer.superlayer!.frame.width - layer.frame.width - layer.frame.origin.x : nil
        case "bottom":
            return layer.superlayer != nil ? layer.superlayer!.frame.height - layer.frame.height - layer.frame.origin.y : nil
        case "zPosition", "zIndex":
            return layer.zPosition
        case "opacity":
            return layer.opacity
        case "margin":
            return self.margin
        case "marginTop":
            return self.margin.top
        case "marginRight":
            return self.margin.right
        case "marginBottom":
            return self.margin.bottom
        case "marginLeft":
            return self.margin.left
            
        case "padding":
            return self.padding
        case "paddingTop":
            return self.padding.top
        case "paddingRight":
            return self.padding.right
        case "paddingBottom":
            return self.padding.bottom
        case "paddingLeft":
            return self.padding.left
        default:
            return self.property[ name ]
        }
    }
    
    final func getValue(name: String, percentOf attr: String? = nil) -> CGFloat? {
        return self.parseValue( self.property[name], percentOf: attr )
    }
    
    final func getValues(name: String, limit: Int = 1, percentOf attrs: [String]? = nil) -> [CGFloat]? {
        return self.parseValues( self.property[name], limit: limit, percentOf: attrs )
    }
    
    final func getValue(name: String, min:String, max:String, def: CGFloat, percentOf: String) -> CGFloat {
        var val = self.getValue(name: name, percentOf: percentOf) ?? def
        if let min = self.getValue(name: min, percentOf: percentOf) {
            if val < min {
                val = min
            }
        }
        if let max = self.getValue(name: max, percentOf: percentOf) {
            if val > max {
                val = max
            }
        }
        return val
    }
    
    final func parseValue(_ str: String?, percentOf attr: String? = nil) -> CGFloat? {
        guard let str = str else {
            return nil
        }
        if let f = Float(str) {
            return CGFloat(f)
        }
        if var layer = self.layer {
            if str.hasSuffix("%") {
                guard var attr = attr, let f = Float( str[0, -1] ) else {
                    return nil
                }
                if attr.hasPrefix(".") {
                    if layer.superlayer == nil {
                        return nil
                    }
                    layer = layer.superlayer!
                    attr = attr.slice(start: 1)
                }
                switch attr {
                case "width":
                    return CGFloat(f/100) * layer.bounds.size.width
                case "height":
                    return CGFloat(f/100) * layer.bounds.size.height
                default:
                    fatalError( "[SwiftyCss.CAStyle.parseValue] nosupport expression: \(str) x \(attr)" )
                }
            }
            if str.hasPrefix("[") {
                if let val = Node.Expression(str[1, -1]).run(with: layer) {
                    return CGFloat(val)
                }
                return nil
            }
        }
        if str.hasSuffix("pt") {
            #if DEBUG
                print("[SwiftyCss] this value does not need to unit! \(str) => \(str[0, -2])")
            #endif
            return CGFloat( str[0, -2] )
        }
        return nil
    }
    
    final func parseValues(_ str: String?, limit: Int = 1, percentOf attrs: [String]? = nil) -> [CGFloat]? {
        guard var list = str?.components(separatedBy: " ", trim: .whitespacesAndNewlines) else {
            return nil
        }
        var res = [CGFloat]()
        if limit > 1 && list.count == 1 {
            list.append(list[0])
        }
        if limit > 2 && list.count == 2 {
            list.append(list[0])
            list.append(list[1])
        }
        for (i, value) in list.enumerated() {
            if attrs != nil && i < attrs!.count {
                res.append( self.parseValue(value, percentOf: attrs![i]) ?? 0 )
            }else{
                res.append( self.parseValue(value) ?? 0 )
            }
        }
        if limit > 3 && res.count == 3 {
            res.append(0)
        }
        return res.isEmpty ? nil : res
    }
    
    final func parseMargin(name: String, value: String) -> (top:CGFloat, right:CGFloat, bottom:CGFloat, left:CGFloat) {
        var data = self.margin
        if name.hasSuffix("Top") {
            data.top = self.parseValue(value, percentOf: ".height") ?? 0
        }else if name.hasSuffix("Right") {
            data.right = self.parseValue(value, percentOf: ".width") ?? 0
        }else if name.hasSuffix("Bottom") {
            data.bottom = self.parseValue(value, percentOf: ".height") ?? 0
        }else if name.hasSuffix("Left") {
            data.left = self.parseValue(value, percentOf: ".width") ?? 0
        }else if let list = self.parseValues(value, limit: 4, percentOf: [".height", ".width", ".height", ".width"]) {
            data.top    = list[0]
            data.right  = list[1]
            data.bottom = list[2]
            data.left   = list[3]
        }
        return data
    }
    
    final func parsePadding(name: String, value: String) -> (top:CGFloat, right:CGFloat, bottom:CGFloat, left:CGFloat) {
        var data = self.padding
        if name.hasSuffix("Top") {
            data.top = self.parseValue(value, percentOf: "height") ?? 0
        }else if name.hasSuffix("Right") {
            data.right = self.parseValue(value, percentOf: "width") ?? 0
        }else if name.hasSuffix("Bottom") {
            data.bottom = self.parseValue(value, percentOf: "height") ?? 0
        }else if name.hasSuffix("Left") {
            data.left = self.parseValue(value, percentOf: "width") ?? 0
        }else if let list = self.parseValues(value, limit: 4, percentOf: ["height", "width", "height", "width"]) {
            data.top    = list[0]
            data.right  = list[1]
            data.bottom = list[2]
            data.left   = list[3]
        }
        return data
    }
    
    final func parseBorder(name: String, value: String) -> [String]? {
        var data = self.border ?? ["", "", "", ""]
        let value = value == "none" ? "" : value
        if name.hasSuffix("Top") {
            data[0] = value
        }else if name.hasSuffix("Right") {
            data[1] = value
        }else if name.hasSuffix("Bottom") {
            data[2] = value
        }else if name.hasSuffix("Left") {
            data[3] = value
        }else{
            data = [value, value, value, value]
        }
        if data.joined(separator: "").isEmpty {
            return nil
        }
        return data
    }

}

