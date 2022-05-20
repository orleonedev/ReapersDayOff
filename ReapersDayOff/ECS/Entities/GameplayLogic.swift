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
    
    var totalSouls: Int {
        get {
            return UserDefaults.standard.integer(forKey: "SoulsCollected")
        }
        set {
            UserDefaults.standard.set(newValue,forKey: "SoulsCollected")
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
    let timeLimit: TimeInterval = 90.0
    var timeRemaining: TimeInterval = 0.0
    
    func setupGame(){
        currentScore = 0
        redSouls = 0
        greenSouls = 0
        blueSouls = 0
        timeRemaining = timeLimit
        
    }
    
    private func timeForDeposit(souls: UInt) -> Double{
        var ret: Double
        switch souls {
        case 0..<2:
            ret = Double(souls)*0.5
        case 2..<5:
            ret = Double(souls)
        case 5..<7:
            ret = Double(souls)*1.5
        case 7...10:
            ret = Double(souls)*2
        default:
            print("Unhandled number")
            ret = 0
        }
        return ret
    }
    private func pointsForDeposit(souls: UInt) -> UInt{
        var ret: UInt
        switch souls {
        case 0..<5:
            ret = souls
        case 5..<9:
            ret = UInt(Double(souls) * 1.5)
        case 9...10:
            ret = souls * 2
        default:
            print("Unhandled number")
            ret = 0
        }
        return ret
    }
    
    func deposit(type: String){
        switch type {
        case "red":
            timeRemaining += timeForDeposit(souls: redSouls)
            currentScore += pointsForDeposit(souls: redSouls)
            totalSouls += Int(redSouls)
            redSouls = 0
        case "green":
            timeRemaining += timeForDeposit(souls: greenSouls)
            currentScore += pointsForDeposit(souls: greenSouls)*2
            totalSouls += Int(greenSouls)
            greenSouls = 0
        case "blue":
            timeRemaining += timeForDeposit(souls: blueSouls)
            currentScore += pointsForDeposit(souls: blueSouls)*3
            totalSouls += Int(blueSouls)
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
