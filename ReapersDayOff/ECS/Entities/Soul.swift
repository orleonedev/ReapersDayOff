//
//  Soul.swift
//  ReapersDayOff
//
//  Created by Maria Smirnova on 05/05/22.
//

import SpriteKit
import GameplayKit

class Soul: GKEntity,GKAgentDelegate, ContactNotifiableType {
    
    // MARK: Nested types
    
    /// Encapsulates a `Soul`'s current mandate, i.e. the aim that the `Soul` is setting out to achieve.
    enum SoulMandate {
        // Hunt another agent (either a `PlayerBot` or a "good" `TaskBot`).
        case fleeAgent(GKAgent2D)

        // Follow the `TaskBot`'s "good" patrol path.
//        case followGoodPatrolPath

        // Follow the `Soul`'s patrol path.
        case followPatrolPath

        // Return to a given position on a patrol path.
        case returnToPositionOnPath(SIMD2<Float>)
    }
    
    // MARK: Properties
    
    
    func didSet() {
    let closestPointOnBadPath = closestPointOnPath(path: pathPoints)
    mandate = .returnToPositionOnPath(SIMD2<Float>(closestPointOnBadPath))
    
    }
    var mandate: SoulMandate
    
    var pathPoints: [CGPoint]
    
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
                radius = GameplayConfiguration.Soul.patrolPathRadius
                agentBehavior = SoulBehavior.behavior(forAgent: agent, patrollingPathWithPoints: pathPoints, pathRadius: radius, inScene: levelScene)
//                debugPathPoints = pathPoints
//                // Patrol paths are always closed loops, so the debug drawing of the path should cycle back round to the start.
//                debugPathShouldCycle = true
//                debugColor = isGood ? SKColor.green : SKColor.purple
            
            case let .fleeAgent(targetAgent):
                radius = GameplayConfiguration.Soul.fleePathRadius
                (agentBehavior, debugPathPoints) = SoulBehavior.behaviorAndPathPoints(forAgent: agent, fleeAgent: targetAgent, pathRadius: radius, inScene: levelScene)
//                debugColor = SKColor.red

            case let .returnToPositionOnPath(position):
                radius = GameplayConfiguration.Soul.returnToPatrolPathRadius
                (agentBehavior, debugPathPoints) = SoulBehavior.behaviorAndPathPoints(forAgent: agent, returningToPoint: position, pathRadius: radius, inScene: levelScene)
//                debugColor = SKColor.yellow
        }

//        if levelScene.debugDrawingEnabled {
//            drawDebugPath(path: debugPathPoints, cycle: debugPathShouldCycle, color: debugColor, radius: radius)
//        }
//        else {
//            debugNode.removeAllChildren()
//        }

        return agentBehavior
    }
    
    /// The `GKAgent` associated with this `TaskBot`.
    var agent: SoulAgent {
        guard let agent = component(ofType: SoulAgent.self) else { fatalError("A TaskBot entity must have a GKAgent2D component.") }
        return agent
    }
    
    var renderComponent: RenderComponent {
        guard let renderComponent = component(ofType: RenderComponent.self) else { fatalError("A Soul must have an RenderComponent.") }
        return renderComponent
    }
    
    // MARK: Initializers
    
    override init() {
//        agent = SoulAgent()
//        agent.radius = GameplayConfiguration.PlayerBot.agentRadius
        self.pathPoints = [CGPoint()]
        self.mandate = SoulMandate.followPatrolPath
        super.init()
    }
    
    required init(pathPoints: [CGPoint], mandate: SoulMandate) {
//        agent = SoulAgent()
        self.pathPoints = pathPoints
        self.mandate = mandate
        super.init()
        // Create a `TaskBotAgent` to represent this `TaskBot` in a steering physics simulation.
        let agent = SoulAgent()
        agent.delegate = self
        
        // Configure the agent's characteristics for the steering physics simulation.
        agent.maxSpeed = GameplayConfiguration.Soul.maximumSpeed
        agent.maxAcceleration = GameplayConfiguration.Soul.maximumAcceleration
        agent.mass = GameplayConfiguration.Soul.agentMass
        agent.radius = GameplayConfiguration.Soul.agentRadius
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
    
    // MARK: GKAgentDelegate
    
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
        
        if intelligenceComponent.stateMachine.currentState is SoulAgentControlledState {
            
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
    
    // MARK: Convenience
    
    /// The direct distance between this `TaskBot`'s agent and another agent in the scene.
    func distanceToAgent(otherAgent: GKAgent2D) -> Float {
        let deltaX = agent.position.x - otherAgent.position.x
        let deltaY = agent.position.y - otherAgent.position.y
        
        return hypot(deltaX, deltaY)
    }
    
    func distanceToPoint(otherPoint: SIMD2<Float>) -> Float {
        let deltaX = agent.position.x - otherPoint.x
        let deltaY = agent.position.y - otherPoint.y
        
        return hypot(deltaX, deltaY)
    }
    
    func closestPointOnPath(path: [CGPoint]) -> CGPoint {
        // Find the closest point to the `TaskBot`.
        let taskBotPosition = agent.position
        let closestPoint = path.min {
            return distance_squared(taskBotPosition, SIMD2<Float>($0)) < distance_squared(taskBotPosition, SIMD2<Float>($1))
        }
    
        return closestPoint!
    }
    
    /// Sets the `TaskBot` `GKAgent` position to match the node position (plus an offset).
    func updateAgentPositionToMatchNodePosition() {
        // `renderComponent` is a computed property. Declare a local version so we don't compute it multiple times.
        let renderComponent = self.renderComponent
        
        let agentOffset = GameplayConfiguration.Soul.agentOffset
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
        
        let agentOffset = GameplayConfiguration.Soul.agentOffset
        renderComponent.node.position = CGPoint(x: agentPosition.x - agentOffset.x, y: agentPosition.y - agentOffset.y)
    }
    
    // MARK: ContactableType
    
    func contactWithEntityDidBegin(_ entity: GKEntity) {}

    func contactWithEntityDidEnd(_ entity: GKEntity) {}
    
    // MARK: Shared Assets
    class func loadSharedAssets() {
        ColliderType.definedCollisions[.Soul] = [
            .Obstacle,
            .Reaper,
            .Soul
        ]
        
        ColliderType.requestedContactNotifications[.Soul] = [
            .Reaper,
        ]
    }
}
