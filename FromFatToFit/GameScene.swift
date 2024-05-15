//
//  GameScene.swift
//  FromFatToFit
//
//  Created by Sigit Academy on 15/05/24.
//

import SpriteKit
import AVFoundation
import Vision

enum GameMode {
    case normal, continous
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var captureOutput: AVCaptureVideoDataOutput?
    
    var vc: ViewController!
    
    let foodCategory:    UInt32 = 1 << 1
    let actorCategory:   UInt32 = 1 << 2
    let sceneCategory:   UInt32 = 1 << 3
    let itemCategory:   UInt32 = 1 << 4
    
    var gameMode: GameMode?
        
    var score = 0
    var lives = 5
    var levelTimerLabel = SKLabelNode(fontNamed: "ArialMT")
    var scoreLabel = SKLabelNode(fontNamed: "ArialMT")
    
    //Immediately after leveTimerValue variable is set, update label's text
    var levelTimerValue: Int = 3 {
        didSet {
            levelTimerLabel.text = "\(levelTimerValue)"
        }
    }
    
    let bgmusic = SKAudioNode(fileNamed: "next-round")
    var gamestatus = "not started"
    var foodPositionX: Float = 0
    let actor = SKSpriteNode(imageNamed: "actor")
        
    override func sceneDidLoad() {
        physicsWorld.contactDelegate = self // Most important part!
    }
    
    override func didMove(to view: SKView) {
        
        commonInit()
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        self.physicsBody?.categoryBitMask = sceneCategory
        
        let background = SKSpriteNode(imageNamed: "background")
        background.alpha = 0.5
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = -1
        self.addChild(background)
        
        actor.physicsBody = SKPhysicsBody(texture: actor.texture!, size: actor.texture!.size())
        actor.physicsBody?.categoryBitMask = actorCategory
        actor.physicsBody?.collisionBitMask = 0
        actor.physicsBody?.collisionBitMask =  sceneCategory
        actor.physicsBody?.contactTestBitMask =  sceneCategory
        
        actor.physicsBody?.affectedByGravity = false
        actor.zPosition = 1
        actor.position = CGPoint(x: self.size.width/2, y: self.size.height/2 - 200)
        self.addChild(actor)
        
        levelTimerLabel.fontSize = 200
        levelTimerLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        levelTimerLabel.zPosition = 20
        levelTimerLabel.text = "\(levelTimerValue)"
        addChild(levelTimerLabel)
        
        scoreLabel.fontSize = 20
        scoreLabel.position = CGPoint(x: frame.maxX - 200, y: frame.maxY - 80)
        scoreLabel.zPosition = 20
        scoreLabel.text = "SCORE: \(score)"
        addChild(scoreLabel)
        
        let wait1 = SKAction.wait(forDuration: 1) //change countdown speed here
        run(wait1){
            let countdown = SKAction.playSoundFileNamed("countdown", waitForCompletion: false)
            self.run(countdown)
            
            let wait = SKAction.wait(forDuration: 1) //change countdown speed here
            let block = SKAction.run({
                [unowned self] in
                
                if self.levelTimerValue > 0{
                    self.levelTimerValue -= 1
                    
                    if self.levelTimerValue == 0 {
                        levelTimerLabel.text = "GO!!!"
                    }
                }else{
                    self.removeAction(forKey: "countdown")
                    levelTimerLabel.removeFromParent()
                    
                    gamestatus = "started"
                    
                    //play bgmusic
                    self.addChild(bgmusic)
                    
                    addFoodAndItems()
                }
            })
            let sequence = SKAction.sequence([wait,block])
            
            self.run(SKAction.repeatForever(sequence), withKey: "countdown")
        }
        
        var offset: CGFloat = 0
        
        if gameMode == .normal {
            
            for i in 1...lives {
                let heart = SKSpriteNode(imageNamed: "heart")
                heart.name = "heart\(i)"
                heart.zPosition = 10
                heart.position = CGPoint(x: frame.maxX - 400 + offset, y: frame.maxY - 72)
                offset += heart.size.width/2 + 15
                
                self.addChild(heart)
            }
        }
    }
    
    func pause(){
        switch gamestatus {
        case "paused":
            self.isPaused = false
            gamestatus = "started"
            addFoodAndItems()
            levelTimerLabel.removeFromParent()
        case "gameover":
            let scene = GameScene(size: CGSize(width: 1512, height: 982))
            scene.scaleMode = .aspectFill

            self.view?.presentScene(scene)
        default:
            gamestatus = "paused"
            
            self.removeAction(forKey: "food")
            self.isPaused = true

            
            levelTimerLabel.text = "Paused"
            self.addChild(levelTimerLabel)
        }
    }
    
    func end(){
        vc.presentMenu()
    }
    
    override func mouseDown(with event: NSEvent) {
        
        switch gamestatus {
        case "paused":
            self.isPaused = false
            gamestatus = "started"
            addFoodAndItems()
            levelTimerLabel.removeFromParent()
        case "gameover":
            let scene = GameScene(size: CGSize(width: 1512, height: 982))
            scene.scaleMode = .aspectFill

            self.view?.presentScene(scene)
        default:
            gamestatus = "paused"
            
            self.removeAction(forKey: "food")
            self.isPaused = true

            
            levelTimerLabel.text = "Paused"
            self.addChild(levelTimerLabel)
        }
    }
    
