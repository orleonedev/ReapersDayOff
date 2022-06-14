//
//  HeartReaper.swift
//  ReapersDayOff
//
//  Created by Maria Smirnova on 20/05/22.
//

import SpriteKit
import GameplayKit
import GameController

class HeartReaper: Enemy {
    
    static var textureSize = CGSize(width: 128.0, height: 128.0)
    
    static var enemyAnimations: [AnimationState: [CompassDirection: Animation]]?
    
    static var appearTextures: [CompassDirection: SKTexture]?
    
    var enemyAnimations: [AnimationState: [CompassDirection: Animation]] {
        return HeartReaper.enemyAnimations!
    }
    
    override init(){
        super.init()
        
        // Create components that define how the entity looks and behaves.
        createRenderingComponents()
        
        let orientationComponent = OrientationComponent()
        addComponent(orientationComponent)
        
        let intelligenceComponent = IntelligenceComponent(states: [
            HeartReaperAppearState(entity: self),
            EnemyAgentControlledState(entity: self),
            HeartReaperDisappearState(entity: self)
        ])
        addComponent(intelligenceComponent)
        
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(pathPoints: [CGPoint], mandate: EnemyMandate) {
        fatalError("init(pathPoints:mandate:color:) has not been implemented")
    }
    
    
    func createRenderingComponents(){
        
        let renderComponent = RenderComponent()
        addComponent(renderComponent)
        
        
        let initialAnimations: [AnimationState: [CompassDirection: Animation]]
        initialAnimations = enemyAnimations
        let animationComponent = AnimationComponent(textureSize: HeartReaper.textureSize, animations: initialAnimations)
        addComponent(animationComponent)
        
        let physicsBody = SKPhysicsBody(circleOfRadius: GameplayConfiguration.Enemy.physicsBodyRadius, center: GameplayConfiguration.Enemy.physicsBodyOffset)
        
        let physicsComponent = PhysicsComponent(physicsBody: physicsBody, colliderType: .Enemy)
        
        addComponent(physicsComponent)
        
        // Connect the `PhysicsComponent` and the `RenderComponent`.
        renderComponent.node.physicsBody = physicsComponent.physicsBody
        
        // Connect the `RenderComponent` and `ShadowComponent` to the `AnimationComponent`.
        renderComponent.node.addChild(animationComponent.node)
        
    }
    
    static func loadResources(withCompletionHandler completionHandler: @escaping () -> ()) {
        
        
        loadMiscellaneousAssets()
        
        let EnemyAtlasNames = [
            "Enemy"
        ]
        
        /*
         Preload all of the texture atlases for `PlayerBot`. This improves
         the overall loading speed of the animation cycles for this character.
         */
        SKTextureAtlas.preloadTextureAtlasesNamed(EnemyAtlasNames) { error, EnemyAtlases in
            if let error = error {
                fatalError("One or more texture atlases could not be found: \(error)")
            }
            
            /*
             This closure sets up all of the `PlayerBot` animations
             after the `PlayerBot` texture atlases have finished preloading.
             
             Store the first texture from each direction of the `PlayerBot`'s idle animation,
             for use in the `PlayerBot`'s "appear"  state.
             */
            
            // Set up all of the `PlayerBot`s animations.
            enemyAnimations = [:]
            enemyAnimations![.walkForward] = AnimationComponent.animationsFromAtlas(atlas: EnemyAtlases[0], withImageIdentifier: "enemy", forAnimationState: .walkForward, bodyActionName: "heartReaperBody")
            enemyAnimations![.walkBackward] = AnimationComponent.animationsFromAtlas(atlas: EnemyAtlases[0], withImageIdentifier: "enemy", forAnimationState: .walkBackward, bodyActionName: "heartReaperBody", playBackwards: true)
            //            animations![.inactive] = AnimationComponent.animationsFromAtlas(atlas: playerBotAtlases[2], withImageIdentifier: "PlayerBotInactive", forAnimationState: .inactive)
            //            animations![.hit] = AnimationComponent.animationsFromAtlas(atlas: playerBotAtlases[3], withImageIdentifier: "PlayerBotHit", forAnimationState: .hit, repeatTexturesForever: false)
            
            // Invoke the passed `completionHandler` to indicate that loading has completed.
            completionHandler()
        }
    }
    
    static func purgeResources() {
        appearTextures = nil
        animations = nil
    }
    
    
    class func loadMiscellaneousAssets() {
        
        ColliderType.definedCollisions[.Enemy] = [
            .Reaper,
            .Obstacle,
            .Soul
        ]
        
        ColliderType.requestedContactNotifications[.Enemy] = [
            .Reaper
        ]
    }
    
    // MARK: ContactableType
    
    override func contactWithEntityDidBegin(_ entity: GKEntity) {
        super.contactWithEntityDidBegin(entity)
        
        let gameState = GameplayLogic.sharedInstance()
        
        gameState.heartReaperHit += 1
        
        
        if GCController.current != nil {
            HapticUtility.playHapticsFile(named: "DamageTaken")
        } else {
            let hap = UINotificationFeedbackGenerator()
            hap.notificationOccurred(.error)
//            let hap = UIImpactFeedbackGenerator(style: .heavy)
//            hap.impactOccurred()
//            let haptic = UIImpactFeedbackGenerator(style: .light)
//            haptic.impactOccurred()
        }
        gameState.loseSouls()
        // add scene.entities.remove(self) when seconds finish
        
        // move to another function
        if let intel = component(ofType: IntelligenceComponent.self) {
            intel.stateMachine.enter(HeartReaperDisappearState.self)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        
                self.removeHeartReaper()
            }
            
        }
    }
    
    func removeHeartReaper() {
        if let scene = renderComponent.node.scene as? RDOLevelScene {
            scene.entities.remove(self)
            scene.resetEnemyTimer = true
        }
        renderComponent.node.removeFromParent()
        GameplayLogic.sharedInstance().enemyOnStage = false
        
    }
}
