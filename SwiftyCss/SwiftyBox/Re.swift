//  Created by Wang Liang on 2017/4/8.
//  Copyright © 2017年 Wang Liang. All rights reserved.

import Foundation

public class Re {
    
    private static let symbol  = Re("([()\\[\\]?{}.*$^!\\+]|^\\|$)")
    private static let pair    = ["(":")", "[":"]", "{": "}", "\"":"\"", "\'": "\'"]
    private static let pairRe  = Re("(\\\\*)([()\"'{}\\[\\]])")
	private static var cache   = [String: NSRegularExpression]()
	
	public enum ExplodeOption {
		case keepSeparator
		case keepSeparatorBack
		case keepSeparatorFront
		case ignoreSeparator
	}
    
    // MARK: -
	
    public class Result: CustomStringConvertible {
        public let values:[String]
        public let index:Int
        public let lastIndex: Int
        public let count:Int
		public subscript (key: Int) -> String? {
			if key < self.values.count{
				return self.values[key]
			}
			return nil
		}
        init(index: Int, lastIndex: Int, values:[String]) {
            self.index  = index
            self.lastIndex = lastIndex
            self.values = values
            self.count  = values.count
        }
        
        public var description: String {
            return "<Re.Result index: \(index), lastIndex: \(lastIndex), values: \(values)>"
        }
	}
	
	// MARK: -
	
	let regex    : NSRegularExpression
	var flags    : Set<Character>
	var lastIndex: Int
	
	public init(_ pattern: String, _ flag:String = "") {
		
		self.lastIndex = 0
		self.flags     = Set(flag.characters)
	
		let id = pattern + "::::::" + self.flags.description
		
		if Re.cache[id] != nil {
			self.regex = Re.cache[id]!
		
		}else{
			var option:NSRegularExpression.Options = [.useUnixLineSeparators]
			for c in flag.characters {
				switch c {
				case "i":
					option.formUnion(.caseInsensitive)
				case "m":
					option.formUnion(.anchorsMatchLines)
				case "s":
					option.formUnion(.dotMatchesLineSeparators)
				case "g":
					break
				default:
					assertionFailure("[SwiftyRe] non-support flag:" + flag)
				}
			}
			self.regex = try! NSRegularExpression(pattern: pattern, options: option)
		}
	}
	
	public final func test(_ input: String, offset:Int = 0) -> Bool {
        guard let r = Re.nsRange(offset: offset, with: input) else {
            return false
        }
		if self.regex.firstMatch(in: input, range: r) != nil {
			return true
		}
		return false
	}
	
	public final func replace(_ input:String, _ template:String, offset:Int = 0) -> String{
        guard let r = Re.nsRange(offset: offset, with: input) else {
            return input
        }
		return self.regex.stringByReplacingMatches(in: input, range: r, withTemplate: template)
	}
    
    public final func replace(_ input:String, offset: Int = 0, _ template:@escaping (Re.Result) -> String ) -> String {
        var list = [String]()
        var offset = offset
        
        if offset > 0 {
           list.append(input[0, offset])
        }
        while let m = self.match(input, offset: offset, nonGlobal: true) {
            list.append( input[offset, m.index] )
            list.append( template(m) )
            offset = m.lastIndex+1
        }
        if offset < input.characters.count {
            list.append( input.slice(start: offset) )
        }
        return list.joined()
    }
	
	public final func match(_ input:String, offset:Int = 0, nonGlobal:Bool = false) -> Result?{
        guard let r = Re.nsRange(offset: offset, with: input) else {
            return nil
        }
		if nonGlobal == false && self.flags.contains("g") {
			let matchs = self.regex.matches(in: input, range: r)
			if matchs.count > 0 {
				var res = [String]()
                var last = -1
				for m in matchs {
                    if m.range.length > 0 && m.range.location + m.range.length - 1 > last {
                        last = m.range.location + m.range.length - 1
                    }
                    res.append( input.slice(with: m.range) )
				}
				return Result(index: String.distance(input, utf16: matchs[0].range.location)!, lastIndex: String.distance(input, utf16: last)!, values: res)
			}

		}else{
			if let match = self.regex.firstMatch(in: input, range: r) {
				var res = [String]()
                var last = -1
				for i in 0 ..< match.numberOfRanges {
					let r = match.rangeAt(i)
                    if r.length > 0 && r.location + r.length - 1 > last {
                        last = r.location + r.length - 1
                    }
					res.append( input.slice(with: r) )
				}
                return Result(index: String.distance(input, utf16: match.range.location)!, lastIndex: String.distance(input, utf16: last)!, values: res)
			}
		}
		return nil
	}
	
