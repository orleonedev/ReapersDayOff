//
//  RDOLevelSceneActiveState.swift
//  ReapersDayOff
//
//  Created by Claudio Silvestri on 09/05/22.
//

/*    
    Abstract:
    A state used by `LevelScene` to indicate that the game is actively being played. This state updates the current time of the level's countdown timer.
*/

import SpriteKit
import GameplayKit

class RDOLevelSceneActiveState: GKState {
    // MARK: Properties
    
    unowned let levelScene: RDOLevelScene
    
    var timeRemaining: TimeInterval = 0.0
    
    /*
        A formatter for individual date components used to provide an appropriate
        display value for the timer.
    */
    let timeRemainingFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        
        return formatter
    }()
    
    // The formatted string representing the time remaining.
    var timeRemainingString: String {
        let components = NSDateComponents()
        components.second = Int(max(0.0, timeRemaining))
        
        return timeRemainingFormatter.string(from: components as DateComponents)!
    }
    
    // MARK: Initializers
    
    init(levelScene: RDOLevelScene) {
        self.levelScene = levelScene
        
        timeRemaining = TimeInterval(10.0)
    }
    
    // MARK: GKState Life Cycle
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)

        levelScene.timerNode.text = timeRemainingString
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        // Subtract the elapsed time from the remaining time.
        timeRemaining -= seconds
        
        // Update the displayed time remaining.
        levelScene.timerNode.text = timeRemainingString
        
        // Check if the `levelScene` contains any bad `TaskBot`s.
//        let allTaskBotsAreGood = !levelScene.entities.contains { entity in
//            if let taskBot = entity as? TaskBot {
//                return !taskBot.isGood
//            }
//
//            return false
//        }
        
        if timeRemaining <= 0.0 {
            // If all the TaskBots are good, the player has completed the level.
            stateMachine?.enter(RDOLevelSceneGameoverState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
            case is RDOLevelScenePauseState.Type, is RDOLevelSceneGameoverState.Type:
                return true
                
            default:
                return false
        }
    }
}
