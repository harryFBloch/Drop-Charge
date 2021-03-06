//
//  WaitingForBomb.swift
//  DropCharge
//
//  Created by harry bloch on 10/5/16.
//  Copyright © 2016 harry bloch. All rights reserved.
//

import UIKit
import GameplayKit
import SpriteKit

class WaitingForBomb: GKState {
    
    unowned let scene: GameScene
    
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        super.init()
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        if previousState is WaitingForTap {
        //scale out title and ready label
            let scale = SKAction.scaleTo(0, duration: 0.4)
            scene.fgNode.childNodeWithName("Title")!.runAction(scale)
            scene.fgNode.childNodeWithName("Ready")!.runAction(SKAction.sequence([SKAction.waitForDuration(0.2), scale]))
            
            //bounce bomb
            let scaleUp = SKAction.scaleTo(1.25, duration: 0.25)
            let scaleDown = SKAction.scaleTo(1.0, duration: 0.25)
            let sequence = SKAction.sequence([scaleUp , scaleDown])
            let repeatSeq = SKAction.repeatActionForever(sequence)
            scene.fgNode.childNodeWithName("Bomb")!.runAction(SKAction.unhide())
            scene.fgNode.childNodeWithName("Bomb")!.runAction(repeatSeq)
            scene.runAction(scene.soundBombDrop)
            scene.runAction(SKAction.repeatAction(scene.soundTickTock, count: 2))
        }
    }
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return stateClass is Playing.Type
    }
    
    override func willExitWithNextState(nextState: GKState) {
        if nextState is Playing {
            let bomb = scene.fgNode.childNodeWithName("Bomb")!
            let explosion = scene.explosion(2.0)
            explosion.position = bomb.position
            scene.fgNode.addChild(explosion)
            bomb.removeFromParent()
            scene.runAction(scene.soundExplosions[3])
            scene.screenShakeByAmt(100)
        }
    }

}
