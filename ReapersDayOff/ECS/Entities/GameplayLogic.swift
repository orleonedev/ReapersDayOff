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
    
    var heartReaperHit : Int {
        get {
            return UserDefaults.standard.integer(forKey: "HeartReaperHit")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "HeartReaperHit")
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
    
    var gamesPlayed: Int {
        get {
            return UserDefaults.standard.integer(forKey: "GamesPlayed")
        }
        set {
            UserDefaults.standard.set(newValue,forKey: "GamesPlayed")
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
    let timeLimit: TimeInterval = 100.0
    var timeRemaining: TimeInterval = 0.0
    
    var soulsOnStage: UInt = 0
    func LOGAddSoulOnStage(n: UInt){
        soulsOnStage += n
//        print(soulsOnStage)
    }
    
    
    
    func LOGremoveSoulOnStage(n: UInt){
        soulsOnStage -= n
//        print(soulsOnStage)
    }
    
    
    
    var enemyOnStage: Bool = false
//    func LOGAddEnemyOnStage(n: UInt){
//        enemyOnStage += n
//        print(enemyOnStage)
//    }
//    func LOGremoveEnemyOnStage(n: UInt){
//        enemyOnStage -= n
//        print(enemyOnStage)
//    }
    
    func setupGame(){
        currentScore = 0
        redSouls = 0
        greenSouls = 0
        blueSouls = 0
        timeRemaining = timeLimit
        soulsOnStage = 0
        enemyOnStage = false
        
    }
    
    func timeForDeposit(souls: UInt) -> Double{
        var ret: Double
        switch souls {
        case 0..<2:
            ret = Double(souls)*0.5
        case 2..<5:
            ret = Double(souls)
        case 5..<9:
            ret = Double(souls)*1.5
        case 9...10:
            ret = Double(souls)*2
        default:
            print("Unhandled number")
            ret = 0
        }
        return ret
    }
    
    func pointsForDeposit(souls: UInt) -> UInt{
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
//            collectedSouls += UInt(totalSouls)
            LOGremoveSoulOnStage(n: redSouls)
            redSouls = 0
        case "green":
            timeRemaining += timeForDeposit(souls: greenSouls)*2
            currentScore += pointsForDeposit(souls: greenSouls)
            totalSouls += Int(greenSouls)
//            collectedSouls += UInt(totalSouls)
            LOGremoveSoulOnStage(n: greenSouls)
            greenSouls = 0
        case "blue":
            timeRemaining += timeForDeposit(souls: blueSouls)
            currentScore += pointsForDeposit(souls: blueSouls)*3
            totalSouls += Int(blueSouls)
//            collectedSouls += UInt(totalSouls)
            LOGremoveSoulOnStage(n: blueSouls)
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
    
    func loseSouls() {

        redSouls = redSouls/2
        greenSouls = greenSouls/2
        blueSouls = blueSouls/2
        
    }
}

private let GameplayLogicInstance = GameplayLogic()
