//  Created by Wang Liang on 2017/4/8.
//  Copyright © 2017年 Wang Liang. All rights reserved.

import Foundation
import QuartzCore

public class Debug: CustomStringConvertible {
    
    public var timeTotal: Float = 0
    public var output: String? = nil
    public var send: String? = nil
    
    private var value     : UInt = 0
    private var map       = [String : (UInt, String)]()
    private var timestamp = [Int: [TimeInterval]]()
    private var queue: DispatchQueue? = nil
    
    public var async: Bool {
        get { return self.queue != nil }
        set {
            if newValue {
                self.queue = DispatchQueue(label: "SwiftyBox.Debug")
            }else{
                self.queue = nil
            }
        }
    }
    
    public init( tags: [String: String], output: String? = nil, send: String? = nil, file: String = #file, line: Int = #line) {
        for (tag, val) in tags {
            self.define(tag: tag, template: val, file: file, line: line)
        }
        self.output = output
        self.send   = send
    }
    
    public final func define(tag: String, template: String, file: String = #file, line: Int = #line) {
        let hash = tag.hashValue
        if self.map[tag] != nil {
            fatalError( Debug._format(template: "✕ SwiftyBox.Debgu define tag % already exist: %file, line %line", contents: [tag], usetime: 0, file: file, method: "", line: line) )
        }
        self.map[tag] =  (UInt(1 << (map.count+1)), template)
        self.timestamp[hash] = []
    }
    
    public final func enable(_ tag: String...){
        for g in tag {
            if g == "all" {
                value = 0
                for (_, v) in map {
                    value += v.0
                }
                return
            }else if let v = map[g] {
                if value & v.0 != v.0 {
                    value += v.0
                }
            }
        }
    }
    
    public final func enabled(_ tag: String) -> Bool {
        if let v = map[tag] {
            if value & v.0 == v.0 {
                return true
            }
        }
        return false
    }
    
    public final func begin(tag: String, id: Int? = nil) {
        guard self.enabled(tag) else {
            return
        }
        if id != nil {
            if timestamp[id!] == nil {
                timestamp[id!] = [CACurrentMediaTime()]
            }
        }else{
            timestamp[tag.hashValue]!.append(CACurrentMediaTime())
        }
    }
    
    public final func end(tag: String, id: Int? = nil, _ contents: Any?..., file: String = #file, method: String = #function, line: Int = #line) {
        guard self.enabled(tag) else {
            return
        }
        let hash = tag.hashValue
        var usetime: Float = 0
        if id != nil {
            if let t = timestamp[id!]?.first {
                usetime = Float(Int((CACurrentMediaTime() - t)*100000))/100
            }
            timestamp[id!] = nil
        } else if timestamp[hash]!.count > 0 {
            usetime = Float(Int((CACurrentMediaTime() - timestamp[hash]!.removeLast())*100000))/100
        }
        timeTotal += usetime
        let tmp = map[tag]!.1
        if self.async {
            self.queue?.async {
                self.echo( Debug._format(template: tmp, contents: contents, usetime: usetime, file: file, method: method, line: line) )
            }
        }else{
            self.echo( Debug._format(template: tmp, contents: contents, usetime: usetime, file: file, method: method, line: line) )
        }
    }
    
    public final func log(tag: String, _ contents: Any?..., file: String = #file, method: String = #function, line: Int = #line) {
        guard self.enabled(tag) else {
            return
        }
        let tmp = map[tag]!.1
        if self.async {
            self.queue?.async {
                self.echo( Debug._format(template: tmp, contents: contents, usetime: 0, file: file, method: method, line: line) )
            }
        }else{
            self.echo( Debug._format(template: tmp, contents: contents, usetime: 0, file: file, method: method, line: line) )
        }
    }
    
    public final func log(format: String = "%%", _ contents: Any?..., file: String = #file, method: String = #function, line: Int = #line) {
        if self.async {
            self.queue?.async {
                self.echo( Debug._format(template: format, contents: contents, usetime: 0, file: file, method: method, line: line) )
            }
        }else{
            self.echo( Debug._format(template: format, contents: contents, usetime: 0, file: file, method: method, line: line) )
        }
    }
    
