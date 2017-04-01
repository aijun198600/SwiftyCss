
import UIKit
import SwiftyNode
import SwiftyBox

extension CAStyle {
    
    // MARK: - Static
    
    static func getStyleProperty(_ style: CAStyle, _ name: String) -> Any? {
        guard let layer = style.layer else {
            return nil
        }
        switch name {
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
            
        case "screenWidth":
            return UIScreen.main.bounds.width
        case "screenHeight":
            return UIScreen.main.bounds.height
            
        case "margin":
            return style.margin
        case "marginTop":
            return style.margin.top
        case "marginRight":
            return style.margin.right
        case "marginBottom":
            return style.margin.bottom
        case "marginLeft":
            return style.margin.left
            
        case "padding":
            return style.padding
        case "paddingTop":
            return style.padding.top
        case "paddingRight":
            return style.padding.right
        case "paddingBottom":
            return style.padding.bottom
        case "paddingLeft":
            return style.padding.left
        default:
            return style.property[ name ]
        }
    }
    
    static func clearStyleProperty(_ style: CAStyle, _ name: String) {
        guard let layer = style.layer else {
            return
        }
        switch name {
        case "hidden":
            layer.isHidden = false
            
        case "opacity":
            layer.opacity = 1
            
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
            style.setStatus( .checkChild )
            
        case "margin", "marginTop", "marginRight", "marginBottom", "marginLeft":
            style.margin = name == "margin" ? (0, 0, 0, 0) : style.parseMargin(name: name, value: "0")
            style.setStatus( .checkFloatSibling )
            
        case "padding", "paddingTop", "paddingRight", "paddingBottom", "paddingLeft":
            style.padding = name == "padding" ? (0, 0, 0, 0) : style.parsePadding(name: name, value: "0")
            style.setStatus( .checkFloatChild )
            
        case "border", "borderTop", "borderRight", "borderBottom", "borderLeft":
            style.border = name == "border" ? nil : style.parseBorder(name: name, value: "none")
            style.setStatus( .checkBorder )
            
        default:
            break
        }
        
    }
    
