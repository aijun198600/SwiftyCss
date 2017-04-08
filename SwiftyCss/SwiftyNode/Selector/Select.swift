//  Created by Wang Liang on 2017/4/8.
//  Copyright © 2017年 Wang Liang. All rights reserved.

import Foundation
import SwiftyBox

extension Node {
    
    public class Select: CustomStringConvertible {
        
        private static let _lexer = Re("([>+~])\\s*")
        
        // MARK: -
        
        let rules: [SelectRule]

        public init(_ text: String) {
            var rules = [SelectRule]()
            for patt in Re.lexer(code: Select._lexer.replace(text, " $1"), separator: " ") {
                rules.append( SelectRule(patt, forCreate: false) )
            }
            self.rules = rules
        }
        
        init(creater text: String) {
            var rules = [SelectRule]()
            for patt in Re.lexer(code: Select._lexer.replace(text, " $1"), separator: " ") {
                rules.append( SelectRule(patt, forCreate: true) )
            }
            self.rules = rules
        }
        
        // MARK: -
        
        public final func check(_ node: NodeProtocol) -> Bool{
            return self._checkRule(node, rules.count - 1)
        }
        
        public final func query(_ node: NodeProtocol) -> [NodeProtocol]? {
            let at = self.rules.count - 1
            guard at >= 0 else {
                return nil
            }
            var result = [NodeProtocol]()
            self._queryChild(node, &result, at)
            return result.isEmpty ? nil : result
        }
        
        // MARK: -

        private final func _queryChild(_ node: NodeProtocol, _ result: inout [NodeProtocol], _ at: Int) {
            for child in node.childNodes {
                if self._checkRule(child, at) {
                    result.append(child)
                }
                self._queryChild(child, &result, at)
            }
        }
        
        private final func _checkRule(_ node: NodeProtocol, _ at: Int) -> Bool {
            guard at >= 0 && rules[at].check(node) else {
                return false
            }
            if at == 0 {
                return true
            }
            var node = node
            for at in (0 ... at-1).reversed() {
                let last = rules[at + 1]
                
                if last.combinator == "+" || last.combinator == "~" {
                    return self._checkCombinator(last.combinator!, node, at)
                }
                
                let rule = self.rules[at]
                while true {
                    if node.parentNode == nil {
                        return false
                    }
                    node = node.parentNode!
                    if rule.check(node) == false {
                        if last.combinator == ">" {
                            return false
                        }
                    }else{
                        break
                    }
                }
            }
            return true
        }
        
        private final func _checkCombinator(_ combinator: String, _ node: NodeProtocol, _ at: Int) -> Bool {
            if let sibling = node.parentNode?.childNodes {
                for i in 0 ..< sibling.count {
                    if sibling[i].hash == node.hash {
                        if i == 0 {
                            return false
                        }
                        if combinator == "+" {
                            return self._checkRule(sibling[i-1], at)
                        }else{
                            for j in 0 ..< i {
                                if self._checkRule(sibling[j], at) {
                                    return true
                                }
                            }
                        }
                        return false
                    }
                }
            }
            return false
        }

        public var description:String {
            var desc = [String]()
            for r in self.rules {
                desc.append( r.description )
            }
            return desc.joined(separator: " ")
        }
        
    }
    
}


