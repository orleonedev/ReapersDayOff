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
        static var physicsBodyRadius: CGFloat = 24

        /// The offset of the `TaskBot` physics body's center from the `TaskBot`'s center.
        static let physicsBodyOffset = CGPoint(x: 0.0, y: -16.0)

        /// The radius (in points) of the agent associated with this `TaskBot` for steering.
        static let agentRadius = Float(physicsBodyRadius)
        
        /// The offset of the agent's center from the `TaskBot`'s center.
        static let agentOffset = physicsBodyOffset
        
        /// The maximum time to look ahead when following a path.
        static let maxPredictionTimeWhenFollowingPath: TimeInterval = 1.0
        
        /// The maximum time to look ahead for obstacles to be avoided.
        static let maxPredictionTimeForObstacleAvoidance: TimeInterval = 1.0
        
        static let maxPredictionTimeForReaperAvoidance: TimeInterval = 1.0

        /// The radius of the path along which an agent patrols.
        static let patrolPathRadius: Float = 32
        
        /// The radius of the path along which an agent travels when hunting.
        static let fleePathRadius: Float = 20.0

        /// The radius of the path along which an agent travels when returning to its patrol path.
        static let returnToPatrolPathRadius: Float = 32
        
        /// The buffer radius (in points) to add to polygon obstacles when calculating agent pathfinding.
        static let pathfindingGraphBufferRadius: Float = 64.0
        
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
    
    struct BlueSoul {
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
    
    struct GreenSoul {
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
    
    struct Reaper {
        /// The movement speed (in points per second) for the `PlayerBot`.
        static let movementSpeed: CGFloat = 220.0

        /// The angular rotation speed (in radians per second) for the `PlayerBot`.
        static let angularSpeed = CGFloat.pi * 1.4
        
        /// The radius of the `PlayerBot`'s physics body.
        static var physicsBodyRadius: CGFloat = 32.0
        
        /// The offset of the `PlayerBot`'s physics body's center from the `PlayerBot`'s center.
        static let physicsBodyOffset = CGPoint(x: 0.0, y: -16.0)
        
        /// The radius of the agent associated with this `PlayerBot` for pathfinding.
        static let agentRadius = Float(physicsBodyRadius)
        
        /// The offset of the agent's center from the `PlayerBot`'s center.
        static let agentOffset = physicsBodyOffset
        
        /// The offset of the `PlayerBot`'s charge bar from its position.
        static let chargeBarOffset = CGPoint(x: 0.0, y: 65.0)
        
        /// The initial charge value for the `PlayerBot`'s health bar.
        static let initialCharge = 100.0

        /// The maximum charge value for the `PlayerBot`'s health bar.
        static let maximumCharge = 100.0
        
        /// The length of time for which the `PlayerBot` remains in its "hit" state.
        static let hitStateDuration: TimeInterval = 0.75
        
        /// The length of time that it takes the `PlayerBot` to recharge when deactivated.
        static let rechargeDelayWhenInactive: TimeInterval = 2.0
        
        /// The amount of charge that the `PlayerBot` gains per second when recharging.
        static let rechargeAmountPerSecond = 10.0
    
        /// The amount of time it takes the `PlayerBot` to appear in a level before becoming controllable by the player.
        static let appearDuration: TimeInterval = 0.50
    }
        struct Timer {
        /// The name of the font to use for the timer.
        static let fontName = "DINCondensed-Bold"
        
        /// The size of the timer node font as a proportion of the level scene's height.
        static let fontSize: CGFloat = 0.05
        
        #if os(tvOS)
        /// The size of padding between the top of the scene and the timer node.
        static let paddingSize: CGFloat = 60.0
        #else
        /// The size of padding between the top of the scene and the timer node as a proportion of the timer node's font size.
        static let paddingSize: CGFloat = 0.2
        #endif
    }
    
    struct Flocking {
        /// Separation, alignment, and cohesion parameters for multiple `TaskBot`s.
        static let separationRadius: Float = 25.3
        static let separationAngle = Float (3 * (Float.pi / 4))
        static let separationWeight: Float = 2.0
        
        static let alignmentRadius: Float = 43.333
        static let alignmentAngle: Float = Float.pi / 2
        static let alignmentWeight: Float = 1.667
        
        static let cohesionRadius: Float = 50.0
        static let cohesionAngle: Float = Float.pi / 2
        static let cohesionWeight: Float = 1.667
        
        static let agentSearchDistanceForFlocking: Float = 50.0
    }
    
    struct TouchControl {
        /// The minimum distance a virtual thumbstick must move before it is considered to have been moved.
        static let minimumRequiredThumbstickDisplacement: Float = 0.35
        
        /// The minimum size for an on-screen control.
        static let minimumControlSize: CGFloat = 200
        
        /// The ideal size for an on-screen control as a ratio of the scene's width.
        static let idealRelativeControlSize: CGFloat = 0.2
    }
}
