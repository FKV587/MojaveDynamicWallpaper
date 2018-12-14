//
//  ImageCollectionViewItem.swift
//  MojaveDynamicWallpaper
//
//  Created by Fukai on 2018/12/14.
//  Copyright © 2018 FuKai. All rights reserved.
//

import Cocoa

class ImageCollectionViewItem: NSCollectionViewItem {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.cgColor
        view.layer?.borderColor = NSColor.white.cgColor
        view.layer?.borderWidth = 0.0
        textField?.stringValue = "xxxx"
    }
}
