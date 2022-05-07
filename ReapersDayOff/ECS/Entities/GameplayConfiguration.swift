//
//  GameplayConfiguration.swift
//  ReapersDayOff
//
//  Created by Maria Smirnova on 05/05/22.
//

import Foundation
import CoreGraphics

struct GameplayConfiguration {
    struct Soul {
        /// The length of time a `TaskBot` waits before re-evaluating its rules.
        static let rulesUpdateWaitDuration: TimeInterval = 1.0

        /// The length of time a `TaskBot` waits before re-checking for an appropriate behavior.
        static let behaviorUpdateWaitDuration: TimeInterval = 0.25
        
        /// How close a `TaskBot` has to be to a patrol path start point in order to start patrolling.
        static let thresholdProximityToPatrolPathStartPoint: Float = 50.0

        /// The maximum speed (in points per second) for the `TaskBot` when in its "bad" state.
        static let maximumSpeed: Float = 120.0

        
        /*
            `maximumAcceleration` is set to a high number to enable the TaskBot to turn very quickly.
            This ensures that the `TaskBot` can follow its patrol path more effectively.
        */
        /// The maximum acceleration (in points per second per second) for the `TaskBot`.
        static let maximumAcceleration: Float = 300.0

        /// The agent's mass.
        static let agentMass: Float = 0.25
        
        /// The radius of the `TaskBot`'s physics body.
        static var physicsBodyRadius: CGFloat = 35.0

        /// The offset of the `TaskBot` physics body's center from the `TaskBot`'s center.
        static let physicsBodyOffset = CGPoint(x: 0.0, y: -25.0)

        /// The radius (in points) of the agent associated with this `TaskBot` for steering.
        static let agentRadius = Float(physicsBodyRadius)
        
        /// The offset of the agent's center from the `TaskBot`'s center.
        static let agentOffset = physicsBodyOffset
        
        /// The maximum time to look ahead when following a path.
        static let maxPredictionTimeWhenFollowingPath: TimeInterval = 1.0
        
        /// The maximum time to look ahead for obstacles to be avoided.
        static let maxPredictionTimeForObstacleAvoidance: TimeInterval = 1.0

        /// The radius of the path along which an agent patrols.
        static let patrolPathRadius: Float = 10.0
        
        /// The radius of the path along which an agent travels when hunting.
        static let huntPathRadius: Float = 20.0

        /// The radius of the path along which an agent travels when returning to its patrol path.
        static let returnToPatrolPathRadius: Float = 20.0
        
        /// The buffer radius (in points) to add to polygon obstacles when calculating agent pathfinding.
        static let pathfindingGraphBufferRadius: Float = 30.0
        
        /// The duration of a `TaskBot`'s pre-attack state.
        static let preAttackStateDuration: TimeInterval = 0.8
        
        /// The duration of a `TaskBot`'s zapped state.
        static let zappedStateDuration: TimeInterval = 0.75
    }
    
    struct RedSoul {
        /// The maximum amount of charge a `FlyingBot` stores.
        static let maximumCharge = 100.0
        
        /// The radius of a `FlyingBot` blast.
        static let blastRadius: Float = 100.0
        
        /// The amount of charge a `FlyingBot` blast drains from `PlayerBot`s per second.
        static let blastChargeLossPerSecond = 25.0

        /// The duration of a `FlyingBot` blast.
        static let blastDuration: TimeInterval = 1.25
        
        /// The duration over which a `FlyingBot` blast affects entities in its blast radius.
        static let blastEffectDuration: TimeInterval = 0.75

        /// The offset from the `FlyingBot`'s position for the blast particle emitter node.
        static let blastEmitterOffset = CGPoint(x: 0.0, y: 20.0)
        
        /// The offset from the `FlyingBot`'s position that should be used for beam targeting.
        static let beamTargetOffset = CGPoint(x: 0.0, y: 65.0)
    }
}
