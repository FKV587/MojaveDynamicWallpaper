//
//  ImageCollectionViewItem.swift
//  MojaveDynamicWallpaper
//
//  Created by Fukai on 2018/12/14.
//  Copyright © 2018 FuKai. All rights reserved.
//

import Cocoa

class ImageCollectionViewItem: NSCollectionViewItem {
    
    override var isSelected: Bool{
        didSet{
            view.layer?.borderColor = isSelected ? NSColor.red.cgColor : NSColor.white.cgColor
        }
    }
    
    override var highlightState: NSCollectionViewItem.HighlightState{
        didSet{
            if highlightState == .forSelection {
                view.layer?.borderColor = NSColor.orange.cgColor
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.cgColor
        view.layer?.borderColor = NSColor.white.cgColor
        view.layer?.borderWidth = 5.0
    }
    
}
