//
//  RDOCollectionScene.swift
//  ReapersDayOff
//
//  Created by Oreste Leone on 06/05/22.
//

import SpriteKit

class RDOCollectionScene: RDOBaseScene {
    // MARK: Properties
    
    /// returns the background node from the scene
    override var backgroundNode: SKSpriteNode? {
        return childNode(withName: "backgroundNode") as? SKSpriteNode
    }
    
    /// The Game button which allows the player to proceed to the first level.
    var HomeButton: RDOButtonNode? {
        return backgroundNode?.childNode(withName: ButtonIdentifier.home.rawValue) as? RDOButtonNode
        
    }
    
    
    
    
    // MARK: Scene Life Cycle
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        // Enable focus based navigation.
        focusChangesEnabled = true
        
        centerCameraOnPoint(point: backgroundNode!.position)
        
    }
    
}
