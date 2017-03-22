//
//  GameScene.swift
//  DropCharge
//
//  Created by harry bloch on 10/4/16.
//  Copyright (c) 2016 harry bloch. All rights reserved.
//

import SpriteKit
import CoreMotion
import GameplayKit

struct PhysicsCategory {
    static let None: UInt32 = 0
    static let Player: UInt32 = 0b1 //1
    static let PlatformNormal: UInt32 = 0b10 //2
    static let PlatformBreakable: UInt32 = 0b100 //4
    static let CoinNormal: UInt32 = 0b1000 //8
    static let CoinSpecial: UInt32 = 0b10000 //16
    static let Edges: UInt32 = 0b100000 //32
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //MARK: - Properties
    var redAlertTime: NSTimeInterval = 0
    let gameGain: CGFloat = 2.5
    var playerTrail: SKEmitterNode!
    var timeSinceLastExplosion: NSTimeInterval = 0
    var timeForNextExpolsion: NSTimeInterval = 1.0
    
    var animJump: SKAction! = nil
    var animFall: SKAction! = nil
    var animSteerLeft: SKAction! = nil
    var animSteerRight: SKAction! = nil
    var curAnim: SKAction! = nil
    
    lazy var gameState: GKStateMachine = GKStateMachine(states: [WaitingForTap(scene: self) , WaitingForBomb(scene: self) , Playing(scene: self) , GameOver(scene: self)])
    lazy var playerState: GKStateMachine = GKStateMachine(states: [IdlePlayer(scene: self) , JumpPlayer(scene: self) , FallPlayer(scene: self) , LavaPlayer(scene: self) , DeadPlayer(scene: self) ])
    
    let livesLabel =  SKLabelNode(fontNamed:"Glimstick")
    let scoreLabel =  SKLabelNode(fontNamed:"Glimstick")
    var lives = 3
    var score = 0
    
    
    var lava: SKSpriteNode!
    let motionManager = CMMotionManager()
    var xAcceleration = CGFloat(0)
    var bgNode = SKNode()
    var fgNode = SKNode()
    var background: SKNode!
    var backHeight: CGFloat = 0.0
    var player: SKSpriteNode!
    
    var backgroundMusic: SKAudioNode!
    var bgMusicAlarm: SKAudioNode!
    let soundBombDrop = SKAction.playSoundFileNamed("bombDrop.wav",
        waitForCompletion: false)
    let soundSuperBoost = SKAction.playSoundFileNamed("nitro.wav",
        waitForCompletion: false)
    let soundTickTock = SKAction.playSoundFileNamed("tickTock.wav",
        waitForCompletion: false)
    let soundBoost = SKAction.playSoundFileNamed("boost.wav",
        waitForCompletion: false)
    let soundJump = SKAction.playSoundFileNamed("jump.wav",
        waitForCompletion: false)
    let soundCoin = SKAction.playSoundFileNamed("coin1.wav",
        waitForCompletion: false)
    let soundBrick = SKAction.playSoundFileNamed("brick.caf",
        waitForCompletion: false)
    let soundHitLava = SKAction.playSoundFileNamed("DrownFireBug.mp3",
        waitForCompletion: false)
    let soundGameOver = SKAction.playSoundFileNamed("player_die.wav",
        waitForCompletion: false)
    let soundExplosions = [
        SKAction.playSoundFileNamed("explosion1.wav",
            waitForCompletion: false),
        SKAction.playSoundFileNamed("explosion2.wav",
            waitForCompletion: false),
        SKAction.playSoundFileNamed("explosion3.wav",
            waitForCompletion: false),
        SKAction.playSoundFileNamed("explosion4.wav",
            waitForCompletion: false)
    ]
    
