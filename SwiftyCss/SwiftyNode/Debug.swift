
import Foundation


extension Node {
    
    public struct DebugMode: OptionSet {
        
        public static let none        = DebugMode(rawValue: 0)
        public static let onRefresh   = DebugMode(rawValue: 1 << 0)
        public static let onUpdate    = DebugMode(rawValue: 1 << 1)
        public static let onChange    = DebugMode(rawValue: 1 << 2)
        public static let onAll       = DebugMode(rawValue: (1 << 0) + (1 << 1) + (1 << 2))
        
        public private(set) var rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    public static var debugMode: DebugMode = .none
    
    #if DEBUG
    
    public static var debugTimestemp: [Int: TimeInterval] = [:]
    
    public static func debugBegin(_ mode: DebugMode, style: Style ) {
        if debugMode.contains(mode) {
            let id = style.master?.hash ?? 0
            if debugTimestemp[id] == nil {
                debugTimestemp[id] = CACurrentMediaTime()
            }
            
        }
    }
    
    public static func debugEnd(_ mode: DebugMode, style: Style, matched: [Node.StyleSheet.Rule]?) {
        if debugMode.contains(mode) {
            let id = style.master?.hash ?? 0
            var t = 0
            if debugTimestemp[id] != nil {
                t = Int((CACurrentMediaTime() - debugTimestemp[id]!)*1000)
                debugTimestemp[id] = nil
            }
            if Node.debugMode.contains(.onRefresh) {
                print("[SwiftyNode Debug onRefresh \(t)ms]", style)
                print("\tstatus:", style.status)
                if matched != nil {
                    for rule in matched! {
                        print("\t match:", rule.description)
                    }
                }
                print("-----------------------------------")
            }
        }
    }
    
    public static func debugEnd(_ mode: DebugMode, style: Style, from: String) {
        if debugMode.contains(mode) {
            print("[SwiftyNode Debug onUpdata]", style)
            print("\tstatus:", style.status)
            print("\t  from:", from)
            print("-----------------------------------")
        }
    }
    
    
    #endif
    
    
}
