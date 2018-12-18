//
//  Heic.swift
//  MojaveDynamicWallpaper
//
//  Created by Fukai on 2018/12/18.
//  Copyright © 2018 FuKai. All rights reserved.
//

import Foundation
import AVFoundation
import AppKit

class Heic: NSObject {
    var outputFileName = "output.heic"
    var outputFilePath:String?
    let options = [kCGImageDestinationLossyCompressionQuality: 1.0]

    func run(list infoList:[PictureInfo]) {
        let destinationData = NSMutableData()
        var list:[PictureInfo] = []
        for info in infoList {
            if (info.image != nil) {
                list.append(info)
            }
        }
        
        if let destination = CGImageDestinationCreateWithData(destinationData, AVFileType.heic as CFString, list.count, nil) {
            
            list.sort { (left, right) -> Bool in
                return left.isPrimary == true
            }
            
            for (index, pictureInfo) in list.enumerated() {
                
                if let cgImage = pictureInfo.image?.CGImage {
                    
                    if index == 0 {
                        let imageMetadata = CGImageMetadataCreateMutable()
                        
                        guard CGImageMetadataRegisterNamespaceForPrefix(imageMetadata, "http://ns.apple.com/namespace/1.0/" as CFString, "apple_desktop" as CFString, nil) else {return}
                        
                        let sequenceInfo = self.createPropertyList(list: list)
                        do{
                            let base64PropertyList = try self.createBase64PropertyList(sequenceInfo: sequenceInfo)
                            let imageMetadataTag = CGImageMetadataTagCreate("http://ns.apple.com/namespace/1.0/" as CFString, "apple_desktop" as CFString, "solar" as CFString, CGImageMetadataType.string, base64PropertyList as CFTypeRef)
                            
                            guard CGImageMetadataSetTagWithPath(imageMetadata, nil, "apple_desktop:solar" as CFString, imageMetadataTag!) else {return}
                            
                            CGImageDestinationAddImageAndMetadata(destination, cgImage, imageMetadata, self.options as CFDictionary)
                        }catch{
                            print("Base64编码失败")
                        }
                    } else {
                        CGImageDestinationAddImage(destination, cgImage, self.options as CFDictionary)
                    }
                }
            }
            
            guard CGImageDestinationFinalize(destination) else {
                return
            }
            
            let outputURL = URL(fileURLWithPath: self.outputFileName, relativeTo: URL.init(fileURLWithPath: self.outputFilePath!))
            let imageData = destinationData as Data
            do{
                try imageData.write(to: outputURL)
            }catch{
                print("图片写入失败")
            }
        }
    }
    
    func createPropertyList(list:[PictureInfo]) -> SequenceInfo {
        
        let sequenceInfo = SequenceInfo()
        for (index, item) in list.enumerated() {
            let sequenceItem = SequenceItem()
            sequenceItem.a = item.altitude
            sequenceItem.z = item.azimuth
            sequenceItem.i = index
            
            if item.isForLight {
                sequenceInfo.ap.l = index
            }
            
            if item.isForDark {
                sequenceInfo.ap.d = index
            }
            
            sequenceInfo.si.append(sequenceItem)
        }
        
        return sequenceInfo
    }
    
    func createBase64PropertyList(sequenceInfo: SequenceInfo) throws -> String {
        
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        let plistData = try encoder.encode(sequenceInfo)
        
        let base64PropertyList = plistData.base64EncodedString()
        return base64PropertyList
    }
}
