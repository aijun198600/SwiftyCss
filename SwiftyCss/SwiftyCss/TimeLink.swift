
import QuartzCore
import SwiftyNode
import SwiftyBox

extension Css {
    
    open class TimeLink: NSObject {
        
        public typealias CallBack = (_ datas: [Data], _ timeLink: TimeLink) -> Void
        
        public enum Effect {
            case easeIn, easeOut, easeInOut, none
        }
        
        public class Data {
            
            public let name:  String
            public let from:  CGFloat
            public let to:    CGFloat
            public let target: Any?
            public fileprivate(set) var value: CGFloat = 0
            public fileprivate(set) var delta: CGFloat = 0
            
            init(target: Any?, name: String, from: CGFloat, to: CGFloat) {
                self.target = target
                self.name   = name
                self.from   = from
                self.to     = to
            }
        }
        
       
        // MARK: - Private
        
        private var timer: CADisplayLink? = nil
        private var startTime: TimeInterval = 0
        private var lastPercent: CGFloat = 0
        private var callback: CallBack?
        
        // MARK: - Public
       
        public private(set) var duration: TimeInterval = 0
        public private(set) var effect: Effect = .none
        public private(set) var percent: CGFloat = 0
        public private(set) var datas: [Data] = []
        
        
        public var isRuning: Bool {
            return timer != nil
        }
        
        public var isOver: Bool {
            return percent == 1
        }
        
        public var isEmpty: Bool {
            return datas.isEmpty
        }

        public func add(target: Any? = nil, name: String, from: CGFloat, to: CGFloat) {
            if isRuning {
                self.clear()
            }
            datas.append( Data(target: target, name: name, from: from, to: to) )
        }
        
        public func add(target: Any? = nil, name: String, from: CGFloat = 0, move: CGFloat) {
            if isRuning {
                self.clear()
            }
            datas.append( Data(target: target, name: name, from: from, to: from + move) )
        }
        
        public func start(duration: TimeInterval, effect: Effect = .none, callback: @escaping CallBack) {
            
            self.percent     = 0
            self.lastPercent = 0
            self.duration    = duration
            self.effect      = effect
            self.callback    = callback
            
            startTime = CACurrentMediaTime()
            timer?.invalidate()
            timer = CADisplayLink(target: self, selector: #selector(loop))
            timer!.add(to: .current, forMode: .commonModes)
        }
        
        public func stop() {
            if percent != 1 && timer != nil {
                self.go(percent: 1)
            }
            self.clear()
        }
        
        public func clear() {
            datas.removeAll()
            timer?.invalidate()
            timer       = nil
            duration    = 0
            callback    = nil
        }
        
        // MARK: - 
        
        func loop() {
            let timestamp = CACurrentMediaTime()
            if (timestamp - self.startTime) > self.duration {
                if self.percent != 1 {
                    self.go(percent: 1)
                }else{
                    self.clear()
                }
                return
            }
            var per = CGFloat((timestamp - self.startTime) / self.duration);
            switch effect {
            case .easeIn:
                per = pow(per, 2)
            case .easeOut:
                per = -(pow((per - 1), 2) - 1);
            case .easeInOut:
                per /= 0.5
                per = (per < 1) ? 0.5 * pow(per, 2) : -0.5 * ( pow(per-2, 2) - 2);
            default:
                break
            }
            self.go(percent: per)
        }
        
        func go( percent: CGFloat ){
            
            self.lastPercent = percent
            self.percent = percent
            for data in datas {
                data.delta = (data.to - data.from) * (percent - lastPercent)
                if percent != 1 {
                    data.value = data.from + (data.to - data.from) * percent
                }else{
                    data.value = data.to
                }
            }
            if callback != nil {
                callback!(datas, self)
            }
        }
        
    }
    
}
