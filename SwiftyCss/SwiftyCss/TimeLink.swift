//  Created by Wang Liang on 2017/4/8.
//  Copyright © 2017年 Wang Liang. All rights reserved.

import QuartzCore
import SwiftyNode
import SwiftyBox

extension Css {
    
    public class TimeLink: NSObject {
        
        public enum Effect {
            case easeIn, easeOut, easeInOut, none
        }
        
        public class Data {
            
            public let name:  String?
            public let from:  CGFloat
            public let to:    CGFloat
            public let target: Any?
            public fileprivate(set) var value: CGFloat = 0
            public fileprivate(set) var delta: CGFloat = 0
            
            fileprivate let action: ((Data, TimeLink) -> Void)?
            fileprivate let completion: ((Bool) -> Void)?
            
            init(target: Any?, name: String?, from: CGFloat, to: CGFloat, action: ((Data, TimeLink) -> Void)?, completion: ((Bool) -> Void)?) {
                self.target = target
                self.name   = name
                self.from   = from
                self.to     = to
                self.action = action
                self.completion = completion
            }
        }
        
       
        // MARK: - Private
        
        private var timer: CADisplayLink?   = nil
        private var startTime: TimeInterval = 0
        private var lastPercent: CGFloat    = 0
        private var action: (([Data], TimeLink) -> Void)?
        private var completion: ((Bool) -> Void)?
        
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
        
//        deinit {
//            print("✨✨✨✨✨✨✨✨✨✨✨timelink deinit")
//        }
        
        public override init() {
            super.init()
        }
        
        public init(target: Any? = nil, name: String? = nil, from: CGFloat, to: CGFloat, action: ((Data, TimeLink) -> Void)? = nil, completion: ((Bool) -> Void)? = nil) {
            super.init()
            _ = self.add(target: target, name: name, from: from, to: to, action: action, completion: completion)
        }
        
        public init(target: Any, name: String, to: CGFloat, action: ((Data, TimeLink) -> Void)? = nil, completion: ((Bool) -> Void)? = nil) {
            super.init()
            _ = self.add(target: target, name: name, to: to, action: action, completion: completion)
        }

        public final func add(target: Any? = nil, name: String? = nil, from: CGFloat, to: CGFloat, action: ((Data, TimeLink) -> Void)? = nil, completion: ((Bool) -> Void)? = nil) -> TimeLink {
            if isRuning {
                self.clear()
            }
            datas.append( Data(target: target, name: name, from: from, to: to, action: action, completion: completion) )
            return self
        }
        
        public final func add(target: Any? = nil, name: String? = nil, from: CGFloat = 0, move: CGFloat, action: ((Data, TimeLink) -> Void)? = nil, completion: ((Bool) -> Void)? = nil)  -> TimeLink {
            return self.add(target: target, name: name, from: from, to: from + move, action: action, completion: completion)
        }
        
        public final func add(target: Any, name: String, to: CGFloat, action: ((Data, TimeLink) -> Void)? = nil, completion: ((Bool) -> Void)? = nil)  -> TimeLink {
            if let obj = target as? NSObject {
                if let from = CGFloat(obj.value(forKey: name)) {
                    return self.add(target: target, name: name, from: from, to: to, action: action, completion: completion)
                }
            }
            assertionFailure("[SwiftyCSS.TimeLink] Cant get \"\(name)\" value from \(target)")
            return self
        }
        
        public final func start(duration: TimeInterval, delay: TimeInterval = 0, effect: Effect = .none, action: (([Data], TimeLink) -> Void)? = nil, completion: ((Bool) -> Void)? = nil) {
            self.percent     = 0
            self.lastPercent = 0
            self.duration    = duration
            self.effect      = effect
            self.action      = action
            self.completion  = completion
            
            if delay > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now()+delay, execute: {
                    self.startTime = CACurrentMediaTime()
                    self.timer?.invalidate()
                    self.timer = CADisplayLink(target: self, selector: #selector(self.loop))
                    self.timer!.add(to: .current, forMode: .commonModes)
                })
            }else{
                startTime = CACurrentMediaTime()
                timer?.invalidate()
                timer = CADisplayLink(target: self, selector: #selector(loop))
                timer!.add(to: .current, forMode: .commonModes)
            }
        }
        
        public final func stop() {
            if percent != 1 && timer != nil {
                self.go(percent: 1)
            }
            self.over()
        }
        
        public final func clear() {
            self.datas.removeAll()
            self.timer?.invalidate()
            self.timer       = nil
            self.duration    = 0
            self.action      = nil
            self.completion  = nil
        }
        
        // MARK: - 
        
        final func loop() {
            let timestamp = CACurrentMediaTime()
            if (timestamp - self.startTime) > self.duration {
                if self.percent != 1 {
                    self.go(percent: 1)
                }
                self.over()
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
        
        final func go(percent: CGFloat){
            self.lastPercent = percent
            self.percent = percent
            for data in datas {
                data.delta = (data.to - data.from) * (percent - lastPercent)
                if percent != 1 {
                    data.value = data.from + (data.to - data.from) * percent
                }else{
                    data.value = data.to
                }
                if data.action != nil {
                    data.action!(data, self)
                }
            }
            if self.action != nil {
                self.action!(datas, self)
            }
        }
        
        final func over(){
            for data in datas {
                if data.completion != nil {
                    data.completion!( self.percent == 1 )
                }
            }
            if self.completion != nil {
                self.completion!( self.percent == 1 )
            }
            self.clear()
        }
        
    }
    
}
