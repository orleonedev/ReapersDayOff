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
    
    var numSoulsCollected: SKLabelNode? {
        return backgroundNode?.childNode(withName: "NumSoulsCollected") as? SKLabelNode
    }
    
    var numHitByHeartReaper: SKLabelNode? {
        return backgroundNode?.childNode(withName: "NumHitByHeartReaper") as? SKLabelNode
    }
    
    var numGamesPlayed: SKLabelNode? {
        return backgroundNode?.childNode(withName: "NumGamesPlayed") as? SKLabelNode
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
        
        centerCameraOnPoint(point: backgroundNode!.position)
        numSoulsCollected?.text = "\(GameplayLogic.sharedInstance().totalSouls)"
        numHitByHeartReaper?.text = "\(GameplayLogic.sharedInstance().heartReaperHit)"
        numGamesPlayed?.text = "\(GameplayLogic.sharedInstance().gamesPlayed)"
    }
    
}
