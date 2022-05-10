//
//  RenderComponent.swift
//  ReapersDayOff
//
//  Created by Maria Smirnova on 05/05/22.
//

import SpriteKit
import GameplayKit

class RenderComponent: GKComponent {
    // MARK: Properties
    
    // The `RenderComponent` vends a node allowing an entity to be rendered in a scene.
    let node = SKNode()

    // MARK: GKComponent
    
    override func didAddToEntity() {
        node.entity = entity
    }
    
    override func willRemoveFromEntity() {
        node.entity = nil
    }
}
