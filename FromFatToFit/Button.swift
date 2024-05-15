//
//  Button.swift
//  FromFatToFit
//
//  Created by Sigit Academy on 26/05/24.
//

import SpriteKit

protocol ButtonDelegate: AnyObject {
    func buttonClicked(sender: Button)
}

class Button: SKSpriteNode {

    //weak so that you don't create a strong circular reference with the parent
    weak var delegate: ButtonDelegate!

    init(texture: SKTexture?, color: SKColor, size: CGSize, text: String) {

        super.init(texture: texture, color: color, size: size)
        
        let label = SKLabelNode(text: text)
        label.fontName = "SFPro-Black"
        label.fontSize = 30
        label.zPosition = 100
        label.position.y = self.position.y - 10
        label.fontColor = .orange
        self.addChild(label)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    func setup() {
        isUserInteractionEnabled = false
    }
}
