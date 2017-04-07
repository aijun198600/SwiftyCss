
import Foundation
#if os(iOS) || os(tvOS)
    import UIKit
#endif

extension String {
    
    public subscript(index: Int) -> String? {
        if index < self.characters.count {
            return String(self[self.index(self.startIndex, offsetBy: index)])
        }
        return nil
    }
    
    public subscript(start: Int, end: Int) -> String {
        return self.slice(start: start, end: end)
    }

    public func components(separatedBy separator: String, trim:CharacterSet) -> [String] {
        var res = self.components(separatedBy: separator)
        for i in (0 ..< res.count).reversed() {
            res[i] = res[i].trimmingCharacters(in: trim)
            if res[i].characters.isEmpty {
                res.remove(at: i)
            }
        }
        return res
    }
    
    public func components(separatedBy separator: String, atAfter: Int, trim:CharacterSet? = nil) -> [String]? {
        guard let r = self.range(of: separator, range: (self.index(self.startIndex, offsetBy: atAfter) ..< self.endIndex) ) else {
            return nil
        }
        var res = [String]()
        res.append( self[ self.startIndex ..< r.lowerBound ] )
        res.append( self[ r.upperBound ..< self.endIndex  ] )
        if trim != nil {
            for i in (0 ..< res.count).reversed() {
                res[i] = res[i].trimmingCharacters(in: trim!)
                if res[i].characters.isEmpty {
                    res.remove(at: i)
                }
            }
        }
        return res
    }

    public func slice(with range: NSRange, trim:CharacterSet? = nil) -> String {
        guard let range = String.range(self, with: range) else {
            return ""
        }
        if trim != nil {
            return self.substring(with: range).trimmingCharacters(in: trim!)
        }
        return self.substring(with: range)
    }
    
    public func slice(start: Int, end: Int? = nil, trim:CharacterSet? = nil) -> String{
        let len = self.characters.count
        var start = start
        var end   = end == nil ? len : end!
        if start < 0 {
            start = len + start
        }
        if start > len {
            return ""
        }
        if end < 0 {
            end = len + end
        }
        if end > len - 1 {
            end = len
        }
        let start_index = self.index(self.startIndex, offsetBy: start)
        let end_index = self.index(self.startIndex, offsetBy: end)
        let ref = self[start_index ..< end_index]
        if trim != nil {
            return ref.trimmingCharacters(in: trim!)
        }
        return ref
    }
    
    // MARK: -
    
    public static func index(_ str: String, utf16: Int) -> String.Index? {
        if let u = str.utf16.index(str.utf16.startIndex, offsetBy: utf16, limitedBy: str.utf16.endIndex) {
            return String.Index(u, within: str)
        }
        return nil
    }
    
    public static func utf16Distance(_ str: String, distance: Int) -> Int? {
        if let i = str.index(str.startIndex, offsetBy: distance, limitedBy: str.endIndex) {
            let u = i.samePosition(in: str.utf16)
            return str.utf16.distance(from: str.utf16.startIndex, to: u)
        }
        return nil
    }
    
    public static func distance(_ str: String, utf16: Int) -> Int? {
        if let i = String.index(str, utf16: utf16) {
            return str.distance(from: str.startIndex, to: i)
        }
        return nil
    }

    public static func range(_ str: String, with range: NSRange) -> Range<String.Index>? {
        guard range.location != NSNotFound else {
            return nil
        }
        return String.range(str, location: range.location, length: range.length)
    }
    
    public static func range(_ str: String, location: Int, length:Int) -> Range<String.Index>? {
        if length <= 0 {
            return nil
        }
        if let start = String.index(str, utf16: location), let end = String.index(str, utf16: location + length) {
            return start ..< end
        }
        return nil
    }
    
    public static func nsRange(_ str: String, start: Int, length: Int) -> NSRange? {
        if length <= 0 {
            return nil
        }
        if let location = String.utf16Distance(str, distance: start), let end = String.utf16Distance(str, distance: start+length) {
            return NSMakeRange(location, end - location)
        }
        return nil
    }
    
    #if os(iOS) || os(tvOS)
    
    public static func size(_ str: String, font: UIFont, size: CGFloat? = nil, limitWidth width: CGFloat = .greatestFiniteMagnitude, limitHeight height: CGFloat = .greatestFiniteMagnitude) -> CGSize {
        var font = font
        if size != nil && font.pointSize != size {
            font = font.withSize(size!)
        }
        let text_frame = str.boundingRect(with: CGSize(width: width, height: height), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSFontAttributeName: font], context: nil)
        let lines = str.components(separatedBy: "\n")
        var text_size = text_frame.size
        text_size.width += text_frame.origin.x
        text_size.height += text_frame.origin.y + CGFloat(lines.count) * font.pointSize * 0.055 + 1
        return text_size
    }
    
    public static func size(_ str: String, font: CTFont, size: CGFloat? = nil, limitWidth: CGFloat = .greatestFiniteMagnitude, limitHeight: CGFloat = .greatestFiniteMagnitude) -> CGSize? {
        guard let font_name = CTFontCopyName(font, kCTFontPostScriptNameKey) else {
            return nil
        }
        let size = size ?? CTFontGetSize(font)
        if let font = UIFont(name: font_name as String, size: size) {
            return String.size(str, font:font, size:nil, limitWidth: limitWidth, limitHeight: limitHeight)
        }
        return nil
    }
    
    #endif
    
    
}
