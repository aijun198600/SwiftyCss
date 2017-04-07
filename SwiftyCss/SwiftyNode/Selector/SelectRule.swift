
import Foundation
import SwiftyBox

extension Node {
    
    class SelectRule: CustomStringConvertible {
        
        private static let _lexer = Re(
            "(^|[#.])([\\w\\-]+)|" +
            "(\\[)((?:\\[[^\\]]*\\]|[^\\]])*)\\]|" +
            "(::|:)([\\w\\-]+)(?:\\(([^)]*)\\))?|" +
            "([>+~*])"
        )
        
        // MARK: -
        
        let tag         :String?
        let id          :String?
        let clas        :Set<String>
        let pseudo      :Pseudo?
        let combinator  :String?
        let conditions  :[Node.Expression]?
        let attributes  :[String]?
        public let description :String
        
        init(_ text: String, forCreate: Bool) {
            var tag:String?        = nil
            var id:String?         = nil
            var clas:Set<String>   = []
            var pseudo:Pseudo?     = nil
            var combinator:String? = nil
            var conditions:[Node.Expression] = []
            var attributes:[String] = []
            
            var offset = 0
            while let m = SelectRule._lexer.match(text, offset: offset) {
                offset = m.lastIndex + 1
                switch m[1]! + m[3]! + m[5]! + m[8]! {
                case ">", "+", "~":
                    combinator = m[8]!
                case "#":
                    id = m[2]!
                case ".":
                    clas.insert(m[2]!)
                case "::", ":":
                    pseudo = Pseudo(name: m[6]!, params: m[7]!.isEmpty ? nil : m[7] )
                case "[":
                    if forCreate {
                        attributes.append( m[4]! )
                    }else{
                        conditions.append( Node.Expression(m[4]!) )
                    }
                case "*":
                    tag = m[8]!
                default:
                    tag = m[2]!
                }
            }
            
            self.tag        = tag
            self.id         = id
            self.clas       = clas
            self.pseudo     = pseudo
            self.combinator = combinator
            self.conditions = conditions.isEmpty ? nil : conditions
            self.attributes = attributes.isEmpty ? nil : attributes
            
            var desc = (self.combinator ?? "") + (self.tag ?? "")
            if self.id != nil {
                desc += "#" + self.id!
            }
            if !self.clas.isEmpty {
                desc += "." + self.clas.joined(separator:".")
            }
            if self.conditions != nil {
                for c in self.conditions! {
                    desc += "[" + c.description + "]"
                }
            }
            if self.attributes != nil {
                for c in self.attributes! {
                    desc += "[" + c + "]"
                }
            }
            if self.pseudo != nil {
                desc += self.pseudo!.description
            }
            self.description = desc
        }
        
        public final func check(_ node: NodeProtocol, nonPseudo: Bool = false ) -> Bool {
            let style = node.nodeStyle
            guard self.tag == nil || self.tag == "*" || self.tag == style.tag else {
                return false
            }
            guard self.id == nil || self.id == style.id else {
                return false
            }
            if self.clas.count > 0 {
                if style.clas.isEmpty {
                    return false
                }
                for name in self.clas {
                    if style.clas.contains(name) == false {
                        return false
                    }
                }
            }
            if nonPseudo == false && self.pseudo != nil {
                if self.pseudo!.run(with: node) == false {
                    return false
                }
            }
            if self.conditions != nil {
                for e in 0 ..< self.conditions!.count {
                    if Bool(self.conditions![e].run(with: node)) == false {
                        return false
                    }
                }
            }
            return true
        }
        
    }
    
}
