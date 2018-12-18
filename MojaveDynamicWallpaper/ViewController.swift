//
//  ViewController.swift
//  MojaveDynamicWallpaper
//
//  Created by Fukai on 2018/12/10.
//  Copyright © 2018年 FuKai. All rights reserved.
//

import Cocoa
import SnapKit

class ViewController: NSViewController {
    
    @IBOutlet weak var collectionView: NSCollectionView!
    var indexPathsOfItemsBeingDragged: Set<IndexPath> = Set()
    let heic = Heic()

    var list : [PictureInfo] = {
        let array = NSMutableArray()
        for index in 1 ... 16 {
            let info = PictureInfo(fileName: "\(index)", isPrimary: index == 1, isForLight: index == 1, isForDark: index == 1, altitude: 0.0, azimuth: 0.0)
            array.add(info)
        }
        return array as! [PictureInfo]
    }()
    
    lazy var flowLayout: NSCollectionViewFlowLayout = {
        let flowLayout = NSCollectionViewFlowLayout.init()
        flowLayout.itemSize = NSSize(width: 400.0, height: 400.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 20.0
        flowLayout.sectionHeadersPinToVisibleBounds = true
        return flowLayout
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = flowLayout
        collectionView.isSelectable = true
        collectionView.registerForDraggedTypes([NSPasteboard.PasteboardType.string])
        collectionView.setDraggingSourceOperationMask(.every, forLocal: true)
    }
    
    @IBAction func synthesisButtonAction(_ sender: NSButton) {
        synthesis()
    }
    
    func synthesis(){
        heic.outputFilePath = "/Users/FK/Desktop/image"
        let fileAccess = AppSandboxFileAccess.init()
        fileAccess?.persistPermissionPath(heic.outputFilePath)
        let parentDirectory = URL.init(fileURLWithPath: heic.outputFilePath!).deletingLastPathComponent().absoluteString

        let accessAllowed = fileAccess?.accessFilePath(parentDirectory, persistPermission: false, with: { [weak self] in
            guard let weakSelf = self else{return}
            weakSelf.heic.run(list:weakSelf.list)
        })
        if !accessAllowed! {
            print("没有授权")
        }
    }
}


extension ViewController:NSCollectionViewDelegate,NSCollectionViewDataSource{
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item:ImageCollectionViewItem = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ImageCollectionViewItem"), for: indexPath) as! ImageCollectionViewItem
        let info = list[indexPath.item]
        item.info = info
        item.indexPath = indexPath
        item.delegate = self
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else {
            print("ZERO")
            return
        }
        print("\(indexPath.item)")
    }
    
// MARK: 移动编辑cell
    func collectionView(_ collectionView: NSCollectionView, canDragItemsAt indexPaths: Set<IndexPath>, with event: NSEvent) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
        let pb = NSPasteboardItem()
        let info = list[indexPath.item]
        pb.setString(info.fileName, forType: NSPasteboard.PasteboardType.string)
        return pb
    }
    
    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItemsAt indexPaths: Set<IndexPath>) {
        for indexPath in indexPaths {
            print("fromItemIndex \(indexPath.item)")
        }
        indexPathsOfItemsBeingDragged = indexPathsOfItemsBeingDragged.union(indexPaths)
    }
    
    func collectionView(_ collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>) -> NSDragOperation {
        
        if !indexPathsOfItemsBeingDragged.isEmpty {
            return .move;
        } else {
            return .copy;
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: IndexPath, dropOperation: NSCollectionView.DropOperation) -> Bool {
        var toItemIndex = indexPath.item
        print("toItemIndex1 \(toItemIndex)")
        let array:[PictureInfo] = NSArray.init(array: list) as! [PictureInfo]
        for fromItemIndexPath in indexPathsOfItemsBeingDragged {
            let fromItemIndex = fromItemIndexPath.item
            list.remove(at: fromItemIndex)
            if fromItemIndex > toItemIndex{
                list.insert(array[fromItemIndex], at: toItemIndex)
                self.collectionView.animator().moveItem(at: fromItemIndexPath, to: indexPath)
            }else{
                toItemIndex = toItemIndex - 1
                list.insert(array[fromItemIndex], at: toItemIndex)
                self.collectionView.animator().moveItem(at: fromItemIndexPath, to: IndexPath.init(item: toItemIndex, section: indexPath.section))
            }
        }

        return true
    }
    
    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, dragOperation operation: NSDragOperation) {
        indexPathsOfItemsBeingDragged.removeAll()
    }

}

extension ViewController: NSCollectionViewDelegateFlowLayout {
    // 返回Item的size
//    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
//        let height =  (self.view.frame.size.width - 20 * 4.0) / 4.0
//        return NSSize.init(width: height, height: height)
//    }
}

extension ViewController: ImageCollectionViewItemDelegate{
    func changePictureInfoType(type: ImageCollectionChangeType, indexPath: IndexPath) {
        
        let info = self.list[indexPath.item]
        switch type {
        case .altitude: break
        case .azimuth: break
        case .primary:
            for lastInfo in self.list{
                lastInfo.isPrimary = false;
            }
            info.isPrimary = true
        case .forLight:
            for lastInfo in self.list{
                lastInfo.isForLight = false;
            }
            info.isForLight = true
        case .forDark:
            for lastInfo in self.list{
                lastInfo.isForDark = false;
            }
            info.isForDark = true
        }
        self.collectionView.reloadData()
    }
}
