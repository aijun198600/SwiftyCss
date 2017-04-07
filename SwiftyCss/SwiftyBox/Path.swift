
import Foundation

public class Path {
    
    public static let root      = NSHomeDirectory()
    public static let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!;
    public static let library   = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!;
    public static let cache     = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!;
    public static let tmp       = NSTemporaryDirectory()

    public static func isExist(_ path: String) -> Bool {
        return FileManager.default.fileExists(atPath: Path.resolve(path))
    }
    
    public static func isDir(_ path: String) -> Bool {
        var isDir = ObjCBool(false)
        if FileManager.default.fileExists(atPath: Path.resolve(path), isDirectory: &isDir) {
            if isDir.boolValue {
                return true
            }
        }
        return false
    }
    
    public static func isFile(_ path: String) -> Bool {
        var isDir = ObjCBool(false)
        if FileManager.default.fileExists(atPath: Path.resolve(path), isDirectory: &isDir) {
            if !isDir.boolValue {
                return true
            }
        }
        return false
    }
    
    public static func resolve(_ path: String) -> String {
        if path.hasPrefix("/") || path.hasPrefix("file://") {
            return path
        }
        if path.hasPrefix("~") {
            return join(root, path.slice(start: 1))
        }
        return join(root, path)
    }
    
    public static func extname(_ path: String) -> String? {
        let comps = Path.filename(path).components(separatedBy: ".")
        if comps.count >= 2 {
            return comps.last!
        }
        return nil
    }
    
    public static func filename(_ path: String) -> String {
        let comps = path.components(separatedBy: "/")
        return comps.last!
       
    }
    
    public static func basename(_ path: String) -> String {
        var comps = Path.filename(path).components(separatedBy: ".")
        if comps.count >= 2 {
            comps.removeLast()
            return comps.joined(separator: ".")
        }
        return comps[0]
    }
    
    public static func dirname(_ path: String) -> String {
        var comps = path.components(separatedBy: "/")
        comps.removeLast()
        return comps.joined(separator: "/")
    }

    public static func join(_ paths: String...) -> String {
        var str = paths.joined(separator: "/")
        str = Re("/{2,}").replace(str, "/")
        str = Re("/\\./").replace(str, "/")
        str = Re("[^/]+/\\.{2}(/|$)|/\\.$").replace(str, "")
        if str.hasSuffix("/"){
            str = str.slice(start: 0, end: -1)
        }
        return str
    }
    
    public static func rm(_ path: String) {
        try? FileManager.default.removeItem(atPath: resolve(path))
    }
    
    public static func mkDir(_ path: String) throws {
        let path = Path.resolve(path)
        if !isDir( path ) {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    public static func ls(_ path: String, all: Bool = false) -> [String]? {
        let re = Re("\\[([^\\]]+)\\]|\\{([^}]+)\\}|[*?]")
        if re.test( path ) == false {
            return Path.ls(path: Path.resolve(path), wildcard: nil, all: all)
        }
        let comps = path.components(separatedBy: "/")
        
        var path  = path
        var patts = [String]()
        for i in 0 ..< comps.count {
            if re.test( comps[i] ) {
                path = comps[0 ..< i].joined(separator: "/")
                patts = Array(comps[i ..< comps.count])
                break
            }
        }
        
        path = Path.resolve(path)
        
        if patts.count == 0 {
            return Path.ls(path: path, wildcard: nil, all: all)
        }
        
        var ref = [path]
        for i in 0 ..< patts.count {
            let patt = Path.wildcard(patts[i])
            var temp = [String]()
            for sub in ref {
                if let t = Path.ls(path: sub, wildcard: patt, all: all) {
                    temp += t
                }
            }
            ref = temp
        }
        
        return ref.count > 0 ? ref : nil
    }
    
    private static func ls(path: String, wildcard: Re?, all: Bool) -> [String]? {
        var isDir = ObjCBool(false)
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
            if isDir.boolValue == false {
                return nil
            }
        }
        
        guard let subs = try? FileManager.default.contentsOfDirectory(atPath: path) else {
            return nil
        }
        
        var res = [String]()
        for name in subs {
            if all == false && name.hasPrefix(".") {
                continue
            }
            if wildcard != nil {
                if wildcard!.test(name) == false {
                    continue
                }
            }
            res.append( path + "/" + name )
        }
        return res
    }
    
    private static func wildcard(_ pattern: String) -> Re {
        let re = Re("\\[(\\!?)([^\\]]+)\\]|\\{([^}]+)\\}|[*?.+\\-$^!]")
        var text = ""
        var offset = 0
        while let m = re.match( pattern, offset: offset) {
            text += pattern.slice(start: offset, end: m.index)
            switch m[0]![0]! {
            case "*":
                text += ".+"
            case "?":
                text += "."
            case "[":
                text += "[" + (m[1] == "!" ? "^" : "") + m[2]! + "]"
            case "{":
                let temp = m[3]?.components(separatedBy: ",", trim: .whitespaces)
                text += "(?:" + temp!.joined(separator: "|") +  ")"
            default:
                text += "\\"+m[0]!
            }
            offset = m.lastIndex + 1
        }
        text += pattern.slice(start: offset)
        return Re("^" + text + "$")
    }
    
}
