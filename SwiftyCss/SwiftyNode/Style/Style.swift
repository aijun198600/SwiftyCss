
import Foundation
import SwiftyBox

extension Node {

    open class Style {
        
        // MARK: - Public

        public var disable = false
        
        public private(set) weak var master: NodeProtocol?
        public private(set) weak var styleSheet: StyleSheet?
        public private(set) var id     = ""
        public private(set) var tag    = ""
        public private(set) var clas   = Set<String>()
        public private(set) var property = [String: String]()
        public private(set) var status = Status.inactive
        
        private var source = [String: String]()
        
        public var hashValue: Int { return (self.master as? NSObject)?.hashValue ?? 0 }
        
        public init(node: NodeProtocol, styleSheet: StyleSheet) {
            self.master = node
            self.styleSheet = styleSheet
            if styleSheet.lazy {
                self.status.insert(.lazy)
            }
        }
        
        public final func set(key: String, value: String) {
            if self.lazySet(key: key, value: value) {
                _ = self.updata( mark: "change" )
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
                var temp = [String: String]()
                for str in value.components(separatedBy: ";", trim: .whitespacesAndNewlines) {
                    let item = str.components(separatedBy: ":", trim: .whitespacesAndNewlines)
                    if item.count == 2 {
                        temp[item[0]] = item[1]
                        self.source[item[0]] = item[1]
                    }
                }
                self.setProperty(list: temp)
                
            default:
                self.setProperty(name: key, value: value)
            
            }
            return !self.status.contains(.lazy) && self.hasStatus(.checkAll, .needRefresh, .checkChild, .checkBorder, .checkFloatChild, .checkFloatSibling)
        }
        
        // MARK: -
        
        open func refresh(all: Bool = false, property: Bool = false) {
            if all == false && property == false && status.contains(.lazy) {
                return
            }
            if styleSheet == nil || master == nil {
                return
            }
            #if DEBUG
                Node.debugBegin(.onRefresh, style: self)
            #endif
            
            if all {
                self.setStatus( .checkAll )
            }
            self.setStatus( .updating )
            
            var ref = [String: String]()
            let matched = styleSheet!.match(node: master!)
            if matched != nil {
                for rule in matched! {
                    for (k, v) in rule.property {
                        ref[k] = v
                    }
                }
            }
            for (k, v) in self.source {
                ref[k] = v
            }
            if ref.count > 0 {
                for name in self.property.keys {
                    if ref[name] != nil {
                        continue
                    }
                    self.clearProperty(name)
                }
                self.setProperty(list: ref)
            }
            
            if property {
                Ticker.remove(style: self, keepCallback: true)
                return
            }
            
            #if DEBUG
                Node.debugEnd(.onRefresh, style: self, matched: matched)
            #endif
            
            _ = self.updata( mark: "refresh" )
        }
        
        open func updata(mark: String = "unkonw") -> Bool {
            #if DEBUG
                Node.debugEnd(.onUpdate, style: self, from: mark)
            #endif
            if status.contains(.lazy) {
                return false
            }
            Ticker.remove(style: self, keepCallback: true)
            if status.contains( .needRefresh ) {
                status.remove( .needRefresh )
                self.refresh()
                return false
            }else{
                status = .none
                return true
            }
        }
        
        // MARK: -
        
        open func setStatus(_ signal: Status) {
            if signal == .needRefresh {
                if status.contains(.lazy) {
                    return
                }
            }else if signal == .checkAll {
                status.remove(.lazy)
                status.remove(.needRefresh)
            }
            status.insert(signal)
            if !status.contains(.lazy) {
                if status.contains(.needRefresh) {
                    status = status.contains(.checkBorder) ? [.needRefresh, .checkBorder] : .needRefresh
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

        // MARK: -
        
        open func getProperty(_ name: String) -> Any? {
            if status.contains( .inactive ) {
                self.refresh( property: true )
            }
            return property[ name ]
        }
        
        open func setProperty(list: [String: String]) {
            for (name, value) in list {
                self.property[name] = value
            }
        }
        
        open func setProperty(name: String, value: String) {
            self.property[name] = value
        }
        
        open func clearProperty(_ name: String) {
            self.property[name] = nil
        }

    }
    
}

#if DEBUG
    extension Node.Style: CustomStringConvertible {
        public var description: String {
            return Node.describing(self)
        }
    }
#endif