    var platform5Across: SKSpriteNode!
    var coinArrow: SKSpriteNode!
    var coinAcross: SKSpriteNode!
    var break5Across: SKSpriteNode!
    var coinSArrow: SKSpriteNode!
    var platformArrow: SKSpriteNode!
    var break5Arrow: SKSpriteNode!
    var platformDiagonal: SKSpriteNode!
    var breakDiagonal: SKSpriteNode!
    var coinCross: SKSpriteNode!
    var coinDiagonal: SKSpriteNode!
    var coinS5Across: SKSpriteNode!
    var coinSDiagonal: SKSpriteNode!
    var coinSCross: SKSpriteNode!
    var platform2_2: SKSpriteNode!
    var platform1_2: SKSpriteNode!
    var platform2_1: SKSpriteNode!
    var platform2Left: SKSpriteNode!
    var platform2Right: SKSpriteNode!
    var platformLeftDiagonalGap: SKSpriteNode!
    var platformZig: SKSpriteNode!
    var coin2_2: SKSpriteNode!
    var coin1_2: SKSpriteNode!
    var coin2_1: SKSpriteNode!
    var coin1_1: SKSpriteNode!
    var coin1_1Mid: SKSpriteNode!
    var coinMid: SKSpriteNode!
    var sCoinBigGap: SKSpriteNode!
    
    
    var lastItemPosition = CGPointZero
    var lastItemHeight: CGFloat = 0.0
    var levelY: CGFloat = 0.0
    var isPlaying: Bool = false
    let cameraNode = SKCameraNode()
    var lastUpdateTimeInterval: NSTimeInterval = 0
    var deltaTime: NSTimeInterval = 0
    
    
    
    var coinRef: SKSpriteNode!
    var coinSpecialRef: SKSpriteNode!
    
    override func didMoveToView(view: SKView) {
        setupNodes()
        setupLevel()
        playerState.enterState(IdlePlayer)
        setupCoreMotion()
        physicsWorld.contactDelegate = self
        setCameraPosition(CGPoint(x: size.width/2, y: size.height/2))
        gameState.enterState(WaitingForTap)
        playBackgroundMusic("SpaceGame.caf")
        animJump = setupAnimWithPrefix("player01_jump_",
            start: 1, end: 4, timePerFrame: 0.1)
        animFall = setupAnimWithPrefix("player01_fall_",
            start: 1, end: 3, timePerFrame: 0.1)
        animSteerLeft = setupAnimWithPrefix("player01_steerleft_",start: 1, end: 2, timePerFrame: 0.1)
        animSteerRight = setupAnimWithPrefix("player01_steerright_",
            start: 1, end: 2, timePerFrame: 0.1)
        setUpLabels()
    }
    
    func setUpLabels() {
        livesLabel.text = "Lives: 3"
        livesLabel.fontColor = SKColor.orangeColor()
        livesLabel.fontSize = 70
        livesLabel.zPosition = 100
        livesLabel.horizontalAlignmentMode = .Left
        livesLabel.verticalAlignmentMode = .Bottom
        livesLabel.position = CGPoint(x: 0 - overlapAmount() + 10,
            y:self.view!.frame.size.height + overlapAmount()/2)
        cameraNode.addChild(livesLabel)
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontColor = SKColor.orangeColor()
        scoreLabel.fontSize = 70
        scoreLabel.zPosition = 100
        scoreLabel.horizontalAlignmentMode = .Right
        scoreLabel.verticalAlignmentMode = .Bottom
        scoreLabel.position = CGPoint(x: self.view!.frame.size.width + overlapAmount() - 100, y: self.view!.frame.size.height + overlapAmount()/2)
        cameraNode.addChild(scoreLabel)
    }
    
