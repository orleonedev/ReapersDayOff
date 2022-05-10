//
//  RDOLevelSceneGameoverState.swift
//  ReapersDayOff
//
//  Created by Claudio Silvestri on 09/05/22.
//

/*
    Abstract:
    A state used by `LevelScene` to indicate that the player ended a game.
*/

import SpriteKit
import GameplayKit

class RDOLevelSceneGameoverState: RDOLevelSceneOverlayState {
    // MARK: Properties
    
    override var overlaySceneFileName: String {
        return "RDOGameoverScene"
    }

    // MARK: GKState Life Cycle
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)

//        if let inputComponent = levelScene.playerBot.component(ofType: InputComponent.self) {
//            inputComponent.isEnabled = false
//        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return false
    }
}
