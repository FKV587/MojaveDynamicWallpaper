//
//  ViewController.swift
//  MojaveDynamicWallpaper
//
//  Created by Fukai on 2018/12/10.
//  Copyright © 2018年 FuKai. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    let program = Program()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getsssss()

    }
    
    func getsssss(){
        program.inputFileName = "/Users/FK/Desktop/image/image1.png"

        let fileAccess = AppSandboxFileAccess.init()
        fileAccess?.persistPermissionPath(program.inputFileName)
        do {
            let parentDirectory = try program.getPathToJsonFile().deletingLastPathComponent().absoluteString
            
            let accessAllowed = fileAccess?.accessFilePath(parentDirectory, persistPermission: true, with: { [weak self] in
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

