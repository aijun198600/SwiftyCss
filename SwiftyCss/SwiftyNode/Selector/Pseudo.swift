
import Foundation
import SwiftyBox

extension Node {
    
    public class Pseudo {
        
        // MARK: - Public Static
        
        public typealias Parser = (String?, SelectRule, NodeProtocol) -> [NodeProtocol]?
        
        // MARK: - Static
        
        static var parsers:[String: Parser] = [
            
            "nth-child" : nthChild,
            
            "first-child" : {
                return nthChild(index: 1, rule: $1, node: $2)
            },
            
            "last-child" : {
                return nthChild(index: -1, rule: $1, node: $2)
            },
            
            "root" : {
                var root = $2
                while root.parentNode != nil {
                    root = root.parentNode!
                }
                return [root]
            },
            
            "empty" : {
                return $2.childNodes.isEmpty ? [$2] : nil
            },
            
            "not"  : {
                return $0 != nil && Node.Select($0!).query($2).isEmpty ? [$2] : nil
            }
        ]
        
        static func parse(rule: SelectRule, node: NodeProtocol) -> [NodeProtocol]? {
            guard let name = rule.pseudo else {
                return nil
            }
            if parsers[name] != nil {
                return parsers[name]!(rule.pseudoParam, rule, node)
            }
            return nil
        }
        
        static func nthChild(_ param: String?, _ rule: SelectRule, _ node: NodeProtocol) -> [NodeProtocol]? {
            guard let param = param, let parent = node.parentNode else {
                return nil
            }
            
            var n: Int = 0
            var step: Int = 0
            var index: Int = 0
            
            if let m = NTH_LEXER.match(param) {
                if !m[1]!.isEmpty {
                    n = 2
                    step = 1
                }else if !m[2]!.isEmpty {
                    n = 2
                }else if !m[3]!.isEmpty {
                    n = Int(m[3]!)!
                    step = Int(m[4]!)!
                }else if !m[5]!.isEmpty {
                    n = Int(m[5]!)!
                }else if !m[6]!.isEmpty{
                    index = Int(m[6]!)!
                }
            }else{
                return nil
            }
            
            if index != 0 {
                return nthChild(index:index, rule: rule, node: node)
            }
            
            if n != 0 || step != 0 {
                var i = 0
                let count = parent.childNodes.count
                var res = [NodeProtocol]()
                while true {
                    index = n * i + step
                    if index < 0 {
                        index = count + index
                    }
                    i += 1
                    if index <= count {
                        if let ref = nthChild(index: index, rule: rule, node: node){
                            res += ref
                        }
                        continue
                    }
                    break
                }
                return res.isEmpty ? nil : res
            }
            return nil
        }
        
        static func nthChild(index: Int, rule: SelectRule, node: NodeProtocol) -> [NodeProtocol]? {
            guard let parent = node.parentNode else {
                return nil
            }
            let len = parent.childNodes.count
            let index = index < 0 ? len + index : index - 1
            guard index < len else {
                return nil
            }
            let child = parent.childNodes[index]
            if child.isEqual(node) {
                return [node]
            }
            if rule.match(child, nonPseudo: true) != nil {
                return [child]
            }
            return nil
        }
        
        
        // MARK: - Private Static
        
        private static let NTH_LEXER = Re("^(?:(odd)|(event)|(-\\d+)n([+\\-]\\d+)|(-?\\d+)n|(-?\\d+))$")
        
    }

}
