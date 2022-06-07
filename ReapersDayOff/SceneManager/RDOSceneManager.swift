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
        case launch
        case start
        case main, settings, about, collection
        case stageOne
    }
    
    var device: UIUserInterfaceIdiom {
       return UIDevice.current.userInterfaceIdiom
    }
    /**
        The games input via connected control input sources. Used to
        provide control to scenes after presentation.
    */
    let gameInput: RDOGameInput
    
    /// The view used to choreograph scene transitions.
    let presentingView: SKView
    
    /// type of transitions
    let t1 = SKTransition.crossFade(withDuration: 1.0)
    let t2 = SKTransition.reveal(with: .up, duration: 1.0)
    let t3 = SKTransition.doorsCloseHorizontal(withDuration: 1.0)
    let t4 = SKTransition.doorsOpenHorizontal(withDuration: 1.0)
    let t5 = SKTransition.doorway(withDuration: 1.0)
    let t6 = SKTransition.push(with: .left, duration: 1.0)
    let t7 = SKTransition.fade(withDuration: 1.0)
    let t8 = SKTransition.push(with: .right, duration: 1.0)
    
    /// The `RDOSceneManager`'s delegate.
    weak var delegate: SceneManagerDelegate?
    
    init(presentingView: SKView , gameInput: RDOGameInput){
        self.presentingView = presentingView
        self.gameInput = gameInput
        
        
    }
    
    func transitionToScene(identifier sceneIdentifier: RDOSceneIdentifier) {
        var scene: RDOBaseScene?
        var transit: SKTransition
        // Block to initial file
        switch sceneIdentifier {
        case .start:
            scene = SKScene.init(fileNamed: "RDOStartScene") as? RDOStartScene
            transit = t2

        case .main:
            scene = SKScene.init(fileNamed: "RDOMainScene") as? RDOMainScene
            if device == .phone {
                scene = SKScene.init(fileNamed: "RDOMainScenePhone") as? RDOMainScene
            }
            transit = t8

        case .settings:
            scene = SKScene.init(fileNamed: "RDOSettingsScene") as? RDOSettingsScene
            if device == .phone {
                scene = SKScene.init(fileNamed: "RDOSettingsScenePhone") as? RDOSettingsScene
            }
            transit = t6

        case .about:
            scene = SKScene.init(fileNamed: "RDOAboutScene") as? RDOAboutScene
            if device == .phone {
                scene = SKScene.init(fileNamed: "RDOAboutScenePhone") as? RDOAboutScene
            }
            transit = t6

        case .collection:
            scene = SKScene.init(fileNamed: "RDOCollectionScene") as? RDOCollectionScene
            transit = t6

        case .stageOne:
            scene = SKScene.init(fileNamed: "RDOStageOneScene") as? RDOLevelScene
            transit = t7

        case .launch:
            scene = SKScene.init(fileNamed: "LaunchscreenScene") as? RDOLaunchScreen
            transit = t7
        }
        
        if scene != nil {
            scene?.createCamera()
            presentScene(scene!, transition: transit)
        }
        
    }
    
    func presentScene(_ scene: RDOBaseScene, transition: SKTransition){
        
        scene.sceneManager = self
        
        
        self.presentingView.presentScene(scene, transition: transition)
        
        
        self.delegate?.sceneManager(self, didTransitionTo: scene)
    }
    
    
}
