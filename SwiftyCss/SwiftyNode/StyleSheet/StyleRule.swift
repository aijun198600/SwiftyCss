//  Created by Wang Liang on 2017/4/8.
//  Copyright © 2017年 Wang Liang. All rights reserved.

import Foundation
import SwiftyBox


extension Node {
    
    public class StyleRule: CustomStringConvertible {
        
        var sortIndex = 0
        let sortPriority: Int
        public let atRule   : Node.AtRule?
        public let selector : Node.Select
        public let property : [String: String]
        
        init(selector: String, property text: String, atRule: Node.AtRule? = nil) {
            self.atRule   = atRule
            self.selector = Node.Select(selector)
            
            var property = [String: String]()
            
            for value in text.components(separatedBy: ";", trim: .whitespacesAndNewlines) {
                let key_value = value.components(separatedBy: ":", trim: .whitespacesAndNewlines)
                if key_value.count == 2{
                    property[key_value[0]] = key_value[1]
                }
            }
            self.property = property
            
            if let last = self.selector.rules.last {
                var v = (last.id == nil ? 0 : 1)
                v += (last.tag == nil ? 0 : 1)
                v += last.clas.count
                v += (last.conditions?.count ?? 0)
                v += (last.pseudo == nil ? 0 : 1)
                v += (last.combinator == nil ? 0 : 1)
                self.sortPriority = v
            }else{
                self.sortPriority = 0
            }
        }
        
        public final func check(node: NodeProtocol) -> Bool {
            return self.selector.check(node)
        }
        
        public var description: String {
            var text = ""
            if self.atRule != nil {
                text += self.atRule!.description + " "
            }
            text += self.selector.description + " "
            text += "{ "
            for (k, v) in self.property {
                text += k + ":" + v + "; "
            }
            text += "}"
            return text
        }
        
    }
    
}
