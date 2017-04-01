
import UIKit
import SwiftyNode
import SwiftyBox


/**
 
 Property:
 
 - Css.styleSheet: Node.StyleSheet
 - Css.lazy: Bool
 - Css.debug: Bool
 - Css.useStrict: Bool
 
 Methods:
 
 - Css.load(file: String?)
 - Css.load(_ text: String)
 - Css.refresh(_ node: NodeProtocol, debug: Bool = false)
 - Css.value(_ str: String) -> CGFloat?
 
 Class:
 
 - Css.TimeLink
 
 Extension **CALayer**: NodeProtocol

 - css(tag: String? = nil, id: String? = nil, class clas: String? = nil, style text: String? = nil, action: Bool? = nil, disable: Bool? = nil, lazy: Bool? = nil)
 - css(remove clas: String)
 - css(refresh signal: Node.Signal = .normal)
 - css(value name: String) -> Any?
 - css(property name: String) -> String?
 - css(create text: String)
 - css(creates list: [String])
 - css(query text: String) -> [CALayer]?
 
 */
public class Css {

    public static var styleSheet = Node.StyleSheet()
    
    public static var useStrict = false
    
    public static var lazy: Bool {
        get {
            return styleSheet.lazy
        }
        set {
            styleSheet.lazy = true
        }
    }
    
    public static var debug: Bool {
        get {
            return Node.debug
        }
        set {
            Node.debug = newValue
        }
    }

    public static func load(file: String?) {
        if file == nil {
            return
        }
        if let text = try? String(contentsOfFile: file!) {
            self.load(text)
        }
    }

    public static func load(_ text: String) {
        Node.registe(atRule: "@media", parser: Css.MediaRule)
        styleSheet.parse(text: text)
    }
    
    public static func value(_ str: String) -> CGFloat? {
        if let f = Float(str) {
            return CGFloat(f)
        }
        if str.hasSuffix("px") {
            return CGFloat( str[0, -2] )
        }
        if str.hasSuffix("deg") {
            return CGFloat( str[0, -3] )
        }
        return nil
    }

    public static func refresh(_ node: NodeProtocol, debug: Bool = false) {
//        #if DEBUG
//            if Node.debug || debug {
//                let t = CACurrentMediaTime()
//                styleSheet.refresh()
//                node.nodeStyle?.refresh( all: true)
//                print("[SwiftyCss debug] Refresh \"\(Node.describing(node))\" used time:", "\(Int((CACurrentMediaTime() - t)*1000))ms" )
//                return
//            }
//        #endif
        styleSheet.refresh()
        node.nodeStyle?.refresh( all: true )
    }

    public static func debugPrint(_ node: NodeProtocol, deep: Bool = false) {
        print( Node.describing(node, deep: deep) )
    }
    
}

