
import Foundation
import SwiftyBox

extension Node {
    
    public class StyleSheet : CustomStringConvertible {
        
        public var lazy = false
        private var list     = [Rule]()
        private var idMap    = [String:[Rule]]()
        private var tagMap   = [String:[Rule]]()
        private var classMap = [String:[Rule]]()
        private var atRuleCache:[Int: Bool]? = nil
        
        public init(){}
        
        final func add(rule: Rule) {
            guard let select_rule = rule.selector?.rules.last else {
                return
            }
            self.list.append( rule)
            rule.sortIndex = self.list.count
            
            if let name = select_rule.id {
                if self.idMap[name] == nil {
                    self.idMap[name] = [Rule]()
                }
                self.idMap[name]!.append(rule)
            }
            if let name = select_rule.tag?.lowercased() {
                if self.tagMap[name] == nil {
                    self.tagMap[name] = [Rule]()
                }
                self.tagMap[name]!.append(rule)
            }
            for name in select_rule.clas {
                if self.classMap[name] == nil {
                    self.classMap[name] = [Rule]()
                }
                self.classMap[name]!.append(rule)
            }
            
        }
        
        public final func parse(text: String){
            
            let text = StyleSheet.COMM_RE.replace(text, "")
            
            for block in StyleSheet.AT_RE.explode(text, trim: .whitespacesAndNewlines) {
                
                var block = block
                var atRule: AtRule? = nil
                
                if block.hasPrefix("@"){
                    guard let m = StyleSheet.AT_RE.match(block) else {
                        continue
                    }
                    atRule = AtRule( "@" + m[1]! )
                    block  = m[2]!
                    if block.isEmpty {
                        _ = atRule?.run(in: self)
                        continue
                    }
                }
                
                for item in block.components(separatedBy: "}", trim: .whitespacesAndNewlines) {
                    let temp = item.components(separatedBy: "{", trim: .whitespacesAndNewlines)
                    guard temp.count == 2 else {
                        continue
                    }
                    let value = StyleSheet.CAMEL_RE.replace(temp[1], {m in return m[1]!.uppercased()})
                    for sel in temp[0].components(separatedBy: ",", trim: .whitespacesAndNewlines) {
                        self.add(rule: Rule(selector: sel, property: value, atRule: atRule) )
                    }
                }
            }
        }
        
        public final func match(node: NodeProtocol) -> [Rule]? {
            guard let style = node.nodeStyle else {
                return nil
            }
            var list = [Rule]()
            if self.idMap[style.id] != nil {
                list += self.idMap[style.id]!
            }
            if self.tagMap[style.tag.lowercased()] != nil {
                list += self.tagMap[style.tag.lowercased()]!
            }
            if self.tagMap["*"] != nil {
                list += self.tagMap["*"]!
            }
            for name in style.clas {
                if self.classMap[name] != nil {
                    list += self.classMap[name]!
                }
            }
            if list.isEmpty {
                return nil
            }
            var res = [Rule]()
            for rule in list.sorted(by: StyleSheet.sort) {
                guard checkAtRule( rule.atRule ) else {
                    continue
                }
                if rule.check(node: node) {
                    res.append( rule )
                }
            }
            return res.isEmpty ? nil : res
        }
        
        public final func refresh() {
            self.atRuleCache = nil
        }
        
        private func checkAtRule(_ atRule: Node.AtRule?) -> Bool {
            guard let id = atRule?.hashValue else {
                return true
            }
            if atRuleCache == nil {
                DispatchQueue.main.asyncAfter(deadline: .now()){
                    self.atRuleCache = nil
                }
                atRuleCache = [:]
            }
            
            if atRuleCache![ id ] == nil {
                atRuleCache![id] = atRule!.run(in: self)
            }
            if atRuleCache![id] == false {
                return false
            }
            return true
        }
        
        public var description: String {
            var desc = [String]()
            for s in list {
                desc.append( s.description )
            }
            return desc.joined(separator: "\n")
        }

        
        // MARK: - Static
        
        static func sort(_ a: Rule, _ b: Rule) -> Bool {
            let _a = a.selector!.rules.last?.description.characters.count ?? 0
            let _b = b.selector!.rules.last?.description.characters.count ?? 0
            if _a == _b {
                return a.sortIndex < b.sortIndex
            }
            return _a < _b
        }
        
        
        // MARK: - Private Static
        
        private static let CAMEL_RE = Re("-([a-z])")
        private static let COMM_RE = Re("\\/\\*(?:.|\\s)*?\\*\\/")
        private static let AT_RE = Re("@([^{\\n@;]+)(?:\\s*\\{((?:\\{[^}]*\\}|[^}])*)\\}|\\s*?[\\n;])?")
        
    }
    
}
