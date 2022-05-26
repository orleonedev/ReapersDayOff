//
//  Enemy.swift
//  ReapersDayOff
//
//  Created by Maria Smirnova on 20/05/22.
//

import SpriteKit
import GameplayKit

class Enemy: GKEntity,GKAgentDelegate, ContactNotifiableType {
    
    enum EnemyMandate {
        case huntAgent(GKAgent2D)
        
        case wander

        // Follow the `Soul`'s patrol path.
        case followPatrolPath

        // Return to a given position on a patrol path.
        case returnToPositionOnPath(SIMD2<Float>)
    }
    
    var mandate: EnemyMandate
    var pathPoints: [CGPoint]
    
    static var animations: [AnimationState: [CompassDirection: Animation]]?
    
    var behaviorForCurrentMandate: GKBehavior {
        // Return an empty behavior if this `TaskBot` is not yet in a `LevelScene`.
        guard let levelScene = component(ofType: RenderComponent.self)?.node.scene as? RDOLevelScene else {
            return GKBehavior()
        }

        let agentBehavior: GKBehavior
        let radius: Float
            
        // `debugPathPoints`, `debugPathShouldCycle`, and `debugColor` are only used when debug drawing is enabled.
        let debugPathPoints: [CGPoint]
        var debugPathShouldCycle = false
        let debugColor: SKColor
        
        switch mandate {
            case .followPatrolPath:
                let pathPoints = pathPoints
                radius = GameplayConfiguration.Enemy.patrolPathRadius
            agentBehavior = EnemyBehavior.behavior(forAgent: agent, patrollingPathWithPoints: pathPoints, pathRadius: radius, inScene: levelScene)
//                debugPathPoints = pathPoints
//                // Patrol paths are always closed loops, so the debug drawing of the path should cycle back round to the start.
//                debugPathShouldCycle = true
//                debugColor = isGood ? SKColor.green : SKColor.purple
            
        case let .huntAgent(targetAgent):
            radius = GameplayConfiguration.Enemy.huntPathRadius
            (agentBehavior, debugPathPoints) = EnemyBehavior.behaviorAndPathPoints(forAgent: agent, huntingAgent: targetAgent, pathRadius: radius, inScene: levelScene)
            
//            case let .huntAgent(targetAgent):
//                radius = GameplayConfiguration.Enemy.huntPathRadius
//                (agentBehavior, debugPathPoints) = EnemyBehavior.behaviorAndPathPoints(forAgent: agent, fleeAgent: targetAgent, pathRadius: radius, inScene: levelScene)
////                debugColor = SKColor.red

            case let .returnToPositionOnPath(position):
                radius = GameplayConfiguration.Enemy.returnToPatrolPathRadius
                (agentBehavior, debugPathPoints) = EnemyBehavior.behaviorAndPathPoints(forAgent: agent, returningToPoint: position, pathRadius: radius, inScene: levelScene)
//                debugColor = SKColor.yellow
        case .wander:
            agentBehavior = EnemyBehavior.behaviorWonder(forAgent: agent, inScene: levelScene)
        }

        return agentBehavior
    }
    
    /// The `GKAgent` associated with this `TaskBot`.
    var agent: EnemyAgent {
        guard let agent = component(ofType: EnemyAgent.self) else { fatalError("A TaskBot entity must have a GKAgent2D component.") }
        return agent
    }
    
    var renderComponent: RenderComponent {
        guard let renderComponent = component(ofType: RenderComponent.self) else { fatalError("A enemy must have an RenderComponent.") }
        return renderComponent
    }
    
