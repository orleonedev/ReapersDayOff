//
//  OrientationComponent.swift
//  ReapersDayOff
//
//  Created by Maria Smirnova on 05/05/22.
//

import SpriteKit
import GameplayKit

class OrientationComponent: GKComponent {
    // MARK: Properties
    
    var zRotation: CGFloat = 0.0 {
        didSet {
            let twoPi = CGFloat.pi * 2
            zRotation = (zRotation + twoPi).truncatingRemainder(dividingBy: twoPi)
        }
    }
    
    var compassDirection: CompassDirection {
        get {
            return CompassDirection(zRotation: zRotation)
        }
        
        set {
            zRotation = newValue.zRotation
        }
    }
}

