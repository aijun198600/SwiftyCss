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
        public let description: String
        
        init(selector: String, property: [String: String], atRule: Node.AtRule? = nil) {
            self.atRule   = atRule
            self.selector = Node.Select(selector)
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
            self.description = text
            
        }
        
        public final func check(node: NodeProtocol) -> Bool {
            return self.selector.check(node)
        }
                
    }
    
}
