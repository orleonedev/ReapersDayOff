//
//  RDOStageOneScene.swift
//  ReapersDayOff
//
//  Created by Claudio Silvestri on 04/05/22.
//


/*
    Abstract:
    `LevelScene` is an `SKScene` representing a playable level in the game. `WorldLayer` is an enumeration that represents the different z-indexed layers of a `LevelScene`.
*/

import SpriteKit
import GameplayKit

/// The names and z-positions of each layer in a level's world.
enum WorldLayer: CGFloat {
    // The zPosition offset to use per character (`PlayerBot` or `TaskBot`).
    static let zSpacePerCharacter: CGFloat = 1
    
    // Specifying `AboveCharacters` as 1000 gives room for 9 enemies on a level.
    case board = -100, shadows = -50, obstacles = -25, characters = 0,  top = 1600
    
    // The expected name for this node in the scene file.
    var nodeName: String {
        switch self {
            case .board: return "board"
           // case .debug: return "debug"
            case .shadows: return "shadows"
            case .obstacles: return "obstacles"
            case .characters: return "characters"
//            case .aboveCharacters: return "above_characters"
            case .top: return "top"
        }
    }
    
    // The full path to this node, for use with `childNode(withName name:)`.
    var nodePath: String {
        return "/world/\(nodeName)"
    }
    

    static var allLayers = [board, shadows, obstacles, characters, top]
}



class RDOLevelScene: RDOBaseScene, SKPhysicsContactDelegate {
    
    // MARK: Properties
    var test = 0

    let reaper = Reaper()
    var isSpeeding = false 
    var redGate: Gate?
    var blueGate: Gate?
    var greenGate: Gate?
    var enemy: HeartReaper?
    var resetEnemyTimer: Bool = false
    /// Stores a reference to the root nodes for each world layer in the scene.
    var worldLayerNodes = [WorldLayer: SKNode]()
    
    var worldNode: SKNode {
        return childNode(withName: "world")!
    }

    var entities = Set<GKEntity>()
    
    var lastUpdateTimeInterval: TimeInterval = 0
    let maximumUpdateDeltaTime: TimeInterval = 1.0 / 60.0
    
//    var levelConfiguration: RDOLevelConfiguration!
    
    lazy var stateMachine: GKStateMachine = GKStateMachine(states: [
        RDOLevelSceneActiveState(levelScene: self),
        RDOLevelScenePauseState(levelScene: self),
        RDOLevelSceneGameoverState(levelScene: self),
        RDOLevelSceneTutorialState(levelScene: self),
    ])
    
    let score = SKLabelNode(text: "0")
    
    let bluecounter = SKLabelNode(text: "0")
    let redcounter = SKLabelNode(text: "0")
    let greencounter = SKLabelNode(text: "0")
    
    
    let blueHUD = SKSpriteNode(texture: SKTexture(imageNamed: "blueSoul_6_00"), color: UIColor.blue, size: CGSize(width: 0, height: 0))
    let redHUD = SKSpriteNode(texture: SKTexture(imageNamed: "redSoul_6_00"), color: UIColor.red, size: CGSize(width: 0, height: 0))
    let greenHUD = SKSpriteNode(texture: SKTexture(imageNamed: "greenSoul_6_00"), color: UIColor.green, size: CGSize(width: 0, height: 0))
    
    //bar indicating the number of souls transported
//  var soulsContainer = SKSpriteNode(texture: nil, color: UIColor.yellow, size: CGSize(width: 0, height: 0))

//    var stamina = SKSpriteNode(texture: SKTexture(imageNamed: "staminaBlack"), color: UIColor.black, size: CGSize(width: 0, height: 0))

    let pauseButton = SKSpriteNode(texture: SKTexture(imageNamed: "pauseBlack"), color: UIColor.gray, size: CGSize(width: 0, height: 0))
    
//    let soulsContainerTexture = SKSpriteNode(texture: SKTexture(imageNamed: "hudBlack"), color: UIColor.gray, size: CGSize(width: 0, height: 0))
    
    override var overlay: RDOSceneOverlay? {
        didSet {
            // Ensure that focus changes are only enabled when the `overlay` is present.
            focusChangesEnabled = (overlay != nil)
        }
    }
  
    // MARK: Pathfinding

    
    lazy var obstacleSpriteNodes: [SKSpriteNode] = self["world/obstacles/*"] as! [SKSpriteNode]
     
