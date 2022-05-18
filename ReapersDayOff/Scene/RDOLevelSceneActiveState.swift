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
    
    var logic = GameplayLogic.sharedInstance()
    var spawnRate: TimeInterval = 2.0
    
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
        components.second = Int(max(0.0, logic.timeRemaining ))
        
        return timeRemainingFormatter.string(from: components as DateComponents)!
    }
    
    // MARK: Initializers
    
    init(levelScene: RDOLevelScene) {
        self.levelScene = levelScene
        
        
        logic.setupGame()
    }
    
    // MARK: GKState Life Cycle
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)

        levelScene.timerNode.text = timeRemainingString
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        // Subtract the elapsed time from the remaining time.
        if levelScene.isSpeeding{
            logic.timeRemaining -= seconds*2
            
        }else {
            logic.timeRemaining -= seconds
        }
        
        spawnRate -= seconds
        if spawnRate < 0 {
            
            spawnRate = 2.0
            levelScene.spawnSoul()
        }
        
        // Update the displayed time remaining.
        levelScene.timerNode.text = timeRemainingString
        levelScene.score.text = String(logic.currentScore)
        levelScene.bluecounter.text = String(logic.blueSouls)
        levelScene.redcounter.text = String(logic.redSouls)
        levelScene.greencounter.text = String(logic.greenSouls)
        levelScene.soulsbar.size.width = CGFloat(logic.sumSoul) * (levelScene.frame.height / 5) / 10
        
        if (logic.isFull){
            levelScene.soulsbar.color = UIColor.red
            
        }
        else
        {
            levelScene.soulsbar.color = UIColor.black
            
        }

        if let movComp = levelScene.reaper.component(ofType: MovementComponent.self) {
            
            if logic.isFull {
                movComp.movementSpeed = GameplayConfiguration.Reaper.movementSpeed - 70
            }
            else {
                if levelScene.isSpeeding {
                    movComp.movementSpeed = GameplayConfiguration.Reaper.movementSpeed + 100
                }
                else {
                    movComp.movementSpeed = GameplayConfiguration.Reaper.movementSpeed
                }
            }
        }
        
        // Check if the `levelScene` contains any bad `TaskBot`s.
//        let allTaskBotsAreGood = !levelScene.entities.contains { entity in
//            if let taskBot = entity as? TaskBot {
//                return !taskBot.isGood
//            }
//
//            return false
//        }
        
        if logic.timeRemaining <= 0.0 {
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
