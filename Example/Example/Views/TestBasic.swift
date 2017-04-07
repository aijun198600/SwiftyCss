
import UIKit
import SwiftyCss

class TestBasic: CssViewController {
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = .white
        
        let css = [
            "#test-basic .box {background:#aaa;}",
            ""
        ]
        Css.load( css.joined(separator: "\n") )
        self.view.css(insert:
            ".body#test-basic",
            "   CALayer.box[style=top:10;left:5%;width:43%;height:100]",
            "   CALayer.box[style=top:10;right:5%;width:43%;height:100]",
            "   CALayer.box[style=top:130;left:5%;right:5%;bottom:10]",
            "     CATextLayer[style=float:center;autoSize:auto;fontSize:16;color:#fff;][content=The center of the universe]",
            "UIScrollView.footer > CATextLayer"
        )
        if let text = self.query(layer: ".footer > CATextLayer")?[0] as? CATextLayer {
            text.string = css.joined(separator: "\n") + "\n------------------------------------------\n" + Css.debugPrint(self.view, noprint: true)
        }
    }
    
}
