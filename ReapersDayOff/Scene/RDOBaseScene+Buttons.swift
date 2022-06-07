//
//  RDOBaseScene+Buttons.swift
//  ReapersDayOff
//
//  Created by Claudio Silvestri on 04/05/22.
//

import Foundation
import SpriteKit

/// Extends `BaseScene` to respond to ButtonNode events.
extension RDOBaseScene: ButtonNodeResponderType {
    
    /// Searches the scene for all `ButtonNode`s.
    func findAllButtonsInScene() -> [RDOButtonNode] {
        return ButtonIdentifier.allButtonIdentifiers.compactMap { buttonIdentifier in
            childNode(withName: "//\(buttonIdentifier.rawValue)") as? RDOButtonNode
        }
    }
    
    // MARK: ButtonNodeResponderType
    
    
    func buttonTriggered(button: RDOButtonNode) {
        switch button.buttonIdentifier! {
            case .home:
                sceneManager.transitionToScene(identifier: .main)
            case .game:
                sceneManager.transitionToScene(identifier: .stageOne)
            case .collection:
                sceneManager.transitionToScene(identifier: .collection)
            case .about:
                sceneManager.transitionToScene(identifier: .about)
            case .settings:
                sceneManager.transitionToScene(identifier: .settings)
            case .retry:
                sceneManager.transitionToScene(identifier: .stageOne)
            case .tutorial:
                if self is RDOAboutScene {
                    if let tutorialScreen = childNode(withName: "//tutorialScreen") as? SKSpriteNode {
                        tutorialScreen.isHidden = false
                    }
                    if let creditScreen = childNode(withName: "//creditScreen") as? SKSpriteNode {
                        creditScreen.isHidden = true
                    }
                }
            case .credits:
            if self is RDOAboutScene {
                if let tutorialScreen = childNode(withName: "//tutorialScreen") as? SKSpriteNode {
                    tutorialScreen.isHidden = true
                }
                if let creditScreen = childNode(withName: "//creditScreen") as? SKSpriteNode {
                    creditScreen.isHidden = false
                }
            }
        case .leaderboard:
            print("Leaderboard")
            
                
            default:
                fatalError("Unsupported ButtonNode type in Scene.")
        }
    }
    
}