    let kVK_LeftArrow = 123
    let kVK_RightArrow = 124
    
    override func keyDown(with event: NSEvent) {
        
        switch Int(event.keyCode){
        case 53:
            vc.presentMenu()
        default:
            break
        }
        
        if gamestatus == "started" {
            switch Int(event.keyCode) {
            case kVK_LeftArrow:
                actor.removeAllActions()
                let xs = actor.position.x
                
                actor.run(SKAction.moveTo(x: xs - 300, duration: 0.5))
            case kVK_RightArrow:
                actor.removeAllActions()
                let xs = actor.position.x
                
                actor.run(SKAction.moveTo(x: xs + 300, duration: 0.5))
            default:
                break
            }
        }
    }
    
    func addFoodAndItems(){
        let wait2 = SKAction.wait(forDuration: 1) //change countdown speed here
        let block2 = SKAction.run({
            [unowned self] in
            
            var random = Float.random(in: -700..<700)
            foodPositionX = random
            
            let foods = ["pie", "burger", "sundae", "ice-cream", "fries"]
            var randomFoodIndex = Int.random(in: 0..<foods.count)
            
            let food = SKSpriteNode(imageNamed: foods[randomFoodIndex])
            food.name = "fooditem"
            food.zPosition = 10
            food.position =  CGPoint(x: self.size.width/2 + CGFloat(random), y: self.size.height/2 + 400)
            food.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: food.size.width, height: food.size.height))
            //            food.physicsBody = SKPhysicsBody(texture: food.texture!, size: food.texture!.size())
            food.physicsBody?.affectedByGravity = true
            food.physicsBody?.categoryBitMask = foodCategory
            food.physicsBody?.collisionBitMask = 0
            food.physicsBody?.collisionBitMask = actorCategory | itemCategory
            food.physicsBody?.contactTestBitMask = actorCategory | sceneCategory | itemCategory
            
            self.addChild(food)
            
            random = Float.random(in: -500..<500)
            
            let items = ["bike", "running", "dumbell"]
            randomFoodIndex = Int.random(in: 0..<items.count)
            
            let item = SKSpriteNode(imageNamed: items[randomFoodIndex])
            item.zPosition = 10
            item.name = "fooditem"
            item.position =  CGPoint(x: self.size.width/2 + CGFloat(random), y: self.size.height/2 + 400)
            item.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: item.size.width, height: item.size.height))
            
            item.physicsBody?.affectedByGravity = true
            item.physicsBody?.categoryBitMask = itemCategory
            item.physicsBody?.collisionBitMask = 0
            item.physicsBody?.collisionBitMask = actorCategory | foodCategory
            item.physicsBody?.contactTestBitMask = actorCategory | sceneCategory | foodCategory
            
            
            self.addChild(item)
        })
        let sequence = SKAction.sequence([wait2,block2])
        
        self.run(SKAction.repeatForever(sequence), withKey: "food")
    }
    
    internal func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == foodCategory &&
            (contact.bodyB.categoryBitMask == actorCategory || contact.bodyB.categoryBitMask == sceneCategory) {
            if contact.bodyB.categoryBitMask == actorCategory{
                lives -= 1
                
                if gameMode == .normal {
                    enumerateChildNodes(withName: "*heart*") { (node: SKNode, nil) in
                        if node.name == "heart\(self.lives+1)" {
                            node.removeFromParent()
                        }
                    }
                } else {
                    score -= 10
                    
                    let plus = SKLabelNode(text: "-10")
                    plus.fontColor = .red
                    plus.fontSize = 30
                    plus.position.x = contact.bodyA.node?.position.x ?? 0
                    plus.position.y = contact.bodyA.node?.position.y ?? 0
                    
                    let grow = SKAction.scale(to:2, duration: 0.5)

                    plus.run(grow)
                    
                    self.addChild(plus)
                    
                    let wait1 = SKAction.wait(forDuration: 0.5) //change countdown speed here
                    run(wait1){
                        plus.removeFromParent()
                    }
                }
            }
            removeAfter(body: contact.bodyA)
        }
        
        if contact.bodyB.categoryBitMask == foodCategory &&
            (contact.bodyA.categoryBitMask == actorCategory || contact.bodyA.categoryBitMask == sceneCategory) {
            if contact.bodyA.categoryBitMask == actorCategory{
                lives -= 1
                if gameMode == .normal {
                    enumerateChildNodes(withName: "*heart*") { (node: SKNode, nil) in
                        if node.name == "heart\(self.lives+1)" {
                            node.removeFromParent()
                        }
                    }
                } else {
                    score -= 10
                    
                    let plus = SKLabelNode(text: "-10")
                    plus.fontColor = .red
                    plus.fontSize = 30
                    plus.position.x = contact.bodyB.node?.position.x ?? 0
                    plus.position.y = contact.bodyB.node?.position.y ?? 0
                    
                    let grow = SKAction.scale(to:2, duration: 0.5)

                    plus.run(grow)
                    
                    self.addChild(plus)
                    
                    let wait1 = SKAction.wait(forDuration: 0.5) //change countdown speed here
                    run(wait1){
                        plus.removeFromParent()
                    }
                }
            }
            removeAfter(body: contact.bodyB)
        }
        
        if contact.bodyA.categoryBitMask == itemCategory &&
            (contact.bodyB.categoryBitMask == actorCategory || contact.bodyB.categoryBitMask == sceneCategory) {
            if contact.bodyB.categoryBitMask == actorCategory{
                score += 10
                
                let plus = SKLabelNode(text: "+10")
                plus.fontColor = .green
                plus.fontSize = 30
                plus.position.x = contact.bodyA.node?.position.x ?? 0
                plus.position.y = contact.bodyA.node?.position.y ?? 0
                
                let grow = SKAction.scale(to:2, duration: 0.5)

                plus.run(grow)
                
                self.addChild(plus)
                
                let wait1 = SKAction.wait(forDuration: 0.5) //change countdown speed here
                run(wait1){
                    plus.removeFromParent()
                }
            }
            removeAfter(body: contact.bodyA)
        }
        
        if contact.bodyB.categoryBitMask == itemCategory &&
            (contact.bodyA.categoryBitMask == actorCategory || contact.bodyA.categoryBitMask == sceneCategory) {
            if contact.bodyA.categoryBitMask == actorCategory{
                score += 10
                
                let plus = SKLabelNode(text: "+10")
                plus.fontColor = .green
                plus.fontSize = 30
                plus.position.x = contact.bodyB.node?.position.x ?? 0
                plus.position.y = contact.bodyB.node?.position.y ?? 0
                
                let grow = SKAction.scale(to:2, duration: 0.5)

                plus.run(grow)
                
                self.addChild(plus)
                                
                
                let wait1 = SKAction.wait(forDuration: 0.5) //change countdown speed here
                run(wait1){
                    plus.removeFromParent()
                }
            }
            removeAfter(body: contact.bodyB)
        }
        
        if (contact.bodyA.categoryBitMask == actorCategory && contact.bodyB.categoryBitMask == sceneCategory) ||
            (contact.bodyA.categoryBitMask == sceneCategory && contact.bodyB.categoryBitMask == actorCategory) {
            actor.removeAllActions()
        }
        
        scoreLabel.text = "SCORE: \(score)"
        
        if gameMode == .normal && self.lives <= 0 && self.gamestatus == "started" {
                self.isPaused = true
                self.gamestatus = "gameover"
                self.levelTimerLabel.text = "GAME OVER!!!"
                self.addChild(self.levelTimerLabel)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
    }
    
    func removeAfter(body: SKPhysicsBody) {
        body.node?.removeFromParent()
    }
    
    private func commonInit() {
        self.removeAllChildren()
        self.removeAllActions()
        levelTimerValue = 3
        score = 0

        
        // Request camera access and set up the capture session
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setUpCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.setUpCaptureSession()
                    }
                }
            }
        case .denied, .restricted:
            return
        @unknown default:
            fatalError()
        }
    }
    
    private func setUpCaptureSession() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }
        captureSession.sessionPreset = .high
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("Error setting up video input: \(error)")
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            print("Couldn't add video input to the session")
            return
        }
        
        captureOutput = AVCaptureVideoDataOutput()
        guard let captureOutput = captureOutput else { return }
        
        if captureSession.canAddOutput(captureOutput) {
            captureSession.addOutput(captureOutput)
        } else {
            print("Couldn't add video output to the session")
            return
        }
        
        let videoQueue = DispatchQueue(label: "videoQueue")
        captureOutput.setSampleBufferDelegate(self, queue: videoQueue)
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        guard let videoPreviewLayer = videoPreviewLayer else { return }
        
        videoPreviewLayer.videoGravity = .resizeAspect
        videoPreviewLayer.frame = self.frame
        
        captureSession.startRunning()
    }
    
}

extension GameScene: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNDetectHumanRectanglesRequest { (request, error) in
            guard let results = request.results as? [VNHumanObservation] else { return }
            DispatchQueue.main.async {
                for result in results {
                    self.drawBoundingBox(for: result)
                }
            }
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .upMirrored, options: [:])
        do {
            try imageRequestHandler.perform([request])
        } catch {
            print("Failed to perform Vision request: \(error)")
        }
    }
    
    private func drawBoundingBox(for observation: VNHumanObservation) {
        let boundingBox = observation.boundingBox
        let size = CGSize(width: boundingBox.width * frame.width, height: boundingBox.height * frame.height)
        let origin = CGPoint(x: boundingBox.minX * frame.width, y: (1 - boundingBox.maxY) * frame.height)
        let rect = CGRect(origin: origin, size: size)
        
        let boundingBoxLayer = CAShapeLayer()
        boundingBoxLayer.frame = rect
        
        actor.position.x = boundingBoxLayer.position.x
    }
}