	public final func exec(_ input:String) -> Result? {
		if let res = self.match(input, offset: self.lastIndex, nonGlobal: true) {
			self.lastIndex = res.lastIndex
			return res
		}
		return nil
	}
	
	public final func split(_ input:String, offset:Int = 0, trim:CharacterSet? = nil) -> [String]{
		return self.explode(input, offset: offset, trim: trim, option: .ignoreSeparator)
	}
	
    public final func explode(_ input:String, offset:Int = 0, trim:CharacterSet? = nil, option:ExplodeOption = .keepSeparator) -> [String] {
        guard let r = Re.nsRange(offset: offset, with: input) else {
            return [input]
        }
		let matchs = self.regex.matches(in: input, range: r)
		
		if matchs.count > 0 {
            
            let len = input.utf16.count
			var res = [String]()
			var i = 0
			
			for m in matchs {
				let r = m.range
				if i != r.location {
                    res.append( input.slice(with: NSMakeRange(i, r.location-i), trim: trim)  )
				}
				switch option {
				case .keepSeparator:
					res.append( input.slice(with: r, trim: trim) )
					i = r.location + r.length
					
				case .ignoreSeparator:
					i = r.location + r.length
					
				case .keepSeparatorBack:
					if res.count > 0 {
						res[res.count - 1] += input.slice(with: r, trim: trim)
					}else{
						res.append( input.slice(with: r, trim: trim) )
					}
					i = r.location + r.length
					
				case .keepSeparatorFront:
					i = r.location
				}
			}
			if i < len {
				res.append( input.slice(with: NSMakeRange(i, len-i), trim: trim) )
			}
			return res.filter({ $0.characters.count > 0 })
		}
		return [input]
	}
	
    // MARK: -
    
    public static func trim(_ string:String, pattern:String? = nil) -> String {
        if var pattern = pattern {
            pattern = symbol.replace(pattern, "\\\\$1")
            return Re("(" + pattern + ")+$").replace(Re("^(" + pattern + ")+").replace(string, ""), "")
        }
        return string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public static func lexer(code:String, separator: String, trim: CharacterSet? = nil) -> [String] {
        return lexer(code: code, separator: Re( symbol.replace(separator, "\\\\$1") ), trim: trim)
    }
    
    public static func lexer(code:String, separator sep: Re, trim: CharacterSet? = nil) -> [String] {
        var code = code
        
        var res    = [String]()
        var stack  = [String]()
        var bad    = false
        var offset = 0
        
        while !code.isEmpty && offset < code.characters.count {
            let sm = sep.match(code, offset: offset)
            if sm == nil && ( stack.isEmpty || bad ) {
                break
            }
            if bad == false {
                if let pm = pairRe.match(code, offset: offset) {
                    if !stack.isEmpty || pm.index < sm!.index {
                        offset = pm.lastIndex+1
                        if pm[1]!.isEmpty || pm[1]!.characters.count % 2 != 0 {
                            if stack.last == pm[2]! {
                                stack.removeLast()
                                continue
                            }
                            
                            if pair[ pm[2]! ] != nil {
                                stack.append( pair[ pm[2]! ]! )
                                continue
                            }
                            
                            if let index = stack.index(of: pm[2]!) {
                                while stack.count > index {
                                    stack.removeLast()
                                }
                                continue
                            }
                            
                            if !stack.isEmpty{
                                bad = true
                                offset = 0
                                continue
                            }
                            
                        }else {
                            continue
                        }
                    }
                }else if !stack.isEmpty {
                    if let pm = pairRe.match(code) {
                        stack.removeAll()
                        offset = pm.lastIndex+1
                        continue
                    }
                    break
                }
            }
            if sm == nil {
                break
            }
            res.append( code.slice(start: 0, end: sm!.index, trim: trim) )
            code = code.slice(start: sm!.lastIndex+1)
            offset = 0
        }
        if !code.isEmpty {
            if trim != nil {
                res.append( code.trimmingCharacters(in: trim!) )
            }else{
                res.append(code)
            }
        }
        return res.filter({ $0.characters.count > 0 })
    }
    
    public static func nsRange(offset: Int, with str: String) -> NSRange? {
        let end = str.utf16.count
        if offset > 0 {
            if let start = String.utf16Distance(str, distance: offset) {
                if start < end {
                    return NSMakeRange(start, end - start)
                }
            }
            return nil
        }
        return NSMakeRange(0, end)
    }

    
}
