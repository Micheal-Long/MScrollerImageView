//
//  ViewController.swift
//  MScrollerImageView
//
//  Created by Micheal on 2016/11/28.
//  Copyright © 2016年 Micheal. All rights reserved.
//

import UIKit

class ViewController: UIViewController,ScrollerImageViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib. 
        
        let imageArray = ["hello1","hello2","hello3","hello4","hello5","hello6","hello7","hello8","hello9"]
        
        let scrollImageView = MScrollImageView(frame: CGRect(x: 0.0, y: 20.0, width: self.view.frame.size.width, height: self.view.frame.size.width*5.0/8.0), images: imageArray, isUrl: false)
        scrollImageView.delegate = self
        scrollImageView.backgroundColor = UIColor.lightGray
        self.view.addSubview(scrollImageView)        
    }
    
    func didSelectedScrollImage(_ scrollImage: MScrollImageView, atIndex: Int) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

