//
//  Reaper.swift
//  ReapersDayOff
//
//  Created by Oreste Leone on 09/05/22.
//

import SpriteKit
import GameplayKit
import GameController

class Reaper: GKEntity, ChargeComponentDelegate, SoulsContainerComponentDelegate, ContactNotifiableType  /*, ResourceLoadableType */{

    
    
    // MARK: Static properties
    
    /// The size to use for the `Reaper`s animation textures.
    static var textureSize = CGSize(width: 128.0, height: 128.0)
    
    
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
    
    var walkedDistance = [MovementComponent().nextTranslation]

    
  

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
        
        let soulsContainerComponent = SoulsContainerComponent(charge: GameplayConfiguration.Reaper.initialContainer, maximumCharge: GameplayConfiguration.Reaper.maximumContainer, displaysChargeBar: true)
        soulsContainerComponent.delegate = self
        addComponent(soulsContainerComponent)
        
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
    
    // MARK: Souls container component delegate

    func soulsContainerComponentDidLoseCharge(soulsContainerComponent: SoulsContainerComponent) {
        
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
            .Gate,
            .Enemy,
            .Soul
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
        let shared = GameplayLogic.sharedInstance()
        if let gate = entity as? Gate {

            if let chargeComp = component(ofType: ChargeComponent.self) {
                if let containerComp = component(ofType: SoulsContainerComponent.self) {
                switch gate.name {
                case "red":
                    chargeComp.addCharge(chargeToAdd: shared.timeForDeposit(souls: shared.redSouls))
                    containerComp.loseCharge(chargeToLose: Double(shared.redSouls))
                case "green":
                    chargeComp.addCharge(chargeToAdd: shared.timeForDeposit(souls: shared.greenSouls)*2)
                    containerComp.loseCharge(chargeToLose: Double(shared.greenSouls))
                case "blue":
                    chargeComp.addCharge(chargeToAdd: shared.timeForDeposit(souls: shared.blueSouls))
                    containerComp.loseCharge(chargeToLose: Double(shared.blueSouls))
                default:
                    fatalError("Unknown Gate type")
                    }
                }
            }
            if let scene = renderComponent.node.scene {
                switch gate.name {
                case "red":
                    if let gem = scene.childNode(withName: "//redFloor") as? SKSpriteNode {
                        gem.run(SKAction(named: "redGem")!)
                    }
                case "green":
                    if let gem = scene.childNode(withName: "//greenFloor") as? SKSpriteNode {
                        gem.run(SKAction(named: "greenGem")!)
                    }
                case "blue":
                    if let gem = scene.childNode(withName: "//blueFloor") as? SKSpriteNode {
                        gem.run(SKAction(named: "blueGem")!)
                    }
                default:
                    fatalError("Unknown Gate type")
                }
            }
            shared.deposit(type: gate.name)
            if HapticUtility.enabled {
                if GCController.current != nil {
                    HapticUtility.playHapticsFile(named: "Oscillate")
                } else {
                    let hap = UINotificationFeedbackGenerator()
                    hap.notificationOccurred(.success)
    //                let haptic = UIImpactFeedbackGenerator(style: .light)
    //                haptic.impactOccurred()
                }
            }
//            collectedSouls +=
        }
        
        if entity is HeartReaper {
            if let chargeComp = component(ofType: ChargeComponent.self) {
                if let containerComp = component(ofType: SoulsContainerComponent.self) {
                    chargeComp.loseCharge(chargeToLose: 8.0)
                    if (shared.redSouls % 2 == 0)
                    {
                        containerComp.loseCharge(chargeToLose: Double(shared.redSouls / 2))
                    }
                    else
                    {
                        containerComp.loseCharge(chargeToLose: (Double(shared.redSouls / 2) + 1.0))

                    }
                    if (shared.blueSouls % 2 == 0)
                    {
                        containerComp.loseCharge(chargeToLose: Double(shared.blueSouls / 2))
                    }
                    else
                    {
                        containerComp.loseCharge(chargeToLose: (Double(shared.blueSouls / 2) + 1.0))

                    }
                    if (shared.greenSouls % 2 == 0)
                    {
                        containerComp.loseCharge(chargeToLose: Double(shared.greenSouls / 2))
                    }
                    else
                    {
                        containerComp.loseCharge(chargeToLose: (Double(shared.greenSouls / 2) + 1.0))

                    }
                }
            }
                
        }
        
        if entity is RedSoul {
        if let containerComp = component(ofType: SoulsContainerComponent.self) {
            containerComp.addCharge(chargeToAdd: 1.0)
            }
        }
        
        if entity is BlueSoul {
        if let containerComp = component(ofType: SoulsContainerComponent.self) {
            containerComp.addCharge(chargeToAdd: 1.0)
            }
        }
        
        if entity is GreenSoul {
        if let containerComp = component(ofType: SoulsContainerComponent.self) {
            containerComp.addCharge(chargeToAdd: 1.0)
            }
        }
    }
    
    
    func contactWithEntityDidEnd(_ entity: GKEntity) {
        
    }
}
