//  Created by Wang Liang on 2017/4/8.
//  Copyright © 2017年 Wang Liang. All rights reserved.

import Foundation
import SwiftyBox

extension Node {

    open class Styler: CustomStringConvertible {
        
        // MARK: - Public
        public let hash: Int
        public private(set) weak var master: NodeProtocol?
        public private(set) weak var styleSheet: StyleSheet?
        public private(set) var id     = ""
        public private(set) var tag    = ""
        public private(set) var clas   = Set<String>()
        public private(set) var property = [String: String]()
        public private(set) var status = Status.inactive
        open                var disable = false
        private             var source = [String: String]()
        
        public init(node: NodeProtocol, styleSheet: StyleSheet) {
            self.master = node
            self.hash = node.hash
            self.styleSheet = styleSheet
            if styleSheet.lazy {
                self.status.insert(.lazy)
            }
        }
        
        public final func set(key: String, value: String) {
            if self.lazySet(key: key, value: value) {
                self.listenStatus( mark: "change" )
            }
        }
        
        open func lazySet(key: String, value: String?) -> Bool {
            guard let value = value else {
                return false
            }
            switch key {
            case "disable":
                self.disable = value != "false"
                return false
                
            case "id":
                if self.id != value {
                    self.id = value
                    self.setStatus(.needRefresh)
                    return true
                }
                return false
                
            case "tag":
                if self.tag != value {
                    self.tag = value
                    self.setStatus(.needRefresh)
                    return true
                }
                return false
                
            case "class":
                let names = Set(value.components(separatedBy: " ", trim: .whitespaces))
                if self.clas != names {
                    self.clas = names
                    self.setStatus( .needRefresh )
                    return true
                }
                return false
                
                
            case "removeClass":
                let names = value.components(separatedBy: " ", trim: .whitespaces)
                let c = self.clas.count
                for name in names {
                    self.clas.remove(name)
                }
                if self.clas.count != c {
                    self.setStatus( .needRefresh )
                    return true
                }
                return false
                
            case "addClass":
                let names = value.components(separatedBy: " ", trim: .whitespaces)
                let c = self.clas.count
                self.clas.formUnion(names)
                if self.clas.count != c {
                    self.setStatus( .needRefresh )
                    return true
                }
                return false
                
            case "style":
                if let ref = StyleSheet.split(text: value) {
                    for (k, v) in ref {
                        self.source[k] = v
                    }
                    _ = self.setProperty(ref)
                }
            default:
                _ = self.setProperty( [key: value] )
            
            }
            
            return !self.status.contains(.lazy) && self.hasStatus(.checkAll, .needRefresh, .checkChild, .checkBorder, .checkSize, .checkHookChild, .rankFloatChild)
        }
        
        // MARK: -
        
        open func refresh(all: Bool = false, passive: Bool = false) {
            if all == false && passive == false && status.contains(.lazy) {
                return
            }
            if let list = self._checkRefresh(all: all, passive: passive) {
                for name in self.property.keys {
                    if list[name] != nil {
                        continue
                    }
                    self.clearProperty(name)
                }
                self.setProperty(list)
            }
            self.listenStatus( mark: "refresh" )
        }
        
        // MARK: -
        
        open func setStatus(_ signal: Status) {
            if signal == .none {
                status = .none
                return
            }
            if signal == .needRefresh {
                if status.contains(.lazy) {
                    return
                }
            }else if signal == .checkAll {
                status.remove( [.lazy, .needRefresh] )
            }
            if !status.contains(signal) {
                status.insert(signal)
                if [.updating, .passive].contains(signal) || status.contains(.lazy) {
                    return
                }
                Ticker.add(style: self)
            }
        }
        
        open func hasStatus(_ signal: Status...) -> Bool {
            for s in signal {
                if status.contains(s) {
                    return true
                }
            }
            return false
        }
        
        open func listenStatus(mark: String = "unkonw") {
            if self._checkStatus() {
                #if DEBUG
                Node.debug.log(tag: "status", mark, self.status, self)
                #endif
                self.status = .none
            }
        }

        // MARK: -
        
        open func getProperty(_ name: String) -> String? {
            if let value = source[name] ?? property[name] {
                return value
            }
            if status.contains( .inactive ) {
                if let matched = styleSheet!.match(node: master!) {
                    for rule in matched {
                        for (k, v) in rule.property {
                            property[k] = v
                        }
                    }
                    for (k, v) in self.source {
                        property[k] = v
                    }
                    _ = self.setProperty(property)
                    Ticker.remove(style: self, keepCallback: true)
                }
            }
            return property[name]
        }
        
        open func setProperty(_ list: [String: String]) {
            _ = self._setProperty(list)
        }
        
        open func clearProperty(_ name: String) {
            self.property[name] = nil
        }
        
        // MARK: -
        
        public final func _checkRefresh(all: Bool = false, passive: Bool = false) -> [String: String]? {
            if styleSheet == nil || master == nil {
                return nil
            }
            #if DEBUG
                Node.debug.begin(tag: "refresh")
            #endif
            if all {
                self.setStatus( .checkAll )
            }
            if passive {
                self.setStatus( .passive )
            }
            self.status.remove( .inactive )
            self.setStatus( .updating )
            
            var low = [String: String]()
            var high = [String: String]()
            let matched = styleSheet!.match(node: master!)
            if matched != nil {
                for rule in matched! {
                    if rule.selector.rules.last?.hash != nil || rule.selector.rules.last?.conditions != nil || rule.selector.rules.last?.pseudo != nil {
                        for (k, v) in rule.property {
                            high[k] = v
                        }
                    }else{
                        for (k, v) in rule.property {
                            low[k] = v
                        }
                    }
                }
            }
            for (k, v) in self.source {
                low[k] = v
            }
            for (k, v) in high {
                low[k] = v
            }
            #if DEBUG
                Node.debug.end(tag: "refresh", self, self.status, matched)
            #endif
            return low.isEmpty ? nil : low
        }
        
        public final func _checkStatus() -> Bool {
            Ticker.remove(style: self, keepCallback: true)
            if status.contains(.lazy) {
                return false
            }
            if status.contains( .needRefresh ) {
                status = .none
                self.refresh()
                return false
            }else if self.hasStatus(.checkAll, .checkChild, .checkBorder, .checkSize, .checkHookChild, .rankFloatChild) {
                return true
            }else{
                status = .none
                return false
            }
        }
        
        public final func _setProperty(_ list: [String: String]) -> [String: String] {
            var available = [String: String]()
            for (name, value) in list {
                if name == "disable" {
                    self.disable = value != "none"
                }else if value == "none" {
                    self.clearProperty(name)
                }else if self.property[name] != value {
                    self.property[name] = value
                    available[name] = value
                }
            }
            return available
        }
        
        // MARK: -
        
        public var description: String {
            var text = self.id.isEmpty ? "" : " id=\"\(self.id)\""
            text += self.clas.isEmpty ? "" : " class=\"\(self.clas.joined(separator: " "))\""
            var temp = ""
            for (k, v) in self.property {
                if k == "content" {
                    continue
                }
                temp += k + ":" + v + ";"
            }
            if !temp.isEmpty {
                text += " style=\"\(temp[0, -1])\""
            }
            let type = self.master == nil ? self.tag : String(describing: type(of:self.master!))
            if type == self.tag{
                text = "<\(type)\(text)>"
            } else {
                text = "<\(type):\(self.tag)\(text)>"
            }
            return text
        }
        
    }
    
}


