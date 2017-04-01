
import Foundation

extension Bool {

    public init(_ value: Any?) {
        if value == nil {
            self.init(false)
        }else if value is Bool {
            self.init(value as! Bool)
        }else {
            self.init(true)
        }
    }
    
    public init(string value: Any?) {
        if value == nil {
            self.init(false)
        }else if value is Bool {
            self.init(value as! Bool)
        }else {
            if value is String && (value as! String) == "false" {
                self.init(false)
            }else{
                self.init(true)
            }
        }
    }
    
}
