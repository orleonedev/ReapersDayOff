//
//  HeartReaperAppearState.swift
//  ReapersDayOff
//
//  Created by Oreste Leone on 12/06/22.
//

import SpriteKit
import GameplayKit

class HeartReaperAppearState: GKState {
    // MARK: Properties
    
    unowned var entity: HeartReaper
    
    /// The amount of time the `PlayerBot` has been in the "appear" state.
    var elapsedTime: TimeInterval = 0.0
    
    /// The `AnimationComponent` associated with the `entity`.
    var animationComponent: AnimationComponent {
        guard let animationComponent = entity.component(ofType: AnimationComponent.self) else { fatalError("A HeartReaperAppearState's entity must have an AnimationComponent.") }
        return animationComponent
    }
    
    /// The `RenderComponent` associated with the `entity`.
    var renderComponent: RenderComponent {
        guard let renderComponent = entity.component(ofType: RenderComponent.self) else { fatalError("A HeartReaperAppearState's entity must have an RenderComponent.") }
        return renderComponent
    }
    
    /// The `OrientationComponent` associated with the `entity`.
    var orientationComponent: OrientationComponent {
        guard let orientationComponent = entity.component(ofType: OrientationComponent.self) else { fatalError("A HeartReaperAppearState's entity must have an OrientationComponent.") }
        return orientationComponent
    }
    
    /// The `SKSpriteNode` used to show the player animating into the scene.
    var node = SKSpriteNode()
    
    // MARK: Initializers
    
    required init(entity: HeartReaper) {
        self.entity = entity
    }
    
    // MARK: GKState Life Cycle
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        // Reset the elapsed time.
        elapsedTime = 0.0
        
        node.size = HeartReaper.textureSize
        
        //animation
        node.run(SKAction(named: "heartAppear")!)
        // Add the node to the `HeartReaper`'s render node.
        renderComponent.node.addChild(node)
        
        
        // Hide the animation component node until the `PlayerBot` exits this state.
        animationComponent.node.isHidden = true

        if SoundClass.sharedInstance().enabled {
            SoundClass.sharedInstance().playSoundEffect2("DonnieAppear.mp3")
        }
        
        
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        // Update the amount of time that the `HeartReaper` has been teleporting in to the level.
        elapsedTime += seconds

        // Check if we have spent enough time
        if elapsedTime > GameplayConfiguration.Reaper.appearDuration {
            // Remove the node from the scene
            node.removeFromParent()
            
            // Switch the `HeartReaper` over to a "agent controlled" state.
            stateMachine?.enter(EnemyAgentControlledState.self)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is EnemyAgentControlledState.Type
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        // Un-hide the animation component node.
        animationComponent.node.isHidden = false
        
    }
}
