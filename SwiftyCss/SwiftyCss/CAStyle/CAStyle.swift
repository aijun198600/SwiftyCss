
import UIKit
import SwiftyNode
import SwiftyBox


class CAStyle: Node.Style {
    
    private(set) weak var layer: CALayer?
    
    var hooks: Set<Int> = []
    var padding: (top:CGFloat, right:CGFloat, bottom:CGFloat, left:CGFloat) = (0, 0, 0, 0)
    var margin: (top:CGFloat, right:CGFloat, bottom:CGFloat, left:CGFloat) = (0, 0, 0, 0)
    var border: [String]? = nil
    var backgroundImagePath: String? = nil
    var sublayersCount: Int = 0
    weak var borderLayer: CAShapeLayer? = nil
    
    var view: UIView? {
        if layer?.delegate is UIView {
            return layer!.delegate as? UIView
        }
        return nil
    }
    
    var isFloat: Bool {
        return self.property["float"] != nil
    }
    
    init( layer: CALayer ) {
        self.layer = layer
        super.init(node: layer, styleSheet: Css.styleSheet)
        if layer.delegate is UIView {
            _ = self.lazySet(key: "tag", value: String(describing: type(of: layer.delegate!) ))
        }else{
            _ = self.lazySet(key: "tag", value: String(describing: type(of: layer) ))
        }
        layer.addObserver( CAStyle.listener, forKeyPath: "bounds", options: [.new, .old], context: nil)
        layer.addObserver( CAStyle.listener, forKeyPath: "sublayers", options: [], context: nil)
    }
    
    override final func refresh(all: Bool = false, property: Bool = false) {
        super.refresh(all: all, property: property)
        _ = self.checkStyleHook()
    }
    
    
    override func getProperty(_ name: String) -> Any? {
        if self.hasStatus(.inactive) {
            self.refresh( property: true )
        }
        return CAStyle.getStyleProperty(self, name)
    }
    
    override func setProperty(list: [String: String]) {
        guard let layer = self.layer else {
            return
        }
        super.setProperty(list: list)
        
        CAStyle.checkTransaction(self)
        
        if list["transform"] != nil{
            layer.transform = CATransform3DMakeTranslation(0, 0, 0)
        }
        for key in ["width", "left", "right", "minWidth", "maxWidth"] {
            if list[key] != nil {
                CAStyle.setStyleProperty(self, key, list[key]!)
                break
            }
        }
        for key in ["height", "top", "bottom", "minHeight", "maxHeight"] {
            if list[key] != nil {
                CAStyle.setStyleProperty(self, key, list[key]!)
                break
            }
        }
        let pass = ["width", "left", "right", "height", "top", "bottom", "minWidth", "maxWidth", "minHeight", "maxHeight"]
        for (key, value) in list {
            if pass.contains(key) {
                continue
            }
            CAStyle.setStyleProperty(self, key, value)
        }
        CAStyle.commitTransaction()
    }
    
    override func setProperty(name: String, value: String) {
        super.setProperty(name: name, value: value)
        CAStyle.checkTransaction(self)
        CAStyle.setStyleProperty(self, name, value)
        CAStyle.commitTransaction()
    }
    
    override func clearProperty(_ name: String) {
        super.clearProperty(name)
        CAStyle.clearStyleProperty(self, name)
    }
    
    override func updata(mark: String = "unkonw") -> Bool {
        let status = self.status
        
        if super.updata(mark: mark) {
            CAStyle.updataStyle(self, status: status)
            return true
        }
        return false
    }
    
    // MARK: - Static
    
    private func checkStyleHook() -> Bool {
        guard let layer = self.layer else {
            return false
        }
        if let parent = layer.superlayer?.nodeStyle as? CAStyle {
            if CAStyle.testStyleHook( self.property ) {
                parent.hooks.insert(layer.hashValue)
                return true
            }else{
                _ = parent.hooks.remove(layer.hashValue)
            }
        }
        return false
    }
    
    static func testStyleHook(_ property:[String: String])  -> Bool {
        if property["float"] != nil {
            return true
        }
        var map   = ["top":false, "left":false, "right":false, "bottom":false, "width":false, "heigth":false, "position":false]
        for k in map.keys {
            if let value = property[k] {
                if value.hasSuffix("%") {
                    return true
                }
                map[k] = true
                switch k {
                case "top" where map["bottom"] == true: return true
                case "bottom" where map["top"] == true: return true
                case "left" where map["right"] == true: return true
                case "right" where map["left"] == true: return true
                default: break
                }
            }
        }
        return false
    }
    
    static func checkTransaction(_ style: Node.Style? ){
        CATransaction.begin()
        if let ani = style?.property["animate"], let t = Double(ani) {
            CATransaction.setAnimationDuration(t)
        }else{
            CATransaction.setDisableActions(true)
        }
    }
    
    static func commitTransaction(){
        CATransaction.commit()
    }
    
    // MARK: -  CAStyle Listener Class
    
    private static let listener = Listener()
    
    private class Listener: NSObject {
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            guard let keyPath = keyPath else {
                return
            }
            guard let layer = object as? CALayer, let style = layer.nodeStyle as? CAStyle else {
                return
            }
            if style.disable || style.hasStatus( .inactive, .lazy, .updating, .checkAll) {
                return
            }
            switch keyPath {
            case "sublayers":
                print("-->", style.status, style)
                guard let sublayers = layer.sublayers else {
                    return
                }
                if sublayers.count > style.sublayersCount {
                    for sub in sublayers {
                        if let sub_style = sub.nodeStyle {
                            if sub_style.hasStatus( .inactive ) {
                                sub_style.refresh( all:true )
                            }
                        }
                    }
                }else if sublayers.count > 0 {
                    style.setStatus( .checkChild )
                }
                style.sublayersCount = sublayers.count
                
            case "bounds":
                guard let new = change?[.newKey] as? CGRect, let old = change?[.oldKey] as? CGRect else {
                    print("xxxxxx")
                    return
                }
                if new.size == old.size {
                    return
                }
                
                print("##>", style.status, style, new, old)
                if style.property["float"] != nil {
                    style.setStatus( .checkFloatSibling )
                }else if layer.sublayers != nil {
                    style.setStatus( .checkChild )
                }
            default:
                break
            }
        }
    
    }
    
}