    func setupNodes() {
        coinRef = loadOverlayNode("Coin")
        coinSpecialRef = loadOverlayNode("CoinSpecial")
        let worldNode = childNodeWithName("World")!
        bgNode = worldNode.childNodeWithName("Background")!
        background = bgNode.childNodeWithName("Overlay")!.copy() as! SKNode
        backHeight = background.calculateAccumulatedFrame().height
        fgNode = worldNode.childNodeWithName("Foreground")!
        player = fgNode.childNodeWithName("Player") as! SKSpriteNode
        fgNode.childNodeWithName("Bomb")?.runAction(SKAction.hide())
        platform5Across = loadOverlayNode("Platform5Across")
        coinArrow = loadCoinOverlayNode("CoinArrow")
        addChild(cameraNode)
        camera = cameraNode
        setupLava()
        break5Across = loadOverlayNode("Break5Across")
        coinSArrow = loadCoinOverlayNode("CoinSArrow")
        platformArrow = loadOverlayNode("PlatformArrow")
        break5Arrow = loadOverlayNode("Break5Arrow")
        breakDiagonal = loadOverlayNode("BreakDiagonal")
        coinCross = loadCoinOverlayNode("coinCross")
        coinAcross = loadCoinOverlayNode("CoinAcross")
        coinS5Across = loadCoinOverlayNode("CoinS5Across")
        coinSDiagonal = loadCoinOverlayNode("CoinSDiagonal")
        coinSCross = loadCoinOverlayNode("CoinSCross")
        platformDiagonal = loadOverlayNode("PlatformDiagonal")
        coinDiagonal = loadCoinOverlayNode("CoinDiagonal")
        platform2_2 = loadOverlayNode("Platform2-2")
        platform1_2 = loadOverlayNode("Platform1-2")
        platform2_1 = loadOverlayNode("Platform2-1")
        platform2Left = loadOverlayNode("Platform2Left")
        platform2Right = loadOverlayNode("Platform2Right")
        platformLeftDiagonalGap = loadOverlayNode("PlatformLeftDiagonalGap")
        platformZig = loadOverlayNode("PlatformZig")
        coin2_2 = loadCoinOverlayNode("Coin2-2")
        coin1_2 = loadCoinOverlayNode("Coin1-2")
        coin2_1 = loadCoinOverlayNode("Coin2-1")
        coin1_1 = loadCoinOverlayNode("Coin1-1")
        coin1_1Mid = loadCoinOverlayNode("Coin1-1Mid")
        coinMid = loadCoinOverlayNode("CoinMid")
        sCoinBigGap = loadCoinOverlayNode("SCoinBigGap")
    }
    
    func setupLevel() {
        //Place initial platform
        let initialPlatform = platform5Across.copy() as! SKSpriteNode
        var itemPosition = player.position
        itemPosition.y = player.position.y -
            ((player.size.height * 0.5) +
                (initialPlatform.size.height * 0.20))
        initialPlatform.position = itemPosition
        fgNode.addChild(initialPlatform)
        lastItemPosition = itemPosition
        lastItemHeight = initialPlatform.size.height / 2.0
        
        //Create random level
        levelY = bgNode.childNodeWithName("Overlay")!.position.y + backHeight
        while lastItemPosition.y < levelY {
            addRandomOverlayNode()
        }
    }
    
    func setupCoreMotion() {
        motionManager.accelerometerUpdateInterval = 0.2
        let queue = NSOperationQueue()
        motionManager.startAccelerometerUpdatesToQueue(queue, withHandler: {
            accelerometerData, error in
            guard let accelerometerData = accelerometerData else{
                return
            }
            let acceleration = accelerometerData.acceleration
            self.xAcceleration = (CGFloat(acceleration.x) * 0.75) + (self.xAcceleration * 0.25)
        })
    }
    
    // MARK: Platform/Coin overlay nodes.
    func loadOverlayNode(fileName: String) -> SKSpriteNode {
        let overlayScene = SKScene(fileNamed: fileName)!
        let contentTemplateNode = overlayScene.childNodeWithName("Overlay")
        return contentTemplateNode as! SKSpriteNode
    }
    
    func loadCoinOverlayNode(fileName: String) -> SKSpriteNode {
        // 1
        let overlayScene = SKScene(fileNamed: fileName)!
        let contentTemplateNode =
        overlayScene.childNodeWithName("Overlay")
        // 2
        contentTemplateNode!.enumerateChildNodesWithName("*",
            usingBlock: {
                (node, stop) in
                let coinPos = node.position
                let ref: SKSpriteNode
                // 3
                if node.name == "special" {
                    ref = self.coinSpecialRef.copy() as! SKSpriteNode
                } else {
                    ref = self.coinRef.copy() as! SKSpriteNode
                }
                // 4
                ref.position = coinPos
                contentTemplateNode?.addChild(ref)
                node.removeFromParent()
        })
        // 5
        return contentTemplateNode as! SKSpriteNode
    }
    
    
    func createOverlayNode(nodeType: SKSpriteNode, flipX: Bool){
        let platform = nodeType.copy() as! SKSpriteNode
        lastItemPosition.y = lastItemPosition.y + (lastItemHeight +  (platform.size.height / 2.0))
        lastItemHeight = platform.size.height / 2.0
        platform.position = lastItemPosition
        
        if  flipX == true {
            platform.xScale = -1.0
        }
        fgNode.addChild(platform)
    }
    
