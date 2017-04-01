
import Foundation
import SwiftyBox

public protocol NodeProtocol: NSObjectProtocol {
    
    var nodeStyle: Node.Style? { get }
    
    var childNodes: [NodeProtocol] {get}
    
    weak var parentNode: NodeProtocol? {get}
    
    func addChild(_ node: NodeProtocol)
    
    func removeChild(_ node: NodeProtocol)
    
    func getAttribute(_ key: String) -> Any?
    
    func setAttribute(_ key: String, value: Any?)
    
}

open class Node {
    
    public static var debug = false

    public static func index(of node: NodeProtocol, parent: NodeProtocol? = nil) -> Int? {
        let parent = parent ?? node.parentNode
        if parent != nil {
            for (i, n) in parent!.childNodes.enumerated() {
                if n.isEqual( node ) {
                    return i
                }
            }
        }
        return nil
    }

    public static func registe(pseudo: String, parser: @escaping Node.Pseudo.Parser) {
        Node.Pseudo.parsers[pseudo] = parser
    }
    
    public static func registe(atRule: String, parser: @escaping Node.AtRule.Parser) {
        Node.AtRule.parsers[atRule] = parser
    }
    
    public static func query(_ node: NodeProtocol, _ text: String) -> [NodeProtocol] {
        var res = [NodeProtocol]()
        for str in Re.lexer(code: text, separator: ",") {
            res += Node.Select(str).query( node )
        }
        return res
    }

    public static func check(_ node: NodeProtocol, _ text: String) -> Bool{
        return Node.Select(text).check(node)
    }
    
    public static func describing(_ node: NodeProtocol, deep: Bool = false) -> String {
        var text = node.nodeStyle != nil ? describing(node.nodeStyle!) : "<\(String(describing: type(of:node)))>"
        if deep && node.childNodes.count > 0 {
            for n in node.childNodes {
                text += "\n    " + describing(n, deep:deep).replacingOccurrences(of: "\n", with: "\n    ")
            }
            text += "\n"
        }
        return text
    }

    public static func describing(_ style: Style) -> String {
        var text = style.id.isEmpty ? "" : " id=\"\(style.id)\""
        text += style.clas.isEmpty ? "" : " class=\"\(style.clas.joined(separator: " "))\""
        var temp = ""
        for (k, v) in style.property {
            temp += k + ":" + v + ";"
        }
        if !temp.isEmpty {
            text += " style=\"\(temp[0, -1])\""
        }
        let type = style.master == nil ? style.tag : String(describing: type(of:style.master!))
        if type == style.tag{
            text = "<\(type)\(text)>"
        } else {
            text = "<\(type):\(style.tag)\(text)>"
        }
        return text
    }
    
}
