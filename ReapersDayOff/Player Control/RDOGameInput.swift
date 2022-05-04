//
//  RDOGameInput.swift
//  ReapersDayOff
//
//  Created by Oreste Leone on 04/05/22.
//

import GameController

protocol GameInputDelegate: AnyObject {
    // Called whenever a control input source is updated.
    func gameInputDidUpdateControlInputSources(gameInput: RDOGameInput)
}

final class RDOGameInput {
    
    /// The control input source that is native to the platform (keyboard or touch).
    let nativeControlInputSource: ControlInputSourceType
    
    /// An optional secondary input source for a connected game controller.
    private(set) var secondaryControlInputSource: GameControllerInputSource?
    
    var isGameControllerConnected: Bool {
        var isGameControllerConnected = false
        controlsQueue.sync {
            isGameControllerConnected = (self.secondaryControlInputSource != nil) || (self.nativeControlInputSource is GameControllerInputSource)
        }
        return isGameControllerConnected
    }

    var controlInputSources: [ControlInputSourceType] {
        // Return a non-optional array of `ControlInputSourceType`s.
        let sources: [ControlInputSourceType?] = [nativeControlInputSource, secondaryControlInputSource]
        
        return sources.compactMap { return $0 as ControlInputSourceType? }
    }

    weak var delegate: GameInputDelegate? {
        didSet {
            // Ensure the delegate is aware of the player's current controls.
            delegate?.gameInputDidUpdateControlInputSources(gameInput: self)
        }
    }
    
    /// An internal queue to protect accessing the player's control input sources.
    private let controlsQueue = DispatchQueue(label: "tatsureraGames.ReapersDayOff.player.controlsqueue")
    
    // MARK: Initialization

    init(nativeControlInputSource: ControlInputSourceType) {
        self.nativeControlInputSource = nativeControlInputSource
        
        registerForGameControllerNotifications()
    }
    
    /// Register for `GCGameController` pairing notifications.
    func registerForGameControllerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(RDOGameInput.handleControllerDidConnectNotification(notification:)), name: NSNotification.Name.GCControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RDOGameInput.handleControllerDidDisconnectNotification(notification:)), name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.GCControllerDidConnect, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
    }
    
    func update(withGameController gameController: GCController) {
        controlsQueue.sync {
            /*
                If not already assigned, add a game controller as the player's
                secondary control input source.
            */
            if self.secondaryControlInputSource == nil {
                let gameControllerInputSource = GameControllerInputSource(gameController: gameController)
                self.secondaryControlInputSource = gameControllerInputSource
                gameController.playerIndex = .index1
            }
        }
    }
    
    // MARK: GCGameController Notification Handling
    
    @objc func handleControllerDidConnectNotification(notification: NSNotification) {
        let connectedGameController = notification.object as! GCController
        
        update(withGameController: connectedGameController)
        delegate?.gameInputDidUpdateControlInputSources(gameInput: self)
    }
    
    @objc func handleControllerDidDisconnectNotification(notification: NSNotification) {
        let disconnectedGameController = notification.object as! GCController
        
        // Check if the player was being controlled by the disconnected controller.
        if secondaryControlInputSource?.gameController == disconnectedGameController {
            controlsQueue.sync {
                self.secondaryControlInputSource = nil
            }
            
            // Check for any other connected controllers.
            if let gameController = GCController.controllers().first {
                update(withGameController: gameController)
            }
            
            delegate?.gameInputDidUpdateControlInputSources(gameInput: self)
        }
    }
}
