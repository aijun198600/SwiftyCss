
import Foundation
import SwiftyBox

public protocol NodeProtocol: NSObjectProtocol {
    
    var nodeStyle: Node.Style { get }
    
    var childNodes: [NodeProtocol] {get}
    
    weak var parentNode: NodeProtocol? {get}
    
    func addChild(_ node: NodeProtocol)
    
    func removeChild(_ node: NodeProtocol)
    
    func getAttribute(_ key: String) -> Any?
    
    func setAttribute(_ key: String, value: Any?)
    
}

public class Node {
    
    public static let debug = Debug(tags: [
        "refresh" : "💣 SwiftyNode Refresh (%ms):\n    node: % 🚥 %\n    matched: %[]\n",
        "status"  : "🛎 SwiftyNode Status (%): % 🚥 %\n",
        "create"  : "💰 SwiftyNode Create (%ms):\n    %[]\n",
        "load"    : "🗄 SwiftyNode StyleSheet Load (%ms):\n    %\n",
        "ticker"  : "⏰ SwiftyNode Ticker % (%): % 🚥 %\n",
        "at-rule" : "@ SwiftyNode AtRule: (%) => %"
    ])
    
    
    public static func registe(atRule: String, parser: @escaping Node.AtRuleParser) {
        Node.AtRule.parsers[atRule] = parser
    }
    
    public static func query(_ node: NodeProtocol, _ text: String) -> [NodeProtocol]? {
        var res = [NodeProtocol]()
        for str in Re.lexer(code: text, separator: ",") {
            if let ref = Node.Select(str).query( node ) {
                res += ref
            }
        }
        return res.isEmpty ? nil : res
    }

    public static func check(_ node: NodeProtocol, _ text: String) -> Bool{
        return Node.Select(text).check(node)
    }
    
    
    
    public static func describing(_ nodes: [NodeProtocol], deep: Bool = false) -> String {
        var text = ""
        for i in 0 ..< nodes.count {
            if i != 0 {
                text += "\n"
            }
            text += describing(nodes[i], deep: deep)
        }
        return text
    }
    
    
    public static func describing(_ node: NodeProtocol, deep: Bool = false) -> String {
        var text = node.nodeStyle.description
        if deep && node.childNodes.count > 0 {
            for n in node.childNodes {
                text += "\n    " + describing(n, deep:deep).replacingOccurrences(of: "\n", with: "\n    ")
            }
        }
        return text
    }
    
}