    func createBackgroundNode() {
        let backNode = background.copy() as! SKNode
        backNode.position = CGPoint(x: 0.0, y: levelY)
        bgNode.addChild(backNode)
        levelY += backHeight
    }
    
    func addRandomOverlayNode() {
        let overlaySprite: SKSpriteNode!
        var flipH = false
        let platformPercentage = 60
        
        if Int.random(min: 1, max: 100) <= platformPercentage {
            if Int.random(min: 1, max: 100) <= 75 {
                // Create standard platforms 75%
                switch Int.random(min: 0, max: 4) {
                case 0:
                    overlaySprite = platformArrow
                case 1:
                    overlaySprite = platform5Across
                case 2:
                    overlaySprite = platformDiagonal
                case 3:
                    overlaySprite = platformDiagonal
                    flipH = true
                case 4:
                    switch Int.random(min: 0, max: 6) {
                    case 0:
                        overlaySprite = platform2_2
                    case 1:
                        overlaySprite = platform1_2
                    case 2:
                        overlaySprite = platform2_1
                    case 3:
                        overlaySprite = platform2Left
                    case 4:
                        overlaySprite = platform2Right
                    case 5:
                        overlaySprite = platformLeftDiagonalGap
                    case 6:
                        overlaySprite = platformZig
                    default:
                        overlaySprite = platformZig
                        break
                    }
                    
                default:
                    overlaySprite = platformArrow
                }
            } else {
                // Create breakable platforms 25%
                switch Int.random(min: 0, max: 3) {
                case 0:
                    overlaySprite = break5Arrow
                case 1:
                    overlaySprite = break5Across
                case 2:
                    overlaySprite = breakDiagonal
                case 3:
                    overlaySprite = breakDiagonal
                    flipH = true
                default:
                    overlaySprite = break5Arrow
                }
            }
        } else {
            if Int.random(min: 1, max: 100) <= 75 {
                // Create standard coins 75%
                switch Int.random(min: 0, max: 10) {
                case 0:
                    overlaySprite = coinArrow
                case 1:
                    overlaySprite = coinAcross
                case 2:
                    overlaySprite = coinDiagonal
                case 3:
                    overlaySprite = coinDiagonal
                    flipH = true
                case 4:
                    overlaySprite = coinCross
                case 5:
                    overlaySprite = coin2_2
                case 6:
                    overlaySprite = coin2_1
                case 7:
                    overlaySprite = coin1_2
                case 8:
                    overlaySprite = coin1_1
                case 9:
                    overlaySprite = coin1_1Mid
                case 10:
                    overlaySprite = coinMid
                default:
                    overlaySprite = coinArrow
                }
            } else {
                // Create special coins 25%
                switch Int.random(min: 0, max: 5) {
                case 0:
                    overlaySprite = coinSArrow
                case 1:
                    overlaySprite = coinS5Across
                case 2:
                    overlaySprite = coinSDiagonal
                case 3:
                    overlaySprite = coinSDiagonal
                    flipH = true
                case 4:
                    overlaySprite = coinSCross
                case 5:
                    overlaySprite = sCoinBigGap
                default:
                    overlaySprite = coinSArrow
                }
            }
        }
        
        createOverlayNode(overlaySprite, flipX: flipH)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        switch gameState.currentState {
        case is WaitingForTap:
            gameState.enterState(WaitingForBomb)
            //switch to playing state
            self.runAction(SKAction.waitForDuration(2.0), completion:{ self.gameState.enterState(Playing) })
            
        case is GameOver:
            let newScene = GameScene(fileNamed: "GameScene")
            newScene!.scaleMode = .AspectFill
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            self.view?.presentScene(newScene!, transition: reveal)
            
        default:
            break
        }
    }
    
    func setPlayerVelocity(amount:CGFloat) {
        player.physicsBody!.velocity.dy = max(player.physicsBody!.velocity.dy, amount * gameGain)
    }
    
    func jumpPlayer() {
        setPlayerVelocity(500)
    }
    
    func boostPlayer() {
        setPlayerVelocity(1000)
        screenShakeByAmt(40)
    }
    
