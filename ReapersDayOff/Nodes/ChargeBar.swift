//
//  ChargeBar.swift
//  ReapersDayOff
//
//  Created by Oreste Leone on 09/05/22.
//

import SpriteKit

class ChargeBar: SKSpriteNode {
    // MARK: Static Properties
    
    struct Configuration {
        /// The size of the complete bar (back and level indicator).
        static let size = CGSize(width: 516.0, height: 20.0)
        
        /// The size of the colored level bar.
        static let chargeLevelNodeSize = CGSize(width: 512.0, height: 16.0)
        
        /// The duration used for actions to update the level indicator.
        static let levelUpdateDuration: TimeInterval = 0.1
        
        /// The background color.
        static let backgroundColor = SKColor.black
        
        /// The charge level node color.
        static let chargeLevelColor = SKColor.green
    }
    
    // MARK: Properties
    
    var level: Double = 1.0 {
        didSet {
            // Scale the level bar node based on the current health level.
            let action = SKAction.scaleX(to: CGFloat(level), duration: Configuration.levelUpdateDuration)
            action.timingMode = .easeInEaseOut

            chargeLevelNode.run(action)
        }
    }
    
    /// A node representing the charge level.
    let chargeLevelNode = SKSpriteNode(color: Configuration.chargeLevelColor, size: Configuration.chargeLevelNodeSize)
    
    /// A node representing the overlay
    let overlayNode = SKSpriteNode(texture: SKTexture(imageNamed: "staminaPurple"), color: .black, size: Configuration.size)
    
    // MARK: Initializers
    
    init() {
        super.init(texture: nil, color: Configuration.backgroundColor, size: Configuration.chargeLevelNodeSize)
        self.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        addChild(chargeLevelNode)
        overlayNode.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        addChild(overlayNode)
        
        // Constrain the position of the `chargeLevelNode`.
        let xRange = SKRange(constantValue: 1.0)
        let yRange = SKRange(constantValue: 0.0)
        
        let constraint = SKConstraint.positionX(xRange, y: yRange)
        constraint.referenceNode = self
        
        chargeLevelNode.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        chargeLevelNode.constraints = [constraint]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

