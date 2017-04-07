
import Foundation
import SwiftyBox

extension Node {
    
    class Pseudo: CustomStringConvertible {
    
        let name: String
        let params: String?
        let description: String
        
        init(name: String, params: String?) {
            self.name        = name
            self.params      = params
            self.description = ":" + name + (params==nil ? "" : "("+params!+")")
        }
        
        final func run(with node: NodeProtocol) -> Bool {
            switch self.name {
            case "nth-child":
                guard params != nil else {
                    return false
                }
                return Pseudo._nthChild(param: params!, node: node)
                
            case "first-child":
                guard let sibling = node.parentNode?.childNodes else {
                    return false
                }
                return node.hash == sibling[0].hash
                
            case "last-child":
                guard let sibling = node.parentNode?.childNodes else {
                    return false
                }
                return node.hash == sibling.last?.hash
                
            case "exmpty":
                return node.childNodes.isEmpty
                
            case "not":
                return params != nil && Node.Select(params!).check(node) == false
                
            default:
                return false
            }
        }
    
        // MARK: -
        
        private static let _nth_child_lexer = Re("^(?:(-\\d+)n([+\\-]\\d+)|(-?\\d+)n|(-?\\d+))$")
        
        private static func _nthChild(param: String, node: NodeProtocol) -> Bool {
            guard let sibling = node.parentNode?.childNodes else {
                return false
            }
            var index = -1
            var count = sibling.count
            for i in 0 ..< sibling.count {
                if sibling[i].nodeStyle.disable {
                    count -= 1
                    continue
                }
                index += 1
                if node.hash == sibling[i].hash {
                    if param == "odd" {
                        return index % 2 == 0
                    }
                    if param == "even" {
                        return index % 2 != 0
                    }
                    guard let m = _nth_child_lexer.match(param) else {
                        return false
                    }
                    if !m[4]!.isEmpty {
                        if let num = Int(m[4]!) {
                            if (num < 0 ? count + num : num - 1) == index {
                                return true
                            }
                        }
                        return false
                    }
                    let n   = Int( m[1]! + m[3]! ) ?? 0
                    let off = m[2]!.isEmpty ? 0 : (Int( m[2]! ) ?? 0)
                    return (index - off) % n == 0
                }
            }
            return false
        }
        
    }

}
