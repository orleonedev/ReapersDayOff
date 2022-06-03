//
//  TouchButtonNode.swift
//  ReapersDayOff
//
//  Created by Oreste Leone on 03/06/22.
//

import Foundation
import SpriteKit


/// Relay control events though `ThumbStickNodeDelegate`.
protocol TouchButtonNodeDelegate: AnyObject {
    
    /// Called to indicate when the `touchPad` is initially pressed, and when it is released.
    func touchButtonNode(touchButtonNode: TouchButtonNode, isPressed: Bool)
}

/// Touch representation of a classic analog stick.
class TouchButtonNode: SKSpriteNode {
    // MARK: Properties
    
    
    weak var delegate: TouchButtonNodeDelegate?
    
    /// The center point of this `ThumbStickNode`.
    let center: CGPoint
    
    /// The distance that `touchPad` can move from the `touchPadAnchorPoint`.
    let trackingDistance: CGFloat
    
    /// Styling settings for the thumbstick's nodes.
    let normalAlpha: CGFloat = 0.3
    let selectedAlpha: CGFloat = 0.5
    
    // MARK: Initialization
    
    init(size: CGSize) {
        trackingDistance = size.width / 2
        
        let touchPadLength = size.width / 2.2
        center = CGPoint(x: size.width / 2 - touchPadLength, y: size.height / 2 - touchPadLength)
        
        let touchPadTexture = SKTexture(imageNamed: "ControlPad")
        
        super.init(texture: touchPadTexture, color: UIColor.clear, size: size)

        alpha = normalAlpha
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIResponder
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        // Highlight that the control is being used by adjusting the alpha.
        alpha = selectedAlpha
        
        // Inform the delegate that the control is being pressed.
        delegate?.touchButtonNode(touchButtonNode: self, isPressed: true)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
       
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        // If the touches set is empty, return immediately.
        guard !touches.isEmpty else { return }
        
        resetTouchPad()
   }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        super.touchesCancelled(touches!, with: event)
        resetTouchPad()
    }
    
    /// When touches end, reset the `touchPad` to the center of the control.
    func resetTouchPad() {
        alpha = normalAlpha
        
        delegate?.touchButtonNode(touchButtonNode: self, isPressed: false)
        
    }
}
