//
//  SoulAgentControlledState.swift
//  ReapersDayOff
//
//  Created by Maria Smirnova on 06/05/22.
//

import SpriteKit
import GameplayKit

class SoulAgentControlledState: GKState {
    // MARK: Properties
    
    unowned var entity: Soul
    
    /// The amount of time that has passed since the `TaskBot` became agent-controlled.
    var elapsedTime: TimeInterval = 0.0
    
    /// The amount of time that has passed since the `TaskBot` last determined an appropriate behavior.
    var timeSinceBehaviorUpdate: TimeInterval = 0.0
    
    var timeSpan: TimeInterval = 6.0
    
    // MARK: Initializers
    
    required init(entity: Soul) {
        self.entity = entity
    }
    
    // MARK: GKState Life Cycle
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        // Reset the amount of time since the last behavior update.
        timeSinceBehaviorUpdate = 0.0
        elapsedTime = 0.0
        
        // Ensure that the agent's behavior is the appropriate behavior for its current mandate.
        entity.agent.behavior = entity.behaviorForCurrentMandate
        
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        // Update the "time since last behavior update" tracker.
        timeSinceBehaviorUpdate += seconds
        elapsedTime += seconds
        timeSpan -= seconds
        
        // Check if enough time has passed since the last behavior update, and update the behavior if so.
        if timeSinceBehaviorUpdate >= GameplayConfiguration.Soul.behaviorUpdateWaitDuration {
            
            if let levelScene = entity.renderComponent.node.scene as? RDOLevelScene {
                
                let reaperAgent = levelScene.reaper.agent
                if entity.distanceToAgent(otherAgent: reaperAgent) < 224{
                    entity.mandate = .fleeAgent(reaperAgent)
                    
                }   else {
                    entity.mandate = .wander
                    if timeSpan < 0 {
                        timeSpan = 6
                        if let orComp = entity.component(ofType: OrientationComponent.self) {
                            orComp.compassDirection = CompassDirection.allDirections.randomElement() ?? .southWest
                        }
                    }
                    
                }
                
            }
            

            // Ensure the agent's behavior is the appropriate behavior for its current mandate.
            entity.agent.behavior = entity.behaviorForCurrentMandate

            // Reset `timeSinceBehaviorUpdate`, to delay when the entity's behavior is next updated.
            timeSinceBehaviorUpdate = 0.0

        }
    
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        /*
            The `TaskBot` will no longer be controlled by an agent in the steering simulation
            when it leaves the `TaskBotAgentControlledState`.
            Assign an empty behavior to cancel any active agent control.
        */
        entity.agent.behavior = GKBehavior()
    }
}

