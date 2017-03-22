//
//  Playing.swift
//  DropCharge
//
//  Created by harry bloch on 10/5/16.
//  Copyright © 2016 harry bloch. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class Playing: GKState {

    unowned let scene: GameScene
    
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        super.init()
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        if previousState is WaitingForBomb {
            scene.playBackgroundMusic("bgMusic.mp3")
            scene.player.physicsBody!.dynamic = true
            scene.superBoostPlayer()
        }
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        scene.updateCamera()
        scene.updateLevel()
        scene.updatePlayer()
        scene.updateLave(seconds)
        scene.updateCollisionLava()
        scene.updateExplosions(seconds)
        scene.updateRedAlert(seconds)
    }
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
            return stateClass is GameOver.Type
    }
}
