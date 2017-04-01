
import Foundation
import SwiftyBox


extension Node {
    
    public struct Status: OptionSet {
        
        public static let none              = Status(rawValue: 0)
        public static let lazy              = Status(rawValue: 1 << 1)
        public static let inactive          = Status(rawValue: 1 << 2)
        public static let checkAll          = Status(rawValue: 1 << 3)
        public static let checkBorder       = Status(rawValue: 1 << 4)
        public static let checkChild        = Status(rawValue: 1 << 5)
        public static let checkFloatChild   = Status(rawValue: 1 << 6)
        public static let checkFloatSibling = Status(rawValue: 1 << 7)
        public static let updating          = Status(rawValue: 1 << 8)
        public static let needRefresh       = Status(rawValue: 1 << 9)
        public static let noFloatSibling    = Status(rawValue: 1 << 10)
        
        // MARK: -
        
        public private(set) var rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
    }
    
}


#if DEBUG
extension Node.Status: CustomStringConvertible {
    
    public var description: String {
        var desc = [String]()
        let types: [String: Node.Status] = [
            "inactive"          : .inactive,
            "lazy"              : .lazy,
            "checkAll"          : .checkAll,
            "checkBorder"       : .checkBorder,
            "checkFloatChild"   : .checkFloatChild,
            "checkChild"        : .checkChild,
            "checkFloatSibling" : .checkFloatSibling,
            "updating"          : .updating,
            "needRefresh"       : .needRefresh,
            "noFloatSibling"    : .noFloatSibling
        ]
        if self == .none {
            desc.append( "none" )
        }else{
            for (k, v) in types {
                if v == .none {
                    continue
                }
                if self.contains(v) {
                    desc.append(k)
                }
            }
        }
        return "<Signal: \(desc.joined(separator: ", "))>"
    }
}
#endif

