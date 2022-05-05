//
//  GameControllerInputSource.swift
//  ReapersDayOff
//
//  Created by Oreste Leone on 04/05/22.
//

import SpriteKit
import GameController

class GameControllerInputSource: ControlInputSourceType {
    // MARK: Properties
    
    /// `ControlInputSourceType` delegates.
    weak var gameStateDelegate: ControlInputSourceGameStateDelegate?
    weak var delegate: ControlInputSourceDelegate?
    
    let allowsStrafing = true

    let gameController: GCController

    // MARK: Initializers
    
    init(gameController: GCController) {
        self.gameController = gameController
        
        registerPauseEvent()
        registerAttackEvents()
        registerMovementEvents()
        registerRotationEvents()
    }
    
    // MARK: Gamepad Registration Methods
    
    private func registerPauseEvent() {
        gameController.controllerPausedHandler = { [unowned self] _ in
            self.gameStateDelegate?.controlInputSourceDidTogglePauseState(self)
        }
    }
    
    private func registerAttackEvents() {
        /// A handler for button press events that trigger an attack action.
        let attackHandler: GCControllerButtonValueChangedHandler = { [unowned self] button, _, pressed in
            if pressed {
                self.delegate?.controlInputSourceDidBeginAttacking(self)
                
                self.gameStateDelegate?.controlInputSourceDidSelect(self)
                
            }
            else {
                self.delegate?.controlInputSourceDidFinishAttacking(self)
            }
        }
    
        // `GCExtendedGamepad` trigger handlers.
        if let extendedGamepad = gameController.extendedGamepad {
            
            /*
                Assign an action to every button, even if this means that multiple
                buttons provide the same functionality. It's better to have repeated
                functionality than to have a button that doesn't do anything.
            */
            extendedGamepad.buttonA.pressedChangedHandler = attackHandler
            extendedGamepad.buttonB.pressedChangedHandler = attackHandler
            extendedGamepad.buttonX.pressedChangedHandler = attackHandler
            extendedGamepad.buttonY.pressedChangedHandler = attackHandler
            extendedGamepad.leftShoulder.pressedChangedHandler = attackHandler
            extendedGamepad.rightShoulder.pressedChangedHandler = attackHandler
            extendedGamepad.rightTrigger.pressedChangedHandler = attackHandler
            extendedGamepad.leftTrigger.pressedChangedHandler  = attackHandler
        }
    }
    
    private func registerMovementEvents() {
        /// An analog movement handler for D-pads and movement thumbsticks.
        let movementHandler: GCControllerDirectionPadValueChangedHandler = { [unowned self] _, xValue, yValue in
            // Move toward the direction of the axis.
            let displacement = SIMD2<Float>(x: xValue, y: yValue)
            
            self.delegate?.controlInputSource(self, didUpdateDisplacement: displacement)
            
            if let direction = ControlInputDirection(vector: displacement) {
                self.gameStateDelegate?.controlInputSource(self, didSpecifyDirection: direction)
            }
        }
        
        // `GCExtendedGamepad` left thumbstick.
        if let extendedGamepad = gameController.extendedGamepad {
            extendedGamepad.leftThumbstick.valueChangedHandler = movementHandler
            extendedGamepad.dpad.valueChangedHandler = movementHandler
        }
    }
    
    private func registerRotationEvents() {
        // `GCExtendedGamepad` right thumbstick controls rotational attack independent of movement direction.
        if let extendedGamepad = gameController.extendedGamepad {
        
            extendedGamepad.rightThumbstick.valueChangedHandler = { [unowned self] _, xValue, yValue in
                // Rotate by the angle formed from the supplied axis.
                let angularDisplacement = SIMD2<Float>(x: xValue, y: yValue)
                
                self.delegate?.controlInputSource(self, didUpdateAngularDisplacement: angularDisplacement)
                
                // Attack while rotating. This closely mirrors the behavior of the iOS touch controls.
                if length(angularDisplacement) > 0 {
                    self.delegate?.controlInputSourceDidBeginAttacking(self)
                }
                else {
                    self.delegate?.controlInputSourceDidFinishAttacking(self)
                }
            }
        }
    }
    
    // MARK: ControlInputSourceType
    
    func resetControlState() {
        /*
            Check the current values of the dpad and right thumbstick to see if
            any direction is currently being requested for focused based navigation.
        
            This allows for continuous scrolling while using game controllers.
        */
        guard let dpad = gameController.microGamepad?.dpad else { return }
        let dpadDisplacement = SIMD2<Float>(x: dpad.xAxis.value, y: dpad.yAxis.value)
        
        if let inputDirection = ControlInputDirection(vector: dpadDisplacement) {
            gameStateDelegate?.controlInputSource(self, didSpecifyDirection: inputDirection)
            return
        }
        
        guard let thumbStick = gameController.extendedGamepad?.leftThumbstick else { return }
        let thumbStickDisplacement = SIMD2<Float>(x: thumbStick.xAxis.value, y: thumbStick.yAxis.value)
        
        if let inputDirection = ControlInputDirection(vector: thumbStickDisplacement) {
            gameStateDelegate?.controlInputSource(self, didSpecifyDirection: inputDirection)
        }
    }

}

