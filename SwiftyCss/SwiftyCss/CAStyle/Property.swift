#if os(iOS) || os(tvOS)
    import UIKit
#endif
import QuartzCore
import SwiftyNode
import SwiftyBox

extension CAStyle {
    
    // 随父的大小改变而改变
    
    static func hasFollower(property: [String: String])  -> Bool {
        if property["float"] != nil || property["autoSize"] != nil {
            return true
        }
        if property["right"] != nil || property["bottom"] != nil {
            return true
        }
        for k in ["top", "left", "width", "heigth", "position"] {
            if property[k]?.hasSuffix("%") == true {
                return true
            }
        }
        return false
    }
    
    static func clearProperty(_ style: CAStyle, _ name: String) {
        guard let layer = style.layer else {
            return
        }
        switch name {
        case "hidden":
            layer.isHidden = false
            
        case "opacity":
            layer.opacity = 1
            
        case "transform":
            layer.transform = CATransform3DMakeTranslation(0, 0, 0)
            
        case "mask", "overflow":
            layer.masksToBounds = false
            
        case "rasterize":
            layer.shouldRasterize = false
            
        case "radius":
            layer.cornerRadius = 0
            
        case "backgroundColor", "background":
            layer.backgroundColor = .clear
            
        case "shadow":
            layer.shadowColor  = nil
            layer.shadowOpacity = 0
            
        case "width", "height":
            if !style.hooks.isEmpty {
                style.setStatus( .checkHookChild )
            }
            
        case "margin", "marginTop", "marginRight", "marginBottom", "marginLeft":
            style.margin = name == "margin" ? (0, 0, 0, 0) : style.parseMargin(name: name, value: "0")
            layer.superlayer?.cssStyle.setStatus( .rankFloatChild )
            
        case "padding", "paddingTop", "paddingRight", "paddingBottom", "paddingLeft":
            style.padding = name == "padding" ? (0, 0, 0, 0) : style.parsePadding(name: name, value: "0")
            style.setStatus( .rankFloatChild )
            
        case "border", "borderTop", "borderRight", "borderBottom", "borderLeft":
            style.border = name == "border" ? nil : style.parseBorder(name: name, value: "none")
            style.setStatus( .checkBorder )
            
        default:
            break
        }
        
    }
    
