//
//  ViewController.swift
//  FromFatToFit
//
//  Created by Sigit Academy on 15/05/24.
//

import Cocoa
import SpriteKit

class ViewController: NSViewController {
    
    @IBOutlet var skView: SKView!
    @IBOutlet var skRendered: SKRenderer!
    
    var menuScene: MenuScene!
    var gameScene: GameScene!
    
    var bluetoothManager : BluetoothManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the SKScene from 'GameScene.sks'
        menuScene = MenuScene(size: CGSize(width: 1512, height: 982))
        menuScene.scaleMode = .aspectFill
        menuScene.vc = self
        
        gameScene = GameScene(size: CGSize(width: 1512, height: 982))
        gameScene.scaleMode = .aspectFill
        gameScene.vc = self
        
        bluetoothManager = BluetoothManager(menuscene: menuScene, gamescene: gameScene)

        presentMenu()
    }
    
    func presentMenu(){
        if let view = self.skView {
                    
            view.showsFPS = false
            view.presentScene(menuScene)
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    func presentGame(_ gameMode: GameMode){
        if let view = self.skView {
            
            view.showsFPS = false
            view.presentScene(gameScene)
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
}