    func superBoostPlayer() {
        setPlayerVelocity(1700)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let other = contact.bodyA.categoryBitMask ==
            PhysicsCategory.Player ? contact.bodyB : contact.bodyA
        switch other.categoryBitMask {
        case PhysicsCategory.CoinNormal:
            if let coin = other.node as? SKSpriteNode {
                emitParticles("CoinEffectNormal", sprite: coin)
                jumpPlayer()
                runAction(soundCoin)
                score += 10
            }
        case PhysicsCategory.PlatformNormal:
            if let platform = other.node as? SKSpriteNode {
                if player.physicsBody!.velocity.dy < 0 {
                    platformAction(platform, breakable: false)
                    jumpPlayer()
                    runAction(soundJump)
                }
            }
        case PhysicsCategory.CoinSpecial:
            if let sCoin = other.node as? SKSpriteNode {
                emitParticles("SpecialCoinEffectNormal", sprite: sCoin)
                boostPlayer()
                runAction(soundBoost)
                score+=50
            }
        case PhysicsCategory.PlatformBreakable:
            if let breakPlat = other.node as? SKSpriteNode {
                if player.physicsBody!.velocity.dy < 0 {
                    jumpPlayer()
                    platformAction(breakPlat, breakable: true)
                    runAction(soundBrick)
                }
            }
        default:
            break;
        }
    }
    
