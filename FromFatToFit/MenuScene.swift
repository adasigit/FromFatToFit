//
//  MenuScene.swift
//  FromFatToFit
//
//  Created by Sigit Academy on 26/05/24.
//

import SpriteKit

class MenuScene: SKScene {
    
    var normalButton: Button!
    var continousButton: Button!
    var vc: ViewController!
    
    var statuslabel = SKLabelNode(fontNamed: "ArialMT")
            
    override func didMove(to view: SKView) {
        self.removeAllChildren()
        self.removeAllActions()
        
        let background = SKSpriteNode(imageNamed: "background")
        background.alpha = 0.1
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = -1
        self.addChild(background)
        
        normalButton = Button(texture: SKTexture(imageNamed: "button"), color: .red, size: CGSize(width: 300, height: 100), text: "Normal")
        normalButton.name = "Normal Mode"
        normalButton.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        
        self.addChild(normalButton)
        
        continousButton = Button(texture: SKTexture(imageNamed: "button"), color: .red, size: CGSize(width: 300, height: 100),text: "Continous")
        continousButton.name = "Continous Mode"
        continousButton.position = CGPoint(x: self.size.width/2, y: self.size.height/2 - 150)
        self.addChild(continousButton)
        
        let label = SKLabelNode(text: "Choose Game Mode")
        label.fontSize = 30
        label.zPosition = 100
        label.position = CGPoint(x: self.size.width/2, y: self.size.height/2 + 100)
        label.fontColor = .white
        
        self.addChild(label)
        
        statuslabel.fontSize = 10
        statuslabel.position = CGPoint(x: frame.maxX - 200, y: frame.maxY - 80)
        statuslabel.zPosition = 20
        statuslabel.text = "Bluetooth disconnected"
        addChild(statuslabel)
    }
    
    override func mouseDown(with event: NSEvent) {
        
        let loc = event.location(in: self)
        
        let node = self.atPoint(loc)
        
        if node.name == "Normal Mode"{
            vc.presentGame(.normal)
        } else {
            vc.presentGame(.continous)
        }
        
    }
    
}
