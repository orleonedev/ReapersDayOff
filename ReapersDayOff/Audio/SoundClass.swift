//
//  SoundClass.swift
//  ReapersDayOff
//
//  Created by Oreste Leone on 06/06/22.
//

import Foundation
import AVFoundation

public class SoundClass {
    public var backgroundMusicPlayer: AVAudioPlayer?
    public var soundEffectPlayer: AVAudioPlayer?
    public var soundEffectPlayer2: AVAudioPlayer?
    
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
            player.volume = 0.3
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
            player.volume = 0.3
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
            player.volume = 0.1
            player.play()
        } else {
            print("Could not create audio player: \(error!)")
        }
    }
    
}

private let SoundClassInstance = SoundClass()