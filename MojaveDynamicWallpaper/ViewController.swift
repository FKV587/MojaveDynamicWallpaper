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
    let program = Program()
    var scrollView: NSScrollView = {
        let c = NSScrollView.init()
        return c
    }()
    
    lazy var imageNames:NSArray = {
        let array = NSMutableArray()
        for index in 00 ... 12{
            array.add("\(index).png")
        }
        return NSArray.init(array: array)
    }()
    
    
    lazy var flowLayout: NSCollectionViewFlowLayout = {   // 这里就是我们的NSCollectionView
        // 这里和UICollectionView中的设计一样，我们需要设定布局
        let flowLayout = NSCollectionViewFlowLayout.init()
//        flowLayout.scrollDirection = .vertical  // 设置排列方式
        flowLayout.itemSize = NSSize(width: 80.0, height: 80.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 20.0
        flowLayout.sectionHeadersPinToVisibleBounds = true

//        let collection = NSCollectionView.init()
//        collection.collectionViewLayout = flowLayout    // 指定布局
//        collection.isSelectable = true                  // item是否可以点击
//        collection.delegate = self
//        collection.dataSource = self

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
        return 16
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ImageCollectionViewItem"), for: indexPath)
        item.textField?.stringValue = "\(indexPath.item)"
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else {
            print("ZERO")
            return
        }
        print("\(indexPath.item)")
    }
    
}

extension ViewController: NSCollectionViewDelegateFlowLayout {
    // 返回Item的size
//    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
//        return NSSize.init(width: 80, height: 80)
//    }
}