    public final func error(format: String = "%%", _ contents: Any?..., file: String = #file, method: String = #function, line: Int = #line) {
        if self.async {
            self.queue?.async {
                let msg = Debug._format(template: format, contents: contents, usetime: 0, file: file, method: method, line: line)
                self.echo(msg)
            }
        }else{
            let msg = Debug._format(template: format, contents: contents, usetime: 0, file: file, method: method, line: line)
            self.echo(msg)
        }
    }
    
    public final func stringify(_ value: @autoclosure @escaping () -> Any?) -> () -> String {
        return { Debug._stringify( value() ) }
    }
    
    private final func echo(_ text: String) {
        print( text )
        if self.output != nil {
            self.queue?.async {
                if let f = FileHandle(forWritingAtPath: self.output! ) {
                    f.seekToEndOfFile()
                    f.write( text.data(using: .utf8, allowLossyConversion: true)! )
                    f.closeFile()
                }
            }
        }
        if self.send != nil {
            // TODO: send to server
        }
    }
    
    public final var description: String {
        var names = [String]()
        for (name, conf) in map {
            if value & conf.0 == conf.0 {
                names.append(name)
            }
        }
        return "<SwiftyBox.Debug Enabel: \(names.joined(separator:", "))>"
    }
    
    // MARK: -
    
    private static let _format_re = Re("(%ms|%file|%who|%line|%now|%date|%time)\\b|(\\n(?:[^%]*[>:]\\s*|\\s*))?(%\\[\\]|%%|%)")
    
    private static func _format(template:String, contents: [Any?], usetime: Float, file: String, method: String, line: Int) -> String {
        var text = ""
        var i = 0
        var tmp = template
        while let m = _format_re.match(tmp) {
            if m.index > 0 {
                text += tmp.slice(start:0, end: m.index)
            }
            tmp = tmp.slice(start: m.lastIndex+1 )
        
            if !m[1]!.isEmpty {
                switch m[1]! {
                case "%file":
                    text += file
                case "%line":
                    text += line.description
                case "%who":
                    text += method
                case "%ms":
                    text += usetime.description + "ms"
                case "%now":
                    let format = DateFormatter()
                    format.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    text += format.string( from: Date() ) + "ms"
                case "%date":
                    let format = DateFormatter()
                    format.dateFormat = "yyyy-MM-dd"
                    text += format.string( from: Date() ) + "ms"
                case "%time":
                    let format = DateFormatter()
                    format.dateFormat = "HH:mm:ss"
                    text += format.string( from: Date() ) + "ms"
                default:
                    continue
                }
            }else{
                
                var temp = ""
                let prefix = m[2]!
                var indent = prefix.isEmpty ? "" : Re("[^\\s]").replace(prefix, " ")
    
                switch m[3]! {
                case "%[]":
                    if i < contents.count {
                        if let val = contents[i] {
                            if val is [Any] {
                                let arr = val as! [Any]
                                for i in 0 ..< arr.count {
                                    if i != 0 {
                                        temp += prefix.isEmpty ? "\n" : prefix
                                    }
                                    temp += _stringify(arr[i]).replacingOccurrences(of: "\n", with: indent)
                                }
                                indent = ""
                            }else{
                                temp = _stringify(val)
                            }
                        }else{
                            temp = "nil"
                        }
                        i += 1
                    }
                    
                case "%%":
                    while i < contents.count {
                        temp += " " + _stringify(contents[i])
                        i += 1
                    }
                    
                case "%":
                    if i < contents.count {
                        temp = _stringify(contents[i])
                        i += 1
                    }
                    
                default:
                    continue
                }
                if !indent.isEmpty {
                    temp = temp.replacingOccurrences(of: "\n", with: indent)
                }
                text += prefix + temp
            }
        }
        text += tmp
        return text
    }
    
    private static func _stringify(_ value: Any?) -> String {
        guard let value = value else {
            return "nil"
        }
        let str = String(describing: value)
        if str == "(Function)" {
            let type = String(describing: type(of: value))
            switch type {
            case "() -> String":
                return String(describing: (value as! () -> String)())
            case "() -> String?":
                return String(describing: (value as! () -> String?)() ?? "nil")
            default:
                return type
            }
        }
        return str
    }
    
}
