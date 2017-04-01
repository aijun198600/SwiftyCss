
import UIKit
import SwiftyNode
import SwiftyBox

extension CAStyle {
    
    // MARK: - Static
    
    static func updataStyle(_ style: CAStyle, status: Node.Status) {
        guard let layer = style.layer else {
            return
        }
        if status.contains( .checkBorder ) {
            CAStyle.updataBorderLayer(style)
        }else if style.border != nil || style.borderLayer != nil {
            if status.contains( .checkFloatSibling ) || status.contains( .checkChild ) {
                CAStyle.updataBorderLayer(style)
            }
        }
        
        if status.contains( .checkAll ) {
            var floats = [CALayer]()
            for i in 0 ..< (layer.sublayers?.count ?? 0) {
                if let sub = layer.sublayers![i].nodeStyle as? CAStyle {
                    if sub.disable {
                        continue
                    }
                    sub.refresh(all: true)
                    if sub.isFloat {
                        floats.append(layer.sublayers![i])
                    }
                }
            }
            if floats.isEmpty == false {
                CAStyle.updataFloatLayer(style, layer, floats)
            }
            
            if style.property["contentSize"] == "auto" {
                CAStyle.updataContentSize(style)
            }
            
        }else {
            if status.contains(.checkFloatSibling) && !status.contains(.noFloatSibling) {
                if let parent = layer.superlayer?.nodeStyle {
                    Node.Ticker.add(style: parent, CAStyle.updataFloatParent)
                }
            }
            
            if status.contains( .checkFloatChild ) || status.contains( .checkChild ) {
                if let floats = CAStyle.getChildren(layer, float: true) {
                    for sub in floats {
                        sub.nodeStyle?.setStatus( .noFloatSibling )
                        sub.nodeStyle?.refresh()
                    }
                    CAStyle.updataFloatLayer(style, layer, floats)
                }
            }
            
            if status.contains( .checkChild ) {
                if let subs = CAStyle.getChildren(layer, float: false) {
                    for sub in subs {
                        if style.hooks.contains( sub.hashValue ) {
                            sub.nodeStyle?.setStatus( .noFloatSibling )
                            sub.nodeStyle?.refresh()
                        }
                    }
                }
            }
            if style.property["contentSize"] == "auto" {
                CAStyle.updataContentSize(style)
            }
        }
    }
    
    
    // MARK: - Private Static
    
    private static func updataContentSize(_ style: Node.Style) {
        
        guard let layer = style.master as? CALayer else {
            return
        }
        guard layer.sublayers != nil else {
            return
        }
        let side = getContentSide( layer.sublayers! )
        if layer.delegate is UIScrollView {
            (layer.delegate as! UIScrollView).contentSize = CGSize(width: side.right, height: side.bottom)
        }else{
            CAStyle.checkTransaction(style)
            
            layer.frame.size = CGSize(width: side.right, height: side.bottom)
            
            CAStyle.commitTransaction()
        }
    }
    
    private static func updataFloatParent(_ style: Node.Style) {
        guard let style = style as? CAStyle else {
            return
        }
        guard let layer = style.layer else {
            return
        }
        updataFloatLayer(style, layer)
        if style.property["contentSize"] == "auto" {
            updataContentSize(style)
        }
    }
    
