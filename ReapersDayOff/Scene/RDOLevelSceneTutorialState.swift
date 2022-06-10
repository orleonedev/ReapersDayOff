//
//  RDOLevelSceneTutorialState.swift
//  ReapersDayOff
//
//  Created by Claudio Silvestri on 03/06/22.
//

import SpriteKit
import GameplayKit

class RDOLevelSceneTutorialState: RDOLevelSceneOverlayState {
    // MARK: Properties
    
    override var overlaySceneFileName: String {
        return "RDOTutorialScene"
    }
    
    // MARK: GKState Life Cycle
    
    override func didEnter(from previousState: GKState?) {
        
        super.didEnter(from: previousState)

    }
    
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is RDOLevelSceneActiveState.Type
    }

    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        levelScene.worldNode.isPaused = false
    }
    
}