    lazy var polygonObstacles: [GKPolygonObstacle] = SKNode.obstacles(fromNodePhysicsBodies: self.obstacleSpriteNodes)
     
    let graph: GKObstacleGraph = GKObstacleGraph(obstacles: [], bufferRadius: GameplayConfiguration.Soul.pathfindingGraphBufferRadius)


    
    // MARK: Rule State
    
    var levelStateSnapshot: RDOLevelStateSnapshot?
    
    func entitySnapshotForEntity(entity: GKEntity) -> EntitySnapshot? {
        // Create a snapshot of the level's state if one does not already exist for this update cycle.
        if levelStateSnapshot == nil {
            levelStateSnapshot = RDOLevelStateSnapshot(scene: self)
        }
        
        // Find and return the entity snapshot for this entity.
        return levelStateSnapshot!.entitySnapshots[entity]
    }
    // MARK: Component Systems
    
    lazy var componentSystems: [GKComponentSystem] = {
        let soulAgentSystem = GKComponentSystem(componentClass: SoulAgent.self)
        let enemyAgentSystem = GKComponentSystem(componentClass: EnemyAgent.self)
        let animationSystem = GKComponentSystem(componentClass: AnimationComponent.self)
        let chargeSystem = GKComponentSystem(componentClass: ChargeComponent.self)
        let intelligenceSystem = GKComponentSystem(componentClass: IntelligenceComponent.self)
        let movementSystem = GKComponentSystem(componentClass: MovementComponent.self)

        let rulesSystem = GKComponentSystem(componentClass: RulesComponent.self)

        // The systems will be updated in order. This order is explicitly defined to match assumptions made within components.
        return [rulesSystem, intelligenceSystem, movementSystem, soulAgentSystem, enemyAgentSystem, chargeSystem, animationSystem]
    }()
    
    
    
    // MARK: Initializers
    
//    deinit {
//        unregisterForPauseNotifications()
//    }

    // MARK: Scene Life Cycle
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Load the level's configuration from the level data file.
//        levelConfiguration = RDOLevelConfiguration(fileName: sceneManager.currentSceneMetadata!.fileName)
        /// physics box con offset ma c'è il problema della profondità di unveil
//        let columns = obstacleSpriteNodes.filter {$0.name == "Pillar"}
//        if columns.count == 3 {
//            let columnsSize = CGSize(width: columns[0].size.width, height: columns[0].size.height - 64)
//            columns[0].physicsBody = SKPhysicsBody(rectangleOf: columnsSize, center: CGPoint(x: 0.0, y: -32))
//            columns[0].physicsBody?.categoryBitMask = ColliderType.Obstacle.categoryMask
//            columns[0].physicsBody?.collisionBitMask = ColliderType.Obstacle.collisionMask
//            columns[0].physicsBody?.contactTestBitMask = ColliderType.Obstacle.contactMask
//            columns[0].physicsBody?.isDynamic = false
//
//            columns[1].physicsBody = SKPhysicsBody(rectangleOf: columnsSize, center: CGPoint(x: 0.0, y: -32))
//            columns[1].physicsBody?.categoryBitMask = ColliderType.Obstacle.categoryMask
//            columns[1].physicsBody?.collisionBitMask = ColliderType.Obstacle.collisionMask
//            columns[1].physicsBody?.contactTestBitMask = ColliderType.Obstacle.contactMask
//            columns[1].physicsBody?.isDynamic = false
//
//            columns[2].physicsBody = SKPhysicsBody(rectangleOf: columnsSize, center: CGPoint(x: 0.0, y: -32))
//            columns[2].physicsBody?.categoryBitMask = ColliderType.Obstacle.categoryMask
//            columns[2].physicsBody?.collisionBitMask = ColliderType.Obstacle.collisionMask
//            columns[2].physicsBody?.contactTestBitMask = ColliderType.Obstacle.contactMask
//            columns[2].physicsBody?.isDynamic = false
//        }
        // Set up the path finding graph with all polygon obstacles.
        graph.addObstacles(polygonObstacles)
        
        // Register for notifications about the app becoming inactive.
//        registerForPauseNotifications()

        // Create references to the base nodes that define the different layers of the scene.
        loadWorldLayers()

        // Add a `PlayerBot` for the player.
        beamInReaper()
        
        
        // Gravity will be in the negative z direction; there is no x or y component.
        physicsWorld.gravity = CGVector.zero
        
