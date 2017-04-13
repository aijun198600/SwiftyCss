import UIKit
import SwiftyCss

class TestText: CssViewController {
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = .white
        
        let css = [
            "#test-text {top:0; bottom:40%; width:100%; auto-size:auto;}",
            "#test-text .title {float:top; left:10; right:10; height:20; margin:10 10 0 10; font-size:16; color:#000;}",
            "#test-text .block {float:top; left:10; right:10; height:100; margin:0 10 0 10; align:center; background:#ddd}",
            "#test-text .box {float:center; background:#000;word-wrap:true}"
        ]
        
        Css.load( css.joined(separator: "\n") )
        
        self.view.css(insert:
            "UIScrollView#test-text",
                      
            " CATextLayer.title[content=font-size:20; color:#fff]",
            " CALayer.block",
            "     CATextLayer.box[style=width:50%;height:80%;fontSize:20;color:#fff][content=Abcd]",
            
            " CATextLayer.title[content=text-align:center]",
            " CALayer.block",
            "     CATextLayer.box[style=width:50%;height:80%;fontSize:20;color:#fff;textAlign:center][content=Abcd]",
            
            " CATextLayer.title[content=word-wrap:true]",
            " CALayer.block",
            "     CATextLayer.box[style=width:50%;height:80%;fontSize:20;color:#fff;wordWrap:true][content=Ab cd ef gh ij kl mn op qr st uv wx yz ab Ab cd ef gh ij kl mn op qr st uv wx yz ab]",
            
            " CATextLayer.title[content=auto-size:auto]",
            " CALayer.block",
            "     CATextLayer.box[style=fontSize:20;color:#fff;autoSize:auto][content=Abcd]",
            
            " CATextLayer.title[content=font-name:Noteworthy-Bold]",
            " CALayer.block",
            "     CATextLayer.box[style=fontSize:20;color:#fff;autoSize:auto;fontName:Noteworthy-Bold][content=Abcd]",
            
            " CATextLayer.title[content=UILabel]",
            " UIView.block",
            "     UILabel.box[style=fontSize:20;color:#fff;autoSize:auto;][content=Abcd]",
            
            " CATextLayer.title[content=UITextField]",
            " UIView.block",
            "     UITextField.box.a1[style=fontSize:20;color:#fff;autoSize:auto;][content=Abcd]",
            
            " CATextLayer.title[content=UITextView]",
            " UIView.block",
            "     UITextView.box.a2[style=fontSize:20;color:#fff;autoSize:auto;][content=Abcd]",

                      
            "UIScrollView.footer > CATextLayer",
            ""
        )
        
        if let text = self.query(layer: ".footer > CATextLayer")?[0] as? CATextLayer {
            text.string = css.joined(separator: "\n") + "\n------------------------------------------\n" + Css.debugPrint(self.view, noprint: true)
        }
        
    }
    
}
