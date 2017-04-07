
import QuartzCore
import SwiftyNode
import SwiftyBox

extension Css {
    static var nonActions:[String : CAAction] = ["position" : NSNull(), "bounds" : NSNull(), "path" : NSNull(), "opacity":NSNull(), "origin":NSNull()]
}

extension CALayer: NodeProtocol {
    
    public final var nodeStyle: Node.Style {
        return CAStyle.make(self)
    }
    public final var cssStyle: CAStyle {
        return CAStyle.make(self)
    }
    
    open func getAttribute(_ key: String) -> Any? {
        return self.cssStyle.getValue(attribute: key)
    }
    
    open func setAttribute(_ key: String, value: Any?) {
        if key == "action" {
            self.actions = Bool(string: value) ? nil : Css.nonActions
        }else if value is String {
            self.nodeStyle.set(key: key, value: value as! String)
        }
    }

    open var childNodes: [NodeProtocol] {
        return self.sublayers ?? []
    }
    
    open var parentNode: NodeProtocol? {
        return self.superlayer
    }
    
    open func addChild(_ node: NodeProtocol) {
        guard node is CALayer else {
            fatalError( "[SwiftyCss.CALayer.addChild] cant add \"\(String(describing: type(of: node)))\" Object" )
        }
        self.addSublayer( node as! CALayer )
    }
    
    open func removeChild(_ node: NodeProtocol) {
        guard node is CALayer else {
            fatalError( "[SwiftyCss.CALayer.removeChild] cant remove \"\(String(describing: type(of: node)))\" Object" )
        }
        guard let layer = node as? CALayer else {
            return
        }
        if layer.superlayer == self {
            layer.removeFromSuperlayer()
        }
    }

    // MARK: -
    
    public convenience init(tag: String? = nil, id: String? = nil, class clas: String? = nil, style: String? = nil, action: Bool? = nil, disable: Bool? = nil, lazy: Bool? = nil) {
        self.init()
        self.css(tag: tag, id: id, class: clas, style: style, action: action, disable: disable, lazy: lazy)
    }
    
    public final func css(tag: String? = nil, id: String? = nil, class clas: String? = nil, style text: String? = nil, action: Bool? = nil, disable: Bool? = nil, lazy: Bool? = nil) {
        let style = self.nodeStyle
        var refresh = style.lazySet(key: "tag", value: tag)
        refresh = style.lazySet(key: "id", value: id) || refresh
        refresh = style.lazySet(key: "class", value: clas) || refresh
        refresh = style.lazySet(key: "style", value: text) || refresh
        
        if action != nil {
            self.actions = action! ? nil  : Css.nonActions
        }
        if disable != nil {
            style.disable = disable!
        }
        if lazy == true {
            style.setStatus(.lazy)
        }
        if refresh {
            style.refresh()
        }
    }
    
    public final func css(addClass clas: String) {
        if self.nodeStyle.lazySet(key: "addClass", value: clas) {
            self.nodeStyle.refresh()
        }
    }
    
    public final func css(removeClass clas: String) {
        if self.nodeStyle.lazySet(key: "removeClass", value: clas) {
            self.nodeStyle.refresh()
        }
    }
    
    public final func css(value name: String) -> Any? {
        return self.cssStyle.getValue(attribute: name)
    }
    
    public final func css(property name: String) -> String? {
        return self.nodeStyle.getProperty(name)
    }
    
    public final func css(query text: String) -> [CALayer]? {
        if let nodes = Node.query(self, text) {
            return nodes as? [CALayer]
        }
        return nil
    }
    
    public final func css(insert: String...) {
        let nodes: [NodeProtocol]?
        if insert.count == 1 {
            nodes = Node.create(text: insert[0], default: "CALayer")
        }else {
            nodes = Node.create(lines: insert, default: "CALayer")
        }
        if nodes != nil {
            for n in nodes! {
                self.addChild( n )
            }
        }
    }
    
    public final func cssRefresh() {
        Css.styleSheet.refrehs()
        self.nodeStyle.refresh()
    }

}


