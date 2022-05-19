//
//  Gate.swift
//  ReapersDayOff
//
//  Created by Oreste Leone on 16/05/22.
//

import GameplayKit
import SpriteKit

class Gate: GKEntity {
    
    var name: String
    
    static var textureSize = CGSize(width: 96, height: 128.0)
    
    /// The `RenderComponent` associated with this `PlayerBot`.
    var renderComponent: RenderComponent {
        guard let renderComponent = component(ofType: RenderComponent.self) else { fatalError("A Gate must have an RenderComponent.") }
        return renderComponent
    }
    
    
    required init(type: String) {
        name = type
        super.init()
        Self.loadSharedAssets()
        
        let renderComponent = RenderComponent()
        addComponent(renderComponent)
        var gateOffset: CGPoint
        switch type {
        case "red":
            gateOffset = CGPoint(x: 32.0, y: 0.0)
        case "green":
            gateOffset = CGPoint(x: 0.0, y: -32.0)
        case "blue":
            gateOffset = CGPoint(x: -32.0, y: 0.0)
        default:
            fatalError("Unknown gate type")
        }
        
        let physicsComponent = PhysicsComponent(physicsBody: SKPhysicsBody(circleOfRadius: GameplayConfiguration.Reaper.physicsBodyRadius*3, center: gateOffset), colliderType: .Gate)
        physicsComponent.physicsBody.isDynamic = false
        addComponent(physicsComponent)

        // Connect the `PhysicsComponent` and the `RenderComponent`.
        renderComponent.node.physicsBody = physicsComponent.physicsBody
        var color: UIColor
        switch name {
        case "red":
            color = UIColor.red
        case "blue":
            color = UIColor.blue
        case "green":
            color = UIColor.green
        default:
            fatalError("Unknown Gate color")
        }
        renderComponent.node.addChild(SKSpriteNode(color: color, size: Gate.textureSize))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func loadSharedAssets() {
        ColliderType.definedCollisions[.Gate] = [
            .Reaper,
            .Soul
        ]
        
        ColliderType.requestedContactNotifications[.Gate] = [
            .Reaper,
        ]
    }
}
