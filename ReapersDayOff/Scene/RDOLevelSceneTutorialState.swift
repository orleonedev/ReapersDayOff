//
//  RDOLevelSceneTutorialState.swift
//  ReapersDayOff
//
//  Created by Claudio Silvestri on 03/06/22.
//

import SpriteKit
import GameplayKit
import GameController

class RDOLevelSceneTutorialState: RDOLevelSceneOverlayState {
    // MARK: Properties
    
    override var overlaySceneFileName: String {
        return "RDOTutorialScene"
    }
    
    // MARK: GKState Life Cycle
    
    override func didEnter(from previousState: GKState?) {
        
        super.didEnter(from: previousState)
        
            if let taptostart = overlay.contentNode.childNode(withName: "//ResumeLabel") as? SKLabelNode {
                if GCController.current != nil {
                    taptostart.text = "Press anything to continue"
                } else {
                    taptostart.text = "Tap anywhere to continue"
                }
        }
        

    }
    
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is RDOLevelSceneActiveState.Type
    }

    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        levelScene.worldNode.isPaused = false
    }
    
}
