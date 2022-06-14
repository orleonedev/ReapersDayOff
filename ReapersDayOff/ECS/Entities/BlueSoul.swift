//
//  BlueSoul.swift
//  ReapersDayOff
//
//  Created by Maria Smirnova on 11/05/22.
//

import SpriteKit
import GameplayKit

class BlueSoul: Soul {
    
    static var textureSize = CGSize(width: 64 , height: 64)
    
    static var soulAnimations: [AnimationState: [CompassDirection: Animation]]?
    
     var soulAnimations: [AnimationState: [CompassDirection: Animation]] {
        return BlueSoul.soulAnimations!
    }
    
    override init() {
        super.init(color: "blue")

        // Create components that define how the entity looks and behaves.
        createRenderingComponents()
        
        let orientationComponent = OrientationComponent()
        addComponent(orientationComponent)

        let intelligenceComponent = IntelligenceComponent(states: [
            SoulAgentControlledState(entity: self)
        ])
        addComponent(intelligenceComponent)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func createRenderingComponents(){
        
        let renderComponent = RenderComponent()
        addComponent(renderComponent)
        
        
        let initialAnimations: [AnimationState: [CompassDirection: Animation]]
        initialAnimations = soulAnimations
        let animationComponent = AnimationComponent(textureSize: BlueSoul.textureSize, animations: initialAnimations)
        addComponent(animationComponent)
        
        let physicsBody = SKPhysicsBody(circleOfRadius: GameplayConfiguration.Soul.physicsBodyRadius, center: GameplayConfiguration.Soul.physicsBodyOffset)
        let physicsComponent = PhysicsComponent(physicsBody: physicsBody, colliderType: .Soul)
        addComponent(physicsComponent)
        
        // Connect the `PhysicsComponent` and the `RenderComponent`.
        renderComponent.node.physicsBody = physicsComponent.physicsBody
        
        // Connect the `RenderComponent` and `ShadowComponent` to the `AnimationComponent`.
        renderComponent.node.addChild(animationComponent.node)
        
    }
    
    static func loadResources(withCompletionHandler completionHandler: @escaping () -> ()) {
        // Load `TaskBot`s shared assets.
        super.loadSharedAssets()
        
        let blueSoulAtlasNames = [
            "BlueSoul"
        ]
        
        /*
            Preload all of the texture atlases for `FlyingBot`. This improves
            the overall loading speed of the animation cycles for this character.
        */
        SKTextureAtlas.preloadTextureAtlasesNamed(blueSoulAtlasNames) { error, blueSoulAtlases in
            if let error = error {
                fatalError("One or more texture atlases could not be found: \(error)")
            }
            /*
                This closure sets up all of the `FlyingBot` animations
                after the `FlyingBot` texture atlases have finished preloading.
            */
            soulAnimations = [:]
            soulAnimations![.walkForward] = AnimationComponent.animationsFromAtlas(atlas: blueSoulAtlases[0], withImageIdentifier: "blueSoul", forAnimationState: .walkForward, bodyActionName: "blueSoulBody")
            
//            badAnimations = [:]
//            badAnimations![.walkForward] = AnimationComponent.animationsFromAtlas(atlas: flyingBotAtlases[2], withImageIdentifier: "FlyingBotBadWalk", forAnimationState: .walkForward, bodyActionName: "FlyingBotBob", shadowActionName: "FlyingBotShadowScale")
//            badAnimations![.attack] = AnimationComponent.animationsFromAtlas(atlas: flyingBotAtlases[3], withImageIdentifier: "FlyingBotBadAttack", forAnimationState: .attack, bodyActionName: "ZappedShake", shadowActionName: "ZappedShadowShake")
//            badAnimations![.zapped] = AnimationComponent.animationsFromAtlas(atlas: flyingBotAtlases[4], withImageIdentifier: "FlyingBotZapped", forAnimationState: .zapped, bodyActionName: "ZappedShake", shadowActionName: "ZappedShadowShake")
//
            // Invoke the passed `completionHandler` to indicate that loading has completed.
            completionHandler()
        }
    }
    
    // MARK: ContactableType

    override func contactWithEntityDidBegin(_ entity: GKEntity) {
        super.contactWithEntityDidBegin(entity)
        let gameState = GameplayLogic.sharedInstance()
        
        if !gameState.isFull{
            
            self.removeSoul()
            gameState.addSouls(type: "blue")
        }
        else {
            print("you can't take more souls")
        }
 
    }

}
