//
//  SoulsContainer.swift
//  ReapersDayOff
//
//  Created by Claudio Silvestri on 26/05/22.
//

import SpriteKit

class SoulsContainer: SKSpriteNode {
    // MARK: Static Properties
    
    struct Configuration {
        /// The size of the complete bar (back and level indicator).
        static let soulsContainerTextureSize = CGSize(width: 80, height: 80)
        
        /// The size of the colored level bar.
        static let soulsContainerSize = CGSize(width: 80, height: 80)
        
        /// The duration used for actions to update the level indicator.
        static let levelUpdateDuration: TimeInterval = 0.1
        
        /// The background color.
        static let backgroundColor = SKColor.black
        
        /// The charge level node color.
        static let soulsContainerColor = SKColor.yellow
    }
    
    // MARK: Properties
    
    var level: Double = 0.0 {
        didSet {

            let action = SKAction.scaleY(to: CGFloat(level), duration: Configuration.levelUpdateDuration)
            action.timingMode = .easeInEaseOut

            soulsContainer.run(action)
                        
            if (level == 1.0)
            {
                soulsContainer.color = SKColor.red
            }
            else
            {
                if (level > 0.7)
                {
                    soulsContainer.color = SKColor.orange

                }
                else
                {
                    soulsContainer.color = SKColor.yellow
                }
            }
        }
    }
    
    /// A node representing the charge level.
    let soulsContainer = SKSpriteNode(color: Configuration.soulsContainerColor, size: Configuration.soulsContainerSize)
    
    /// A node representing the overlay
    let overlayNode = SKSpriteNode(texture: SKTexture(imageNamed: "hudBlackSquare"), color: .black, size: Configuration.soulsContainerTextureSize)
    
    // MARK: Initializers
    
    init() {
        super.init(texture: nil, color: Configuration.backgroundColor, size: CGSize(width: 0, height: 0))
        self.anchorPoint = CGPoint(x: 0.0, y: 1.0)
        self.zPosition = 100
//        Hide the container because, at the start, it appears to fill and in the wrong position.
        soulsContainer.isHidden = true
        soulsContainer.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.1),
            SKAction.run {self.soulsContainer.isHidden = false }]))
        soulsContainer.zPosition = 98
        addChild(soulsContainer)
        overlayNode.anchorPoint = CGPoint(x: 0.0, y: 1.0)
        overlayNode.zPosition = 99
        addChild(overlayNode)
        
        // Constrain the position of the `chargeLevelNode`.
        let xRange = SKRange(constantValue: 0.0)
        let yRange = SKRange(constantValue: -overlayNode.size.height/1.5)
        
        let constraint = SKConstraint.positionX(xRange, y: yRange)
        constraint.referenceNode = self
        
        soulsContainer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        soulsContainer.constraints = [constraint]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
