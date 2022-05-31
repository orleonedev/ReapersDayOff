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
    var spawnRate: TimeInterval = 1.0
    var heartReapSpwan: TimeInterval = GameplayConfiguration.HeartReaper.enemySpawnRate
    var aliveTimer: TimeInterval = GameplayConfiguration.HeartReaper.enemySpawnRate*2
    
    
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
    
    var chargeComponent: ChargeComponent {
        guard let chargeComponent = levelScene.reaper.component(ofType: ChargeComponent.self) else { fatalError("A Reaper must have an ChargeComponent.") }
        return chargeComponent
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
        
        spawnRate -= seconds
        if spawnRate < 0 {
            spawnRate = 1.0
            if logic.soulsOnStage < 50 {
                levelScene.spawnSoul()
            }
        }
        
        
        if !logic.enemyOnStage {
            
            heartReapSpwan -= seconds
            
            print("heartReapSpwan \(heartReapSpwan)")
            if heartReapSpwan < 0 {
                heartReapSpwan = GameplayConfiguration.HeartReaper.enemySpawnRate
                levelScene.spawnEnemy()
                print("SPAWN")
                logic.enemyOnStage = true
            }
        }
        else {
            aliveTimer -= seconds
            print("aliveTimer \(aliveTimer)")
            if aliveTimer < 0 {
                aliveTimer = GameplayConfiguration.HeartReaper.enemySpawnRate*2
                levelScene.enemy?.removeHeartReaper()
                print("REMOVE")
                logic.enemyOnStage = false
            }
        }
        
        if levelScene.resetEnemyTimer{
            aliveTimer = GameplayConfiguration.HeartReaper.enemySpawnRate*2
            levelScene.resetEnemyTimer = false
        }
        //solo se enemy non ci sta sulla scena: controllare
        
        // Update the displayed time remaining.
        levelScene.timerNode.text = timeRemainingString
        levelScene.score.text = String(logic.currentScore)
        levelScene.bluecounter.text = String(logic.blueSouls)
        levelScene.redcounter.text = String(logic.redSouls)
        levelScene.greencounter.text = String(logic.greenSouls)
        levelScene.soulsContainer.size.height = CGFloat(logic.sumSoul) * (levelScene.soulsContainerTexture.size.height / 10)
        
        
        if (logic.isFull){
            levelScene.soulsContainer.color = UIColor.orange
        }
        else
        {
            levelScene.soulsContainer.color = UIColor.yellow
        }
        
        if let movComp = levelScene.reaper.component(ofType: MovementComponent.self) {
            
            if logic.isFull {
                movComp.movementSpeed = GameplayConfiguration.Reaper.movementSpeed - 100
                logic.timeRemaining -= seconds
                chargeComponent.loseCharge(chargeToLose: Double(seconds))
            }
            else {
                if levelScene.isSpeeding {
                    movComp.movementSpeed = GameplayConfiguration.Reaper.movementSpeed + 100
                    logic.timeRemaining -= seconds*2
                    chargeComponent.loseCharge(chargeToLose: Double(seconds)*2)
                }
                else {
                    movComp.movementSpeed = GameplayConfiguration.Reaper.movementSpeed
                    logic.timeRemaining -= seconds
                    chargeComponent.loseCharge(chargeToLose: Double(seconds))
                }
            }
        }
        
        if !chargeComponent.hasCharge {
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