    static func setProperty(_ style: CAStyle, _ source: [String: String], _ available: [String: String]) {
        guard let layer = style.layer else {
            return
        }
        let isfloat = style.property["float"] != nil
        if style.property["transform"] != nil{
            layer.transform = CATransform3DMakeTranslation(0, 0, 0)
        }
        
        // frame
        let frame = parsePropertyToFrame(style, isfloat, available)
        if frame != layer.frame {
            if frame.size != layer.frame.size {
                if isfloat {
                    layer.superlayer?.cssStyle.setStatus( .rankFloatChild )
                }
                if !style.hooks.isEmpty {
                    style.setStatus( .checkHookChild )
                }
            }
            if isfloat {
                layer.frame.size = frame.size
            }else{
                layer.frame = frame
            }
        }
        // frame end
        
        for (name, value) in available {
            switch name {
            case "float":
                layer.superlayer?.cssStyle.setStatus( .rankFloatChild )
                
            case "position":
                if let list = style.parseValues(value, limit: 2, percentOf: [".width", ".height"]) {
                    layer.position = CGPoint(x: list[0], y: list[1])
                }
                
            // Display
            case "hidden":
                let v = value == "false" ? false : true
                if layer.isHidden != v  {
                    layer.isHidden = v
                }
                
            case "rasterize":
                layer.shouldRasterize = value == "true"
                
            case "mask", "overflow":
                layer.masksToBounds = value == "hidden" || value == "true" ? true : false
                
            // Layout
            case "zPosition", "zIndex":
                layer.zPosition = CGFloat(value) ?? 1
                
            case "padding", "paddingTop", "paddingRight", "paddingBottom", "paddingLeft":
                let padding = style.parsePadding(name: name, value: value)
                if style.padding != padding {
                    style.padding = padding
                    if isfloat {
                        style.setStatus( .rankFloatChild )
                    }
                }
                
            case "margin", "marginTop", "marginRight", "marginBottom", "marginLeft":
                let margin = style.parsePadding(name: name, value: value)
                if style.margin != margin {
                    style.margin = margin
                    if isfloat {
                        layer.superlayer?.cssStyle.setStatus( .rankFloatChild )
                    }
                }
                
            case "anchorPoint":
                if let list = style.parseValues(value, limit: 2, percentOf: ["width", "height"]) {
                    let point = CGPoint(x: list[0], y: list[1])
                    layer.anchorPoint = point.x < 0 ? point : CGPoint(x: point.x/layer.frame.width, y: point.y/layer.frame.height )
                }
            
            // Style
            case "border", "borderTop", "borderRight", "borderBottom", "borderLeft":
                style.border = style.parseBorder(name: name, value: value)
                style.setStatus( .checkBorder )
                
            case "opacity":
                layer.opacity = Float(value) ?? 1
                
            case "fillColor", "fill":
                if layer is CAShapeLayer {
                    (layer as! CAShapeLayer).fillColor = Color(value)
                }
                
            case "backgroundColor", "background":
                layer.backgroundColor = Color(value)
                
            case "backgroundImage":
                if let file = value.hasPrefix("/") ? value : Bundle.main.path(forResource: value, ofType: nil) {
                    layer.contents = UIImage(contentsOfFile: file)?.cgImage
                    if layer.contents != nil {
                        layer.setNeedsLayout()
                    }
                }
                
            case "radius":
                layer.cornerRadius = style.parseValue(value, percentOf: "width") ?? 0
                
            // shadow
            case "shadow":
                let list = value.components(separatedBy: " ", trim: .whitespacesAndNewlines)
                if list.count == 4 {
                    layer.shadowOffset  = CGSize(width: CGFloat(list[0]) ?? 0, height: CGFloat(list[1]) ?? 0)
                    layer.shadowRadius  = CGFloat(list[2]) ?? 0
                    layer.shadowColor   = Color(list[3])
                    layer.shadowOpacity = 1
                }
            case "shadowOffset":
                if let list = style.parseValues(value) {
                    if list.count == 2 {
                        layer.shadowOffset = CGSize(width: list[0], height:list[1])
                    }
                }
            case "shadowOpacity":
                layer.shadowOpacity = Float(value) ?? 1
            case "shadowRadius":
                layer.shadowRadius  = CGFloat(value) ?? 0
            case "shadowColor":
                layer.shadowColor   = Color(value)
                
            // Text
            case "content", "textAlign", "fontSize", "fontName", "color", "wordWrap":
                if let text_layer = layer as? CATextLayer {
                    switch name {
                    case "wordWrap":
                        text_layer.isWrapped = value == "true"
                    case "content":
                        text_layer.string = value.replacingOccurrences(of: "\\n", with: "\n")
                    case "textAlign":
                        switch value {
                        case "right":
                            text_layer.alignmentMode = kCAAlignmentRight
                        case "center":
                            text_layer.alignmentMode = kCAAlignmentCenter
                        case "natural":
                            text_layer.alignmentMode = kCAAlignmentNatural
                        case "justified":
                            text_layer.alignmentMode = kCAAlignmentJustified
                        default:
                            text_layer.alignmentMode = kCAAlignmentLeft
                        }
                    case "fontSize":
                        text_layer.contentsScale = UIScreen.main.scale
                        if let size = CGFloat(value) {
                            text_layer.fontSize = size
                        }
                    case "fontName":
                        text_layer.font = CTFontCreateWithName(value as CFString, text_layer.fontSize,  nil)
                            //CGFont(value as CFString)
                    default:
                        text_layer.foregroundColor = Color(value)
                        continue
                    }
                    if style.property["autoSize"] != nil {
                        style.setStatus( .checkSize )
                    }
                    break
                }
                
                #if os(iOS) || os(tvOS)
                    if let label = layer.delegate as? UILabel {
                        switch name {
                            
                        case "wordWrap":
                            label.lineBreakMode = NSLineBreakMode.byWordWrapping
                            label.numberOfLines = 0
                            
                        case "content":
                            label.text = value.replacingOccurrences(of: "\\n", with: "\n")
                            
                        case "textAlign":
                            switch value {
                            case "right":
                                label.textAlignment = .right
                            case "center":
                                label.textAlignment = .center
                            case "natural":
                                label.textAlignment = .natural
                            case "justified":
                                label.textAlignment = .justified
                            default:
                                label.textAlignment = .left
                            }
                        case "fontSize":
                            if let size = CGFloat(value) {
                                label.font = label.font.withSize(size)
                            }
                        case "fontName":
                            label.font = UIFont(name: value, size: label.font.pointSize)
                        default:
                            if let color = Color(value) {
                                label.textColor = UIColor(cgColor: color)
                            }
                            continue
                        }
                        if style.property["autoSize"] != nil {
                            style.setStatus( .checkSize )
                        }
                    }
                #endif
                
            case "transform":
                var offset = 0
                var trans = CATransform3DMakeTranslation(0, 0, 0)
                while let m = TRANSFORM_LEXER.match(value, offset: offset) {
                    switch m[1]! {
                    case "perspective":
                        trans.m34 = -1 / (style.parseValue(m[2]) ?? 1)
                    case "translate":
                        if let v = style.parseValues(m[2], percentOf: ["width", "height", "width"]) {
                            let x = v.count > 0 ? v[0] : 0
                            let y = v.count > 1 ? v[1] : 0
                            let z = v.count > 2 ? v[2] : 0
                            trans = CATransform3DTranslate(trans, x, y, z)
                        }
                    case "scale":
                        if let v = style.parseValues(m[2], percentOf: ["width", "height", "width"]) {
                            let x = v.count > 0 ? v[0] : 1
                            let y = v.count > 1 ? v[1] : x
                            let z = v.count > 2 ? v[2] : 1
                            trans = CATransform3DScale(trans, x, y, z)
                        }
                    case "rotate":
                        if let v = style.parseValues(m[2]) {
                            let a = v[0] * CGFloat.pi / 180.0
                            if v.count == 1 {
                                trans = CATransform3DRotate(trans, a, 0, 0, v[0] > 0 ? 1 : -1)
                            }else{
                                let x:CGFloat = 1
                                let y = v.count > 1 ? v[1]/v[0] : 0
                                let z = v.count > 2 ? v[2]/v[0] : 0
                                trans = CATransform3DRotate(trans, a, x, y, z)
                            }
                        }
                    default:
                        assertionFailure("[SwiftyCSS.CACssDelegate.setTransformProperty] nonsupport transform property \"\(m[1]!)\"")
                    }
                    offset = m.lastIndex + 1
                }
                layer.transform = trans
                
            default:
                break
            }

        }
        

    }
    
