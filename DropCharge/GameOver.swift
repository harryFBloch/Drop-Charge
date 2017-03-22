//
//  GameOver.swift
//  DropCharge
//
//  Created by harry bloch on 10/5/16.
//  Copyright © 2016 harry bloch. All rights reserved.
//

import UIKit
import GameplayKit
import SpriteKit

class GameOver: GKState {

    unowned let scene: GameScene
    
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        super.init()
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        if previousState is Playing {
            
            scene.playBackgroundMusic("SpaceGame.caf")
            let gameOver = SKSpriteNode(imageNamed: "GameOver")
            gameOver.position = scene.getCameraPosition()
            gameOver.zPosition = 10
            scene.addChild(gameOver)
            
            let explosion = scene.explosion(3.0)
            explosion.position = gameOver.position
            explosion.zPosition = 11
            scene.addChild(explosion)
            scene.runAction(scene.soundExplosions[3])
        }
    }
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return stateClass is WaitingForTap.Type
    }
}
