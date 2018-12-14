//
//  Generator.swift
//  wallpapper
//
//  Created by Marcin Czachurski on 02/07/2018.
//  Copyright © 2018 Marcin Czachurski. All rights reserved.
//

import Foundation
import AppKit
import AVFoundation

class Generator {

    var picureInfos: [PictureInfo]
    let baseURL: URL
    let outputFileName: String
    let options = [kCGImageDestinationLossyCompressionQuality: 1.0]
    let consoleIO = ConsoleIO()

    init(picureInfos: [PictureInfo], baseURL: URL, outputFileName: String) {
        self.picureInfos = picureInfos
        self.baseURL = baseURL
        self.outputFileName = outputFileName
    }

    func run() throws {
        if #available(OSX 10.13, *) {
            let destinationData = NSMutableData()
            if let destination = CGImageDestinationCreateWithData(destinationData, AVFileType.heic as CFString, self.picureInfos.count, nil) {

                self.picureInfos.sort { (left, right) -> Bool in
                    return left.isPrimary == true
                }

                for (index, pictureInfo) in self.picureInfos.enumerated() {
                    let fileURL = URL(fileURLWithPath: pictureInfo.fileName, relativeTo: self.baseURL)

                    self.consoleIO.writeMessage("Reading image file: '\(fileURL.absoluteString)'...", to: .debug)
                    guard let orginalImage = NSImage(contentsOf: fileURL) else {
                        self.consoleIO.writeMessage("ERROR.\n", to: .debug)
                        return
                    }

                    self.consoleIO.writeMessage("OK.\n", to: .debug)

                    if let cgImage = orginalImage.CGImage {

                        if index == 0 {
                            let imageMetadata = CGImageMetadataCreateMutable()

                            guard CGImageMetadataRegisterNamespaceForPrefix(imageMetadata, "http://ns.apple.com/namespace/1.0/" as CFString, "apple_desktop" as CFString, nil) else {
                                throw NamespaceNotRegisteredError()
                            }

                            let sequenceInfo = self.createPropertyList()
                            let base64PropertyList = try self.createBase64PropertyList(sequenceInfo: sequenceInfo)

                            let imageMetadataTag = CGImageMetadataTagCreate("http://ns.apple.com/namespace/1.0/" as CFString, "apple_desktop" as CFString, "solar" as CFString, CGImageMetadataType.string, base64PropertyList as CFTypeRef)

                            guard CGImageMetadataSetTagWithPath(imageMetadata, nil, "apple_desktop:solar" as CFString, imageMetadataTag!) else {
                                throw AddTagImageError()
                            }

                            self.consoleIO.writeMessage("Adding image and metadata...", to: .debug)
                            CGImageDestinationAddImageAndMetadata(destination, cgImage, imageMetadata, self.options as CFDictionary)
                            self.consoleIO.writeMessage("OK.\n", to: .debug)
                        } else {
                            self.consoleIO.writeMessage("Adding image...", to: .debug)
                            CGImageDestinationAddImage(destination, cgImage, self.options as CFDictionary)
                            self.consoleIO.writeMessage("OK.\n", to: .debug)
                        }
                    }
                }

                self.consoleIO.writeMessage("Finalizing image container...", to: .debug)
                guard CGImageDestinationFinalize(destination) else {
                    throw ImageFinalizingError()
                }
                self.consoleIO.writeMessage("OK.\n", to: .debug)

                let outputURL = URL(fileURLWithPath: self.outputFileName, relativeTo: self.baseURL)
                self.consoleIO.writeMessage("Saving data to file '\(outputURL.absoluteString)'...", to: .debug)
                let imageData = destinationData as Data
                try imageData.write(to: outputURL)
                self.consoleIO.writeMessage("OK.\n", to: .debug)
            }
        } else {
            throw NotSupportedSystemError()
        }
    }

    func createPropertyList() -> SequenceInfo {

        let sequenceInfo = SequenceInfo()

        for (index, item) in self.picureInfos.enumerated() {
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
