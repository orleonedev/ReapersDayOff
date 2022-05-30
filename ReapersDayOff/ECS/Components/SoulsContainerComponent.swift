//
//  SoulsContainerComponent.swift
//  ReapersDayOff
//
//  Created by Claudio Silvestri on 26/05/22.
//

import SpriteKit
import GameplayKit

protocol SoulsContainerComponentDelegate: AnyObject {
    // Called whenever a `ChargeComponent` loses charge through a call to `loseCharge`
    func soulsContainerComponentDidLoseCharge(soulsContainerComponent: SoulsContainerComponent)
}

class SoulsContainerComponent: GKComponent {
    // MARK: Properties
    
    var charge: Double
    
    let maximumCharge: Double

    var percentageCharge: Double {
        if maximumCharge == 0 {
            return 0.0
        }

        return charge / maximumCharge
    }
    
    var hasCharge: Bool {
        return (charge > 0.0)
    }
    
    var isFullyCharged: Bool {
        return charge == maximumCharge
    }

    /**
        A `ChargeBar` used to show the current charge level. The `ChargeBar`'s node
        is added to the scene when the component's entity is added to a `LevelScene`
        via `addEntity(_:)`.
    */
    let chargeBar: SoulsContainer?

    weak var delegate: SoulsContainerComponentDelegate?

    // MARK: Initializers

    init(charge: Double, maximumCharge: Double, displaysChargeBar: Bool = false) {
        self.charge = charge
        self.maximumCharge = maximumCharge

        // Create a `ChargeBar` if this `ChargeComponent` should display one.
        if displaysChargeBar {
            chargeBar = SoulsContainer()
        }
        else {
            chargeBar = nil
        }
        
        super.init()

        chargeBar?.level = percentageCharge
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Component actions
    
    func loseCharge(chargeToLose: Double) {
        var newCharge = charge - chargeToLose
        
        // Clamp the new value to the valid range.
        newCharge = min(maximumCharge, newCharge)
        newCharge = max(0.0, newCharge)
        
        // Check if the new charge is less than the current charge.
        if newCharge < charge {
            charge = newCharge
            chargeBar?.level = percentageCharge
            delegate?.soulsContainerComponentDidLoseCharge(soulsContainerComponent: self)
        }
    }
    
    func addCharge(chargeToAdd: Double) {
        var newCharge = charge + chargeToAdd
        
        // Clamp the new value to the valid range.
        newCharge = min(maximumCharge, newCharge)
        newCharge = max(0.0, newCharge)
        
        // Check if the new charge is greater than the current charge.
        if newCharge > charge {
            charge = newCharge
            chargeBar?.level = percentageCharge
        }
    }
}
