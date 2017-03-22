//
//  WaitingForTap.swift
//  DropCharge
//
//  Created by harry bloch on 10/5/16.
//  Copyright © 2016 harry bloch. All rights reserved.
//

import GameplayKit
import SpriteKit
import UIKit

class WaitingForTap: GKState {
    unowned let scene: GameScene
    
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        super.init()
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        let scale = SKAction.scaleTo(1.0, duration: 0.5)
        scene.fgNode.childNodeWithName("Ready")!.runAction(scale)
    }
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return stateClass is WaitingForBomb.Type
    }
}
