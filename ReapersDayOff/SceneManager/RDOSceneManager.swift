//
//  RDOSceneManager.swift
//  ReapersDayOff
//
//  Created by Oreste Leone on 03/05/22.
//

import SpriteKit

protocol SceneManagerDelegate: AnyObject {
    
    func sceneManager(_ sceneManager: RDOSceneManager, didTransitionTo scene: SKScene)
}

final class RDOSceneManager {
    // MARK: Types
    
    enum RDOSceneIdentifier {
        case start
        case main, settings, about, collection
        case stageOne, results
    }
    
    /**
        The games input via connected control input sources. Used to
        provide control to scenes after presentation.
    */
    let gameInput: RDOGameInput
    
    /// The view used to choreograph scene transitions.
    let presentingView: SKView
    
    /// The `RDOSceneManager`'s delegate.
    weak var delegate: SceneManagerDelegate?
    
    init(presentingView: SKView , gameInput: RDOGameInput){
        self.presentingView = presentingView
        self.gameInput = gameInput
        
        
    }
    
    func transitionToScene(identifier sceneIdentifier: RDOSceneIdentifier) {
        var scene: RDOBaseScene?
        // Block to initial file
        switch sceneIdentifier {
        case .start:
            scene = SKScene.init(fileNamed: "RDOStartScene") as! RDOStartScene
//            scene = SKScene.init(fileNamed: "Start")
        case .main:
            scene = SKScene.init(fileNamed: "GameScene") as? RDOBaseScene
//            scene = SKScene.init(fileNamed: "Main")
        case .settings:
            scene = SKScene.init(fileNamed: "GameScene") as? RDOBaseScene
//            scene = SKScene.init(fileNamed: "Settings")
        case .about:
            scene = SKScene.init(fileNamed: "GameScene") as? RDOBaseScene
//            scene = SKScene.init(fileNamed: "About")
        case .collection:
            scene = SKScene.init(fileNamed: "GameScene") as? RDOBaseScene
//            scene = SKScene.init(fileNamed: "Preparation")
        case .stageOne:
            scene = SKScene.init(fileNamed: "RDOStageOneScene") as! RDOStageOneScene
//            scene = SKScene.init(fileNamed: "StageOne")
        case .results:
            scene = SKScene.init(fileNamed: "GameScene") as? RDOBaseScene
//            scene = SKScene.init(fileNamed: "Results")
        }
        
        if scene != nil {
            scene?.createCamera()
            presentScene(scene!)
        }
        
    }
    
    func presentScene(_ scene: RDOBaseScene){
        
        scene.sceneManager = self
        
        let transition = SKTransition.fade(withDuration: 2.0)
        self.presentingView.presentScene(scene, transition: transition)
        
        
        self.delegate?.sceneManager(self, didTransitionTo: scene)
    }
    
    
}
