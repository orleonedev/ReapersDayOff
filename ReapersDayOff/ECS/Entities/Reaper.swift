//
//  Reaper.swift
//  ReapersDayOff
//
//  Created by Oreste Leone on 09/05/22.
//

import SpriteKit
import GameplayKit

class Reaper: GKEntity, ChargeComponentDelegate, ContactNotifiableType  /*, ResourceLoadableType */{
    
    // MARK: Static properties
    
    /// The size to use for the `Reaper`s animation textures.
    static var textureSize = CGSize(width: 120.0, height: 120.0)
    
    
    /// The animations to use for a `PlayerBot`.
    static var animations: [AnimationState: [CompassDirection: Animation]]?

    /// Textures used by `PlayerBotAppearState` to show a `PlayerBot` appearing in the scene.
    static var appearTextures: [CompassDirection: SKTexture]?
    
    
    // MARK: Properties
    
    var isPoweredDown = false
    
    /// The agent used when pathfinding to the `PlayerBot`.
    let agent: GKAgent2D
    
    var isFleeable: Bool {
        guard let currentState = component(ofType: IntelligenceComponent.self)?.stateMachine.currentState else { return false }

        switch currentState {
            case is ReaperPlayerControlledState, is ReaperFleeState:
                return true

            default:
                return false
        }
    }
    
    var position: CGPoint
    
    /// The `RenderComponent` associated with this `PlayerBot`.
    var renderComponent: RenderComponent {
        guard let renderComponent = component(ofType: RenderComponent.self) else { fatalError("A Reaper must have an RenderComponent.") }
        return renderComponent
    }

    // MARK: Initializers
    
