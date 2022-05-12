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
    
    var redSouls: UInt = 0
    var greenSouls: UInt = 0
    var blueSouls: UInt = 0
    var isFull: Bool {
        return (redSouls+greenSouls+blueSouls) == soulLimit
    }
    
     var soulLimit: UInt = 15
     let timeLimit: TimeInterval = 60.0
    
    func setupGame(){
        redSouls = 0
        greenSouls = 0
        blueSouls = 0
        
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
