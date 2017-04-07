
import UIKit
import SwiftyCss

class TestSelector: CssViewController {
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = .white
        
        
        let css = [
            "#test-sel {top:0; bottom:40%; width:100%; auto-size:auto;}",
            "#test-sel .title {float:top; left:10; right:10; height:20; margin:10 10 0 10; font-size:16; color:#000;}",
            "#test-sel .block {float:top; left:10; right:10; height:100; margin:0 10 0 10; align:center; background:#ddd}",
            "#test-sel .box {float:auto; margin:5; background:#c00;width:40;height:40;color:#fff; font-size:10; word-wrap:true}",
            
            "#test-sel-block-1 * {background:#000}",
            "#test-sel-block-2 CATextLayer {background:#000;}",
            "#test-sel-block-3 .box:nth-child(even) {background:#000;}",
            "#test-sel-block-4 .box:last-child {background:#000;}",
            "#test-sel-block-5 .box[width>=60] {background:#000}",
            "#test-sel-block-6 .box:not(CALayer) {background:#000}",
            "#test-sel-block-7 * {width:80%;height:60%;float:center; border:2 solid #0f0; background:#aaa; color:#fff; font-size:10; word-wrap:true}",
            "#test-sel-block-7 CALayer > CATextLayer {background:#000}}"
            
        ]
        
        Css.load( css.joined(separator: "\n") )
        
        self.view.css(insert:
            "UIScrollView#test-sel",
                      
            " CATextLayer.title[content=* {background:#000}]",
            " CALayer#test-sel-block-1.block",
            "     CALayer.box",
            "     CALayer.box",
            "     CALayer.box",
            "     CATextLayer.box[content:Iam Text]",
            
            " CATextLayer.title[content=CATextLayer {background:#000}]",
            " CALayer#test-sel-block-2.block",
            "     CALayer.box",
            "     CATextLayer.box[content=Iam Text]",
            "     CALayer.box",
            "     CALayer.box",
            
            " CATextLayer.title[content=.box:nth-child(even) {background:#000}]",
            " CALayer#test-sel-block-3.block",
            "     CALayer.box",
            "     CALayer.box",
            "     CALayer.box",
            "     CALayer.box",
            "     CALayer.box",
            "     CALayer.box",
            
            " CATextLayer.title[content=.box:last-child {background:#000}]",
            " CALayer#test-sel-block-4.block",
            "     CALayer.box",
            "     CALayer.box",
            "     CALayer.box",
            "     CALayer.box",
            
            " CATextLayer.title[content=.box[width>=60] {background:#000}]",
            " CALayer#test-sel-block-5.block",
            "     CALayer.box[style=width:40]",
            "     CALayer.box[style=width:50]",
            "     CALayer.box[style=width:60]",
            "     CALayer.box[style=width:70]",
            
            " CATextLayer.title[content=.box:not(CALayer) {background:#000}]",
            " CALayer#test-sel-block-6.block",
            "     CALayer.box[style=width:40]",
            "     CATextLayer.box[style=width:50][content=Iam Text]",
            "     CALayer.box[style=width:60]",
            "     CALayer.box[style=width:70]",
            
            " CATextLayer.title[content=CALayer>CATextLayer {background:#000}]",
            " CALayer#test-sel-block-7.block[style=height:200]",
            "     CALayer",
            "       CATextLayer[content=Iam Text]",
            "           CATextLayer[content=Iam Text]",
            "               CALayer",
            
            "UIScrollView.footer > CATextLayer",
            ""
        )

        if let text = self.query(layer: ".footer > CATextLayer")?[0] as? CATextLayer {
            text.string = css.joined(separator: "\n") + "\n------------------------------------------\n" + Css.debugPrint(self.view, noprint: true)
        }
        
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        Css.debugPrint(self.view)
//    }
    
    
}
