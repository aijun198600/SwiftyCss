
import Foundation
import SwiftyBox

extension Node {
    
    public class StyleSheet : CustomStringConvertible {
        
        private static let _comment_lexer = Re("\\/\\*(?:.|\\s)*?\\*\\/")
        private static let _atrule_lexer = Re("(@[^{\\n@;]+)(?:\\s*\\{((?:\\{[^}]*\\}|[^}])*)\\}|\\s*?[\\n;])?")
        private static let _camel_lexer = Re("-([a-z])")
        
        // MARK: -
        
        public  var lazy          = false
        private var _rules        = [StyleRule]()
        private var _rulesById    = [String: [Int]]()
        private var _rulesByTag   = [String: [Int]]()
        private var _rulesByClass = [String: [Int]]()
        private var _atRuleCache:[Int: Bool]? = nil
        
        public init(){}
        
        public final func refrehs(){
            self._atRuleCache = nil
        }
        
        public final func clear(){
            self._rules.removeAll()
            self._rulesById.removeAll()
            self._rulesByTag.removeAll()
            self._rulesByClass.removeAll()
            self._atRuleCache = nil
        }
        
        public final func parse(text: String){
            
            let text = StyleSheet._comment_lexer.replace(text, "")
            #if DEBUG
                Node.debug.begin(tag: "load", id: text.hashValue)
            #endif
            
            var str = text
            while let m = StyleSheet._atrule_lexer.match(str) {
                if m.index > 0 {
                    self._parse( str.slice(start: 0, end: m.index), atRule: nil)
                }
                str = str.slice(start: m.lastIndex+1)
                let at_rule = AtRule( m[1]! )
                if m[2]!.isEmpty {
                    _ = at_rule.run(with: self)
                    #if DEBUG
                        Node.debug.begin(tag: "load", id: text.hashValue)
                    #endif
                }else{
                    self._parse(m[2]!, atRule: at_rule)
                }
            }
            if !str.isEmpty {
                self._parse( str, atRule: nil)
            }
           
            #if DEBUG
                Node.debug.end(tag: "load", id: text.hashValue, self)
            #endif
            
        }
        
        public final func match(node: NodeProtocol) -> [StyleRule]? {
            let style = node.nodeStyle
            var indexs = Set<Int>()
            
            if _rulesById[ style.id ] != nil {
                indexs.formUnion( _rulesById[ style.id ]! )
            }
            if _rulesByTag[ style.tag ] != nil {
                indexs.formUnion( _rulesByTag[ style.tag ]! )
            }
            if _rulesByTag["*"] != nil {
                indexs.formUnion( _rulesByTag["*"]! )
            }
            for name in style.clas {
                if _rulesByClass[name] != nil {
                    indexs.formUnion( _rulesByClass[name]! )
                }
            }
            
            if indexs.count > 0 {
                if _atRuleCache == nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 ){
                        self._atRuleCache = nil
                    }
                    _atRuleCache = [:]
                }
                var res = [StyleRule]()
                for i in indexs {
                    if let id = _rules[i].atRule?.hashValue {
                        if _atRuleCache?[id] != true {
                            if _atRuleCache?[id] == false {
                                continue
                            }else {
                                if _rules[i].atRule!.run(with: self) {
                                    _atRuleCache?[id] = true
                                }else{
                                    _atRuleCache?[id] = false
                                    continue
                                }
                            }
                        }
                    }
                    if _rules[i].check(node: node) {
                        res.append( _rules[i] )
                    }
                }
                if res.count > 0 {
                    return res.sorted(by: StyleSheet.sort)
                }
            }
            return nil
        }
        
        private final func _parse(_ text: String, atRule: AtRule?) {
            for item in text.components(separatedBy: "}", trim: .whitespacesAndNewlines) {
                let temp = item.components(separatedBy: "{", trim: .whitespacesAndNewlines)
                guard temp.count == 2 else {
                    continue
                }
                let value = StyleSheet._camel_lexer.replace(temp[1], {m in return m[1]!.uppercased()})
                for sel in temp[0].components(separatedBy: ",", trim: .whitespacesAndNewlines) {
                    self._add(rule: StyleRule(selector: sel, property: value, atRule: atRule) )
                }
            }
        }
        
        private final func _add( rule: StyleRule ) {
            guard let key = rule.selector.rules.last else {
                return
            }
            
            let index = _rules.count
            rule.sortIndex = index
            _rules.append( rule )
            
            if let name = key.id {
                if _rulesById[name] == nil {
                    _rulesById[name] = []
                }
                _rulesById[name]!.append(index)
                
            }else if let name = key.tag {
                if _rulesByTag[name] == nil {
                    _rulesByTag[name] = []
                }
                _rulesByTag[name]!.append(index)
                
            }else {
                for name in key.clas {
                    if _rulesByClass[name] == nil {
                        _rulesByClass[name] = []
                    }
                    _rulesByClass[name]!.append(index)
                }
            }
        }
        

        // MARK: -
        
        public var description: String {
            var desc = ""
            var atrule = [String: String]()
            for rule in _rules {
                if rule.atRule == nil {
                    desc += rule.description + "\n"
                }else{
                    let at_text = rule.atRule!.description
                    if atrule[at_text] == nil {
                        atrule[at_text] = ""
                    }
                    atrule[at_text]! += "    " + rule.description.slice(start: at_text.characters.count+1) + "\n"
                }
            }
            for (key, value) in atrule {
                desc += key + " {\n" + value + "}\n"
            }
            return desc
        }

        
        // MARK: - Static
        
        static func sort(_ a: StyleRule, _ b: StyleRule) -> Bool {
            if a.sortPriority == b.sortPriority {
                return a.sortIndex < b.sortIndex
            }
            return a.sortPriority < b.sortPriority
        }
        
    }
    
}
