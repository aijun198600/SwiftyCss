//
//  ViewController.swift
//  Example
//
//  Created by Wang Liang on 2017/3/31.
//  Copyright © 2017年 Wang Liang. All rights reserved.
//

import UIKit
import SwiftyCss
import SwiftyNode

class ViewController: CssViewController {

    override func viewDidLoad() {
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        Css.load(
            "#list-view {width:100%; height:100%; content-size:auto;}" +
            ".list-item {width:100%; height:80; float:top; background:#f00; border-bottom:1 solid #aaa;}" +
            ".list-title {font-size:30; color:#333; height:60; width:100%;}"
        )
        
        super.viewDidLoad()
        
        self.view.css(creates: [
            "UIScrollView#list-view",
            "   CALayer.list-item",
            "       CATextLayer.list-title[style=content:Basic]",
            "   CALayer.list-item",
            "       CATextLayer.list-title[style=content:Basic]",
            "   CALayer.list-item",
            "       CATextLayer.list-title[style=content:Basic]",
            "   CALayer.list-item",
            "       CATextLayer.list-title[style=content:Basic]",
            "   CALayer.list-item",
            "       CATextLayer.list-title[style=content:Basic]",
            "   CALayer.list-item",
            "       CATextLayer.list-title[style=content:Basic]",
            "   CALayer.list-item",
            "       CATextLayer.list-title[style=content:Basic]",
            "   CALayer.list-item",
            "       CATextLayer.list-title[style=content:Basic]",
            "   CALayer.list-item",
            "       CATextLayer.list-title[style=content:Basic]",
            "   CALayer.list-item",
            "       CATextLayer.list-title[style=content:Basic]",
            "   CALayer.list-item",
            "       CATextLayer.list-title[style=content:Basic]",
            ""
        ])
        
//        self.view.css(id: "root-view")
//        self.view.css(create: "#center-block")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        let t2 = CACurrentMediaTime()
//        var sele2 = Node.Select(".list-title")
//        for _ in 0 ... 10000 {
//            _ = sele2.query(self.view)
//        }
//        let dt2 = CACurrentMediaTime() - t2
//        print("-----2>", dt2)
        
        
//        Css.debugPrint(self.view, deep: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

