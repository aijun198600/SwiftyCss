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

class ListViewController: UITableViewController {
    
    let examples: [(title: String, clas: UIViewController.Type )] = [
        ("Basic", TestBasic.self),
        ("Style", TestStyle.self),
        ("Layout", TestLayout.self),
        ("Selector", TestSelector.self),
        ("Media", TestMedia.self),
        ("Text", TestBasic.self)
    ]
    
    override func loadView() {
        super.loadView()
        self.title = "Examples"
        self.view.backgroundColor = .white
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SwiftyCss.Examples")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data =  self.examples[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwiftyCss.Examples", for: indexPath)
        cell.textLabel?.text = data.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examples.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.examples[indexPath.row]
        let view = data.clas.init()
        if view.title == nil {
            view.title = "Test "+data.title
        }
        self.navigationController?.pushViewController(view, animated: true)
    }
    
}


