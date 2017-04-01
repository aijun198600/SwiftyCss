

import Foundation
import SwiftyBox

extension Node {
    
    public class Select: CustomStringConvertible {
        
        private static let lexer = Re("([>+~])\\s*")
        
        
        private(set) var rules: [SelectRule] = []
        public let description:String
        
        public init(_ text: String) {
            let list = Re.lexer(code: Select.lexer.replace(text, " $1"), separator: " ")
            for patt in list {
                self.rules.append( SelectRule(patt) )
            }
            var desc = [String]()
            for r in self.rules {
                desc.append( r.description )
            }
            self.description = desc.joined(separator: " ")
        }
        
        public final func query (_ node: NodeProtocol) -> [NodeProtocol]{
            var res = [NodeProtocol]()
            self._query(node, &res)
            return res
        }
        
        public final func check(_ node: NodeProtocol) -> Bool{
            return self._check(node)
        }
        
        private func _query(_ node: NodeProtocol, _ res: inout [NodeProtocol], offset: Int = 0) {
            guard offset < self.rules.count else {
                return
            }
            let rule = self.rules[offset]
            
            if rule.combinator == "+" || rule.combinator == "~" {
                if let index = Node.index(of: node) {
                    let children = node.parentNode!.childNodes
                    if index + 1 < children.count {
                        if rule.combinator == "+" {
                            self._match(children[index + 1], &res, offset: offset)
                        }else{
                            for i in (index + 1) ..< children.count {
                                self._match(children[i], &res, offset: offset)
                            }
                        }
                    }
                }
            }else{
                for child in node.childNodes {
                    self._match(child, &res, offset: offset)
                }
            }
        }
        
        private func _match(_ node: NodeProtocol, _ res: inout [NodeProtocol], offset: Int = 0) {
            guard offset >= 0 && offset < self.rules.count else {
                return
            }
            for n in res {
                if n.isEqual(node) {
                    return
                }
            }
            let rule = self.rules[offset]
            let isLast = (offset == self.rules.count - 1)
            if let ref = rule.match( node ) {
                if isLast {
                    add: for r in ref {
                        for i in (0 ..< res.count).reversed() {
                            if res[i].isEqual(r) {
                                continue add
                            }
                        }
                        res.append(r)
                    }
                    if rule.combinator != ">" {
                        self._query(node, &res, offset: offset)
                    }
                }else{
                    for r in ref {
                        self._query(r, &res, offset: offset + 1)
                    }
                }
            }else{
                if rule.combinator == ">" {
                    self._match(node, &res, offset: offset - 1)
                }else{
                    self._query(node, &res, offset: offset)
                }
            }
        }
        
        private func _check(_ node: NodeProtocol, offset: Int = -1) -> Bool {
            var node = node
            let offset = offset < 0 ? self.rules.count + offset : offset
            
            guard offset < self.rules.count else {
                return false
            }
            
            if self.rules[offset].match(node) == nil {
                return false
            }
            
            for i in (0 ..< offset).reversed() {
                
                let rule = self.rules[i]
                let lastRule = self.rules[i + 1]
                
                if lastRule.combinator == "+" || lastRule.combinator == "~" {
                    guard let index = Node.index(of: node) else {
                        return false
                    }
                    guard index >= 1 else {
                        return false
                    }
                    if lastRule.combinator == "+" {
                        return self._check( node.parentNode!.childNodes[index - 1], offset: i)
                    }else{
                        for j in 0 ..< index {
                            if self._check( node.parentNode!.childNodes[j], offset: i) {
                                return true
                            }
                        }
                    }
                    return false
                }
        
                while true {
                    if node.parentNode == nil {
                        return false
                    }
                    node = node.parentNode!
                    if rule.match(node) == nil {
                        if lastRule.combinator == ">" {
                            return false
                        }
                    }else{
                        if i == 0 {
                            return true
                        }
                        break
                    }
                }
            }
            return true
        }
        
        
    }
    
}