        // The scene will handle physics contacts itself.
        physicsWorld.contactDelegate = self
        
        // Start tutorial
        
        if !UserDefaults.standard.bool(forKey: "tutorial")
        {
            UserDefaults.standard.set(true, forKey: "tutorial")
            stateMachine.enter(RDOLevelSceneTutorialState.self)
        } else {
            stateMachine.enter(RDOLevelSceneActiveState.self)
        }

        
        // Setup score label
        score.zPosition = WorldLayer.top.rawValue
        score.fontColor = SKColor.white
        score.fontName = GameplayConfiguration.Timer.fontName
        score.horizontalAlignmentMode = .right
        score.verticalAlignmentMode = .top
        scaleScoreNode()
        camera!.addChild(score)
        
        let counterHUDSize = CGSize(width: frame.height / 15, height: frame.height / 15)
        blueHUD.size = counterHUDSize
        blueHUD.zPosition = WorldLayer.top.rawValue
        blueHUD.anchorPoint.y = 1
        blueHUD.anchorPoint.x = 0
        scaleBlueHUD()
        camera!.addChild(blueHUD)
        
        bluecounter.zPosition = WorldLayer.top.rawValue
        bluecounter.fontColor = SKColor.black
        bluecounter.fontName = GameplayConfiguration.Timer.fontName
        bluecounter.horizontalAlignmentMode = .left
        bluecounter.verticalAlignmentMode = .top
        scaleBlueCounterNode()
        camera!.addChild(bluecounter)
        
        greenHUD.size = counterHUDSize
        greenHUD.zPosition = WorldLayer.top.rawValue
        greenHUD.anchorPoint.y = 1
        greenHUD.anchorPoint.x = 0
        scaleGreenHUD()
        camera!.addChild(greenHUD)
        
        greencounter.zPosition = WorldLayer.top.rawValue
        greencounter.fontColor = SKColor.black
        greencounter.fontName = GameplayConfiguration.Timer.fontName
        greencounter.horizontalAlignmentMode = .left
        greencounter.verticalAlignmentMode = .top
        scaleGreenCounterNode()
        camera!.addChild(greencounter)
        
        redHUD.size = counterHUDSize
        redHUD.anchorPoint.y = 1
        redHUD.anchorPoint.x = 0
        redHUD.zPosition = WorldLayer.top.rawValue
        scaleRedHUD()
        camera!.addChild(redHUD)
        
        redcounter.zPosition = WorldLayer.top.rawValue
        redcounter.fontColor = SKColor.black
        redcounter.fontName = GameplayConfiguration.Timer.fontName
        redcounter.horizontalAlignmentMode = .left
        redcounter.verticalAlignmentMode = .top
        scaleRedCounterNode()
        camera!.addChild(redcounter)
        
        let buttonSize = CGSize(width: frame.height / 15, height: frame.height / 15)
        pauseButton.size = buttonSize
        pauseButton.anchorPoint.y = 1
        pauseButton.zPosition = WorldLayer.top.rawValue
        scalePauseButton()
        camera!.addChild(pauseButton)
        
        
        // A convenience function to find node locations given a set of node names.
        func nodePointsFromNodeNames(nodeNames: [String]) -> [CGPoint] {
            let charactersNode = childNode(withName: WorldLayer.characters.nodePath)!
            return nodeNames.map {
                charactersNode[$0].first!.position
            }
        }
        
        redGate = Gate(type: "red")
        blueGate = Gate(type: "blue")
        greenGate = Gate(type: "green")
        
        
        putGateInScene(gate: redGate!, pos: 1)
        putGateInScene(gate: blueGate!, pos: 2)
        putGateInScene(gate: greenGate!, pos: 3)
        
        spawnSoul()
        spawnSoul()
        spawnSoul()
        
        
        #if os(iOS)
        /*
            Set up iOS touch controls. The player's `nativeControlInputSource`
            is added to the scene by the `BaseSceneTouchEventForwarding` extension.
        */
        addTouchInputToScene()
        touchControlInputNode.hideThumbStickNodes = sceneManager.gameInput.isGameControllerConnected
            
        #endif
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        
        /*
            A `LevelScene` needs to update its camera constraints to match the new
            aspect ratio of the window when the window size changes.
        */
        setCameraConstraints()
        
        // As the scene may now have a different height, scale and position the timer node appropriately.
        
