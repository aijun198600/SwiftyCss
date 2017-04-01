
import Foundation
import SwiftyBox

extension Node.Style {
    
    public final func getValue(name: String, percentOf attr: String? = nil) -> CGFloat? {
        return self.parseValue( self.property[name], percentOf: attr )
    }
    
    public final func getValues(name: String, limit: Int = 1, percentOf attrs: [String]? = nil) -> [CGFloat]? {
        return self.parseValues( self.property[name], limit: limit, percentOf: attrs )
    }
    
    public final func parseValue(_ str: String?, percentOf attr: String? = nil) -> CGFloat? {
        guard let str = str else {
            return nil
        }
        if let f = Float(str) {
            return CGFloat(f)
        }
        if str.hasSuffix("px") {
            return CGFloat( str[0, -2] )
        }
        if str.hasSuffix("deg") {
            return CGFloat( str[0, -3] )
        }
        
        if var node = self.master {
            if str.hasPrefix("[") {
                var exp = Node.Expression(str[1, -1])
                if let val = exp.run(with: node) {
                    return CGFloat(val)
                }
                return nil
            }
            if str.hasSuffix("%") {
                guard var attr = attr, let f = Float( str[0, -1] ) else {
                    return nil
                }
                if attr.hasPrefix(".") {
                    
                    if node.parentNode == nil {
                        return nil
                    }
                    node = node.parentNode!
                    attr = attr.slice(start: 1)
                }
                if let value = CGFloat(node.getAttribute(attr)) {
                    return CGFloat(f/100) * (value)
                }
            }
        }
        return nil
    }
    
    public final func parseValues(_ str: String?, limit: Int = 1, percentOf attrs: [String]? = nil) -> [CGFloat]? {
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
    
}

