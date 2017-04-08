//  Created by Wang Liang on 2017/4/8.
//  Copyright © 2017年 Wang Liang. All rights reserved.

import QuartzCore
import SwiftyNode
import SwiftyBox

public class CAStyler: Node.Styler {
    
    public static var cache = [Int: Weak<CAStyler>]()
    
    static func make(_ layer: CALayer) -> CAStyler {
        let hash = layer.hash
        if let style = cache[ hash ]?.value {
            return style
        }
        let style = CAStyler(layer: layer)
        layer.setValue(style, forKey: "_node_style_")
        cache[hash] = Weak(style)
        return style
    }
    
    // MARK: -
    
    private(set) weak var layer: CALayer?

    public var padding: (top:CGFloat, right:CGFloat, bottom:CGFloat, left:CGFloat) = (0, 0, 0, 0)
    public var margin: (top:CGFloat, right:CGFloat, bottom:CGFloat, left:CGFloat) = (0, 0, 0, 0)
    
    var border: [String]? = nil
    weak var borderLayer: CAShapeLayer? = nil
    
    var hooks: Set<Int> = []
    
//    var _disable = false
    private var _is_follower = false
    private var _is_hooker = false
    private var _listen_bounds = false
    private var _sublayer_count: Int = 0
    
    init( layer: CALayer ) {
        self.layer = layer
        super.init(node: layer, styleSheet: Css.styleSheet)
        layer.addObserver( CAStyler.listener, forKeyPath: "sublayers", options: [], context: nil)
        layer.addObserver( CAStyler.listener, forKeyPath: "hidden", options: [.new], context: nil)
    }
    
    deinit {
        CAStyler.cache[self.hash] = nil
    }
    
    public override final var disable: Bool {
        get { return super.disable }
        set {
            guard super.disable != newValue else {
                return
            }
            super.disable = newValue
            if newValue {
                layer?.removeObserver(CAStyler.listener, forKeyPath: "sublayers")
                layer?.removeObserver(CAStyler.listener, forKeyPath: "hidden")
                if self._listen_bounds {
                    layer?.removeObserver(CAStyler.listener, forKeyPath: "bounds")
                }
            }else{
                layer?.addObserver( CAStyler.listener, forKeyPath: "sublayers", options: [], context: nil)
                layer?.addObserver( CAStyler.listener, forKeyPath: "hidden", options: [.new], context: nil)
                if self._listen_bounds {
                    layer?.addObserver(CAStyler.listener, forKeyPath: "bounds", options: [.new, .old], context: nil)
                }
            }
        }
    }
    
    public override final func refresh(all: Bool = false, passive: Bool = false) {
        if self.disable {
            return
        }
        self._refresh(all: all, passive: passive, async: Css._async)
    }
    
    public override final func listenStatus(mark: String = "unkonw") {
        if self._checkStatus() {
            guard let layer = self.layer else {
                return
            }
            #if DEBUG
            Node.debug.log(tag: "status", mark, self.status, self)
            #endif
            
            let check_all   = status.contains(.checkAll)
            let check_child = status.contains(.checkChild)
            let check_hook  = status.contains(.checkHookChild)
            let rank_float  = status.contains(.rankFloatChild)
            
            if check_all || check_child || rank_float || check_hook {
                if let sublayers = layer.sublayers {
                    var float_children = [CALayer]()
                    for sub in sublayers {
                        if sub.isHidden {
                            continue
                        }
                        let sub_styler = sub.cssStyler
                        if sub_styler.disable {
                            continue
                        }
                        if check_all {
                            sub_styler.refresh(all: true, passive: true)
                            if Css._async == false {
                                if sub_styler.property["float"] != nil {
                                    float_children.append(sub)
                                }
                                sub_styler.setStatus(.none)
                            }
                            continue
                        }
                        if check_child {
                            sub_styler.refresh(passive: true)
                            continue
                        }
                        if sub_styler.status.contains(.inactive) {
                            sub_styler._refresh( passive: true )
                        }else if check_hook {
                            if self.hooks.contains(sub_styler.hash) {
                                sub_styler.refresh(passive: true)
                            }
                        }
                        if rank_float && sub_styler.property["float"] != nil {
                            float_children.append(sub)
                        }
                    }
                    if !float_children.isEmpty {
                        CAStyler.updataFloatLayer(self, float_children)
                    }else{
                        if Css._async {
                            self.setStatus(.none)
                            if status.contains(.checkBorder) {
                                self.setStatus(.checkBorder)
                            } else if self.property["autoSize"] != nil {
                                self.setStatus(.checkSize)
                            }
                            return
                        }
                    }
                }
            }
            if self.property["autoSize"] != nil {
                CAStyler.updataAutoSize(self)
            }
            if status.contains(.checkBorder) || (self.borderLayer != nil && self.borderLayer!.frame != layer.bounds) {
                CAStyler.updataBorderLayer(self)
            }
            self.setStatus(.none)
        }
    }
    