        scaleScoreNode()
        scaleBlueHUD()
        scaleBlueCounterNode()
        scaleGreenHUD()
        scaleGreenCounterNode()
        scaleRedHUD()
        scaleRedCounterNode()
        scalePauseButton()

    }
    
    // MARK: SKScene Processing
    
    /// Called before each frame is rendered.
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        // Don't perform any updates if the scene isn't in a view.
        guard view != nil else { return }
        
        // Calculate the amount of time since `update` was last called.
        var deltaTime = currentTime - lastUpdateTimeInterval
        
        // If more than `maximumUpdateDeltaTime` has passed, clamp to the maximum; otherwise use `deltaTime`.
        deltaTime = deltaTime > maximumUpdateDeltaTime ? maximumUpdateDeltaTime : deltaTime
        
        // The current time will be used as the last update time in the next execution of the method.
        lastUpdateTimeInterval = currentTime
        
        // Get rid of the now-stale `LevelStateSnapshot` if it exists. It will be regenerated when next needed.
        levelStateSnapshot = nil
        
        /*
            Don't evaluate any updates if the `worldNode` is paused.
            Pausing a subsection of the node tree allows the `camera`
            and `overlay` nodes to remain interactive.
        */
        if worldNode.isPaused { return }
        
        // Update the level's state machine.
        stateMachine.update(deltaTime: deltaTime)

        /*
            Update each component system.
            The order of systems in `componentSystems` is important
            and was determined when the `componentSystems` array was instantiated.
        */
        for componentSystem in componentSystems {
            componentSystem.update(deltaTime: deltaTime)
        }
        

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        for touch in touches {
            let touchPoint = touch.location(in: self)
            /// Toggle pause when touching in the pause node.
            if pauseButton === atPoint(touchPoint) {
                stateMachine.enter(RDOLevelScenePauseState.self)
                break
            }
        }
        
    }

    override func didFinishUpdate() {
        // Check if the `playerBot` has been added to this scene.
        if let reaperNode = reaper.component(ofType: RenderComponent.self)?.node, reaperNode.scene == self {
            /*
                Update the `PlayerBot`'s agent position to match its node position.
                This makes sure that the agent is in a valid location in the SpriteKit
               physics world at the start of its next update cycle.
            */
            reaper.updateAgentPositionToMatchNodePosition()
        }
        
        // Sort the entities in the scene by ascending y-position.
        let ySortedEntities = entities.sorted {
            let nodeA = $0.component(ofType: RenderComponent.self)!.node
            let nodeB = $1.component(ofType: RenderComponent.self)!.node
            
            return nodeA.position.y > nodeB.position.y
        }
        
        // Set the `zPosition` of each entity so that entities with a higher y-position are rendered above those with a lower y-position.
        var characterZPosition = WorldLayer.zSpacePerCharacter
        for entity in ySortedEntities {
            let node = entity.component(ofType: RenderComponent.self)!.node
            node.zPosition = characterZPosition
            
            // Use a large enough z-position increment to leave space for emitter effects.
            characterZPosition += WorldLayer.zSpacePerCharacter
        }
    }
    
    // MARK: SKPhysicsContactDelegate
    
    @objc(didBeginContact:) func didBegin(_ contact: SKPhysicsContact) {
        handleContact(contact: contact) { (ContactNotifiableType: ContactNotifiableType, otherEntity: GKEntity) in
            ContactNotifiableType.contactWithEntityDidBegin(otherEntity)
        }
    }

    @objc(didEndContact:) func didEnd(_ contact: SKPhysicsContact) {
        handleContact(contact: contact) { (ContactNotifiableType: ContactNotifiableType, otherEntity: GKEntity) in
            ContactNotifiableType.contactWithEntityDidEnd(otherEntity)
        }
    }
    
    // MARK: SKPhysicsContactDelegate convenience
    
    private func handleContact(contact: SKPhysicsContact, contactCallback: (ContactNotifiableType, GKEntity) -> Void) {
        // Get the `ColliderType` for each contacted body.
        let colliderTypeA = ColliderType(rawValue: contact.bodyA.categoryBitMask)
        let colliderTypeB = ColliderType(rawValue: contact.bodyB.categoryBitMask)
        
        // Determine which `ColliderType` should be notified of the contact.
        let aWantsCallback = colliderTypeA.notifyOnContactWith(colliderTypeB)
        let bWantsCallback = colliderTypeB.notifyOnContactWith(colliderTypeA)
        
        // Make sure that at least one of the entities wants to handle this contact.
        assert(aWantsCallback || bWantsCallback, "Unhandled physics contact - A = \(colliderTypeA), B = \(colliderTypeB)")
        
        let entityA = contact.bodyA.node?.entity
        let entityB = contact.bodyB.node?.entity

        /*
            If `entityA` is a notifiable type and `colliderTypeA` specifies that it should be notified
            of contact with `colliderTypeB`, call the callback on `entityA`.
        */
        if let notifiableEntity = entityA as? ContactNotifiableType, let otherEntity = entityB, aWantsCallback {
            contactCallback(notifiableEntity, otherEntity)
        }
        
        /*
            If `entityB` is a notifiable type and `colliderTypeB` specifies that it should be notified
            of contact with `colliderTypeA`, call the callback on `entityB`.
        */
        if let notifiableEntity = entityB as? ContactNotifiableType, let otherEntity = entityA, bWantsCallback {
            contactCallback(notifiableEntity, otherEntity)
        }
    }
    
    // MARK: Level Construction
    
    func loadWorldLayers() {
        for worldLayer in WorldLayer.allLayers {
            // Try to find a matching node for this world layer's node name.
            let foundNodes = self["world/\(worldLayer.nodeName)"]
            
            // Make sure it was possible to find a node with this name.
            precondition(!foundNodes.isEmpty, "Could not find a world layer node for \(worldLayer.nodeName)")
            
            // Retrieve the actual node.
            let layerNode = foundNodes.first!
            
            // Make sure that the node's `zPosition` is correct relative to the other world layers.
            layerNode.zPosition = worldLayer.rawValue
            
            // Store a reference to the retrieved node.
            worldLayerNodes[worldLayer] = layerNode
        }
    }
    
    func addEntity(entity: GKEntity) {
        entities.insert(entity)

        for componentSystem in self.componentSystems {
            componentSystem.addComponent(foundIn: entity)
        }

        // If the entity has a `RenderComponent`, add its node to the scene.
        if let renderNode = entity.component(ofType: RenderComponent.self)?.node {
            addNode(node: renderNode, toWorldLayer: .characters)

                        
            /*
                If the entity has a `ChargeComponent` with a `ChargeBar`, add the `ChargeBar`
                to the scene. Constrain the `ChargeBar` to the `RenderComponent`'s node.
            */
            if let chargeBar = entity.component(ofType: ChargeComponent.self)?.chargeBar {
                
//                addNode(node: chargeBar, toWorldLayer: .top)
                chargeBar.position.y = size.height / 2.15
                chargeBar.position.x = -size.width / 3.2
                chargeBar.position.y -= GameplayConfiguration.Timer.paddingSize * GameplayConfiguration.Timer.fontSize*size.height
                camera!.addChild(chargeBar)
               
            }
            
            if let soulsContainer = entity.component(ofType: SoulsContainerComponent.self)?.chargeBar {
                
                soulsContainer.position.y = size.height / 2.0
                soulsContainer.position.x = -size.width / 2.3
                soulsContainer.position.y -= GameplayConfiguration.Timer.paddingSize * GameplayConfiguration.Timer.fontSize*size.height
                camera!.addChild(soulsContainer)
                
            }
        }
        
        // If the entity has an `IntelligenceComponent`, enter its initial state.
        if let intelligenceComponent = entity.component(ofType: IntelligenceComponent.self) {
            intelligenceComponent.enterInitialState()
        }
    }
    
    func addNode(node: SKNode, toWorldLayer worldLayer: WorldLayer) {
        let worldLayerNode = worldLayerNodes[worldLayer]!
        
        worldLayerNode.addChild(node)
    }
    
    // MARK: GameInputDelegate

    override func gameInputDidUpdateControlInputSources(gameInput: RDOGameInput) {
        super.gameInputDidUpdateControlInputSources(gameInput: gameInput)
        
        /*
            Update the player's `controlInputSources` to delegate input
            to the playerBot's `InputComponent`.
        */
        for controlInputSource in gameInput.controlInputSources {
            controlInputSource.delegate = reaper.component(ofType: InputComponent.self)
        }
        
        #if os(iOS)
        // When a game controller is connected, hide the thumb stick nodes.
        touchControlInputNode.hideThumbStickNodes = gameInput.isGameControllerConnected
        #endif
    }
    
    // MARK: ControlInputSourceGameStateDelegate
    
    override func controlInputSourceDidTogglePauseState(_ controlInputSource: ControlInputSourceType) {
        if stateMachine.currentState is RDOLevelSceneActiveState {
            stateMachine.enter(RDOLevelScenePauseState.self)
        }
        else {
            stateMachine.enter(RDOLevelSceneActiveState.self)
        }
    }


    
    // MARK: ButtonNodeResponderType
    
    override func buttonTriggered(button: RDOButtonNode) {
        switch button.buttonIdentifier! {
        case .resume:
            stateMachine.enter(RDOLevelSceneActiveState.self)
        default:
            // Allow `BaseScene` to handle the event in `BaseScene+Buttons`.
            super.buttonTriggered(button: button)
        }
    }
    
    // MARK: Convenience
    
    /// Constrains the camera to follow the PlayerBot without approaching the scene edges.
     func setCameraConstraints() {
        // Don't try to set up camera constraints if we don't yet have a camera.
        guard let camera = camera else { return }
        
        // Constrain the camera to stay a constant distance of 0 points from the player node.
        let zeroRange = SKRange(constantValue: 0.0)
        let reaperNode = reaper.renderComponent.node
        let reaperLocationConstraint = SKConstraint.distance(zeroRange, to: reaperNode)
        
        /*
            Also constrain the camera to avoid it moving to the very edges of the scene.
            First, work out the scaled size of the scene. Its scaled height will always be
            the original height of the scene, but its scaled width will vary based on
            the window's current aspect ratio.
        */
        let scaledSize = CGSize(width: size.width * camera.xScale, height: size.height * camera.yScale)

        /*
            Find the root "board" node in the scene (the container node for
            the level's background tiles).
        */
        let boardNode = childNode(withName: WorldLayer.board.nodePath)!
        
        /*
            Calculate the accumulated frame of this node.
            The accumulated frame of a node is the outer bounds of all of the node's
            child nodes, i.e. the total size of the entire contents of the node.
            This gives us the bounding rectangle for the level's environment.
        */
        let boardContentRect = boardNode.calculateAccumulatedFrame()

        /*
            Work out how far within this rectangle to constrain the camera.
            We want to stop the camera when we get within 100pts of the edge of the screen,
            unless the level is so small that this inset would be outside of the level.
        */
         let xInset = min((scaledSize.width / 2) - 16.0, boardContentRect.width / 2)
         let yInset = min((scaledSize.height / 2) - 16.0, boardContentRect.height / 2)
        
        // Use these insets to create a smaller inset rectangle within which the camera must stay.
        let insetContentRect = boardContentRect.insetBy(dx: xInset, dy: yInset)
        
        // Define an `SKRange` for each of the x and y axes to stay within the inset rectangle.
        let xRange = SKRange(lowerLimit: insetContentRect.minX, upperLimit: insetContentRect.maxX)
        let yRange = SKRange(lowerLimit: insetContentRect.minY, upperLimit: insetContentRect.maxY)
        
        // Constrain the camera within the inset rectangle.
        let levelEdgeConstraint = SKConstraint.positionX(xRange, y: yRange)
        levelEdgeConstraint.referenceNode = boardNode
        
        /*
            Add both constraints to the camera. The scene edge constraint is added
            second, so that it takes precedence over following the `PlayerBot`.
            The result is that the camera will follow the player, unless this would mean
            moving too close to the edge of the level.
        */
        camera.constraints = [reaperLocationConstraint, levelEdgeConstraint]
    }
    
    func scaleScoreNode() {
       // Update the font size of the score node based on the height of the scene.
       score.fontSize = size.height * GameplayConfiguration.Timer.fontSize
       
       // Make sure the score node is positioned at the top of the scene.
       score.position.y = size.height / 2.1
       
        // Make sure the score node is positioned at the right of the scene.
        score.position.x = size.width / 2.5
        
       // Add padding between the top of scene and the top of the score node.
       #if os(tvOS)
       score.position.y -= GameplayConfiguration.Timer.paddingSize
       #else
       score.position.y -= GameplayConfiguration.Timer.paddingSize * GameplayConfiguration.Timer.fontSize*size.height
       #endif
   }
    
    func scaleBlueCounterNode() {
       // Update the font size of the score node based on the height of the scene.
       bluecounter.fontSize = size.height * GameplayConfiguration.Timer.fontSize
       
        // Make sure the score node is positioned at the top of the scene.
        bluecounter.position.y = size.height / 2.3
        
         // Make sure the score node is positioned at the right of the scene.
        //bluecounter.position.x = -size.width / 3.6
        bluecounter.position.x = blueHUD.position.x + blueHUD.size.width
       // Add padding between the top of scene and the top of the score node.
       #if os(tvOS)
       bluecounter.position.y -= GameplayConfiguration.Timer.paddingSize
       #else
       bluecounter.position.y -= GameplayConfiguration.Timer.paddingSize * GameplayConfiguration.Timer.fontSize*size.height
       #endif
   }
    
    func scaleGreenCounterNode() {
       // Update the font size of the score node based on the height of the scene.
       greencounter.fontSize = size.height * GameplayConfiguration.Timer.fontSize
       
       // Make sure the score node is positioned at the top of the scene.
       greencounter.position.y = size.height / 2.3
       
        // Make sure the score node is positioned at the right of the scene.
        //greencounter.position.x = -size.width / 4.25 + greencounter.fontSize
        greencounter.position.x = greenHUD.position.x + greenHUD.size.width
       // Add padding between the top of scene and the top of the score node.
       #if os(tvOS)
       greencounter.position.y -= GameplayConfiguration.Timer.paddingSize
       #else
       greencounter.position.y -= GameplayConfiguration.Timer.paddingSize * GameplayConfiguration.Timer.fontSize*size.height
       #endif
   }
    
    func scaleRedCounterNode() {
       // Update the font size of the score node based on the height of the scene.
       redcounter.fontSize = size.height * GameplayConfiguration.Timer.fontSize
       
       // Make sure the score node is positioned at the top of the scene.
       redcounter.position.y = size.height / 2.3
       
        // Make sure the score node is positioned at the right of the scene.
        //redcounter.position.x = -size.width / 5.25 + (2 * redcounter.fontSize)
        redcounter.position.x = redHUD.position.x + redHUD.size.width
        
       // Add padding between the top of scene and the top of the score node.
       #if os(tvOS)
       redcounter.position.y -= GameplayConfiguration.Timer.paddingSize
       #else
       redcounter.position.y -= GameplayConfiguration.Timer.paddingSize * GameplayConfiguration.Timer.fontSize*size.height
       #endif
   }
    
    func scaleBlueHUD() {

         // Make sure the score node is positioned at the top of the scene.
         blueHUD.position.y = size.height / 2.25
         
          // Make sure the score node is positioned at the right of the scene.
         blueHUD.position.x = -size.width / 3.2
         
        // Add padding between the top of scene and the top of the score node.
        #if os(tvOS)
        blueHUD.position.y -= GameplayConfiguration.Timer.paddingSize
        #else
        blueHUD.position.y -= GameplayConfiguration.Timer.paddingSize * GameplayConfiguration.Timer.fontSize*size.height
        #endif
   }
    
    func scaleGreenHUD() {
        // Make sure the score node is positioned at the top of the scene.
        greenHUD.position.y = size.height / 2.25
        
         // Make sure the score node is positioned at the right of the scene.
         //greenHUD.position.x = -size.width / 3.5 + greencounter.fontSize
        greenHUD.position.x = bluecounter.position.x + bluecounter.frame.width*1.5
        
        // Add padding between the top of scene and the top of the score node.
        #if os(tvOS)
        greenHUD.position.y -= GameplayConfiguration.Timer.paddingSize
        #else
        greenHUD.position.y -= GameplayConfiguration.Timer.paddingSize * GameplayConfiguration.Timer.fontSize*size.height
        #endif
   }
    func scaleRedHUD() {
       // Make sure the score node is positioned at the top of the scene.
       redHUD.position.y = size.height / 2.25
       
        // Make sure the score node is positioned at the right of the scene.
        //redHUD.position.x = -size.width / 4.25 + (2 * redcounter.fontSize)
        redHUD.position.x = greencounter.position.x + greencounter.frame.width*1.5
       // Add padding between the top of scene and the top of the score node.
       #if os(tvOS)
       redHUD.position.y -= GameplayConfiguration.Timer.paddingSize
       #else
       redHUD.position.y -= GameplayConfiguration.Timer.paddingSize * GameplayConfiguration.Timer.fontSize*size.height
       #endif
   }
    
    func scalePauseButton() {
        
       // Make sure the score node is positioned at the top of the scene.
       pauseButton.position.y = size.height / 2.1
       
        // Make sure the score node is positioned at the right of the scene.
        pauseButton.position.x = size.width / 2.3
        
       // Add padding between the top of scene and the top of the score node.
       #if os(tvOS)
       pauseButton.position.y -= GameplayConfiguration.Timer.paddingSize
       #else
       pauseButton.position.y -= GameplayConfiguration.Timer.paddingSize * GameplayConfiguration.Timer.fontSize*size.height
       #endif
   }
    
    
    private func beamInReaper() {
        // Find the location of the player's initial position.
        let charactersNode = childNode(withName: WorldLayer.characters.nodePath)!
        let transporterCoordinate = charactersNode.childNode(withName: "transporter_coordinate")!
        
        // Set the initial orientation.
        guard let orientationComponent = reaper.component(ofType: OrientationComponent.self) else {
            fatalError("A player bot must have an orientation component to be able to be added to a level")
        }
        orientationComponent.compassDirection = .south

        // Set up the `PlayerBot` position in the scene.
        let reaperNode = reaper.renderComponent.node
        reaperNode.position = transporterCoordinate.position
        reaper.updateAgentPositionToMatchNodePosition()
        if let animationComponent = reaper.component(ofType: AnimationComponent.self) {
            animationComponent.node.isHidden = true
        }
        
        // Constrain the camera to the `PlayerBot` position and the level edges.
        setCameraConstraints()
        
        // Add the `PlayerBot` to the scene and component systems.
        addEntity(entity: reaper)
    }
    
    func beamInEnemy(enemy: HeartReaper, pos: Int) {
        // Find the location of the player's initial position.
        let charactersNode = childNode(withName: WorldLayer.characters.nodePath)!
        let transporterCoordinate = charactersNode.childNode(withName: "enemy_coordinate\(pos)")!
        
        // Set the initial orientation.
        guard let orientationComponent = enemy.component(ofType: OrientationComponent.self) else {
            fatalError("An enemy bot must have an orientation component to be able to be added to a level")
        }
        orientationComponent.compassDirection = .south

        // Set up the `PlayerBot` position in the scene.
        
        let enemyNode = enemy.renderComponent.node
        enemyNode.position = transporterCoordinate.position
        enemy.updateAgentPositionToMatchNodePosition()
        enemyNode.run(SKAction(named: "heartAppear")!)
         
        
        // Constrain the camera to the `PlayerBot` position and the level edges.
//        setCameraConstraints()
        
        
        
        // Add the `PlayerBot` to the scene and component systems.
        addEntity(entity: enemy)
    }
    
    func spawnEnemy() {

        let newEnemy = HeartReaper()
        enemy = newEnemy
        beamInEnemy(enemy: enemy!, pos:  Int.random(in: 1...3))

    }
    
    private func putGateInScene(gate: Gate, pos: Int){
        let charactersNode = childNode(withName: WorldLayer.characters.nodePath)!
        let gateCoordinate = charactersNode.childNode(withName: "gate_coordinate\(pos)")!
        
        let gateNode = gate.renderComponent.node
        gateNode.position = gateCoordinate.position
        
        addEntity(entity: gate)
        if let gate = charactersNode.childNode(withName: "//\(gate.name)Gate") as? SKSpriteNode {
            gate.run(SKAction(named: gate.name!)!)
        }
        
    }
    
    private func createSoul() -> Soul {
        let random = UInt.random(in: 0...3)
        var soul: Soul
        switch random {
        case 1:
            soul = GreenSoul()
        case 2:
            soul = BlueSoul()
        default:
            soul = RedSoul()
        }
        
        return soul
    }
  
    func spawnSoul() {
        
        let soul = createSoul()
        guard let orientationComponent = soul.component(ofType: OrientationComponent.self) else {
            fatalError("A task bot must have an orientation component to be able to be added to a level")
        }
        orientationComponent.compassDirection = CompassDirection.allDirections.randomElement() ?? .northEast
        
        putSoulInScene(soul: soul, pos: Int.random(in: 1...3))
        GameplayLogic.sharedInstance().LOGAddSoulOnStage(n: 1)
        
    }
    
    private func putSoulInScene(soul: Soul, pos: Int){
        let charactersNode = childNode(withName: WorldLayer.characters.nodePath)!
        let spawnCoordinate = charactersNode.childNode(withName: "spawn_coordinate\(pos)")!
        
        let soulNode = soul.renderComponent.node
        soulNode.position = spawnCoordinate.position
        soul.updateAgentPositionToMatchNodePosition()
        
        addEntity(entity: soul)
        
    }
    
}

