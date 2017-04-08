//  Created by Wang Liang on 2017/4/8.
//  Copyright © 2017年 Wang Liang. All rights reserved.

import Foundation
import CoreGraphics
import SwiftyBox

extension Node {
    
    public class Expression: CustomStringConvertible {
        
        private static let _lexer = Re("\\(|(?<=[\\w)]) *([&|]{2}|[<>=!]=?|[~|^$*]=|[+\\-*/(),])")
        
        private static let _operators = [
            ")" :-1, "," : -1,
            "*" :0, "/" :0,
            "+" :1, "-" :1,
            "<" :2, ">" :2, "=" :2, "<=":2, ">=":2, "!=":2, "==":2,
            "~=":2, "|=":2, "^=":2, "$=":2, "*=":2,
            "&&":3, "||":3
        ]
        
        // MARK: -
        
        public let exps: [String]
        public let description: String
        
        public init(_ text: String){
            self.exps = Expression._lexer.explode(text, trim: .whitespacesAndNewlines)
            self.description = exps.joined()
        }
        
        public final subscript (index: Int) -> String? {
            return index >= 0 && index < self.exps.count ? self.exps[index] : nil
        }
        
        public final func run(with node: NodeProtocol) -> Any? {
            var offset = 0
            return self._parseExps(&offset, node)
        }
        
        
        // MARK: - Private
        
        private final func _parseExps(_ i: inout Int, _ node: NodeProtocol, priority: Int = 3) -> Any? {
            
            var res = priority == 0 ? self._parseValue(&i, node) : self._parseExps(&i, node, priority: priority - 1)
            if res == nil {
                return nil
            }
            while let oper = self[i + 1] {
                
                if Expression._operators[oper] == nil {
                    assertionFailure("[SwiftNode Expression Error] nonsupport operator: \(self.exps) At \(i)")
                    return nil
                }
                
                if Expression._operators[oper] != priority {
                    break
                }
                if oper == "&&" && !Bool(res) {
                    return nil
                }
                if oper == "||" && Bool(res) {
                    return true
                }
                i += 2
                guard let ref = self._parseExps(&i, node, priority: priority) else {
                    return nil
                }
                res = self._parseOperation(res, oper, ref)
                if res == nil {
                    return nil
                }
            }
            return res
        }
        
        private final func _parseValue(_ i: inout Int, _ node: NodeProtocol) -> Any? {
            guard let exp = self[i] else {
                assertionFailure("[SwiftNode Expression Error] parse failure : \(self.exps) At \(i)")
                return false
            }
            if exp == "(" {
                return self._parseGoupe(&i, node)
            }
            if exp.hasPrefix("\"") {
                return exp[1, -1]
            }
            if let f = Float(exp) {
                return f
            }
            if let params = self._parseParams(&i, node) {
                return params.isEmpty ? nil : self._parseMethod(&i, node, name: exp, params: params)
            }else{
                return node.getAttribute(exp)
            }
        }
        
        private final func _parseGoupe(_ i: inout Int, _ node: NodeProtocol) -> Any? {
            i += 1
            let ref = self._parseExps(&i, node)
            i += 1
            if self[i] != ")" {
                assertionFailure("[SwiftNode Expression Error] parse failure : \(self.exps) At \(i)")
                return false
            }
            return ref
        }
        
        private final func _parseMethod(_ i: inout Int, _ node: NodeProtocol, name: String, params:[Any]) -> Any? {
            var ref: CGFloat? = nil
            switch name {
            case "max":
                for v in params {
                    if let f = CGFloat(v) {
                        ref = ref == nil ? f : max(ref!, f)
                    }
                }
                
            case "min":
                for v in params {
                    if let f = CGFloat(v) {
                        ref = ref == nil ? f : min(ref!, f)
                    }
                }
            default:
                break
            }
            return ref
        }
        
        private final func _parseParams(_ i: inout Int, _ node: NodeProtocol) -> [Any]? {
            guard self[i + 1] == "(" else {
                return nil
            }
            
            var params = [Any]()
            i += 2
            while i < self.exps.count {
                guard let ref = self._parseExps(&i, node) else {
                    return []
                }
                params.append( ref )
                i += 1
                if self[i] == "," {
                    i += 1
                    continue
                }
                if self[i] == ")" {
                    break
                }
                assertionFailure("[SwiftNode Expression Error] parse failure : \(self.exps) At \(i)")
                return []
            }
            return params
        }
        
        private final func _parseOperation (_ left: Any?, _ oper: String, _ right: Any?) -> Any? {
            if left == nil || right == nil {
                return nil
            }
            switch oper {
            case "*", "/", "+", "-", "<", ">", "<=", ">=":
                guard let l = CGFloat(left), let r = CGFloat(right) else {
                    return nil
                }
                switch oper {
                case "*":
                    return l * r
                case "/":
                    return l / r
                case "+":
                    return l + r
                case "-":
                    return l - r
                case "<":
                    return l < r ? true : nil
                case ">":
                    return l > r ? true : nil
                case "<=":
                    return l <= r ? true : nil
                default:
                    return l >= r ? true : nil
                }
                
            case "=", "!=", "==":
                guard left is NSObject && right is NSObject else {
                    return nil
                }
                let ref = (left as! NSObject).hashValue == (left as! NSObject).hashValue
                return (oper == "!=" ? !ref : ref) ? true : nil
                
            case "~=", "|=", "^=", "$=", "*=":
                guard left is String && right is String else {
                    return nil
                }
                let l = left as! String
                let r = left as! String
                switch oper {
                case "|=", "^=":
                    return  l.hasPrefix(r) ? true : nil
                case "$=":
                    return l.hasSuffix(r) ? true : nil
                default:
                    return l.contains(r) ? true : nil
                }
                
            default:
                break
            }
            return nil
        }
        
    }
    
}
