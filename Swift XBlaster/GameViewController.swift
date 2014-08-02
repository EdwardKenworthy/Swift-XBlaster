//
//  GameViewController.swift
//  Swift XBlaster
//
//  Created by Edward Kenworthy on 04/06/2014.
//  Copyright (c) 2014 Himeji Heavy Industry. All rights reserved.
//

import UIKit
import SpriteKit

//extension SKNode {
//    class func unarchiveFromFile(file : NSString) -> SKNode? {
//        
//        let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks")
//        
//        var sceneData = NSData.dataWithContentsOfFile(path, options: .DataReadingMappedIfSafe, error: nil)
//        var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
//        
//        archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
//        let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
//        archiver.finishDecoding()
//        return scene
//    }
//}

class GameViewController: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Configure the view.
        let skView = self.view as SKView
        skView.showsFPS = true;
        skView.showsNodeCount = true;
        
        // Create and configure the scene.
        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill;
        
        // Present the scene.
        skView.presentScene(scene)
    }

    override func prefersStatusBarHidden() -> Bool {return true}
    override func shouldAutorotate() -> Bool {return true}

    override func supportedInterfaceOrientations() -> Int
    {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.toRaw())
        }
        else
        {
            return Int(UIInterfaceOrientationMask.All.toRaw())
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
}
