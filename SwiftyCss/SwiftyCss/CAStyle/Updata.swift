//  Created by Wang Liang on 2017/4/8.
//  Copyright © 2017年 Wang Liang. All rights reserved.

#if os(iOS) || os(tvOS)
    import UIKit
#endif
import QuartzCore
import SwiftyNode
import SwiftyBox

extension CAStyler {
    
    static func updataFloatLayer(_ parent_styler: CAStyler, _ chilren: [CALayer]? = nil){
        guard let parent = parent_styler.layer else {
            return
        }
        guard let chilren = chilren ?? getChildren(parent, float: true) else {
            return
        }
        
        var types = [String: [CALayer]]()
        for child in chilren {
            if child.isHidden {
                continue
            }
            if let type = child.cssStyler.property["float"] {
                if types[type] == nil {
                    types[type] = [CALayer]()
                }
               types[type]!.append(child)
            }
        }
        
        let box         = parent.frame.size
        let box_padding = parent_styler.padding
        
        for (type, children) in types {
            for i in 0 ..< children.count {
                let child = children[i]
                let child_styler = child.cssStyler
                if child_styler.disable {
                    continue
                }
                
                var point        = CGPoint.zero
                let block        = child.frame.size
                let block_margin = child_styler.margin
                
                if type == "center" {
                    point.x = (box.width - (block.width + block_margin.left + block_margin.right) )/2
                    point.y = (box.height - (block.height + block_margin.top + block_margin.bottom))/2
                    
                }else if i == 0 {
                    switch type {
                    case "top", "left", "auto":
                        point.x = box_padding.left + block_margin.left
                        point.y = box_padding.top + block_margin.top
                        
                    case "right":
                        point.x = box.width - block.width - (box_padding.right + block_margin.right)
                        point.y = box_padding.top + block_margin.top
                    default:
                        continue
                    }
                }else {
                    let prev = children[i-1].frame
                    let prev_margin = children[i-1].cssStyler.margin
                    switch type {
                    case "top":
                        point.x = box_padding.left + block_margin.left
                        point.y = prev.origin.y + prev.size.height + prev_margin.bottom + block_margin.top
                        
                    case "left":
                        point.x = prev.origin.x + prev.size.width + prev_margin.right + block_margin.left
                        point.y = prev.origin.y - prev_margin.top + block_margin.top
                        
                    case "right":
                        point.x = prev.origin.x - (prev_margin.left + block_margin.right + block.width)
                        point.y = prev.origin.y - prev_margin.top + block_margin.top
                        
                    case "auto":
                        point.x = prev.origin.x + prev.size.width + prev_margin.right + block_margin.left
                        point.y = prev.origin.y - prev_margin.top + block_margin.top
                        if point.x + block.width + block_margin.right > box.width - box_padding.right - box_padding.left {
                            point.x = box_padding.left + block_margin.left
                            let side = getContentSide( Array(chilren[0..<i]) )
                            point.y = side.bottom + block_margin.top
                        }
                    default:
                        continue
                    }
                }
                if child.frame.origin != point {
                    child_styler.animateBegin()
                    child.frame.origin = point
                    child_styler.animateCommit()
                }
            }
        }
        
        if let align = parent_styler.property["align"], let children = types["auto"] {
            updateAlign(parent_styler, align, children)
        }
        
    }
    