    override init() {
        self.pathPoints = []
        self.mandate = .wander
        super.init()
        let agent = EnemyAgent()
        agent.delegate = self
        agent.maxSpeed = GameplayConfiguration.HeartReaper.maximumSpeedRed
        agent.maxAcceleration = GameplayConfiguration.Enemy.maximumAcceleration
        agent.mass = GameplayConfiguration.Enemy.agentMass
        agent.radius = GameplayConfiguration.Enemy.agentRadius
        agent.behavior = GKBehavior()
              
              /*
                  `GKAgent2D` is a `GKComponent` subclass.
                  Add it to the `TaskBot` entity's list of components so that it will be updated
                  on each component update cycle.
              */
        addComponent(agent)
    }
    required init(pathPoints: [CGPoint], mandate: EnemyMandate) {
        
        self.pathPoints = pathPoints
        self.mandate = mandate
        
        super.init()
        // Create a `TaskBotAgent` to represent this `TaskBot` in a steering physics simulation.
        let agent = EnemyAgent()
        agent.delegate = self
        agent.maxSpeed = GameplayConfiguration.HeartReaper.maximumSpeedRed
        agent.maxAcceleration = GameplayConfiguration.Enemy.maximumAcceleration
        agent.mass = GameplayConfiguration.Enemy.agentMass
        agent.radius = GameplayConfiguration.Enemy.agentRadius
        agent.behavior = GKBehavior()
              
              /*
                  `GKAgent2D` is a `GKComponent` subclass.
                  Add it to the `TaskBot` entity's list of components so that it will be updated
                  on each component update cycle.
              */
        addComponent(agent)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func agentWillUpdate(_: GKAgent) {
        /*
            `GKAgent`s do not operate in the SpriteKit physics world,
            and are not affected by SpriteKit physics collisions.
            Because of this, the agent's position and rotation in the scene
            may have values that are not valid in the SpriteKit physics simulation.
            For example, the agent may have moved into a position that is not allowed
            by interactions between the `TaskBot`'s physics body and the level's scenery.
            To counter this, set the agent's position and rotation to match
            the `TaskBot` position and orientation before the agent calculates
            its steering physics update.
        */
        updateAgentPositionToMatchNodePosition()
        updateAgentRotationToMatchTaskBotOrientation()
    }
    
    func agentDidUpdate(_: GKAgent) {
        guard let intelligenceComponent = component(ofType: IntelligenceComponent.self) else { return }
        guard let orientationComponent = component(ofType: OrientationComponent.self) else { return }
        
        if intelligenceComponent.stateMachine.currentState is EnemyAgentControlledState {
            
            // `TaskBot`s always move in a forward direction when they are agent-controlled.
            component(ofType: AnimationComponent.self)?.requestedAnimationState = .walkForward
            
            // When the `TaskBot` is agent-controlled, the node position follows the agent position.
            updateNodePositionToMatchAgentPosition()
            
            // If the agent has a velocity, the `zRotation` should be the arctangent of the agent's velocity. Otherwise use the agent's `rotation` value.
            let newRotation: Float
            if agent.velocity.x > 0.0 || agent.velocity.y > 0.0 {
                newRotation = atan2(agent.velocity.y, agent.velocity.x)
            }
            else {
                newRotation = agent.rotation
            }

            // Ensure we have a valid rotation.
            if newRotation.isNaN { return }

            orientationComponent.zRotation = CGFloat(newRotation)
        }
        else {
            /*
                When the `TaskBot` is not agent-controlled, the agent position
                and rotation follow the node position and `TaskBot` orientation.
            */
            updateAgentPositionToMatchNodePosition()
            updateAgentRotationToMatchTaskBotOrientation()
        }
    }
    
    func distanceToAgent(otherAgent: GKAgent2D) -> Float {
        let deltaX = agent.position.x - otherAgent.position.x
        let deltaY = agent.position.y - otherAgent.position.y
        
        return hypot(deltaX, deltaY)
    }
    
    /// Sets the `TaskBot` `GKAgent` position to match the node position (plus an offset).
    func updateAgentPositionToMatchNodePosition() {
        // `renderComponent` is a computed property. Declare a local version so we don't compute it multiple times.
        let renderComponent = self.renderComponent
        
        let agentOffset = GameplayConfiguration.Enemy.agentOffset
        agent.position = SIMD2<Float>(x: Float(renderComponent.node.position.x + agentOffset.x), y: Float(renderComponent.node.position.y + agentOffset.y))
    }
    
    /// Sets the `TaskBot` `GKAgent` rotation to match the `TaskBot`'s orientation.
    func updateAgentRotationToMatchTaskBotOrientation() {
        guard let orientationComponent = component(ofType: OrientationComponent.self) else { return }
        agent.rotation = Float(orientationComponent.zRotation)
    }
    
    
    /// Sets the `TaskBot` node position to match the `GKAgent` position (minus an offset).
    func updateNodePositionToMatchAgentPosition() {
        // `agent` is a computed property. Declare a local version of its property so we don't compute it multiple times.
        let agentPosition = CGPoint(agent.position)
        
        let agentOffset = GameplayConfiguration.Enemy.agentOffset
        renderComponent.node.position = CGPoint(x: agentPosition.x - agentOffset.x, y: agentPosition.y - agentOffset.y)
    }
    
    func contactWithEntityDidBegin(_ entity: GKEntity) {
        
    }
    
    func contactWithEntityDidEnd(_ entity: GKEntity) {
        
    }
    
    
    
    
}
