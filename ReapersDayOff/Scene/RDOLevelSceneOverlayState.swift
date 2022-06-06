//
//  RDOLevelSceneOverlayState.swift
//  ReapersDayOff
//
//  Created by Claudio Silvestri on 09/05/22.
//

/*
    Abstract:
    The base class for a `LevelScene`'s Pause, Fail, and Success states. Handles the task of loading and displaying a full-screen overlay from a scene file when the state is entered.
*/

import SpriteKit
import GameplayKit

class RDOLevelSceneOverlayState: GKState {
    // MARK: Properties
    
    unowned let levelScene: RDOLevelScene
    
    /// The `SceneOverlay` to display when the state is entered.
    var overlay: RDOSceneOverlay!
    
    /// Overridden by subclasses to provide the name of the .sks file to load to show as an overlay.
    var overlaySceneFileName: String { fatalError("Unimplemented overlaySceneName") }
    
    // MARK: Initializers
    
    init(levelScene: RDOLevelScene) {
        self.levelScene = levelScene
        
        super.init()
        
        overlay = RDOSceneOverlay(overlaySceneFileName: overlaySceneFileName, zPosition: WorldLayer.top.rawValue)
    }

    // MARK: GKState Life Cycle

    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        // Provide the levelScene with a reference to the overlay node.
        levelScene.overlay = overlay
        overlay.contentNode.isPaused = false
        SoundClass.sharedInstance().backgroundMusicPlayer?.setVolume(0.05, fadeDuration: 0.5)
    }

    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        levelScene.overlay = nil
        SoundClass.sharedInstance().backgroundMusicPlayer?.setVolume(0.3, fadeDuration: 0.5)
        
    }
    
    // MARK: Convenience
    
    func button(withIdentifier identifier: ButtonIdentifier) -> RDOButtonNode? {
        return overlay.contentNode.childNode(withName: "//\(identifier.rawValue)") as? RDOButtonNode
    }
}