    private static func updataFloatLayer(_ style: CAStyle, _ parent: CALayer, _ chilren: [CALayer]? = nil){
        guard let chilren = chilren ?? getChildren(parent, float: true) else {
            return
        }
        
        var temp = [String: [CALayer]]()
        for child in chilren {
            if let type = child.nodeStyle?.property["float"] {
                if temp[type] == nil {
                    temp[type] = [CALayer]()
                }
               temp[type]!.append(child)
            }
        }
        
        let padding = style.padding
        let outer = parent.frame.size
        
        for (type, chilren) in temp {
            for i in 0 ..< chilren.count {
                let child = chilren[i]
                guard let child_style = child.nodeStyle as? CAStyle else {
                    continue
                }
                if child_style.disable {
                    continue
                }
                
                let block  = child.frame.size
                let margin = child_style.margin
                var point  = CGPoint.zero
                
                if type == "center" {
                    point.x = (outer.width - (block.width + margin.left + margin.right) )/2
                    point.y = (outer.height - (block.height + margin.top + margin.bottom))/2
                    
                }else if i == 0 {
                    switch type {
                    case "top", "left", "auto":
                        point.x = padding.left + margin.left
                        point.y = padding.top + margin.top
                        
                    case "right":
                        point.x = outer.width - block.width - (padding.right + margin.right)
                        point.y = padding.top + margin.top
                    default:
                        continue
                    }
                }else {
                    let prev = chilren[i-1].frame
                    let prev_margin = (chilren[i-1].nodeStyle as! CAStyle).margin
                    switch type {
                    case "top":
                        point.x = padding.left + margin.left
                        point.y = prev.origin.y + prev.size.height + prev_margin.bottom + margin.top
                        
                    case "left":
                        point.x = prev.origin.x + prev.size.width + prev_margin.right + margin.left
                        point.y = prev.origin.y - prev_margin.top + margin.top
                        
                    case "right":
                        point.x = prev.origin.x - (prev_margin.left + margin.right + block.width)
                        point.y = prev.origin.y - prev_margin.top + margin.top
                        
                    case "auto":
                        point.x = prev.origin.x + prev.size.width + prev_margin.right + margin.left
                        point.y = prev.origin.y - prev_margin.top + margin.top
                        
                        if point.x + block.width + margin.right > outer.width - padding.right - padding.left {
                            point.x = padding.left + margin.left
                            let side = getContentSide( Array(chilren[0..<i]) )
                            point.y = side.bottom + margin.top
                        }
                    default:
                        continue
                    }
                }
                CAStyle.checkTransaction(child_style)
                child.frame.origin = point
                CAStyle.commitTransaction()
            }
        }
        
        if let align = style.property["align"], let chilren = temp["auto"] {
            if chilren.count > 0 {
                
                let side = getContentSide(chilren)
                var x = outer.width - side.left - abs(side.right-side.left)
                var y = outer.height - side.top - abs(side.bottom-side.top)
                
                switch align {
                case "center":
                    x = x/2
                    y = y/2
                case "centerLeft", "leftCenter":
                    x = 0
                    y = y/2
                case "centerTop", "topCenter":
                    x = x/2
                    y = 0
                case "centerRight", "rightCenter":
                    y = y/2
                case "centerBottom", "centerCenter":
                    x = x/2
                case "left", "topLeft", "leftTop":
                    x = 0
                    y = 0
                case "right", "topRight", "rightTop":
                    y = 0
                case "bottom", "bottomLeft", "leftBottom":
                    x = 0
                case "bottomRight", "rightBottom":
                    break
                default:
                    x = 0
                    y = 0
                }
                for child in chilren {
                    CAStyle.checkTransaction(child.nodeStyle)
                    child.frame.origin.x += x
                    child.frame.origin.y += y
                    CAStyle.commitTransaction()
                }
            }
        }
    }
    
    private static func updataBorderLayer(_ style: CAStyle) {
        guard let layer = style.layer else {
            return
        }
        
        var border = style.borderLayer
        
        guard let data = style.border else {
            border?.removeFromSuperlayer()
            style.borderLayer = nil
            return
        }
        
        if border == nil {
            border = CAShapeLayer()
            border!.zPosition = -1
            layer.insertSublayer(border!, at: 0)
            style.borderLayer = border!
            
        }else if border!.sublayers != nil{
            for sub in border!.sublayers! {
                sub.removeFromSuperlayer()
            }
        }
        
        let size = layer.bounds.size
        var border_path: UIBezierPath? = nil
        var border_data: (CGFloat, String, CGColor)? = nil
        for i in 0 ..< data.count {
            if let d = BorderData(data[i]) {
                guard let p = BorderPath(position: i, size: size, width: d.0, style: d.1) else {
                    continue
                }
                if border_path == nil {
                    border_path = p
                    border_data = d
                    continue
                }
                
                if d.0 == border_data?.0 && d.2 == border_data?.2  {
                    border_path!.append(p)
                    continue
                }
                
                let g = CAShapeLayer()
                g.strokeColor = d.2
                g.lineWidth = d.0
                g.path = p.cgPath
                border?.addSublayer(g)
            }
        }
        border!.path = border_path?.cgPath
        border!.strokeColor = border_data?.2
        border!.lineWidth = border_data?.0 ?? 0
    }

