
import Foundation
import CoreGraphics

extension CGFloat {
    
    public init?(_ string: String?) {
        if string == nil {
            return nil
        }else if let f = Float(string!) {
            self.init(f)
        }else{
            return nil
        }
        
    }
        
    public init?(_ value: Any?) {
        switch value {
        case is Int:
            self.init(value as! Int)
        case is Float:
            self.init(value as! Float)
        case is CGFloat:
            self.init(value as! CGFloat)
        case is String:
            if let f = Float(value as! String){
                self.init(f)
            }else{
                return nil
            }
        default:
            return nil
        }
    }
}
