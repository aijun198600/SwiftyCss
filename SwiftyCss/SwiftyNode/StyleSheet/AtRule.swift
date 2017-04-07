
import Foundation
import SwiftyBox

extension Node {
    
    public typealias AtRuleContext = (self: AtRule, at: Int, root: StyleSheet, arguments: Any?)
    public typealias AtRuleParser = (_ param: String, _ context:inout AtRuleContext) -> Bool
    
    public class AtRule: CustomStringConvertible {
        
        private static let _lexer = Re("@\\w+|\\b(?:and|not|only)\\b|,")
        
        // MARK: -
        
        public let name: String
        public let exps: [String]
        public let description: String
        public let hashValue: Int

        init(_ text: String ) {
            var list         =  AtRule._lexer.explode(text, trim: .whitespacesAndNewlines)
            self.name        = list.remove(at: 0)
            self.exps        = list
            self.description = "\(name) \(exps.joined(separator: " "))"
            self.hashValue   = self.description.hashValue
        }
        
        final func run(with stylesheet: StyleSheet) -> Bool {
            guard let parser = AtRule.parsers[name] else {
                return false
            }
            var logic = "and"
            var ref   = false
            var context: AtRuleContext = (self, 0, stylesheet, nil)
            
            for i in 0 ..< exps.count {
                context.at = i
                
                switch exps[i] {
                case "and", "not", "only", ",":
                    logic = exps[i]
                    continue
                case "(", "\"":
                    ref = parser(exps[i][1, -1], &context)
                default:
                    ref = parser(exps[i], &context)
                }
                if i != 0 && logic.isEmpty {
                    fatalError( "[SwiftyNode AtRule Error] expression error: \(description)" )
                }
                if logic == "not" ? ref == true : ref == false {
                    #if DEBUG
                        Node.debug.log(tag: "at-rule", self, false)
                    #endif
                    return false
                }
                logic = ""
            }
            #if DEBUG
                Node.debug.log(tag: "at-rule", self, true)
            #endif
            return true
        }
                
        // MARK: -
        
        static var parsers: [String: AtRuleParser] = [
            "@lazy": {
                (_ param: String, _ context:inout AtRuleContext) in
                
                context.root.lazy = (param == "true")
                return true
            },
            "@debug": {
                (_ param: String, _ context:inout AtRuleContext) in
                if param == "true" {
                    Node.debug.enable( "all" )
                }else{
                    Node.debug.enable( param )
                }
                return true
            },
        ]
        
    }
    
}
