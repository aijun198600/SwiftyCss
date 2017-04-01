
import Foundation
import SwiftyBox


extension Node.StyleSheet {
    
    public class Rule: Hashable, Equatable, CustomStringConvertible {
        
        // MARK: - Protocol
        
        public var hashValue: Int {
            return description.hashValue
        }
        
        public var description: String {
            var text = ""
            if self.atRule != nil {
                text += self.atRule!.description + " "
            }
            if self.selector != nil {
                text += self.selector!.description + " "
            }
            text += "{ "
            for (k, v) in self.property {
                text += k + ":" + v + "; "
            }
            text += "}"
            return text
        }
        
        
        // MARK: - Public
        
        public let atRule   : Node.AtRule?
        
        public let selector : Node.Select?
        
        public private(set) var property = [String: String]()
        
        
        public final func check(node: NodeProtocol) -> Bool {
            if self.selector != nil && !self.selector!.check(node){
                return false
            }
            return true
        }
        
        public final func parseProperty(_ text: String) {
            for value in  text.components(separatedBy: ";", trim: .whitespacesAndNewlines) {
                let key_value = value.components(separatedBy: ":", trim: .whitespacesAndNewlines)
                if key_value.count == 2{
                    self.addProperty(name: key_value[0], value: key_value[1])
                }
            }
        }
        
        public final func addProperty(name: String, value: String?) {
            self.property[name] = value
        }
        
        
        // MARK: -
        
        var sortIndex = 0
        
        init(selector: String? = nil, property: String? = nil, atRule: Node.AtRule? = nil) {
            self.atRule    = atRule
            if selector != nil {
                self.selector = Node.Select(selector!)
            }else{
                self.selector = nil
            }
            if property != nil {
                self.parseProperty( property! )
            }
        }
        
        
        
        public static func == (lhs: Rule, rhs: Rule) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }

    }
    
}
