//
//  LavaPlayer.swift
//  DropCharge
//
//  Created by harry bloch on 10/5/16.
//  Copyright © 2016 harry bloch. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class LavaPlayer: GKState {

    unowned let scene: GameScene
    
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        super.init()
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        self.scene.boostPlayer()
        scene.screenShakeByAmt(50)
        self.scene.lives -= 1
        scene.runAction(scene.soundHitLava)
        scene.playerTrail.particleBirthRate = 0
        
        let smokeTrail = scene.addTrail("SmokeTrail")
        scene.runAction(SKAction.sequence([SKAction.waitForDuration(3.0) , SKAction.runBlock(){
                self.scene.removeTrail(smokeTrail)
            }]))
    }
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return stateClass is DeadPlayer.Type || stateClass is JumpPlayer.Type
    }

}
