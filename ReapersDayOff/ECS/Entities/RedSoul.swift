//
//  RedSoul.swift
//  ReapersDayOff
//
//  Created by Maria Smirnova on 05/05/22.
//

import SpriteKit
import GameplayKit


class RedSoul: Soul {
    
    static var textureSize = CGSize(width: 144.0, height: 144.0)
    
    static var soulAnimations: [AnimationState: [CompassDirection: Animation]]?
    
     var soulAnimations: [AnimationState: [CompassDirection: Animation]] {
        return RedSoul.soulAnimations!
    }
    
    required override init(pathPoints: [CGPoint]) {
        super.init(pathPoints: pathPoints)
        RedSoul.loadResources() {
            
        }
        // Determine initial animations and charge based on the initial state of the bot.
        let initialAnimations: [AnimationState: [CompassDirection: Animation]]
//        let initialCharge: Double
        
//            guard let soulAnimations = RedSoul.soulAnimations else {
//                fatalError("Attempt to access FlyingBot.badAnimations before they have been loaded.")
//            }
            initialAnimations = soulAnimations
//            initialCharge = GameplayConfiguration.RedSoul.maximumCharge
        

        // Create components that define how the entity looks and behaves.
        let renderComponent = RenderComponent()
        addComponent(renderComponent)

        let orientationComponent = OrientationComponent()
        addComponent(orientationComponent)

//        let shadowComponent = ShadowComponent(texture: FlyingBot.shadowTexture, size: FlyingBot.shadowSize, offset: FlyingBot.shadowOffset)
//        addComponent(shadowComponent)

        let animationComponent = AnimationComponent(textureSize: RedSoul.textureSize, animations: initialAnimations)
        addComponent(animationComponent)

//        let intelligenceComponent = IntelligenceComponent(states: [
//            TaskBotAgentControlledState(entity: self),
//            FlyingBotPreAttackState(entity: self),
//            FlyingBotBlastState(entity: self),
//            TaskBotZappedState(entity: self)
//        ])
//        addComponent(intelligenceComponent)

        let physicsBody = SKPhysicsBody(circleOfRadius: GameplayConfiguration.Soul.physicsBodyRadius, center: GameplayConfiguration.Soul.physicsBodyOffset)
        let physicsComponent = PhysicsComponent(physicsBody: physicsBody, colliderType: .Soul)
        addComponent(physicsComponent)
        
//        let chargeComponent = ChargeComponent(charge: initialCharge, maximumCharge: GameplayConfiguration.RedSoul.maximumCharge)
//        chargeComponent.delegate = self
//        addComponent(chargeComponent)

        // Connect the `PhysicsComponent` and the `RenderComponent`.
        renderComponent.node.physicsBody = physicsComponent.physicsBody
        
        // Connect the `RenderComponent` and `ShadowComponent` to the `AnimationComponent`.
        renderComponent.node.addChild(animationComponent.node)
//        animationComponent.shadowNode = shadowComponent.node
        
        // Specify the offset for beam targeting.
//        beamTargetOffset = GameplayConfiguration.RedSoul.beamTargetOffset
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func loadResources(withCompletionHandler completionHandler: @escaping () -> ()) {
        // Load `TaskBot`s shared assets.
        super.loadSharedAssets()
        
        let redSoulAtlasNames = [
            "redSoul"
        ]
        
        /*
            Preload all of the texture atlases for `FlyingBot`. This improves
            the overall loading speed of the animation cycles for this character.
        */
        SKTextureAtlas.preloadTextureAtlasesNamed(redSoulAtlasNames) { error, redSoulAtlases in
            if let error = error {
                fatalError("One or more texture atlases could not be found: \(error)")
            }
            /*
                This closure sets up all of the `FlyingBot` animations
                after the `FlyingBot` texture atlases have finished preloading.
            */
            soulAnimations = [:]
            soulAnimations![.walkForward] = AnimationComponent.animationsFromAtlas(atlas: redSoulAtlases[0], withImageIdentifier: "redSoul", forAnimationState: .walkForward)
//            badAnimations = [:]
//            badAnimations![.walkForward] = AnimationComponent.animationsFromAtlas(atlas: flyingBotAtlases[2], withImageIdentifier: "FlyingBotBadWalk", forAnimationState: .walkForward, bodyActionName: "FlyingBotBob", shadowActionName: "FlyingBotShadowScale")
//            badAnimations![.attack] = AnimationComponent.animationsFromAtlas(atlas: flyingBotAtlases[3], withImageIdentifier: "FlyingBotBadAttack", forAnimationState: .attack, bodyActionName: "ZappedShake", shadowActionName: "ZappedShadowShake")
//            badAnimations![.zapped] = AnimationComponent.animationsFromAtlas(atlas: flyingBotAtlases[4], withImageIdentifier: "FlyingBotZapped", forAnimationState: .zapped, bodyActionName: "ZappedShake", shadowActionName: "ZappedShadowShake")
//
            // Invoke the passed `completionHandler` to indicate that loading has completed.
            completionHandler()
        }
    }
}
