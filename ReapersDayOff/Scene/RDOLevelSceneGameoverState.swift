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
import GameController

class RDOLevelSceneGameoverState: RDOLevelSceneOverlayState {
    // MARK: Properties
    
    override var overlaySceneFileName: String {
        return "RDOGameoverScene"
    }

    var logic = GameplayLogic.sharedInstance()
    
    // MARK: GKState Life Cycle
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)

        if let controller = GCController.current {
            controller.light?.color = GCColor.init(red: 1.0, green: 0.0, blue: 0.0)
        }
        
        if let inputComponent = levelScene.reaper.component(ofType: InputComponent.self) {
            inputComponent.isEnabled = false
        }
        levelScene.worldNode.isPaused = true
        
        if logic.currentScore > logic.highScore {
            logic.highScore = Int(logic.currentScore)
        }
        
        if let scoreLabel = overlay.contentNode.childNode(withName: "//score") as? SKLabelNode {
            scoreLabel.text = "Score: " + String(logic.currentScore)
        }
        if let highLabel = overlay.contentNode.childNode(withName: "//highscore") as? SKLabelNode {
            highLabel.text = "Highest: " + String(logic.highScore)
        }
        if let total = overlay.contentNode.childNode(withName: "//total") as? SKLabelNode {
            total.text = String(logic.totalSouls)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return false
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        levelScene.worldNode.isPaused = false
    }
}
