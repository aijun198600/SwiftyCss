//  Created by Wang Liang on 2017/4/8.
//  Copyright © 2017年 Wang Liang. All rights reserved.

import QuartzCore
import SwiftyNode
import SwiftyBox

extension Css {
    static var nonActions:[String : CAAction] = ["position" : NSNull(), "bounds" : NSNull(), "path" : NSNull(), "opacity":NSNull(), "origin":NSNull()]
}

extension CALayer: NodeProtocol {
    
    public final var styler: Node.Styler {
        return CAStyler.make(self)
    }
    public final var cssStyler: CAStyler {
        return CAStyler.make(self)
    }
    
    open func getAttribute(_ key: String) -> Any? {
        return self.cssStyler.getValue(attribute: key)
    }
    
    open func setAttribute(_ key: String, value: Any?) {
        if key == "action" {
            self.actions = Bool(string: value) ? nil : Css.nonActions
        }else if value is String {
            self.cssStyler.set(key: key, value: value as! String)
        }
    }

    open var childNodes: [NodeProtocol] {
        return self.sublayers ?? []
    }
    
    open var parentNode: NodeProtocol? {
        return self.superlayer
    }
    
    open func addChild(_ node: NodeProtocol) {
        guard let layer = node as? CALayer else {
            fatalError( "[SwiftyCss.CALayer.addChild] cant add \"\(String(describing: type(of: node)))\" Object" )
        }
        self.addSublayer( layer )
    }
    
    open func removeChild(_ node: NodeProtocol) {
        guard let layer = node as? CALayer else {
            fatalError( "[SwiftyCss.CALayer.removeChild] cant remove \"\(String(describing: type(of: node)))\" Object" )
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
        let styler = self.cssStyler
        var refresh = styler.lazySet(key: "tag", value: tag)
        refresh = styler.lazySet(key: "id", value: id) || refresh
        refresh = styler.lazySet(key: "class", value: clas) || refresh
        refresh = styler.lazySet(key: "style", value: text) || refresh
        
        if action != nil {
            self.actions = action! ? nil  : Css.nonActions
        }
        if disable != nil {
            styler.disable = disable!
        }
        if lazy == true {
            styler.setStatus(.lazy)
        }
        if refresh {
            styler.refresh()
        }
    }
    
    public final func css(addClass clas: String) {
        if self.cssStyler.lazySet(key: "addClass", value: clas) {
            self.cssStyler.refresh()
        }
    }
    
    public final func css(removeClass clas: String) {
        if self.cssStyler.lazySet(key: "removeClass", value: clas) {
            self.cssStyler.refresh()
        }
    }
    
    public final func css(rules: String...) {
        let prefix = "&" + self.hash.description
        var text = ""
        for r in rules {
            text += prefix + " " + r + "\n"
        }
        Css.styleSheet.parse(text: text)
    }
    
    public final func css(value name: String) -> Any? {
        return self.cssStyler.getValue(attribute: name)
    }
    
    public final func css(property name: String) -> String? {
        return self.cssStyler.getProperty(name)
    }
    
    public final func css(query text: String) -> [CALayer]? {
        if let nodes = Node.query(self, text) {
            return nodes as? [CALayer]
        }
        return nil
    }
    
    public final func css(insert: String...) {
        #if DEBUG
        Node.debug.begin(tag: "insert")
        #endif
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
        #if DEBUG
        Node.debug.end(tag: "insert", {Css.debugPrint(self, noprint: true)})
        #endif
    }
    
    public final func cssRefresh() {
        Css.styleSheet.refrehs()
        self.cssStyler.refresh()
    }

}