    //
    
    private static func getChildren(_ parent: CALayer, float: Bool? = nil) -> [CALayer]? {
        guard parent.sublayers != nil else {
            return nil
        }
        var list = [CALayer]()
        for child in parent.sublayers! {
            guard let style = child.nodeStyle as? CAStyle else {
                continue
            }
            if style.disable {
                continue
            }
            if float == nil {
                list.append(child)
            }else if style.isFloat == float {
                list.append(child)
            }
        }
        return list.isEmpty ? nil : list
    }
    
    private static func getContentSide(_ contents: [CALayer]) -> (top:CGFloat, bottom:CGFloat, left:CGFloat, right:CGFloat) {
        guard contents.count > 0 else {
            return (0, 0, 0, 0)
        }
        let M: (CGFloat, CGFloat, CGFloat, CGFloat) = (0,0,0,0)
        var s: (top:CGFloat, bottom:CGFloat, left:CGFloat, right:CGFloat) = (.nan, .nan, .nan, .nan)
        for child in contents {
            var m = M
            let f = child.frame
            if let style = child.nodeStyle as? CAStyle {
                if style.isFloat {
                    m = style.margin
                }
            }
            s.top    = min(f.origin.y - m.0, s.top)
            s.bottom = max(f.origin.y + f.height + m.2, s.bottom)
            s.left   = min(f.origin.x - m.3, s.left)
            s.right  = max(f.origin.x + f.width + m.1, s.right)
        }
        return s
    }
    
    private static func getContentFrame(_ contents: [CALayer]) -> CGRect {
        let s = getContentSide( contents )
        return CGRect(x: s.left, y: s.top, width: s.right - s.left, height: s.bottom - s.top)
    }

    private static func BorderPath(position: Int, size: CGSize, width: CGFloat, style: String, radius: CGFloat = 0) -> UIBezierPath? {
        
        let w = width / 2
        let path = UIBezierPath()
        switch style {
        case "dashed":
            path.setLineDash([width], count: 1, phase: 0)
        case "hidden":
            return nil
        case "solid":
            break
        default:
            break
        }
        //        var frame: CGRect
        switch position {
        case 0:
            //            frame = CGRect(x: 0, y: 0, width: size.width, height: width)
            path.move(to: CGPoint(x:0, y: w))
            path.addLine(to: CGPoint(x: size.width, y: w))
        case 1:
            //            frame = CGRect(x: size.width-width, y: 0, width: width, height: size.height)
            path.move(to: CGPoint(x:size.width-w, y: 0))
            path.addLine(to: CGPoint(x:size.width-w, y: size.height))
        case 2:
            //            frame = CGRect(x: 0, y: size.height-width, width: size.width, height: width)
            path.move(to: CGPoint(x:0, y: size.height-w))
            path.addLine(to: CGPoint(x: size.width, y: size.height-w))
        default:
            //            frame = CGRect(x: 0, y: 0, width: width, height: size.height)
            path.move(to: CGPoint(x:w, y: 0))
            path.addLine(to: CGPoint(x:w, y: size.height))
        }
        return path
        
    }

    private static func BorderData(_ text: String) -> (CGFloat, String, CGColor)? {
        var list = text.components(separatedBy: " ", trim: .whitespacesAndNewlines)
        guard list.count > 0 else {
            return nil
        }
        let width = CGFloat(list.first) ?? 0
        let style = list.count > 1 ? list[1] : "solid"
        let color = Color(list.last) ?? CGColor.black
        return (width, style, color)
    }
}