    static func setStyleProperty(_ style: CAStyle, _ name: String, _ value: String) {
        guard value != "none" && value != "nil" else {
            style.clearProperty(name)
            return
        }
        guard let layer = style.layer else {
            return
        }
        switch name {
        // Pass
        case "id", "tag", "class", "animate", "align", "float", "contentSize":
            break
            
        // Display
        case "hidden":
            let v = value == "false" ? false : true
            if layer.isHidden != v  {
                layer.isHidden = v
                if v == false {
                    style.refresh()
                }
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
                if style.isFloat {
                    style.setStatus( .checkFloatChild )
                }
            }
            
        case "margin", "marginTop", "marginRight", "marginBottom", "marginLeft":
            let margin = style.parsePadding(name: name, value: value)
            if style.margin != margin {
                style.margin = margin
                if style.isFloat {
                    style.setStatus( .checkFloatChild )
                }
            }
            
        case "anchorPoint":
            if let list = style.parseValues(value, limit: 2, percentOf: ["width", "height"]) {
                let point = CGPoint(x: list[0], y: list[1])
                layer.anchorPoint = point.x < 0 ? point : CGPoint(x: point.x/layer.frame.width, y: point.y/layer.frame.height )
            }
            
        case "width", "maxWidth", "minWidth", "height", "maxHeight", "minHeight", "top", "left", "right", "bottom", "position":
            
            if style.isFloat {
                
                switch name {
                case "width", "maxWidth", "minWidth":
                    
                    var width = style.parseValue(value, percentOf: ".width") ?? 0

                    width = max(width, style.getValue(name: "minWidth", percentOf: ".width") ?? .nan)
                    width = max(width, style.getValue(name: "maxWidth", percentOf: ".width") ?? .nan)
                    if width != layer.frame.size.width {
                        layer.frame.size.width = width
                        style.setStatus( .checkFloatSibling )
                    }
                    
                case "height", "maxHeight", "minHeight":
                    var height = style.parseValue(value, percentOf: ".height") ?? 0
                    height = max(height, style.getValue(name: "minHeight", percentOf: ".height") ?? .nan)
                    height = min(height, style.getValue(name: "maxHeight", percentOf: ".height") ?? .nan)
                    if height != layer.frame.size.height {
                        layer.frame.size.height = height
                        style.setStatus( .checkFloatSibling )
                    }
                    
                default:
                    return
                }
                
            }else{
                
                switch name {
                case "width", "left", "right", "maxWidth", "minWidth":
                    
                    var rect = layer.frame
                    let left  = style.getValue(name: "left", percentOf: ".width")
                    let right = style.getValue(name: "right", percentOf: ".width")
    
                    if left != nil && right != nil {
                        rect.size.width = (layer.superlayer?.bounds.size.width ?? 0) - left! - right!
                        rect.origin.x = left!
                    }else {
                        var width = style.getValue(name: "width", percentOf: ".width") ?? rect.width
                        width = max(width, style.getValue(name: "minWidth", percentOf: ".width") ?? .nan)
                        width = max(width, style.getValue(name: "maxWidth", percentOf: ".width") ?? .nan)
                        rect.size.width = width
                        
                        if left != nil {
                            rect.origin.x = left!
                        }else if right != nil {
                            rect.origin.x = (layer.superlayer?.bounds.size.width ?? 0) - width - right!
                        }
                    }
                    if rect.width != layer.frame.width {
                        style.setStatus( .checkChild )
                    }
                    layer.frame = rect
                    
                case "height", "top", "bottom", "maxHeight", "minHeight":
                    
                    var rect  = layer.frame
                    let top    = style.getValue(name: "top", percentOf: ".height")
                    let bottom = style.getValue(name: "bottom", percentOf: ".height")
                    
                    if top != nil && bottom != nil {
                        rect.size.height = (layer.superlayer?.bounds.size.height ?? 0) - top! - bottom!
                        rect.origin.y    = top!
                    }else{
                        var height = style.getValue(name: "height", percentOf: ".height") ?? rect.height
                        height = max(height, style.getValue(name: "minHeight", percentOf: ".height") ?? .nan)
                        height = min(height, style.getValue(name: "maxHeight", percentOf: ".height") ?? .nan)
                        rect.size.height = height
                        if top != nil {
                            rect.origin.y = top!
                        }else if bottom != nil {
                            rect.origin.y = (layer.superlayer?.bounds.size.height ?? 0) - height - top!
                        }
                    }
                    if rect.height != layer.frame.height {
                        style.setStatus( .checkChild )
                    }
                    layer.frame = rect
                    
                case "position":
                    if let list = style.parseValues(value, limit: 2, percentOf: [".width", ".height"]) {
                        layer.position = CGPoint(x: list[0], y: list[1])
                    }
            
                default:
                    return
                }
                
            }
            
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
            if let file = Bundle.main.path(forResource: value, ofType: nil) {
                if style.backgroundImagePath != file {
                    style.backgroundImagePath = file
                    layer.contents = UIImage(contentsOfFile: file)?.cgImage
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
        case "content", "textAlign", "fontSize", "fontName", "color":
            if layer is CATextLayer {
                let text = layer as! CATextLayer
                switch name {
                case "content":
                    text.string = value
                case "textAlign":
                    switch value {
                    case "right":
                        text.alignmentMode = kCAAlignmentRight
                    case "center":
                        text.alignmentMode = kCAAlignmentCenter
                    case "natural":
                        text.alignmentMode = kCAAlignmentNatural
                    case "justified":
                        text.alignmentMode = kCAAlignmentJustified
                    default:
                        text.alignmentMode = kCAAlignmentLeft
                    }
                case "fontSize":
                    text.contentsScale = UIScreen.main.scale
                    if let size = CGFloat(value) {
                        text.fontSize = size
                    }
                case "fontName":
                    text.font = CGFont(value as CFString)
                default:
                    text.foregroundColor = Color(value)
                }
                
            }else if style.view is UILabel {
                
                let label = style.view as! UILabel
                switch name {
                case "content":
                    label.text = value
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
                }
            }
            
        default:
            if Css.useStrict {
                fatalError("[SwiftyCSS] nonsupport style property \"\(name)\"")
            }
        }
    }
    
    // MARK: - Private Static
    
    private static let TRANSFORM_LEXER = Re("(\\w+)\\s*\\(([^)]+)\\)")
    
}


