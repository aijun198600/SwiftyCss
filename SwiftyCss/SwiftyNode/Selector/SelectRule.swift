
import Foundation
import SwiftyBox

extension Node {
    
    public class SelectRule {
        
        private static let lexer = Re(
            "(^|[#.])([\\w\\-]+)|" +
            "(\\[)([^\\]]*)\\]|" +
            "(::|:)([\\w\\-]+)(?:\\(([^)]*)\\))?|" +
            "([>+~*])"
        )
        
        // MARK: -
        
        let tag         :String?
        let id          :String?
        let clas        :Set<String>
        let conditions  :[Node.Expression]
        let pseudo      :String?
        let pseudoParam :String?
        let combinator  :String?
        let description :String
        
        init(_ text: String) {
            
            var tag:String?        = nil
            var id:String?         = nil
            var clas:Set<String>   = []
            var conditions:[Node.Expression] = []
            var pseudo:String?         = nil
            var pseudoParam:String?    = nil
            var combinator:String?     = nil
            
            var offset = 0
            while let m = SelectRule.lexer.match(text, offset: offset) {
                offset = m.lastIndex + 1
                switch m[1]! + m[3]! + m[5]! + m[8]! {
                case ">", "+", "~":
                    combinator = m[8]!
                case "#":
                    id = m[2]!
                case ".":
                    clas.insert(m[2]!)
                case "::", ":":
                    pseudo = m[6]!
                    if !m[7]!.isEmpty {
                        pseudoParam = m[7]!
                    }
                case "[":
                    conditions.append( Node.Expression(m[4]!) )
                case "*":
                    tag = m[8]!
                default:
                    tag = m[2]!
                }
            }
            
            self.tag = tag
            self.id  = id
            self.clas = clas
            self.conditions = conditions
            self.pseudo = pseudo
            self.pseudoParam = pseudoParam
            self.combinator = combinator
            
            var desc = (self.combinator ?? "") + (self.tag ?? "")
            if self.id != nil {
                desc += "#" + self.id!
            }
            if !self.clas.isEmpty {
                desc += "." + self.clas.joined(separator:".")
            }
            for c in self.conditions {
                desc += "[" + c.exps.joined() + "]"
            }
            if self.pseudo != nil {
                desc += ":\(self.pseudo!)" + (self.pseudoParam != nil ? "(\(self.pseudoParam!))" : "")
            }
            self.description = desc
        }
        
        public func match(_ node: NodeProtocol, nonPseudo: Bool = false ) -> [NodeProtocol]? {
            guard let style = node.nodeStyle else {
                return nil
            }
            
            if self.tag != nil && self.tag != "*" && self.tag!.lowercased() != style.tag.lowercased() {
                return nil
            }
            if self.id != nil && self.id != style.id {
                return nil
            }
            if self.clas.count > 0 {
                if style.clas.isEmpty {
                    return nil
                }
                for n in self.clas {
                    if style.clas.contains(n) == false {
                        return nil
                    }
                }
            }
            var res = [node]
            if nonPseudo == false && self.pseudo != nil {
                if let ref = Pseudo.parse(rule: self, node: node) {
                    res = ref
                }else{
                    return nil
                }
            }
            if self.conditions.isEmpty == false {
                for i in (0 ..< res.count).reversed() {
                    for e in 0 ..< self.conditions.count {
                        if Bool(self.conditions[e].run(with: node)) == false {
                            res.remove(at: i)
                            break
                        }
                    }
                }
            }
            return res.isEmpty ? nil : res
        }
        
    }
    
}
