
#if os(watchOS)
    import WatchKit
#elseif os(iOS) || os(tvOS)
    import UIKit
#endif

import CoreGraphics
import SwiftyNode
import SwiftyBox

extension Css {
    
    public static func IfRule(_ param: String, _ context:inout Node.AtRuleContext ) -> Bool {
        #if os(iOS) || os(tvOS)
            if let view = UIApplication.shared.windows.first?.rootViewController?.view {
                if Node.query(view, param) != nil {
                    return true
                }
            }
            return false
        #endif
    }

    public static func MediaRule(_ param: String, _ context:inout Node.AtRuleContext ) -> Bool {
        
        let parmas = param.components(separatedBy: ":", trim: .whitespacesAndNewlines)
        let name = parmas[0].lowercased()
        let value = parmas.count > 1 ? parmas[1] : ""
        
        switch name {
        case "orientation":
            var size: CGSize = .zero
            #if os(watchOS)
                size = WKInterfaceDevice.currentDevice().screenBounds.size
            #elseif os(iOS) || os(tvOS)
                size = UIScreen.main.bounds.size
            #else
                return false
            #endif
            switch value {
            case "landscape":
                return size.width > size.height
            case "portrait":
                return size.width <= size.height
            default:
                return false
            }
            
        case "min-width", "max-width", "width", "min-height", "max-height", "height":
            guard value.isEmpty == false else {
                return false
            }
            guard let val = Css.value(value) else {
                return false
            }
            var size: CGSize = .zero
            #if os(watchOS)
                size = WKInterfaceDevice.currentDevice().screenBounds.size
            #elseif os(iOS) || os(tvOS)
                size = UIScreen.main.bounds.size
            #else
                return false
            #endif
            switch name {
            case "min-width":
                return size.width >= val
            case "max-width":
                return size.width <= val
            case "width":
                return size.width == val
            case "min-height":
                return size.height >= val
            case "max-height":
                return size.height <= val
            case "height":
                return size.height == val
            default:
                return false
            }
            
        default:
            #if os(watchOS)
                let size = WKInterfaceDevice.currentDevice().screenBounds.size
                switch name {
                case "watchos":
                    return true
                case "watch-48":
                    return min(size.width, size.height)/max(size.width, size.height) == 136/170
                case "watch-42":
                    return min(size.width, size.height)/max(size.width, size.height) == 156/195
                default:
                    break
                }
                
            #elseif os(iOS) || os(tvOS)
                switch name {
                case "tvos":
                    return UIDevice.current.userInterfaceIdiom == .tv
                case "ios":
                    return UIDevice.current.userInterfaceIdiom == .phone || UIDevice.current.userInterfaceIdiom == .pad
                case "iphone":
                    return UIDevice.current.userInterfaceIdiom == .phone
                case "ipad":
                    return UIDevice.current.userInterfaceIdiom == .pad
                case "iphone4", "iphone5", "iphone6", "iphone6plus", "ipadmin", "ipadpro":
                    let width        = UIScreen.main.bounds.width
                    let height       = UIScreen.main.bounds.height
                    let size         = min(width, height)/max(width, height)
                    switch name {
                    case "iphone4":
                        return size == 320 / 480
                    case "iphone5":
                        return size == 320 / 568
                    case "iphone6":
                        return size == 375 / 667
                    case "iphone6plus":
                        return size == 414 / 736
                    case "ipadpro":
                        return size == 2732/2048
                    default:
                        return false
                    }
                default:
                    break
                }
            #endif
            break
        }
        return false
    }
    
}

