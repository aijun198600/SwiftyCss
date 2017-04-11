//  Created by Wang Liang on 2017/4/8.
//  Copyright © 2017年 Wang Liang. All rights reserved.

import UIKit
import SwiftyNode
import SwiftyBox

extension UIView: NodeProtocol {
    
    // MARK: - Protocol
    
    public final var styler: Node.Styler {
        return layer.cssStyler
    }
    
    public final var cssStyler: CAStyler {
        return layer.cssStyler
    }
    
    open func getAttribute(_ key: String) -> Any? {
        return layer.getAttribute(key)
    }
    
    open func setAttribute(_ key: String, value: Any?) {
        layer.setAttribute(key, value: value)
    }
    
    open var parentNode: NodeProtocol? {
        return superview
    }
    
    open var childNodes: [NodeProtocol] {
        guard let subs = self.layer.sublayers else {
            return []
        }
        var nodes = subs as [NodeProtocol]
        for v in self.subviews {
            if let i = subs.index(of: v.layer) {
                nodes[i] = v
            }
        }
        return nodes
    }
    
    open func addChild(_ node: NodeProtocol) {
        if node is CALayer {
            self.layer.addSublayer(node as! CALayer)
        }else if node is UIView {
            self.addSubview(node as! UIView)
        }else{
           fatalError( "[SwiftyCss.UIView.addChild] cant add \"\(String(describing: type(of: node)))\" Object" )
        }
    }
    
    open func removeChild(_ node: NodeProtocol) {
        if node is UIView {
            let view = node as! UIView
            if view.superview == self {
                view.removeFromSuperview()
            }
        }else if node is CALayer{
            self.layer.removeChild( node )
        }else{
            fatalError( "[SwiftyCss.UIView.removeChild] cant remove \"\(String(describing: type(of: node)))\" Object" )
        }
    }
    
    // MARK: -
    
    public final func css(tag: String? = nil, id: String? = nil, class clas: String? = nil, style text: String? = nil, action: Bool? = nil, disable: Bool? = nil, lazy: Bool? = nil) {
        self.layer.css(tag: tag, id: id, class: clas, style: text, action: action, disable: disable, lazy: lazy)
    }
    
    public final func css(addClass clas: String) {
        self.layer.css(addClass: clas)
    }
    
    public final func css(removeClass clas: String) {
        self.layer.css(removeClass: clas)
    }
    
    public final func css(rules: String...) {
        for r in rules {
            self.layer.css(rules: r)
        }
    }
    
    public final func css(value name: String) -> Any? {
        return self.layer.css(value: name)
    }
    
    public final func css(property name: String) -> String? {
        return self.layer.css(property: name)
    }
    
    public final func css(query text: String) -> [CALayer]? {
        return self.layer.css(query: text)
    }
    
    public final func css(insert: String...) {
        let nodes: [NodeProtocol]?
        if insert.count == 1 {
            nodes = Node.create(text: insert[0], default: "UIView")
        }else {
            nodes = Node.create(lines: insert, default: "UIView")
        }
        if nodes != nil {
            for n in nodes! {
                self.addChild( n )
            }
        }
    }

    public final func cssRefresh() {
        self.layer.cssRefresh()
    }
    
}

