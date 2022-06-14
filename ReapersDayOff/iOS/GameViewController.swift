//
//  GameViewController.swift
//  ReapersDayOff
//
//  Created by Oreste Leone on 03/05/22.
//

import UIKit
import SpriteKit
import GameplayKit
import GameKit

class GameViewController: UIViewController, SceneManagerDelegate, GKGameCenterControllerDelegate, SoundDelegate {
    
    
    var sceneManager: RDOSceneManager!
    
    let soundInstance = SoundClass.sharedInstance()
    var isinMenu = false
    let gamecenterHelper = GameCenterHelper.sharedInstance()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        soundInstance.delegate = self
        gamecenterHelper.viewDelegate = self
        gamecenterHelper.authenticateLocalPlayer()
        
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
            
            view.showsFPS = false
            view.showsNodeCount = false
            view.showsPhysics = false
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
        
        if soundInstance.enabled {
            if scene is RDOLevelScene {
            isinMenu = false
            soundInstance.playBackgroundMusic("life-of-a-wandering-wizard-15549.mp3")
        }
        else if scene is RDOLaunchScreen {
            soundInstance.playSoundEffect("DrumRoll.mp3")
        }
        else {
            if !isinMenu {
                soundInstance.playBackgroundMusic("jazz-happy-110855.mp3")
                isinMenu = true
            }
        }
            
        }
    }
    
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    func soundEnabled() {
        soundInstance.playBackgroundMusic("jazz-happy-110855.mp3")
    }
    
}
