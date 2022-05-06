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
            case .game:
                sceneManager.transitionToScene(identifier: .stageOne)
            case .collection:
                sceneManager.transitionToScene(identifier: .collection)
            case .about:
                sceneManager.transitionToScene(identifier: .about)
            case .settings:
                sceneManager.transitionToScene(identifier: .settings)
            
            default:
                fatalError("Unsupported ButtonNode type in Scene.")
        }
    }
    
    
}
