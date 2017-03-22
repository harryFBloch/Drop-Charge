//
//  FallPlayer.swift
//  DropCharge
//
//  Created by harry bloch on 10/5/16.
//  Copyright © 2016 harry bloch. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class FallPlayer: GKState {

    unowned let scene: GameScene
    
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        super.init()
    }
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
         return stateClass is JumpPlayer.Type || stateClass is LavaPlayer.Type
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        scene.runAnim(scene.animFall)
    }

}
