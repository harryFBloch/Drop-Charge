//
//  IdlePlayer.swift
//  DropCharge
//
//  Created by harry bloch on 10/5/16.
//  Copyright © 2016 harry bloch. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class IdlePlayer: GKState {

    unowned let scene: GameScene
    
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        super.init()
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        scene.player.physicsBody = SKPhysicsBody(circleOfRadius: scene.player.size.width * 0.3)
        scene.player.physicsBody!.dynamic = false
        scene.player.physicsBody!.allowsRotation = false
        scene.player.physicsBody!.categoryBitMask = PhysicsCategory.Player
        scene.player.physicsBody!.collisionBitMask = 0
        scene.playerTrail = scene.addTrail("PlayerTrailTest")
    }

}
