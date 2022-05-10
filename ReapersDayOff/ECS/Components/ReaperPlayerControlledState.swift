//
//  ReaperPlayerControlledState.swift
//  ReapersDayOff
//
//  Created by Oreste Leone on 09/05/22.
//

import SpriteKit
import GameplayKit

class ReaperPlayerControlledState: GKState {
    // MARK: Properties
    
    unowned var entity: Reaper
    
    /// The `AnimationComponent` associated with the `entity`.
    var animationComponent: AnimationComponent {
        guard let animationComponent = entity.component(ofType: AnimationComponent.self) else { fatalError("A PlayerBotPlayerControlledState's entity must have an AnimationComponent.") }
        return animationComponent
    }
    
    /// The `MovementComponent` associated with the `entity`.
    var movementComponent: MovementComponent {
        guard let movementComponent = entity.component(ofType: MovementComponent.self) else { fatalError("A PlayerBotPlayerControlledState's entity must have a MovementComponent.") }
        return movementComponent
    }
    
    /// The `InputComponent` associated with the `entity`.
    var inputComponent: InputComponent {
        guard let inputComponent = entity.component(ofType: InputComponent.self) else { fatalError("A PlayerBotPlayerControlledState's entity must have an InputComponent.") }
        return inputComponent
    }
    
    // MARK: Initializers
    
    required init(entity: Reaper) {
        self.entity = entity
    }
    
    // MARK: GKState Life Cycle
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        // Turn on controller input for the `PlayerBot` when entering the player-controlled state.
        inputComponent.isEnabled = true
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        /*
            Assume an animation of "idle" that can then be overwritten by the movement
            component in response to user input.
        */
        animationComponent.requestedAnimationState = .idle
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
            case is ReaperHitState.Type, is ReaperRechargingState.Type:
                return true
            
            default:
                return false
        }
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        // Turn off controller input for the `PlayerBot` when leaving the player-controlled state.
        entity.component(ofType: InputComponent.self)?.isEnabled = false
        
        // `movementComponent` is a computed property. Declare a local version so we don't compute it multiple times.
        let movementComponent = self.movementComponent

        // Cancel any planned movement or rotation when leaving the player-controlled state.
        movementComponent.nextTranslation = nil
        movementComponent.nextRotation = nil
    }
}
