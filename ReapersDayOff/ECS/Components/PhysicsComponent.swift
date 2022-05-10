//
//  PhysicsComponent.swift
//  ReapersDayOff
//
//  Created by Maria Smirnova on 05/05/22.
//

import SpriteKit
import GameplayKit

class PhysicsComponent: GKComponent {
    // MARK: Properties
    
    var physicsBody: SKPhysicsBody
    
    // MARK: Initializers
    
    init(physicsBody: SKPhysicsBody, colliderType: ColliderType) {
        self.physicsBody = physicsBody
        self.physicsBody.categoryBitMask = colliderType.categoryMask
        self.physicsBody.collisionBitMask = colliderType.collisionMask
        self.physicsBody.contactTestBitMask = colliderType.contactMask
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
