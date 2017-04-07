
import UIKit
import SwiftyCss

class TestLayout: CssViewController {
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = .white
        
        let css = [
            "#test-layout {top:0; bottom:40%; width:100%; auto-size:auto;}",
            "#test-layout .title {float:top; left:10; right:10; height:20; margin:10 10 0 10; font-size:16; color:#000;}",
            "#test-layout .block {float:top; left:10; right:10; height:100; margin:0 10 0 10; background:#ddd}",
            "#test-layout .box {background:#c00;width:40;height:40;color:#fff; font-size:8; word-wrap:true}"
        ]
        
        Css.load( css.joined(separator: "\n") )
        
        self.view.css(insert:
            "UIScrollView#test-layout",
            
            " CATextLayer.title[content=Position: top right bottom left]",
            " CALayer.block[style=height:90]",
            "     CATextLayer.box[content=top:0;\\nleft:0]",
            "     CATextLayer.box[style=right:0][content=top:0;\\nright:0]",
            "     CATextLayer.box[style=bottom:0;][content=bottom:0;\\nleft:0]",
            "     CATextLayer.box[style=right:0;bottom:0;][content=bottom:0;\\nrignt:0]",
            "     CATextLayer.box[style=top:50%;left:50%;][content=top:50%;\\nleft:50%;]",
            
            " CATextLayer.title[content=Size: width maxWidth minWidth height maxHeight minHeight]",
            " CALayer.block[style=height:100]",
            "     CATextLayer.box[style=top:0;left:0;right:50%][content=left:0;\\nright:50%]",
            "     CATextLayer.box[style=top:0;left:55%;width:100%;maxWidth:100;][content=width:100%;\\nmaxWidth:100]",
            "     CATextLayer.box[style=top:50;right:0;width:50%][content=right:0;\\nwidth:50%]",
            "     CATextLayer.box[style=top:50;bottom:0;][content=top:50;\\nbottom:0;]",
            
            " CATextLayer.title[content=float = auto and margin = 5]",
            " CALayer.block[style=height:100;]",
            "     CALayer.box[style=float:auto; margin:5]",
            "     CALayer.box[style=float:auto; margin:5]",
            "     CALayer.box[style=float:auto; margin:5]",
            "     CALayer.box[style=float:auto; margin:5]",
            "     CALayer.box[style=float:auto; margin:5]",
            "     CALayer.box[style=float:auto; margin:5]",
            "     CALayer.box[style=float:auto; margin:5]",
            "     CALayer.box[style=float:auto; margin:5]",
            "     CALayer.box[style=float:auto; margin:5]",
            "     CALayer.box[style=float:auto; margin:5]",
            
            " CATextLayer.title[content=float = top/right/cneter and margin = 5]",
            " CALayer.block[style=height:150;]",
            "     CATextLayer.box[style=float:top; margin:5][content=float:top]",
            "     CATextLayer.box[style=float:top; margin:5][content=float:top]",
            "     CATextLayer.box[style=float:top; margin:5][content=float:top]",
            
            "     CATextLayer.box[style=float:right; margin:5][content=float:rignt]",
            "     CATextLayer.box[style=float:right; margin:5][content=float:rignt]",
            "     CATextLayer.box[style=float:right; margin:5][content=float:rignt]",
            
            "     CATextLayer.box[style=float:center; margin:5][content=float:center]",
            
            " CATextLayer.title[content=float = auto and parent.align = center]",
            " CALayer.block[style=height:100; align:center]",
            "     CALayer.box[style=float:auto; margin:5]",
            "     CALayer.box[style=float:auto; margin:5]",
            "     CALayer.box[style=float:auto; margin:5]",
            "     CALayer.box[style=float:auto; margin:5]",
            
            " CATextLayer.title[content=float = auto and parent.align = bottom]",
            " CALayer.block[style=height:100; align:bottom]",
            "     CALayer.box[style=float:auto; margin:5]",
            "     CALayer.box[style=float:auto; margin:5]",
            "     CALayer.box[style=float:auto; margin:5]",
            "     CALayer.box[style=float:auto; margin:5]",
            
            " CATextLayer.title[content=float = auto and parent.align = topCenter]",
            " CALayer.block[style=height:100; align:topCenter]",
            "     CALayer.box[style=float:auto; margin:5]",
            "     CALayer.box[style=float:auto; margin:5]",
            "     CALayer.box[style=float:auto; margin:5]",
            "     CALayer.box[style=float:auto; margin:5]",
            
            " CATextLayer.title[content=float = auto and parent.align = bottomCenter]",
            " CALayer.block[style=height:100; align:bottomCenter]",
            "     CALayer.box[style=float:auto; margin:5]",
            "     CALayer.box[style=float:auto; margin:5]",
            "     CALayer.box[style=float:auto; margin:5]",
            "     CALayer.box[style=float:auto; margin:5]",
            
                      
            "UIScrollView.footer > CATextLayer",
            ""
        )
        
        if let text = self.query(layer: ".footer > CATextLayer")?[0] as? CATextLayer {
            text.string = css.joined(separator: "\n") + "\n------------------------------------------\n" + Css.debugPrint(self.view, noprint: true)
        }
        
    }
    
}