    func updatePlayer(){
        //set velocity based on core motion
        player.physicsBody?.velocity.dx = xAcceleration * 1000.0
        if player.physicsBody?.velocity.dy > 0 {
            playerState.enterState(JumpPlayer)
        }else{
            playerState.enterState(FallPlayer)
        }
        
        //wrap player around edges of screen
        var playerPosition = convertPoint(player.position, fromNode: fgNode)
        if playerPosition.x < -player.size.width/2{
            playerPosition = convertPoint(CGPoint (x: size.width + player.size.width/2, y: 0.0), toNode: fgNode)
            player.position.x = playerPosition.x
        }else if playerPosition.x > size.width + player.size.width/2{
            playerPosition = convertPoint(CGPoint(x: -player.size.width/2, y: 0.0), toNode: fgNode)
            player.position.x = playerPosition.x
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        updateLevel()
        livesLabel.text = "Lives: \(lives)"
        scoreLabel.text = "Score: \(score)"
        playerState.updateWithDeltaTime(deltaTime)
        if lastUpdateTimeInterval > 0 {
            deltaTime = currentTime - lastUpdateTimeInterval
        } else {
            deltaTime = 0
        }
        lastUpdateTimeInterval = currentTime
        if paused { return }
        gameState.updateWithDeltaTime(deltaTime)
    }
    
    //MARK: -Camera
    func overlapAmount() -> CGFloat {
        guard let view = self.view else {
            return 0
        }
        let scale = view.bounds.size.height / self.size.height
        let scaledWidth = self.size.width * scale
        let scaledOverlap = scaledWidth - view.bounds.size.width
        return scaledOverlap / scale
    }
    
    func getCameraPosition() -> CGPoint {
        return CGPoint(
            x: cameraNode.position.x + overlapAmount()/2,
            y: cameraNode.position.y)
    }
    
    func setCameraPosition(position: CGPoint) {
        cameraNode.position = CGPoint(x: position.x - overlapAmount()/2, y: position.y)
    }
    
    func updateCamera() {
        //1
        let cameraTarget = convertPoint(player.position, fromNode: fgNode)
        var targetPosition = CGPoint(x: getCameraPosition().x, y: cameraTarget.y - (scene!.view!.bounds.height * 0.40))
        let lavaPos = convertPoint(lava.position, fromNode: fgNode)
        targetPosition.y = max(targetPosition.y, lavaPos.y)
        let lerpValue = CGFloat(0.2)
        let diff = targetPosition - getCameraPosition()
        let lerpDiff = diff * lerpValue
        let newPosition = getCameraPosition() + lerpDiff
        
        setCameraPosition(CGPoint(x: size.width/2, y: newPosition.y))
    }
    
    func updateLave(dt: NSTimeInterval) {
        let lowerLeft = CGPoint(x: 0, y: cameraNode.position.y - (size.height / 2))
        let visableMinYFg = scene!.convertPoint(lowerLeft, toNode: fgNode).y
        let lavaVelocity = CGPoint(x: 0, y: 120)
        let lavaStep = lavaVelocity * CGFloat(dt)
        var newPosition = lava.position + lavaStep
        newPosition.y = max(newPosition.y, (visableMinYFg - 125.0))
        lava.position = newPosition
    }
    
    func updateCollisionLava() {
        if player.position.y < lava.position.y + 180 {
            playerState.enterState(LavaPlayer)
            if lives <= 0 {
                playerState.enterState(DeadPlayer)
                gameState.enterState(GameOver)
            }
        }
    }
    
    func updateExplosions(dt: NSTimeInterval) {
        timeSinceLastExplosion += dt
        if  (timeSinceLastExplosion > timeForNextExpolsion) {
            timeForNextExpolsion = NSTimeInterval(CGFloat.random(min: 0.1, max: 0.5))
            timeSinceLastExplosion = 0
            createRandomExplosion()
        }
    }
    
    func updateLevel() {
        let cameraPos = getCameraPosition()
        //update labelPosition
        if cameraPos.y > levelY - (size.height * 0.55) {
            createBackgroundNode()
            while lastItemPosition.y < levelY {
                addRandomOverlayNode()
            }
        }
        for fg in fgNode.children {
            for node in fg.children {
                if let sprite = node as? SKSpriteNode {
                    let nodePos = fg.convertPoint(sprite.position, toNode: self)
                    if isNodeVisable(sprite, positionY: nodePos.y) == false {
                        sprite.removeFromParent()
                    }
                }
            }
        }
    }
    
    func createRandomExplosion() {
        let cameraPos = getCameraPosition()
        let screenSize = self.view!.bounds.size
        
        let screenPos = CGPoint(x: CGFloat.random(min: 0.0,
            max: cameraPos.x * 2.0), y: CGFloat.random(min:
                cameraPos.y - screenSize.height * 0.75,
                max: cameraPos.y + screenSize.height))
        
        let randomNum = Int.random(soundExplosions.count)
        runAction(soundExplosions[randomNum])
        
        let explode = explosion(0.25 * CGFloat(randomNum + 1))
        explode.position = convertPoint(screenPos, toNode: bgNode)
        explode.runAction(SKAction.removeFromParentAfterDelay(2.0))
        if randomNum == 3 {
            screenShakeByAmt(10)
        }
        bgNode.addChild(explode)
    }
    
    func explosion(intensity: CGFloat) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        let particleTexture = SKTexture(imageNamed: "spark")
        
        emitter.zPosition = 2
        emitter.particleTexture = particleTexture
        emitter.particleBirthRate = 4000 * intensity
        emitter.numParticlesToEmit = Int(400 * intensity)
        emitter.particleLifetime = 2.0
        emitter.emissionAngle = CGFloat(90.0).degreesToRadians()
        emitter.emissionAngleRange = CGFloat(360.0).degreesToRadians()
        emitter.particleSpeed = 600 * intensity
        emitter.particleSpeedRange = 1000 * intensity
        emitter.particleAlpha = 1.0
        emitter.particleAlphaRange = 0.25
        emitter.particleScale = 1.2
        emitter.particleScaleRange = 2.0
        emitter.particleScaleSpeed = -1.5
        emitter.particleColor = SKColor.orangeColor()
        emitter.particleColorBlendFactor = 1
        emitter.particleBlendMode = SKBlendMode.Add
        emitter.runAction(SKAction.removeFromParentAfterDelay(2.0))
        
        let sequence = SKKeyframeSequence(capacity: 5)
        sequence.addKeyframeValue(SKColor.whiteColor(), time: 0)
        sequence.addKeyframeValue(SKColor.yellowColor(), time: 0.10)
        sequence.addKeyframeValue(SKColor.orangeColor(), time: 0.15)
        sequence.addKeyframeValue(SKColor.redColor(), time: 0.75)
        sequence.addKeyframeValue(SKColor.blackColor(), time: 0.95)
        emitter.particleColorSequence = sequence
        
        return emitter
    }
    
    func setupLava() {
        lava = fgNode.childNodeWithName("Lava") as! SKSpriteNode
        let emitter = SKEmitterNode(fileNamed: "Lava.sks")!
        emitter.particlePositionRange = CGVector(dx: size.width * 1.125, dy: 0.0)
        emitter.advanceSimulationTime(3.0)
        emitter.zPosition = 4
        lava.addChild(emitter)
    }
    
