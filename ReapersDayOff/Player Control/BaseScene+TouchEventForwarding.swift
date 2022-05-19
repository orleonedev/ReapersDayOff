//
//  BaseScene+TouchEventForwarding.swift
//  ReapersDayOff
//
//  Created by Oreste Leone on 04/05/22.
//

import UIKit

/*
    Extend `BaseScene` to forward events from the scene to a platform-specific
    control input source. On iOS, this is a `TouchControlInputNode`, which is
    overlaid on the scene to receive touch events.
*/
extension RDOBaseScene {
    // MARK: Properties
    
    var touchControlInputNode: TouchControlInputNode {
        return sceneManager.gameInput.nativeControlInputSource as! TouchControlInputNode
    }
    
    // MARK: Setup Touch Handling
    
    func addTouchInputToScene() {
        guard let camera = camera else { fatalError("Touch input controls can only be added to a scene that has an associated camera.") }
        
        // Ensure the touch input source is not associated any other parent.
        touchControlInputNode.removeFromParent()
        
        if self is RDOLevelScene {
            // Ensure the control node fills the scene's size.
            touchControlInputNode.size = size
//            touchControlInputNode.size = size

            // Center the control node on the camera.
            touchControlInputNode.position = CGPoint.zero

            /*
                Assign a `zPosition` that is above in-game elements, but below the top
                layer where buttons are added.
            */
            touchControlInputNode.zPosition = WorldLayer.top.rawValue - CGFloat(1.0)

            // Add the control node to the camera node so the controls remain stationary as the camera moves.
            camera.addChild(touchControlInputNode)

            // Make sure the controls are visible.
            touchControlInputNode.hideThumbStickNodes = false
        }
    }
}

