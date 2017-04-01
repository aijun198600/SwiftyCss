
import UIKit
import SwiftyNode
import SwiftyBox

private var nonActions:[String : CAAction] = ["position" : NSNull(), "bounds" : NSNull(), "path" : NSNull(), "opacity":NSNull(), "origin":NSNull()]

extension CALayer: NodeProtocol {

    // MARK: - Protocol
    
    open var nodeStyle: Node.Style? {
        if let style = self.value(forKey: "_cssStyle_") {
            return style as? Node.Style
        }
        let style = CAStyle(layer: self)
        self.setValue(style, forKey: "_cssStyle_")
        return style
    }
    
    open func getAttribute(_ key: String) -> Any? {
        return self.nodeStyle?.getProperty(key)
    }
    
    open func setAttribute(_ key: String, value: Any?) {
        if key == "action" {
            self.actions = Bool(string: value) ? nil : nonActions
        }else if value is String {
            self.nodeStyle?.set(key: key, value: value as! String)
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

    // MARK: - Public
    
    public convenience init(tag: String? = nil, id: String? = nil, class clas: String? = nil, style: String? = nil, action: Bool? = nil, disable: Bool? = nil, lazy: Bool? = nil) {
        self.init()
        self.css(tag: tag, id: id, class: clas, style: style, action: action, disable: disable, lazy: lazy)
    }
    
    public func css(tag: String? = nil, id: String? = nil, class clas: String? = nil, style text: String? = nil, action: Bool? = nil, disable: Bool? = nil, lazy: Bool? = nil) {
        guard let style = self.nodeStyle else {
            return
        }
        var refresh = false
        refresh = style.lazySet(key: "tag", value: tag) || refresh
        refresh = style.lazySet(key: "id", value: id) || refresh
        refresh = style.lazySet(key: "class", value: clas) || refresh
        refresh = style.lazySet(key: "style", value: text) || refresh
        
        if action != nil {
            self.actions = action! ? nil  : nonActions
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
    
    public func css(addClass clas: String) {
        guard let style = self.nodeStyle else {
            return
        }
        if style.lazySet(key: "addClass", value: clas) {
            style.refresh()
        }
    }
    
    public func css(removeClass clas: String) {
        guard let style = self.nodeStyle else {
            return
        }
        if style.lazySet(key: "removeClass", value: clas) {
            style.refresh()
        }
    }
    
    public func css(refresh signal: Node.Status? = nil) {
        self.nodeStyle?.refresh()
    }
    
    public func css(value name: String) -> Any? {
        return self.nodeStyle?.getProperty(name)
    }
    
    public func css(property name: String) -> String? {
        return self.nodeStyle?.property[name]
    }
    
    public func css(create text: String) {
        if let nodes = Node.create(jade: text, default: "CALayer") {
            for n in nodes {
                self.addChild( n )
            }
        }
    }
    
    public func css(creates list: [String]) {
        if let nodes = Node.create(jade: list, default: "CALayer") {
            for n in nodes {
                self.addChild( n )
            }
        }
    }
    
    public func css(query text: String) -> [CALayer]? {
        let nodes = Node.query(self, text)
        if nodes.isEmpty {
            return nil
        }
        return nodes as? [CALayer]
    }

}


