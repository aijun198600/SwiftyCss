
import Foundation
import SwiftyBox

extension Node {
    
    public class Ticker {
        
        public static var queue: DispatchQueue? = nil
        
        public static var async: Bool {
            get { return self.queue != nil }
            set {
                if newValue {
                    queue = DispatchQueue(label: "SwiftyCss.CAStyle", attributes: .concurrent)
                }else{
                    queue = nil
                }
            }
        }
        
        
        public typealias CallBack = (Style) -> Void
        
        private class _Data {
            weak var target: Style?
            var callback: CallBack?
            var active = true
            
            init(style: Style, callback: CallBack?) {
                self.target = style
                self.callback = callback
            }
        }
        
        // MARK: -
        
        private static var _cache = [Int: _Data]()
        private static var _runing = false
        private static var _id = 0
        
        public static func add(execute work: @escaping @convention(block) () -> Swift.Void){
            if queue != nil {
                queue!.async(execute: work)
            }else{
                DispatchQueue.main.async(execute: work)
            }
        }
        
        public static func add(style: Style, _ callback: CallBack? = nil) {
            if _cache[ style.hash ] != nil {
                if callback != nil {
                    _cache[style.hash]!.callback = callback
                }
                return
            }
            _cache[ style.hash ] = _Data(style: style, callback: callback)
            if _runing == false && _cache.isEmpty == false {
                _runing = true
                if queue != nil {
                    queue!.asyncAfter(deadline: .now()) {
                        DispatchQueue.main.asyncAfter(deadline: .now()){
                            _checkQueue()
                        }
                    }
                }else{
                    DispatchQueue.main.asyncAfter(deadline: .now()){
                        _checkQueue()
                    }
                }
            }
        }
        
        public static func remove(style: Style, keepCallback: Bool = false) {
            if _cache[ style.hash ] != nil {
                if keepCallback == false || _cache[style.hash]?.callback == nil {
                    _cache[style.hash] = nil
                }else{
                    _cache[style.hash]?.active = false
                }
            }
        }
        
        private static func _checkQueue(){
            let temp = _cache
            _runing = false
            _cache.removeAll()
            
            for (_, data) in temp {
                if data.target != nil {
                    if data.active {
                        #if DEBUG
                            Node.debug.log(tag: "ticker", queue == nil ? "sync" : "async", _id, data.target?.status, data.target)
                        #endif
                        data.target!.listenStatus(mark: "ticker\(_id)")
                    }
                    if data.callback != nil {
                        data.callback!( data.target! )
                    }
                }
                
            }
            _id += 1
        }
        
    }

}
