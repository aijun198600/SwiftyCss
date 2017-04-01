
import UIKit
import SwiftyBox

private let NodeSyntaxRe = Re("^([ \t]*)(.+) *$")

extension Node {
    
    // MARK: - Public Static
    
    public static func create(jade text: String, default def: String) -> [NodeProtocol]? {
        return create(jade: text.components(separatedBy: "\n"), default: def)
    }
    
    public static func create(jade lines: [String], default def: String) -> [NodeProtocol]? {
    
        var res:[NodeProtocol] = []
        
        var level       = -1
        var level_stack = [Int]()
        var parent_stack = [NodeProtocol]()
        
        for line in lines {
            guard let m = NodeSyntaxRe.match(line), var text = m[2] else{
                continue
            }
            if lines.count > 2 {
                text = text.replacingOccurrences(of: " ", with: "")
            }
            let nodes = create(selector: Select(text) , default: def)
            
            let indent = m[1]!.replacingOccurrences(of: "\t", with: "    ").characters.count
            
            if level == -1 {
                level_stack.append( indent )
                
            }else if indent > level_stack[level] {
                level_stack.append( indent )
                
            }else if indent < level_stack[level] {
                while level >= 0 && indent <= level_stack[level] {
                    level_stack.removeLast()
                    level = level_stack.count - 1
                    if parent_stack.count > 0 {
                        parent_stack.removeLast()
                    }
                }
                level_stack.append(indent)
                
            }else{
                parent_stack.removeLast()
            }
            level = level_stack.count - 1
            
            if parent_stack.count > 0 {
                for node in nodes {
                    parent_stack.last!.addChild(node)
                }
            }else{
                res += nodes
            }
            parent_stack.append(nodes.last!)
        }
        return res.isEmpty ? nil : res
    }
    
    
    
    // MARK: - Private Static
    
    private static let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as? String
    
    private static func create(selector: Select, default def: String? = nil) -> [NodeProtocol] {
        var res = [NodeProtocol]()
        var tar: NodeProtocol? = nil
        
        for rule in selector.rules {
            
            var attrs = [String]()
            for c in rule.conditions {
                attrs.append( c.exps.joined() )
            }
            guard let tag = rule.tag ?? def else {
                fatalError("[SwiftyNode.Creater] pattern error: \(selector.description)")
            }
            
            let node = create(tag: tag, id: rule.id, class: rule.clas, attributes: attrs, default: def)
            
            if rule.combinator == "+" {
                tar = tar?.parentNode
            }else if rule.combinator == "~" {
                tar = tar?.parentNode?.parentNode
            }
            if tar != nil {
                tar!.addChild( node )
            }else{
                res.append(node)
            }
            tar = node
        }
        assert(res.isEmpty == false, "[SwiftyNode.Creater] pattern error: \(selector.description)")
        return res
    }
    
    private static func create(tag: String, id: String? = nil, class clas: Set<String>? = nil, attributes: [String]? = nil, default def: String? = nil) -> NodeProtocol {
        var type = NSClassFromString(tag) as? NSObject.Type
        if type == nil {
            type = NSClassFromString(bundleName! + "." + tag) as? NSObject.Type
        }
        if type == nil && def != nil {
            type = NSClassFromString(def!) as? NSObject.Type
        }
        if type == nil && def != nil {
            type = NSClassFromString(bundleName! + "." + def!) as? NSObject.Type
        }
        guard let node = type?.init() as? NodeProtocol else {
            fatalError( "[SwiftyNode.Creater] Cant init \"\(bundleName!).\(tag)\" class \(String(describing: type))" )
        }
        if let style = node.nodeStyle {
            if style.tag.isEmpty == true {
                _ = style.lazySet(key: "tag", value: tag)
            }
            _ = style.lazySet(key: "id", value: id)
            _ = style.lazySet(key: "class", value: clas?.joined(separator: " "))
        }
        
        if attributes != nil {
            for attr in attributes! {
                if let kv = attr.components(separatedBy: "=", atAfter: 0, trim: .whitespacesAndNewlines) {
                    node.setAttribute(kv[0], value: kv[1])
                }
            }
        }
        return node
    }

}
