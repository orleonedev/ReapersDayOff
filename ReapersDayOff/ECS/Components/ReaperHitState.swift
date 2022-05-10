//
//  ReaperHitState.swift
//  ReapersDayOff
//
//  Created by Oreste Leone on 09/05/22.
//

import SpriteKit
import GameplayKit

class ReaperHitState: GKState {
    // MARK: Properties
    
    unowned var entity: Reaper
    
    /// The amount of time the `PlayerBot` has been in the "hit" state.
    var elapsedTime: TimeInterval = 0.0
    
    /// The `AnimationComponent` associated with the `entity`.
    var animationComponent: AnimationComponent {
        guard let animationComponent = entity.component(ofType: AnimationComponent.self) else { fatalError("A PlayerBotHitState's entity must have an AnimationComponent.") }
        return animationComponent
    }
    
    // MARK: Initializers
    
    required init(entity: Reaper) {
        self.entity = entity
    }
    
    // MARK: GKState Life Cycle
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        // Reset the elapsed "hit" duration on entering this state.
        elapsedTime = 0.0
        
        // Request the "hit" animation for this `PlayerBot`.
        animationComponent.requestedAnimationState = .hit
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        // Update the amount of time the `PlayerBot` has been in the "hit" state.
        elapsedTime += seconds
        
        // When the `PlayerBot` has been in this state for long enough, transition to the appropriate next state.
        if elapsedTime >= GameplayConfiguration.Reaper.hitStateDuration {
            if entity.isPoweredDown {
                stateMachine?.enter(ReaperRechargingState.self)
            }
            else {
                stateMachine?.enter(ReaperPlayerControlledState.self)
            }
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
            case is ReaperPlayerControlledState.Type, is ReaperRechargingState.Type:
                return true
            
            default:
                return false
        }
    }
}
