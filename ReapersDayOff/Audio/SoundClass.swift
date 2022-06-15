//
//  SoundClass.swift
//  ReapersDayOff
//
//  Created by Oreste Leone on 06/06/22.
//

import Foundation
import AVFoundation

protocol SoundDelegate: AnyObject {
    
    func soundEnabled()
}

public class SoundClass {
    public var backgroundMusicPlayer: AVAudioPlayer?
    public var soundEffectPlayer: AVAudioPlayer?
    public var soundEffectPlayer2: AVAudioPlayer?
    public var soundEffectPlayer3: AVAudioPlayer?
    public var soundEffectPlayer4: AVAudioPlayer?
    var delegate: SoundDelegate?
    
    public var enabled: Bool = true {
        willSet {
            if !newValue {
                backgroundMusicPlayer?.stop()
                soundEffectPlayer?.stop()
                soundEffectPlayer2?.stop()
                soundEffectPlayer3?.stop()
                soundEffectPlayer4?.stop()
            } else {
                delegate?.soundEnabled()
                
            }
        }
    }
    
    public class func sharedInstance() -> SoundClass {
        return SoundClassInstance
    }
    
    public func playBackgroundMusic(_ filename: String) {
        let url = Bundle.main.url(forResource: filename, withExtension: nil)
        if (url == nil) {
            print("Could not find file: \(filename)")
            return
        }
        
        var error: NSError? = nil
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url!)
        } catch let error1 as NSError {
            error = error1
            backgroundMusicPlayer = nil
        }
        if let player = backgroundMusicPlayer {
            player.numberOfLoops = -1
            player.prepareToPlay()
            player.volume = 0.2
            player.play()
        } else {
            print("Could not create audio player: \(error!)")
        }
    }
    
    public func pauseBackgroundMusic() {
      if let player = backgroundMusicPlayer {
        if player.isPlaying {
          player.pause()
        }
      }
    }
    
    public func resumeBackgroundMusic() {
      if let player = backgroundMusicPlayer {
        if !player.isPlaying {
          player.play()
        }
      }
    }
    
    public func playSoundEffect(_ filename: String) {
        let url = Bundle.main.url(forResource: filename, withExtension: nil)
        if (url == nil) {
            print("Could not find file: \(filename)")
            return
        }
        
        var error: NSError? = nil
        do {
            soundEffectPlayer = try AVAudioPlayer(contentsOf: url!)
        } catch let error1 as NSError {
            error = error1
            soundEffectPlayer = nil
        }
        if let player = soundEffectPlayer {
            player.numberOfLoops = 0
            player.prepareToPlay()
            player.volume = 0.4
            player.play()
        } else {
            print("Could not create audio player: \(error!)")
        }
    }
    
    public func playSoundEffect2(_ filename: String) {
        let url = Bundle.main.url(forResource: filename, withExtension: nil)
        if (url == nil) {
            print("Could not find file: \(filename)")
            return
        }
        
        var error: NSError? = nil
        do {
            soundEffectPlayer2 = try AVAudioPlayer(contentsOf: url!)
        } catch let error1 as NSError {
            error = error1
            soundEffectPlayer2 = nil
        }
        if let player = soundEffectPlayer2 {
            player.numberOfLoops = 0
            player.prepareToPlay()
            player.volume = 0.4
            player.play()
        } else {
            print("Could not create audio player: \(error!)")
        }
    }
    
    public func playSoundEffect3(_ filename: String) {
        let url = Bundle.main.url(forResource: filename, withExtension: nil)
        if (url == nil) {
            print("Could not find file: \(filename)")
            return
        }
        
        var error: NSError? = nil
        do {
            soundEffectPlayer3 = try AVAudioPlayer(contentsOf: url!)
        } catch let error1 as NSError {
            error = error1
            soundEffectPlayer3 = nil
        }
        if let player = soundEffectPlayer3 {
            player.numberOfLoops = 0
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
        } else {
            print("Could not create audio player: \(error!)")
        }
    }
    
    public func playSoundEffect4(_ filename: String) {
        let url = Bundle.main.url(forResource: filename, withExtension: nil)
        if (url == nil) {
            print("Could not find file: \(filename)")
            return
        }
        
        var error: NSError? = nil
        do {
            soundEffectPlayer4 = try AVAudioPlayer(contentsOf: url!)
        } catch let error1 as NSError {
            error = error1
            soundEffectPlayer4 = nil
        }
        if let player = soundEffectPlayer4 {
            player.numberOfLoops = 0
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
        } else {
            print("Could not create audio player: \(error!)")
        }
    }
    
}

private let SoundClassInstance = SoundClass()
