//
//  TestMedia.swift
//  Example
//
//  Created by Wang Liang on 2017/4/7.
//  Copyright © 2017年 Wang Liang. All rights reserved.
//

import UIKit
import SwiftyCss

class TestMedia: CssViewController {
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = .white
        
        let css = [
            "#test-media {top:0; bottom:40%; width:100%; auto-size:auto;}",
            "#test-media .title {float:top; left:10; right:10; height:20; margin:10 10 0 10; font-size:16; color:#000;}",
            "#test-media .block {float:top; align: center; left:10; right:10; height:100; margin:0 10 0 10; background:#ddd}",
            "#test-media .box {float:auto; margin:5; background:#c00;width:40;height:40;color:#fff; font-size:8; word-wrap:true}",
            "@media orientation:landscape     {",
            "#test-media .title {content: media = landscape}",
            "#test-media .box {radius:20;}",
            "}",
            "@media orientation:portrait     {",
            "#test-media .title {content: media = portrait}",
            "}"
        ]
        
        Css.load( css.joined(separator: "\n") )
        
        self.view.css(insert:
            "UIScrollView#test-media",
                      
            " CATextLayer.title",
            " CALayer.block",
            "     CALayer.box",
            "     CALayer.box",
            "     CALayer.box",
            "     CALayer.box",
            "     CALayer.box",
            
            "UIScrollView.footer > CATextLayer",
            ""
        )
        
        if let text = self.query(layer: ".footer > CATextLayer")?[0] as? CATextLayer {
            text.string = css.joined(separator: "\n") + "\n------------------------------------------\n" + Css.debugPrint(self.view, noprint: true)
        }
        
    }
    
}
