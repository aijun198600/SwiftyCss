//  Created by Wang Liang on 2017/4/8.
//  Copyright © 2017年 Wang Liang. All rights reserved.

import CoreGraphics
import SwiftyNode
import SwiftyBox

public class Css {

    private static var inited = false
    
    public static let debug = Node.debug
    
    public static let styleSheet = Node.StyleSheet()
    
    static var _async = Node.Ticker.async
    
    public static var async: Bool {
        get { return _async }
        set {
            if newValue {
                Node.Ticker.async = true
                _async = true
            }else{
                fatalError( "[SwiftyCss asyncRefresh] Can't close" )
            }
        }
    }
    
    public static var lazy: Bool {
        get {
            return styleSheet.lazy
        }
        set {
            styleSheet.lazy = true
        }
    }
    
    public static func ready() {
        if inited == false {
            inited = true
            Node.registe(atRule: "@media", parser: Css.MediaRule)
            Node.registe(atRule: "@if", parser: Css.IfRule)
            #if DEBUG
            Node.debug.define(tag: "begin", template: "⏱ Css refresh root used time %ms: %")
            Node.debug.define(tag: "listen", template: "👂 Css listen %: % 🚥 %")
            Node.debug.define(tag: "insert", template: "📌 Css insert (%ms):\n    %\n")
            #endif
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

    public static func load(_ text: String...) {
        if inited == false {
            Css.ready()
        }
        styleSheet.parse(text: text.joined(separator: "\n"))
    }
    
    public static func refresh(_ node: NodeProtocol, debug: Bool = false) {
        if inited == false {
            Css.ready()
        }
        Css.styleSheet.refrehs()
        #if DEBUG
        Node.debug.begin(tag: "begin")
        #endif
        node.styler.refresh(all: true, passive: true)
        #if DEBUG
        Node.debug.end(tag: "begin", node.styler)
        #endif
    }

    public static func debugPrint(_ node: NodeProtocol, noprint: Bool = false) -> String {
        var text = node.styler.description //?? "<\(String(describing: type(of:node)))>"
        if node.childNodes.count > 0 {
            for n in node.childNodes {
                text += "\n    " + debugPrint(n, noprint: true).replacingOccurrences(of: "\n", with: "\n    ")
            }
        }
        if !noprint {
           print( text )
        }
        return text
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
    
}