    func addTrail(name: String) -> SKEmitterNode {
        let trail = SKEmitterNode(fileNamed: name)!
        trail.targetNode = fgNode
        player.addChild(trail)
        return trail
    }
    
    func removeTrail(trail: SKEmitterNode) {
        trail.numParticlesToEmit = 1
        trail.runAction(SKAction.removeFromParentAfterDelay(1.0))
    }
    
    func playBackgroundMusic(name: String) {
        var delay = 0.0
        if backgroundMusic != nil {
            backgroundMusic.removeFromParent()
            if bgMusicAlarm != nil {
                bgMusicAlarm.removeFromParent()
            } else {
                bgMusicAlarm = SKAudioNode(fileNamed: "alarm.wav") as SKAudioNode
                bgMusicAlarm.autoplayLooped = true
                addChild(bgMusicAlarm)
            }
        } else {
            delay = 0.2
        }
        runAction(SKAction.waitForDuration(delay))
        self.backgroundMusic = SKAudioNode(fileNamed: name) as SKAudioNode
        self.backgroundMusic.autoplayLooped = true
        self.addChild(self.backgroundMusic)
    }
    
    func setupAnimWithPrefix(prefix: String, start: Int, end: Int, timePerFrame: NSTimeInterval) -> SKAction {
        var textures = [SKTexture]()
        for i in start...end {
            textures.append(SKTexture(imageNamed: "\(prefix)\(i)"))
        }
        return SKAction.animateWithTextures(textures, timePerFrame: timePerFrame)
    }
    
    func runAnim(anim: SKAction) {
        if curAnim == nil || curAnim! != anim {
            player.removeActionForKey("anim")
            player.runAction(anim, withKey: "anim")
            curAnim = anim
        }
    }
    
    func emitParticles(name: String, sprite: SKSpriteNode) {
        let pos = fgNode.convertPoint(sprite.position, fromNode: sprite.parent!)
        let particles = SKEmitterNode(fileNamed: name)!
        particles.position = pos
        particles.zPosition = 3
        fgNode.addChild(particles)
        particles.runAction(SKAction.removeFromParentAfterDelay(1.0))
        sprite.runAction(SKAction.sequence([SKAction.scaleTo(0.0, duration: 0.5)]))
    }
    
    func screenShakeByAmt(amt: CGFloat) {
        let worldNode = childNodeWithName("World")
        worldNode?.position = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
        let amount = CGPoint(x: 0, y: -(amt * gameGain))
        let action = SKAction.screenShakeWithNode(worldNode!, amount: amount, oscillations: 10, duration: 2.0)
        
        worldNode?.runAction(action, withKey: "shake")
    }
    
    func isNodeVisable(node: SKSpriteNode, positionY: CGFloat) -> Bool {
        if !cameraNode.containsNode(node) {
            if positionY < getCameraPosition().y * 0.25{
                return false
            }
            
        }
        return true
    }
    
    func updateRedAlert(lastUpdate: NSTimeInterval) {
        redAlertTime += lastUpdate
        let amt: CGFloat = CGFloat(redAlertTime) * π * 2.0 / 1.93725
        let colorBlendFactor = (sin(amt) + 1.0) / 2.0
        for bg in bgNode.children {
            for node in bg.children {
                if let sprite = node as? SKSpriteNode {
                    let nodePos = bg.convertPoint(sprite.position, toNode: self)
                    if isNodeVisable(sprite, positionY: nodePos.y) == false {
                        sprite.removeFromParent()
                    } else {
                        sprite.color = SKColorWithRGB(255, g: 0, b: 0)
                        sprite.colorBlendFactor = colorBlendFactor
                    }
                }
            }
        }
    }
    
    func platformAction(sprite: SKSpriteNode, breakable: Bool) {
        let amount = CGPoint(x: 0, y: -75.0)
        let action = SKAction.screenShakeWithNode(sprite, amount: amount, oscillations: 10, duration: 2.0)
        sprite.runAction(action)
        
        if breakable == true {
            emitParticles("BrokenPlatform", sprite:  sprite)
        }
    }
    
}















