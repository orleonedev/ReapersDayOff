//
//  GameplayLogic.swift
//  ReapersDayOff
//
//  Created by Oreste Leone on 12/05/22.
//

import Foundation

class GameplayLogic {
    
    public class func sharedInstance() -> GameplayLogic {
        return GameplayLogicInstance
    }
    
    var highScore: Int {
        get{
            return UserDefaults.standard.integer(forKey: "HighScore")
        }
        set{
            UserDefaults.standard.set(newValue, forKey: "HighScore")
        }
    }
    
    var currentScore: UInt = 0
    var redSouls: UInt = 0
    var greenSouls: UInt = 0
    var blueSouls: UInt = 0
    var sumSoul: UInt {
        return redSouls+greenSouls+blueSouls
    }
    var isFull: Bool {
        return sumSoul == soulLimit
    }
    
     var soulLimit: UInt = 10
     let timeLimit: TimeInterval = 60.0
    var timeRemaining: TimeInterval = 0.0
    
    func setupGame(){
        currentScore = 0
        redSouls = 0
        greenSouls = 0
        blueSouls = 0
        timeRemaining = timeLimit
        
    }
    
    func deposit(type: String){
        switch type {
        case "red":
            timeRemaining += Double(redSouls)/2
            currentScore += redSouls
            redSouls = 0
        case "green":
            timeRemaining += Double(greenSouls)/2
            currentScore += greenSouls
            greenSouls = 0
        case "blue":
            timeRemaining += Double(blueSouls)/2
            currentScore += blueSouls
            blueSouls = 0
        default:
            fatalError("Unknown Gate type")
        }
        
        
        
    }
    
    func addSouls(type: String){
        switch type{
        case "red":
            redSouls += 1
        case "blue":
            blueSouls += 1
        case "green":
            greenSouls += 1
        default:
            fatalError("Unknown Soul type")
        }
        
    }
    
}

private let GameplayLogicInstance = GameplayLogic()
