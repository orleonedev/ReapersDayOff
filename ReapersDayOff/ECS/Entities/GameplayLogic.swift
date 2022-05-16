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
    
    var score: UInt = 0
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
    
    func setupGame(){
        score = 0
        redSouls = 0
        greenSouls = 0
        blueSouls = 0
        
    }
    
    func deposit(type: String){
        switch type {
        case "red":
            score += redSouls
            redSouls = 0
        case "green":
            score += greenSouls
            greenSouls = 0
        case "blue":
            score += blueSouls
            blueSouls = 0
        default:
            print("Unknown Gate type")
        }
        
        print("Red:\(redSouls) Green:\(greenSouls) Blue:\(blueSouls) Total:\(sumSoul)")
        
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
        print("Red:\(redSouls) Green:\(greenSouls) Blue:\(blueSouls) Total:\(sumSoul)")
    }
    
}

private let GameplayLogicInstance = GameplayLogic()
