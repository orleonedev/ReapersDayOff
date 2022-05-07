//
//  Soul.swift
//  ReapersDayOff
//
//  Created by Maria Smirnova on 05/05/22.
//

import SpriteKit
import GameplayKit

class Soul: GKEntity,GKAgentDelegate {
    
    /// The agent used when pathfinding to the `Soul`.
    let agent: GKAgent2D
    
    var renderComponent: RenderComponent {
        guard let renderComponent = component(ofType: RenderComponent.self) else { fatalError("A Soul must have an RenderComponent.") }
        return renderComponent
    }
    
    // MARK: Initializers
    
    override init() {
        agent = GKAgent2D()
//        agent.radius = GameplayConfiguration.PlayerBot.agentRadius
        
        super.init()
    }
    
    init(pathPoints: [CGPoint]) {
        agent = GKAgent2D()
        super.init()
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
    
    // MARK: Shared Assets
    class func loadSharedAssets() {
        ColliderType.definedCollisions[.Soul] = [
            .Obstacle,
            .Reaper,
            .Soul
        ]
        
        ColliderType.requestedContactNotifications[.Soul] = [
            .Obstacle,
            .Reaper,
            .Soul
        ]
    }
}
