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
    
    var indexPathsOfItemsBeingDragged: Set<IndexPath> = Set()
    var list : [[String:String]] = {
        let array = NSMutableArray()
        
        for index in 0 ... 16 {
            let dic = NSMutableDictionary()
            dic.setValue("\(index)", forKey: "fileName")
            dic.setValue("\(false)", forKey: "isPrimary")
            dic.setValue("\(false)", forKey: "isForLight")
            dic.setValue("", forKey: "altitude")
            dic.setValue("", forKey: "azimuth")
            dic.setValue("", forKey: "filePath")
            array.add(dic)
        }
        
        return array as! [[String : String]]
    }()
    
    @IBOutlet weak var collectionView: NSCollectionView!
    let program = Program()
    
    lazy var flowLayout: NSCollectionViewFlowLayout = {
        let flowLayout = NSCollectionViewFlowLayout.init()
//        flowLayout.itemSize = NSSize(width: 80.0, height: 80.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 20.0
        flowLayout.sectionHeadersPinToVisibleBounds = true
        return flowLayout
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        getsssss()
        collectionView.collectionViewLayout = flowLayout
        collectionView.isSelectable = true
//        卧槽不需要注册？？？
//        collectionView.register(ImageCollectionViewItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ImageCollectionViewItem"))
        collectionView.registerForDraggedTypes([NSPasteboard.PasteboardType.string])
        collectionView.setDraggingSourceOperationMask(.every, forLocal: true)
    }
    
    func getsssss(){
        program.inputFileName = "/Users/FK/Desktop/image/text.json"

        let fileAccess = AppSandboxFileAccess.init()
        fileAccess?.persistPermissionPath(program.inputFileName)
        do {
            let parentDirectory = try program.getPathToJsonFile().deletingLastPathComponent().absoluteString
            
            let accessAllowed = fileAccess?.accessFilePath(parentDirectory, persistPermission: false, with: { [weak self] in
                self?.run()
            })
            
            if accessAllowed! {
                print("Sad Wookie")
            }else{
                run()
            }
        } catch {
            
        }
    }
    
    func run() {
        let result = program.run()
        exit(result ? EXIT_SUCCESS : EXIT_FAILURE)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
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
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ImageCollectionViewItem"), for: indexPath)
        let dic = list[indexPath.item]
        if  let imageName = dic["fileName"] , !imageName.isEmpty{
                item.textField?.stringValue = imageName
                item.imageView?.image = NSImage.init(named: imageName)
        }else{
            item.textField?.stringValue = "\(indexPath.item)"
        }
        
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
        return String(indexPath.item) as NSPasteboardWriting
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
        let array:[[String : String]] = NSArray.init(array: list) as! [[String : String]]
        for fromItemIndexPath in indexPathsOfItemsBeingDragged {
            let fromItemIndex = fromItemIndexPath.item
            list.remove(at: fromItemIndex)
            if fromItemIndex > toItemIndex{
                list.insert(array[fromItemIndex], at: toItemIndex)
                collectionView.moveItem(at: fromItemIndexPath, to: indexPath)
            }else{
                toItemIndex = toItemIndex - 1
                list.insert(array[fromItemIndex], at: toItemIndex)
                collectionView.moveItem(at: fromItemIndexPath, to: IndexPath.init(item: toItemIndex, section: indexPath.section))
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
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        let height =  (self.view.frame.size.width - 20 * 4.0) / 4.0
        return NSSize.init(width: height, height: height)
    }
}

