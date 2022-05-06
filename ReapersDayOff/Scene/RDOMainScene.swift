//
//  RDOMainScene.swift
//  ReapersDayOff
//
//  Created by Oreste Leone on 06/05/22.
//

import SpriteKit

class RDOMainScene: RDOBaseScene {
    // MARK: Properties
    
    /// returns the background node from the scene
    override var backgroundNode: SKSpriteNode? {
        return childNode(withName: "backgroundNode") as? SKSpriteNode
    }
    
    /// The Game button which allows the player to proceed to the first level.
    var GameButton: RDOButtonNode? {
        return backgroundNode?.childNode(withName: ButtonIdentifier.game.rawValue) as? RDOButtonNode
        
    }
    
    ///  the Settings button
    var settingsButton: RDOButtonNode? {
        return backgroundNode?.childNode(withName: ButtonIdentifier.settings.rawValue) as? RDOButtonNode
        
    }
    
    ///  the About button
    var aboutButton: RDOButtonNode? {
        return backgroundNode?.childNode(withName: ButtonIdentifier.about.rawValue) as? RDOButtonNode
        
    }
    
    ///  the collection button
    var collectionButton: RDOButtonNode? {
        return backgroundNode?.childNode(withName: ButtonIdentifier.collection.rawValue) as? RDOButtonNode
        
    }
    
    // MARK: Scene Life Cycle
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        // Enable focus based navigation.
        focusChangesEnabled = true
        
        centerCameraOnPoint(point: backgroundNode!.position)
        
    }
    
}
