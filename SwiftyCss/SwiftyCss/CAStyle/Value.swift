
import UIKit
import SwiftyNode
import SwiftyBox

extension CAStyle {
    
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

