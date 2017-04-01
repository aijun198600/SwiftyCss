
import UIKit
import SwiftyNode
import SwiftyBox

extension Css {
    
    open static func MediaRule(_ param: String, _ sheet: Node.StyleSheet) -> Bool {
        
        let parmas = param.components(separatedBy: ":", trim: .whitespacesAndNewlines)
        let name = parmas[0].lowercased()
        let value = parmas.count > 1 ? parmas[1] : ""
        
        switch name {
        case "all", "screen":
            return true
            
        case "tvos":
            if #available(tvOS 0, *) {
                return true
            }
            
        case "macos":
            if #available(macOS 0, *) {
                return true
            }
            
        case "watchos":
            if #available(watchOS 0, *) {
                return true
            }
        case "ios":
            if #available(iOS 0, *) {
                return true
            }
        
        case "orientation":
            switch value {
            case "landscape":
                return UIDevice.current.orientation.isLandscape
            case "portrait":
                return UIDevice.current.orientation.isPortrait
            default:
                return false
            }
            
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
            
        case "min-width", "max-width", "width", "min-height", "max-height", "height":
            guard value.isEmpty == false else {
                return false
            }
            guard let val = Css.value(value) else {
                return false
            }
            let width        = UIScreen.main.bounds.width
            let height       = UIScreen.main.bounds.height
            switch name {
            case "min-width":
                return width >= val
            case "max-width":
                return width <= val
            case "width":
                return width == val
            case "min-height":
                return height >= val
            case "max-height":
                return height <= val
            case "height":
                return height == val
            default:
                return false
            }
            
        default:
            break
        }
        return false
    }
    
}


//
//
////public extension UIDevice {
////    var modelName: String {
////        var systemInfo = utsname()
////        uname(&systemInfo)
////        let machineMirror = Mirror(reflecting: systemInfo.machine)
////        let identifier = machineMirror.children.reduce("") { identifier, element in
////            guard let value = element.value as? Int8 where value != 0 else { return identifier }
////            return identifier + String(UnicodeScalar(UInt8(value)))
////        }
////        
////        switch identifier {
////        case "iPod5,1":                                 return "iPod Touch 5"
////        case "iPod7,1":                                 return "iPod Touch 6"
////        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
////        case "iPhone4,1":                               return "iPhone 4s"
////        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
////        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
////        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
////        case "iPhone7,2":                               return "iPhone 6"
////        case "iPhone7,1":                               return "iPhone 6 Plus"
////        case "iPhone8,1":                               return "iPhone 6s"
////        case "iPhone8,2":                               return "iPhone 6s Plus"
////        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
////        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
////        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
////        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
////        case "iPad5,1", "iPad5,3", "iPad5,4":           return "iPad Air 2"
////        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
////        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
////        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
////        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
////        case "iPad6,7", "iPad6,8":                      return "iPad Pro"
////        case "i386", "x86_64":                          return "Simulator"
////        default:                                        return identifier
////        }
////}
////}
////- (NSString*) deviceName
////    {
////        struct utsname systemInfo;
////        
////        uname(&systemInfo);
////        
////        NSString* code = [NSString stringWithCString:systemInfo.machine
////        encoding:NSUTF8StringEncoding];
////        
////        static NSDictionary* deviceNamesByCode = nil;
////        
////        if (!deviceNamesByCode) {
////            
////            deviceNamesByCode = @{@"i386"      :@"Simulator",
////                @"x86_64"    :@"Simulator",
////                @"iPod1,1"   :@"iPod Touch",        // (Original)
////                @"iPod2,1"   :@"iPod Touch",        // (Second Generation)
////                @"iPod3,1"   :@"iPod Touch",        // (Third Generation)
////                @"iPod4,1"   :@"iPod Touch",        // (Fourth Generation)
////                @"iPod7,1"   :@"iPod Touch",        // (6th Generation)
////                @"iPhone1,1" :@"iPhone",            // (Original)
////                @"iPhone1,2" :@"iPhone",            // (3G)
////                @"iPhone2,1" :@"iPhone",            // (3GS)
////                @"iPad1,1"   :@"iPad",              // (Original)
////                @"iPad2,1"   :@"iPad 2",            //
////                @"iPad3,1"   :@"iPad",              // (3rd Generation)
////                @"iPhone3,1" :@"iPhone 4",          // (GSM)
////                @"iPhone3,3" :@"iPhone 4",          // (CDMA/Verizon/Sprint)
////                @"iPhone4,1" :@"iPhone 4S",         //
////                @"iPhone5,1" :@"iPhone 5",          // (model A1428, AT&T/Canada)
////                @"iPhone5,2" :@"iPhone 5",          // (model A1429, everything else)
////                @"iPad3,4"   :@"iPad",              // (4th Generation)
////                @"iPad2,5"   :@"iPad Mini",         // (Original)
////                @"iPhone5,3" :@"iPhone 5c",         // (model A1456, A1532 | GSM)
////                @"iPhone5,4" :@"iPhone 5c",         // (model A1507, A1516, A1526 (China), A1529 | Global)
////                @"iPhone6,1" :@"iPhone 5s",         // (model A1433, A1533 | GSM)
////                @"iPhone6,2" :@"iPhone 5s",         // (model A1457, A1518, A1528 (China), A1530 | Global)
////                @"iPhone7,1" :@"iPhone 6 Plus",     //
////                @"iPhone7,2" :@"iPhone 6",          //
////                @"iPhone8,1" :@"iPhone 6S",         //
////                @"iPhone8,2" :@"iPhone 6S Plus",    //
////                @"iPhone8,4" :@"iPhone SE",         //
////                @"iPhone9,1" :@"iPhone 7",          //
////                @"iPhone9,3" :@"iPhone 7",          //
////                @"iPhone9,2" :@"iPhone 7 Plus",     //
////                @"iPhone9,4" :@"iPhone 7 Plus",     //
////                
////                @"iPad4,1"   :@"iPad Air",          // 5th Generation iPad (iPad Air) - Wifi
////                @"iPad4,2"   :@"iPad Air",          // 5th Generation iPad (iPad Air) - Cellular
////                @"iPad4,4"   :@"iPad Mini",         // (2nd Generation iPad Mini - Wifi)
////                @"iPad4,5"   :@"iPad Mini",         // (2nd Generation iPad Mini - Cellular)
////                @"iPad4,7"   :@"iPad Mini",         // (3rd Generation iPad Mini - Wifi (model A1599))
////                @"iPad6,7"   :@"iPad Pro (12.9\")", // iPad Pro 12.9 inches - (model A1584)
////                @"iPad6,8"   :@"iPad Pro (12.9\")", // iPad Pro 12.9 inches - (model A1652)
////                @"iPad6,3"   :@"iPad Pro (9.7\")",  // iPad Pro 9.7 inches - (model A1673)
////                @"iPad6,4"   :@"iPad Pro (9.7\")"   // iPad Pro 9.7 inches - (models A1674 and A1675)
////            };
////        }
////        
////        NSString* deviceName = [deviceNamesByCode objectForKey:code];
////        
////        if (!deviceName) {
////            // Not found on database. At least guess main device type from string contents:
////            
////            if ([code rangeOfString:@"iPod"].location != NSNotFound) {
////                deviceName = @"iPod Touch";
////            }
////            else if([code rangeOfString:@"iPad"].location != NSNotFound) {
////                deviceName = @"iPad";
////            }
////            else if([code rangeOfString:@"iPhone"].location != NSNotFound){
////                deviceName = @"iPhone";
////            }
////            else {
////                deviceName = @"Unknown";
////            }
////        }
////        
////        return deviceName;
////}
//
//
//
