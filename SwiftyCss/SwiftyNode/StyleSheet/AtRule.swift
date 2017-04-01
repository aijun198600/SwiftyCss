
import Foundation
import SwiftyBox

extension Node {
    
    public class AtRule: Hashable, Equatable {
        
        public let description: String
        public let hashValue: Int

        let name: String
        let exps: [String]
        
        init(_ text: String ) {
            var list =  AtRule.AT_LEXER.explode(text, trim: .whitespacesAndNewlines)
            guard list.first?.hasPrefix("@") == true else {
                fatalError( "[SwiftyNode.AtRule] init error: \(text)" )
            }
            self.name = list.remove(at: 0)
            self.exps = list
            self.description = "\(name) \(exps.joined(separator: " "))"
            self.hashValue = self.description.hashValue
        }
        
        func run( in sheet: StyleSheet) -> Bool {
            guard let parser = AtRule.parsers[name] else {
                return false
            }
            var logic = "and"
            var ref   = false
            for i in 0 ..< exps.count {
                switch exps[i] {
                case "and", "not", "only", ",":
                    logic = exps[i]
                    continue
                case "(", "\"":
                    ref = parser(exps[i][1, -1], sheet)
                default:
                    ref = parser(exps[i], sheet)
                }
                if i != 0 && logic.isEmpty {
                    fatalError( "[SwiftyNode.AtRule] expression error: \(description)" )
                }
                if logic == "not" ? ref == true : ref == false {
                    return false
                }
                logic = ""
            }
            return true
        }
        
        // MARK: - Static
        
        public typealias Parser = (_ param: String, _ styleSheet: StyleSheet) -> Bool
        
        static var parsers: [String: Parser] = [
            "@lazy": {
                (_ param: String, _ styleSheet: Node.StyleSheet) in
                    styleSheet.lazy = (param == "true")
                    return true
            },
            
            "@debug": {
                (_ param: String, _ styleSheet: Node.StyleSheet) in
                switch param {
                case "true", "all":
                    Node.debugMode = .onAll
                case "refresh":
                    Node.debugMode = .onRefresh
                case "update":
                    Node.debugMode = .onUpdate
                default:
                    break
                }
                return true
            }
        ]
        
        public static func == (lhs: Node.AtRule, rhs: Node.AtRule) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }
        
        // MARK: - Private Static
        
        private static let AT_LEXER = Re("@\\w+|\\b(?:and|not|only)\\b|,")
        
    }
    
}
