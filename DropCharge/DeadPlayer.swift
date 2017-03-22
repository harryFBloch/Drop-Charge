//
//  DeadPlayer.swift
//  DropCharge
//
//  Created by harry bloch on 10/5/16.
//  Copyright © 2016 harry bloch. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class DeadPlayer: GKState {

    unowned let scene: GameScene
    
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        super.init()
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        if previousState is LavaPlayer{
        scene.physicsWorld.contactDelegate = nil
        scene.player.physicsBody?.dynamic = false
        
        let moveUpAction = SKAction.moveByX(0, y: scene.size.height/2, duration: 0.5)
        moveUpAction.timingMode = .EaseOut
        let moveDownAction = SKAction.moveByX(0, y: -(scene.size.height * 1.5), duration: 1.0)
        moveDownAction.timingMode = .EaseIn
        
        let sequence = SKAction.sequence([moveUpAction , moveDownAction])
        scene.player.runAction(sequence)
        scene.runAction(scene.soundGameOver)
        }
    }
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return stateClass is IdlePlayer.Type
    }
}
