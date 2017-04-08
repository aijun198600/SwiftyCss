//  Created by Wang Liang on 2017/4/8.
//  Copyright © 2017年 Wang Liang. All rights reserved.

import Foundation

public class Weak <Element: AnyObject>: CustomStringConvertible {

    public weak var value : Element?
    
    public init(_ value: Element) {
        self.value = value
    }
    
    public final var description: String {
        return "Weak(" + (self.value != nil ? String(describing: self.value!) : "nil") + ")"
    }

}

public class WeakArray <Element: AnyObject> {
    
    public var list: [Weak<Element>]
    
    public init() {
        list = [Weak<Element>]()
    }
    
    public var count: Int {
        return list.count
    }
    
    public subscript (index: Int) -> Element? {
        if index < list.count {
            return list[index].value
        }
        return nil
    }
    
    public final func append(_ element: Element) {
        list.append( Weak( element ) )
    }
    
    public final func remove(at: Int) -> Element? {
        let elm = list.remove(at: at < 0 ? list.count + at : at)
        return elm.value
    }
    
}

public class WeakDict <Key: Hashable, Element: AnyObject> {
    
    public var dict: [Key: Weak<Element>]
    
    public init() {
        dict = [Key: Weak<Element>]()
    }
    
    public var count: Int {
        return dict.count
    }
    
    public var values: [Element?] {
        var res = [Element?]()
        for (_, v) in dict {
            res.append(  v.value )
        }
        return res
    }
    
    public var keys: LazyMapCollection<Dictionary<Key, Weak<Element>>, Key> {
        return dict.keys
    }
    
    public subscript (key: Key) -> Element? {
        get {
            return dict[key]?.value
        }
        set {
            if newValue == nil {
                dict[key] = nil
            }else{
                dict[key] = Weak( newValue! )
            }
        }
    }
    
}