    private static func parsePropertyToFrame(_ style: CAStyle, _ isfloat: Bool, _ target: [String: String]) -> CGRect {
        let layer = style.layer!
        var frame = layer.frame
        var isfloat = isfloat
        var width_changed  = false
        var height_changed = false
        for key in isfloat ? ["width", "minWidth", "maxWidth", "right"] : ["width", "minWidth", "maxWidth", "left", "right"] {
            if target[key] != nil {
                if isfloat {
                    isfloat = key != "right"
                }
                width_changed = true
                break
            }
        }
        for key in isfloat ? ["height", "minHeight", "maxHeight", "bottom"] : ["height", "minHeight", "maxHeight", "top", "bottom"] {
            if target[key] != nil {
                if isfloat {
                    isfloat = key != "bottom"
                }
                height_changed = true
                break
            }
        }
        if width_changed {
            if isfloat {
                frame.size.width = style.getValue(name: "width", min: "minWidth", max: "maxWidth", def: 0, percentOf: ".width")
            }else{
                let left  = style.getValue(name: "left", percentOf: ".width")
                let right = style.getValue(name: "right", percentOf: ".width")
                
                if left != nil && right != nil {
                    frame.size.width = (layer.superlayer?.bounds.size.width ?? 0) - left! - right!
                    frame.origin.x = left!
                }else {
                    frame.size.width = style.getValue(name: "width", min: "minWidth", max: "maxWidth", def: frame.width, percentOf: ".width")
                    if left != nil {
                        frame.origin.x = left!
                    }else if right != nil {
                        frame.origin.x = (layer.superlayer?.bounds.size.width ?? 0) - frame.size.width - right!
                    }
                }
            }
        }
        if height_changed {
            if isfloat {
                frame.size.height = style.getValue(name: "height", min: "minHeight", max: "maxHeight", def: 0, percentOf: ".height")
            }else{
                let top    = style.getValue(name: "top", percentOf: ".height")
                let bottom = style.getValue(name: "bottom", percentOf: ".height")
                if top != nil && bottom != nil {
                    frame.size.height = (layer.superlayer?.bounds.size.height ?? 0) - top! - bottom!
                    frame.origin.y    = top!
                }else{
                    frame.size.height = style.getValue(name: "height", min: "minHeight", max: "maxHeight", def: frame.height, percentOf: ".height")
                    if top != nil {
                        frame.origin.y = top!
                    }else if bottom != nil {
                        frame.origin.y = (layer.superlayer?.bounds.size.height ?? 0) - frame.size.height - bottom!
                    }
                }
            }
        }
        return frame
    }
    
    // MARK: - Private Static
    
    private static let TRANSFORM_LEXER = Re("(\\w+)\\s*\\(([^)]+)\\)")
    
}


