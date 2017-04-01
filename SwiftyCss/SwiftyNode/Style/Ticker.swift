
import Foundation
import SwiftyBox

extension Node {
    
    public class Ticker {
        
        // MARK: - Public Static
        
        public typealias CallBack = (Style) -> Void
        
        public static func add(style: Style, _ callback: CallBack? = nil) {
            for i in 0 ..< queue.count {
                if queue[i].target?.hashValue == style.hashValue {
                    if callback != nil {
                        queue[i].callback = callback
                    }
                    return
                }
            }
            queue.append(Data(style: style, callback: callback))
            if runing == false && queue.isEmpty == false {
                runing = true
                DispatchQueue.main.asyncAfter(deadline: .now()){ checkQueue() }
            }
        }
        
        public static func remove(style: Style, keepCallback: Bool = false) {
            var i = 0
            while i < queue.count {
                if queue[i].target?.hashValue == style.hashValue {
                    if keepCallback == false || queue[i].callback == nil {
                        queue.remove(at: i)
                        continue
                    }else{
                        queue[i].active = false
                    }
                }
                i += 1
            }
        }
        
        // MARK: - Private Static
        
        private class Data {
            weak var target: Style?
            var callback: CallBack?
            var active = true
            
            init(style: Style, callback: CallBack?) {
                self.target = style
                self.callback = callback
            }
        }
        
        private static var queue = [Data]()
        private static var runing = false
        
        private static func checkQueue(){
            while !queue.isEmpty {
                let data = queue.removeLast()
                if data.target != nil {
                    if data.active {
                        _ = data.target!.updata(mark: "ticker")
                    }
                    if data.callback != nil {
                        data.callback!( data.target! )
                    }
                }
            }
            runing = false
        }
        
    }

}
