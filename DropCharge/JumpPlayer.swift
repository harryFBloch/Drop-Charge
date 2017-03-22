//
//  JumpPlayer.swift
//  DropCharge
//
//  Created by harry bloch on 10/5/16.
//  Copyright © 2016 harry bloch. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class JumpPlayer: GKState {

    unowned let scene: GameScene
    
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        super.init()
    }
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return stateClass is FallPlayer.Type
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        if previousState is LavaPlayer {
            return
        }
        if scene.playerTrail.particleBirthRate == 0 {
            scene.playerTrail.particleBirthRate = 200
        }
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        if abs(scene.player.physicsBody!.velocity.dx) > 100.0 {
            if (scene.player.physicsBody!.velocity.dx > 0) {
                scene.runAnim(scene.animSteerRight)
            } else {
                scene.runAnim(scene.animSteerLeft)
            }
        } else {
            scene.runAnim(scene.animJump)
        }
    }
    
    
}
