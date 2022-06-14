//
//  RDOMainScene.swift
//  ReapersDayOff
//
//  Created by Oreste Leone on 06/05/22.
//

import SpriteKit
import GameController

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
    
    var reaper: SKSpriteNode? {
        return backgroundNode?.childNode(withName: "//reaper") as? SKSpriteNode
    }
    var donnie: SKSpriteNode? {
        return backgroundNode?.childNode(withName: "//donnie") as? SKSpriteNode
    }
    
    var bg : SKSpriteNode? {
        return backgroundNode?.childNode(withName: "bg") as? SKSpriteNode
    }

    var bg2 : SKSpriteNode? {
        return backgroundNode?.childNode(withName: "bg2") as? SKSpriteNode
    }
    
    // MARK: Scene Life Cycle
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        // Enable focus based navigation.
        focusChangesEnabled = true
        let seq1 = SKAction.sequence([
            SKAction(named: "moveBG")!,
            SKAction.run{
                self.bg?.position = CGPoint(x: 0, y: 0)
            }
        ])
        let seq2 = SKAction.sequence([
            SKAction(named: "moveBG")!,
            SKAction.run{
                self.bg2?.position = CGPoint(x: 1888, y: 0)
            }
        ])
        bg?.run(SKAction.repeatForever(seq1))
        bg2?.run(SKAction.repeatForever(seq2))
        
        if let controller = GCController.current {
            controller.light?.color = GCColor.init(red: 175/255, green: 82/255, blue: 222/255)
        }
        centerCameraOnPoint(point: backgroundNode!.position)
        reaper?.run(SKAction.repeatForever(SKAction(named: "reaperRotation")!))
        donnie?.run(SKAction.repeatForever(SKAction(named: "DonnieMainScreen")!))
        
        
    }
    
}