    final func _refresh(all: Bool = false, passive: Bool = false, async: Bool = false) {
        if self.tag.isEmpty {
            if layer!.delegate != nil {
                _ = self.lazySet(key: "tag", value: String(describing: type(of: layer!.delegate!) ))
            }else{
                _ = self.lazySet(key: "tag", value: String(describing: type(of: layer!) ))
            }
        }
        if all == false && passive == false && status.contains(.lazy) {
            return
        }
        if async {
            Node.Ticker.add {
                guard let list = self._checkRefresh(all: all, passive: passive) else {
                    self.listenStatus( mark: "refresh" )
                    return
                }
                DispatchQueue.main.async {
                    for name in self.property.keys {
                        if list[name] != nil {
                            continue
                        }
                        self.clearProperty(name)
                    }
                    self.setProperty(list)
                    self.listenStatus( mark: "refresh" )
                }
            }
        }else{
            super.refresh(all: all, passive: passive)
        }
    }
    
    // MARK: -
    
    public override final func setProperty(_ list: [String: String]) {
        if self.disable || self.layer?.isHidden == true {
            return
        }
        var available = self._setProperty(list)
        if self._is_follower == false {
            self._is_follower = CAStyler.hasFollower(property: available)
        }
        if self._is_follower {
            if !self._is_hooker {
                if let parent_styler = self.layer?.superlayer?.cssStyler {
                    self._is_hooker = true
                    parent_styler.hooks.insert( self.hash )
                }
            }
            if self.status.contains(.passive) {
                for (k, v) in list {
                    if v.characters.index(of: "%") != nil || k == "right" || k == "bottom" {
                        available[k] = v
                    }
                }
            }
        }
        if self._listen_bounds == false {
            if self.property["float"] != nil || !self.hooks.isEmpty {
                self._listen_bounds = true
                self.layer!.addObserver(CAStyler.listener, forKeyPath: "bounds", options: [.new, .old], context: nil)
            }
        }
        
        self.animateBegin()
        
        CAStyler.setProperty(self, list, available)
        
        self.animateCommit()
    }
        
    public override final func clearProperty(_ name: String) {
        super.clearProperty(name)
        CAStyler.clearProperty(self, name)
    }
    
    // MARK: -
    
    final func animateBegin() {
        if self.layer?.actions == nil {
            CATransaction.begin()
            if let ani = self.property["animate"], let t = Double(ani) {
                CATransaction.setAnimationDuration(t)
            }else{
                CATransaction.setDisableActions(true)
            }
        }
    }
    
    final func animateCommit() {
        if self.layer?.actions == nil {
            CATransaction.commit()
        }
    }
    
    // MARK: -  CAStyle Listener Class
    
    private static let listener = Listener()
    
    private class Listener: NSObject {
        
        override final func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            guard let keyPath = keyPath, let layer = object as? CALayer else {
                return
            }
            guard let style = CAStyler.cache[layer.hash]?.value else {
                return
            }
            if style.disable || style.hasStatus(.inactive, .lazy, .updating) {
                return
            }
            switch keyPath {
            case "sublayers":
                let count = layer.sublayers?.count ?? 0
                if count > style._sublayer_count {
                    for sub in layer.sublayers! {
                        if sub.cssStyler.hasStatus(.inactive) {
                            sub.cssStyler.refresh( all:true, passive: true)
                        }
                    }
                }else if count > 0 {
                    style.setStatus( .checkChild )
                }
                style._sublayer_count = count
                
            case "bounds":
                guard let new = change?[.newKey] as? CGRect, let old = change?[.oldKey] as? CGRect else {
                    return
                }
                if new.size == old.size {
                    return
                }
                if style.property["float"] != nil {
                    layer.superlayer?.cssStyler.setStatus( .rankFloatChild )
                }else if !style.hooks.isEmpty {
                    style.setStatus( .checkHookChild )
                }
                
            case "hidden":
                guard let hidden = change?[.newKey] as? Bool else {
                    return
                }
                
                if !hidden {
                    style.setStatus( .needRefresh )
                }else{
                    if style.property["float"] != nil {
                        layer.superlayer?.cssStyler.setStatus( .rankFloatChild )
                    }
                }
                
            default:
                break
            }
            #if DEBUG
            Node.debug.log(tag: "listen", keyPath, style.status, style)
            #endif
        }
    
    }
    
}

