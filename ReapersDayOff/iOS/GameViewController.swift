//
//  GameViewController.swift
//  ReapersDayOff
//
//  Created by Oreste Leone on 03/05/22.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, SceneManagerDelegate {
    
    
    var sceneManager: RDOSceneManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewSize = view.bounds.size
        
        /// Controller
        let controlLength = min(GameplayConfiguration.TouchControl.minimumControlSize, viewSize.width * GameplayConfiguration.TouchControl.idealRelativeControlSize)
        let controlSize = CGSize(width: controlLength, height: controlLength)

        let touchControlInputNode = TouchControlInputNode(frame: view.bounds, thumbStickNodeSize: controlSize)
        let gameInput = RDOGameInput(nativeControlInputSource: touchControlInputNode)
        
        // Present the scene
        if let view = self.view as! SKView? {
            sceneManager = RDOSceneManager(presentingView: view, gameInput: gameInput )
            sceneManager.delegate = self
            sceneManager.transitionToScene(identifier: .launch)
            
            view.showsFPS = true
            view.showsNodeCount = true
            view.showsPhysics = true
        }
        
        
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .landscape
        } else {
            return .landscape
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func sceneManager(_ sceneManager: RDOSceneManager, didTransitionTo scene: SKScene) {
        
    }
}