    static func updateAlign(_ styler: CAStyler, _ align: String, _ children: [CALayer]) {
        guard let box = styler.layer?.frame.size else {
            return
        }
        let side = getContentSide(children)
        var x = box.width - side.left - abs(side.right - side.left)
        var y = box.height - side.top - abs(side.bottom - side.top)
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
        case "right", "topRight", "rightTop":
            y = 0
        case "bottom", "bottomLeft", "leftBottom":
            x = 0
        case "bottomRight", "rightBottom":
            break
        case "left", "topLeft", "leftTop":
            return
        default:
            return
        }
        if x != 0 || y != 0 {
            for child in children {
                child.cssStyler.animateBegin()
                child.frame.origin.x += x
                child.frame.origin.y += y
                child.cssStyler.animateCommit()
            }
        }
    }
    
    static func updataAutoSize(_ styler: CAStyler) {
        guard let layer = styler.layer else {
            return
        }
        let auto = styler.property["autoSize"]
        
        if layer.sublayers == nil {
            
            if let text_layer = layer as? CATextLayer {
                guard let content = text_layer.string as? String else {
                    return
                }
                let limit_width  = auto == "height" ? text_layer.frame.width : .greatestFiniteMagnitude
                let limit_height = auto == "width" ? text_layer.frame.height : .greatestFiniteMagnitude
                
                guard let text_size = String.size(content, font: text_layer.font as! CTFont, size: text_layer.fontSize, limitWidth:limit_width, limitHeight:limit_height) else {
                    return
                }
                if layer.frame.size != text_size {
                    styler.animateBegin()
                    if auto == "height" {
                        layer.frame.size.height = text_size.height
                    }else if auto == "width" {
                        layer.frame.size.width = text_size.width
                    }else {
                        layer.frame.size = text_size
                    }
                    styler.animateCommit()
                }
            }
            return
        }
        
        let side = getContentSide( layer.sublayers! )
        let size = CGSize(width: side.right, height: side.bottom)
        
        #if os(iOS) || os(tvOS)
            if let sc = layer.delegate as? UIScrollView {
                if sc.contentSize != size {
                    if auto == "height" {
                        sc.contentSize.height = size.height
                    }else if auto == "width" {
                        sc.contentSize.width = size.width
                    }else {
                        sc.contentSize = size
                    }
                }
                return
            }
        #endif
        
        if layer.frame.size != size {
            styler.animateBegin()
            if auto == "height" {
                layer.frame.size.height = size.height
            }else if auto == "width" {
                layer.frame.size.width = size.width
            }else {
                layer.frame.size = size
            }
            styler.animateCommit()
        }
    }
    
    static func updataBorderLayer(_ styler: CAStyler) {
        guard let layer = styler.layer else {
            return
        }
        var border = styler.borderLayer
        guard let data = styler.border else {
            border?.removeFromSuperlayer()
            styler.borderLayer = nil
            return
        }
        
        if border == nil {
            border = CAShapeLayer(disable: true)
            border!.zPosition = -1
            layer.insertSublayer(border!, at: 0)
            styler.borderLayer = border!
            
        }else if border!.sublayers != nil{
            for sub in border!.sublayers! {
                sub.removeFromSuperlayer()
            }
        }
        let size = layer.bounds.size
        var main_path: UIBezierPath? = nil
        var main_data: (CGFloat, String, CGColor)? = nil
        for i in 0 ..< data.count {
            if let d = BorderData(data[i]) {
                let p = BorderPath(position: i, size: size, width: d.0)
                var b = border!
                if main_path == nil {
                    main_path = p
                    main_data = d
                }else if d.0 == main_data!.0 && d.1 == main_data!.1 && d.2 == main_data!.2 {
                    main_path!.append(p)
                    continue
                }else{
                    b = CAShapeLayer(disable: true)
                    b.path = p.cgPath
                    border!.addSublayer(b)
                }
                b.strokeColor = d.2
                b.lineWidth = d.0
                if d.1 == "dashed" {
                    b.lineDashPattern = [NSNumber(value:Float(d.0))]
                }else if let f = Float(d.1) {
                    b.lineDashPattern = [NSNumber(value:f)]
                }
            }
        }
        border!.frame = layer.bounds
        border!.path = main_path?.cgPath
    }

    // MARK: -
    
    static func getChildren(_ parent: CALayer, float: Bool? = nil) -> [CALayer]? {
        guard parent.sublayers != nil else {
            return nil
        }
        var list = [CALayer]()
        for child in parent.sublayers! {
            if child.isHidden {
                continue
            }
            let styler = child.cssStyler
            if styler.disable {
                continue
            }
            if float == nil {
                list.append(child)
            }else if (styler.property["float"] != nil) == float {
                list.append(child)
            }
        }
        return list.isEmpty ? nil : list
    }
    
    static func getContentSide(_ contents: [CALayer]) -> (top:CGFloat, bottom:CGFloat, left:CGFloat, right:CGFloat) {
        guard contents.count > 0 else {
            return (0, 0, 0, 0)
        }
        let M: (CGFloat, CGFloat, CGFloat, CGFloat) = (0,0,0,0)
        var s: (top:CGFloat, bottom:CGFloat, left:CGFloat, right:CGFloat) = (.nan, .nan, .nan, .nan)
        for child in contents {
            var m = M
            let f = child.frame
            let styler = child.cssStyler
            if styler.property["float"] != nil {
                m = styler.margin
            }
            s.top    = min(f.origin.y - m.0, s.top)
            s.bottom = max(f.origin.y + f.height + m.2, s.bottom)
            s.left   = min(f.origin.x - m.3, s.left)
            s.right  = max(f.origin.x + f.width + m.1, s.right)
        }
        return s
    }
    
    // MARK: -

    private static func BorderPath(position: Int, size: CGSize, width: CGFloat, radius: CGFloat = 0) -> UIBezierPath {
        let w = width / 2
        let path = UIBezierPath()
        switch position {
        case 0:
            path.move(to: CGPoint(x:0, y: w))
            path.addLine(to: CGPoint(x: size.width, y: w))
        case 1:
            path.move(to: CGPoint(x:size.width-w, y: 0))
            path.addLine(to: CGPoint(x:size.width-w, y: size.height))
        case 2:
            path.move(to: CGPoint(x:0, y: size.height-w))
            path.addLine(to: CGPoint(x: size.width, y: size.height-w))
        default:
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