    override init() {
        agent = GKAgent2D()
        agent.radius = GameplayConfiguration.Reaper.agentRadius
        self.position = CGPoint()
        
        super.init()
        
        /*
            Add the `RenderComponent` before creating the `IntelligenceComponent` states,
            so that they have the render node available to them when first entered
            (e.g. so that `PlayerBotAppearState` can add a shader to the render node).
        */
        let renderComponent = RenderComponent()
        addComponent(renderComponent)
        
        let orientationComponent = OrientationComponent()
        addComponent(orientationComponent)
        
        let inputComponent = InputComponent()
        addComponent(inputComponent)

        // `PhysicsComponent` provides the `PlayerBot`'s physics body and collision masks.
        let physicsComponent = PhysicsComponent(physicsBody: SKPhysicsBody(circleOfRadius: GameplayConfiguration.Reaper.physicsBodyRadius, center: GameplayConfiguration.Reaper.physicsBodyOffset), colliderType: .Reaper)
        addComponent(physicsComponent)

        // Connect the `PhysicsComponent` and the `RenderComponent`.
        renderComponent.node.physicsBody = physicsComponent.physicsBody
        
        // `MovementComponent` manages the movement of a `PhysicalEntity` in 2D space, and chooses appropriate movement animations.
        let movementComponent = MovementComponent()
        addComponent(movementComponent)
        
        // `ChargeComponent` manages the `PlayerBot`'s charge (i.e. health).
        let chargeComponent = ChargeComponent(charge: GameplayConfiguration.Reaper.initialCharge, maximumCharge: GameplayConfiguration.Reaper.maximumCharge, displaysChargeBar: true)
        chargeComponent.delegate = self
        addComponent(chargeComponent)
        
        // `AnimationComponent` tracks and vends the animations for different entity states and directions.
        guard let animations = Reaper.animations else {
            fatalError("Attempt to access Reaper.animations before they have been loaded.")
        }
        let animationComponent = AnimationComponent(textureSize: Reaper.textureSize, animations: animations)
        addComponent(animationComponent)
        
        // Connect the `RenderComponent` and `ShadowComponent` to the `AnimationComponent`.
        renderComponent.node.addChild(animationComponent.node)
        
        
        // `BeamComponent` implements the beam that a `PlayerBot` fires at "bad" `TaskBot`s.
//        let beamComponent = BeamComponent()
//        addComponent(beamComponent)
        
        let intelligenceComponent = IntelligenceComponent(states: [
            ReaperAppearState(entity: self),
            ReaperPlayerControlledState(entity: self),
            ReaperFleeState(entity: self),
            ReaperRechargingState(entity: self)
        ])
        addComponent(intelligenceComponent)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Charge component delegate
    
    func chargeComponentDidLoseCharge(chargeComponent: ChargeComponent) {
//        if let intelligenceComponent = component(ofType: IntelligenceComponent.self) {
//            if !chargeComponent.hasCharge {
//                isPoweredDown = true
//                intelligenceComponent.stateMachine.enter(ReaperRechargingState.self)
//            }
//            else {
//                intelligenceComponent.stateMachine.enter(ReaperFleeState.self)
//            }
//        }
    }
    
    // MARK: ResourceLoadableType
    
    static var resourcesNeedLoading: Bool {
        return appearTextures == nil || animations == nil
    }
    
    static func loadResources(withCompletionHandler completionHandler: @escaping () -> ()) {
            loadMiscellaneousAssets()
            
            let ReaperAtlasNames = [
            "ReaperIdle",
            "ReaperWalk"
        ]
        
        /*
            Preload all of the texture atlases for `PlayerBot`. This improves
            the overall loading speed of the animation cycles for this character.
        */
        SKTextureAtlas.preloadTextureAtlasesNamed(ReaperAtlasNames) { error, ReaperAtlases in
            if let error = error {
                fatalError("One or more texture atlases could not be found: \(error)")
            }

            /*
                This closure sets up all of the `PlayerBot` animations
                after the `PlayerBot` texture atlases have finished preloading.

                Store the first texture from each direction of the `PlayerBot`'s idle animation,
                for use in the `PlayerBot`'s "appear"  state.
            */
            appearTextures = [:]
            for orientation in CompassDirection.allDirections {
                appearTextures![orientation] = AnimationComponent.firstTextureForOrientation(compassDirection: orientation, inAtlas: ReaperAtlases[0], withImageIdentifier: "reaperIdle")
            }
            
            // Set up all of the `PlayerBot`s animations.
            animations = [:]
            animations![.idle] = AnimationComponent.animationsFromAtlas(atlas: ReaperAtlases[0], withImageIdentifier: "reaperIdle", forAnimationState: .idle)
            animations![.walkForward] = AnimationComponent.animationsFromAtlas(atlas: ReaperAtlases[1], withImageIdentifier: "reaperWalk", forAnimationState: .walkForward)
            animations![.walkBackward] = AnimationComponent.animationsFromAtlas(atlas: ReaperAtlases[1], withImageIdentifier: "reaperWalk", forAnimationState: .walkBackward, playBackwards: true)
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
        
        ColliderType.definedCollisions[.Reaper] = [
            .Reaper,
            .Soul,
            .Obstacle
        ]
        
        ColliderType.requestedContactNotifications[.Reaper] = [
            .Gate
        ]
    }

    // MARK: Convenience
    
    /// Sets the `PlayerBot` `GKAgent` position to match the node position (plus an offset).
    func updateAgentPositionToMatchNodePosition() {
        // `renderComponent` is a computed property. Declare a local version so we don't compute it multiple times.
        let renderComponent = self.renderComponent
        
        let agentOffset = GameplayConfiguration.Reaper.agentOffset
        agent.position = SIMD2<Float>(x: Float(renderComponent.node.position.x + agentOffset.x), y: Float(renderComponent.node.position.y + agentOffset.y))
    }
    
    func contactWithEntityDidBegin(_ entity: GKEntity) {
        if let gate = entity as? Gate {
            let shared = GameplayLogic.sharedInstance()
            
            
            if let chargeComp = component(ofType: ChargeComponent.self) {
                
                switch gate.name {
                case "red":
                    chargeComp.addCharge(chargeToAdd: shared.timeForDeposit(souls: shared.redSouls))
                case "green":
                    chargeComp.addCharge(chargeToAdd: shared.timeForDeposit(souls: shared.greenSouls))
                case "blue":
                    chargeComp.addCharge(chargeToAdd: shared.timeForDeposit(souls: shared.blueSouls))
                default:
                    fatalError("Unknown Gate type")
                }
            }
            
            shared.deposit(type: gate.name)
        }
        
    }
    
    func contactWithEntityDidEnd(_ entity: GKEntity) {
        
    }
}
