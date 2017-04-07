import UIKit
import SwiftyCss

class TestStyle: CssViewController {
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = .white
        
        let css = [
            "#test-style {top:0; bottom:40%; width:100%; auto-size:auto;}",
            "#test-style .title {float:top; left:10; right:10; height:20; margin:10 10 0 10; font-size:16; color:#000;}",
            "#test-style .block {float:top; left:10; right:10; height:100; margin:0 10 0 10; align:center; background:#ddd}",
            "#test-style .box {float:auto; margin:5; background:#c00;width:40;height:40;color:#000; font-size:8; word-wrap:true}"
        ]
        
        Css.load( css.joined(separator: "\n") )
        
        self.view.css(insert:
                      "UIScrollView#test-style",
                   
                      " CATextLayer.title[content=border]",
                      " CALayer.block",
                      "     CATextLayer.box[style=width:100; border:2 solid #0f0;][content=border:2 solid #0f0]",
                      "     CATextLayer.box[style=width:100; border:2 dashed #0f0;][content=border:2 dashed #0f0]",
                      "     CATextLayer.box[style=width:100; border:2 6 #0f0;][content=border:2 6 #0f0]",
                      "     CATextLayer.box[style=width:100; borderBottom:2 solid #0f0;][content=border-bottom:2 solid #0f0]",
                      
                      " CATextLayer.title[content=backgroundIamge]",
                      " CALayer.block",
                      "     CALayer.box[style=width:80; height:80; backgroundImage:icon.png]",
                      
                      " CATextLayer.title[content=Radius]",
                      " CALayer.block",
                      "     CALayer.box[style=radius:10]",
                      "     CALayer.box[style=radius:20]",
                      "     CALayer.box[style=radius:30]",
                      
                      " CATextLayer.title[content=shadow]",
                      " CALayer.block[style=height:100;]",
                      "     CALayer.box[style=shadow:0 0 5 #000]",
                      "     CALayer.box[style=shadow:5 5 5 #000]",
                      "     CALayer.box[style=shadow:5 5 0 #000]",
                      
                      " CATextLayer.title[content=opacity]",
                      " CALayer.block[style=height:100;]",
                      "     CALayer.box[style=opacity:1]",
                      "     CALayer.box[style=opacity:0.8]",
                      "     CALayer.box[style=opacity:0.6]",
                      "     CALayer.box[style=opacity:0.4]",
                      
                      "UIScrollView.footer > CATextLayer",
                      ""
        )
        
        if let text = self.query(layer: ".footer > CATextLayer")?[0] as? CATextLayer {
            text.string = css.joined(separator: "\n") + "\n------------------------------------------\n" + Css.debugPrint(self.view, noprint: true)
        }
        
    }
    
}
