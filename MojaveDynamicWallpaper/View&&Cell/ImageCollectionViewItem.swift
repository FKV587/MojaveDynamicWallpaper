//
//  ImageCollectionViewItem.swift
//  MojaveDynamicWallpaper
//
//  Created by Fukai on 2018/12/14.
//  Copyright © 2018 FuKai. All rights reserved.
//

import Cocoa

enum ImageCollectionChangeType {
    case altitude
    case azimuth
    case primary
    case forLight
    case forDark
}

protocol ImageCollectionViewItemDelegate {
    //代理函数
    func changePictureInfoType(type:ImageCollectionChangeType,indexPath:IndexPath)
}

class ImageCollectionViewItem: NSCollectionViewItem {
    
    var delegate:ImageCollectionViewItemDelegate?
    
    @IBOutlet weak var altitudeTextField: NSTextField!
    @IBOutlet weak var azimuthTextField: NSTextField!
    @IBOutlet weak var primarySwitch: NSButton!
    @IBOutlet weak var forLightSwitch: NSButton!
    @IBOutlet weak var forDarkSwitch: NSButton!
    
    var info: PictureInfo?{
        didSet {
            self.reloadView()
        }
    }
    var indexPath:IndexPath?
    
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
        view.layer?.backgroundColor = NSColor.black.cgColor
        view.layer?.borderColor = NSColor.white.cgColor
        view.layer?.borderWidth = 5.0
    }
    
    func reloadView() {
        guard let info = self.info else {return}
        self.altitudeTextField.stringValue = "\(info.altitude)"
        self.azimuthTextField.stringValue = "\(info.azimuth)"
        
        if !info.fileName.isEmpty {
            self.textField?.stringValue = info.fileName
            let image = NSImage.init(named: info.fileName)
            self.imageView?.image = image
            self.info?.image = image
        }else{
            self.textField?.stringValue = "name"
        }

        if info.isPrimary == true {
            self.primarySwitch.state = .on;
        }else{
            self.primarySwitch.state = .off;
        }
        
        if info.isForLight == true{
            self.forLightSwitch.state = .on;
        }else{
            self.forLightSwitch.state = .off;
        }
        
        if info.isForDark == true{
            self.forDarkSwitch.state = .on;
        }else{
            self.forDarkSwitch.state = .off;
        }
    }

    @IBAction func pfimarySwitchAction(_ sender: NSButton) {
        self.info?.isPrimary = sender.state == .on
        changeDic(.primary)
    }
    
    @IBAction func forLightSwitchAction(_ sender: NSButton) {
        self.info?.isForLight = sender.state == .on
        changeDic(.forLight)
    }
    
    @IBAction func forDarkSwitchAction(_ sender: NSButton) {
        self.info?.isForDark = sender.state == .on
        changeDic(.forDark)
    }
    
    @IBAction func textFiledAction(_ sender: NSTextField) {
        self.info?.altitude = Double(sender.stringValue) ?? 0.0
        changeDic(.altitude)
    }
    
    @IBAction func azimuthTextFieldAction(_ sender: NSTextField) {
        self.info?.azimuth = Double(sender.stringValue) ?? 0.0
        changeDic(.azimuth)
    }
    
    func changeDic(_ type:ImageCollectionChangeType) {
        guard let indexPath = indexPath else {return}
        delegate?.changePictureInfoType(type: type, indexPath: indexPath)
    }
    
}
