//
//  InputComponent.swift
//  ReapersDayOff
//
//  Created by Oreste Leone on 09/05/22.
//

import SpriteKit
import GameplayKit
import GameController

class InputComponent: GKComponent, ControlInputSourceDelegate {
    // MARK: Types
    
    struct InputState {
        var translation: MovementKind?
        var rotation: MovementKind?
        var beamIsTriggered = false
        var allowsStrafing = false
        
        static let noInput = InputState()
    }
    
    // MARK: Properties
    
    /**
        `InputComponent` has the ability to ignore input when disabled.

        This is used to prevent the player from moving or firing while
        being attacked.
    */
    
    var isEnabled = true {
        didSet {
            if isEnabled {
                // Apply the current input state to the movement and beam components.
                applyInputState(state: state)
            }
            else {
                // Apply a state of no input to the movement and beam components.
                applyInputState(state: InputState.noInput)
            }
        }
    }
    
    var state = InputState() {
        didSet {
            if isEnabled {
                applyInputState(state: state)
            }
        }
    }
    
    // MARK: ControlInputSourceDelegate
    
    func controlInputSource(_ controlInputSource: ControlInputSourceType, didUpdateDisplacement displacement: SIMD2<Float>) {
        state.translation = MovementKind(displacement: displacement)
    }
    
    func controlInputSource(_ controlInputSource: ControlInputSourceType, didUpdateAngularDisplacement angularDisplacement: SIMD2<Float>) {
        state.rotation = MovementKind(displacement: angularDisplacement)
    }
    
    func controlInputSource(_ controlInputSource: ControlInputSourceType, didUpdateWithRelativeDisplacement relativeDisplacement: SIMD2<Float>) {
        /*
            Create a `MovementKind` instance indicating whether the displacement
            should translate the entity forwards or backwards from the direction
            it is facing.
        */
        state.translation = MovementKind(displacement: relativeDisplacement, relativeToOrientation: true)
    }
    
    func controlInputSource(_ controlInputSource: ControlInputSourceType, didUpdateWithRelativeAngularDisplacement relativeAngularDisplacement: SIMD2<Float>) {
        /*
            Create a `MovementKind` instance indicating whether the displacement
            should rotate the entity clockwise or counter-clockwise from the direction
            it is facing.
        */
        state.rotation = MovementKind(displacement: relativeAngularDisplacement, relativeToOrientation: true)
    }
    
    func controlInputSourceDidBeginAttacking(_ controlInputSource: ControlInputSourceType) {
        state.allowsStrafing = controlInputSource.allowsStrafing
        state.beamIsTriggered = true
    }
    
    func controlInputSourceDidFinishAttacking(_ controlInputSource: ControlInputSourceType) {
        state.beamIsTriggered = false
    }
    
    // MARK: Convenience
    
    func applyInputState(state: InputState) {
        if let movementComponent = entity?.component(ofType: MovementComponent.self) {
            movementComponent.allowsStrafing = state.allowsStrafing
            movementComponent.nextRotation = state.rotation
            movementComponent.nextTranslation = state.translation
            if state.beamIsTriggered {
                if let levelScene = entity?.component(ofType: RenderComponent.self)?.node.scene as? RDOLevelScene {
                    levelScene.isSpeeding = true
                    if !GameplayLogic.sharedInstance().isFull{
                            if GCController.current != nil {
                                HapticUtility.playHapticsFile(named: "Sprint")
                            } else {
//                                let haptic = UIImpactFeedbackGenerator(style: .light)
//                                haptic.impactOccurred()
                            }
                    
                    }
                }
            }else{
                
                if let levelScene = entity?.component(ofType: RenderComponent.self)?.node.scene as? RDOLevelScene {
                    levelScene.isSpeeding = false
                }
            }
        }
        
//        if let beamComponent = entity?.component(ofType: BeamComponent.self) {
//            beamComponent.isTriggered = state.beamIsTriggered
//        }
        
    }
}

