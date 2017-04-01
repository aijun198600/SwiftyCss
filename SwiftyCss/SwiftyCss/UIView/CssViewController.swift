
import UIKit
import SwiftyNode
import SwiftyBox

open class CssViewController: UIViewController {
    
//    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//    }
    
    open override func viewWillLayoutSubviews () {
        super.viewWillLayoutSubviews()
        Css.refresh(self.view, debug: Css.debug)
    }
    
    open func query(view seletor: String) -> [UIView]? {
        if let layers = view.css(query: seletor) {
            var res = [UIView]()
            for layer in layers {
                if layer.delegate is UIView {
                    res.append(layer.delegate as! UIView)
                }
            }
            if res.count > 0 {
                return res
            }
        }
        return nil
    }
    
    open func query(layer seletor: String) -> [CALayer]? {
        return view.css(query: seletor)
    }
    
}
