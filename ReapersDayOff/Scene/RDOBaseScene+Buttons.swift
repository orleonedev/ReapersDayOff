//
//  RDOBaseScene+Buttons.swift
//  ReapersDayOff
//
//  Created by Claudio Silvestri on 04/05/22.
//

import Foundation

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
                sceneManager.transitionToScene(identifier: .start)
            case .proceedToNextScene:
                sceneManager.transitionToScene(identifier: .stageOne)

            case .replay:
//                sceneManager.transitionToScene(identifier: .currentLevel)
            print("replay")
            default:
                fatalError("Unsupported ButtonNode type in Scene.")
        }
    }
    
    
}
