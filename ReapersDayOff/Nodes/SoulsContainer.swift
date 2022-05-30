//
//  SoulsContainer.swift
//  ReapersDayOff
//
//  Created by Claudio Silvestri on 26/05/22.
//

import SpriteKit

//var soulsContainer = SKSpriteNode(texture: nil, color: UIColor.yellow, size: CGSize(width: 0, height: 0))
//
//let soulsContainerTexture = SKSpriteNode(texture: SKTexture(imageNamed: "hudBlack"), color: UIColor.gray, size: CGSize(width: 0, height: 0))
//
//let barSize = CGSize(width: frame.height / 10, height: 0)
//soulsContainer.anchorPoint.y = 0
//soulsContainer.anchorPoint.x = 0
//soulsContainer.size = barSize
//scaleSoulsContainer()
//soulsContainer.zPosition = WorldLayer.top.rawValue
//camera!.addChild(soulsContainer)
//
//let SoulsContainerTextureSize = CGSize(width: frame.height / 10, height: frame.height / 10)
//soulsContainerTexture.anchorPoint.y = 1
//soulsContainerTexture.anchorPoint.x = 0
//soulsContainerTexture.size = SoulsContainerTextureSize
//soulsContainerTexture.zPosition = WorldLayer.top.rawValue + 1
//scaleSoulsContainerTexture()
//camera!.addChild(soulsContainerTexture)
//
//func scaleSoulsContainer() {
//
//   // Make sure the score node is positioned at the top of the scene.
//   soulsContainer.position.y = size.height / 2.5
//
//    // Make sure the score node is positioned at the right of the scene.
//    soulsContainer.position.x = -size.width / 2.25
//
//   // Add padding between the top of scene and the top of the score node.
//   #if os(tvOS)
//   soulsContainer.position.y -= GameplayConfiguration.Timer.paddingSize
//   #else
//   soulsContainer.position.y -= GameplayConfiguration.Timer.paddingSize * timerNode.fontSize
//   #endif
//}
//
//func scaleSoulsContainerTexture() {
//
//   // Make sure the score node is positioned at the top of the scene.
//   soulsContainerTexture.position.y = size.height / 2.0
//
//    // Make sure the score node is positioned at the right of the scene.
//    soulsContainerTexture.position.x = -size.width / 2.25
//
//   // Add padding between the top of scene and the top of the score node.
//   #if os(tvOS)
//    soulsContainerTexture.position.y -= GameplayConfiguration.Timer.paddingSize
//   #else
//    soulsContainerTexture.position.y -= GameplayConfiguration.Timer.paddingSize * timerNode.fontSize
//   #endif
//}

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
    
    var level: Double = 1.0 {
        didSet {
            let action = SKAction.scaleX(to: CGFloat(level), duration: Configuration.levelUpdateDuration)
            action.timingMode = .easeInEaseOut

            soulsContainer.run(action)
        }
    }
    
    /// A node representing the charge level.
    let soulsContainer = SKSpriteNode(color: Configuration.soulsContainerColor, size: Configuration.soulsContainerSize)
    
    /// A node representing the overlay
    let overlayNode = SKSpriteNode(texture: SKTexture(imageNamed: "hudBlack"), color: .black, size: Configuration.soulsContainerTextureSize)
    
    // MARK: Initializers
    
    init() {
        super.init(texture: nil, color: Configuration.backgroundColor, size: Configuration.soulsContainerSize)
        self.anchorPoint = CGPoint(x: 0.0, y: 1.0)
        addChild(soulsContainer)
        overlayNode.anchorPoint = CGPoint(x: 0.0, y: 1.0)
        addChild(overlayNode)
        
        // Constrain the position of the `chargeLevelNode`.
        let xRange = SKRange(constantValue: 1.0)
        let yRange = SKRange(constantValue: 0.0)
        
        let constraint = SKConstraint.positionX(xRange, y: yRange)
        constraint.referenceNode = self
        
        soulsContainer.anchorPoint = CGPoint(x: 0.0, y: 1.0)
        soulsContainer.constraints = [constraint]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
