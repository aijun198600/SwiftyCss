
import Foundation
import SwiftyBox


extension Node {
    
    public struct Status: OptionSet {
        
        public static let none              = Status(rawValue: 0)
        public static let lazy              = Status(rawValue: 1 << 1)
        public static let inactive          = Status(rawValue: 1 << 2)
        public static let needRefresh       = Status(rawValue: 1 << 3)
        public static let checkAll          = Status(rawValue: 1 << 4)
        public static let checkChild        = Status(rawValue: 1 << 5)
        public static let checkHookChild    = Status(rawValue: 1 << 6)
        public static let rankFloatChild    = Status(rawValue: 1 << 7)
        public static let checkSize         = Status(rawValue: 1 << 8)
        public static let checkBorder       = Status(rawValue: 1 << 9)
        public static let updating          = Status(rawValue: 1 << 10)
        public static let passive           = Status(rawValue: 1 << 11)
        
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
            "checkChild"        : .checkChild,
            "checkHookChild"    : .checkHookChild,
            "rankFloatChild"    : .rankFloatChild,
            "checkBorder"       : .checkBorder,
            "checkSize"         : .checkSize,
            "updating"          : .updating,
            "needRefresh"       : .needRefresh
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
        return "<Status: \(desc.joined(separator: ", "))>"
    }
}
#endif

