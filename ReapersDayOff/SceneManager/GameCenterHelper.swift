//
//  GameCenterHelper.swift
//  ReapersDayOff
//
//  Created by Oreste Leone on 10/06/22.
//

import Foundation
import GameKit

enum LeaderboardKinds: String {
    case score = "high_score"
    case hit = "hit_by_donnie"
    case stolen = "souls_stolen"
    case catched = "soul_catched"
    case games = "games_played"
}

public class GameCenterHelper {
    
    
    
    var viewDelegate: GameViewController?
    
    var gcEnabled = Bool()
    var gcDefaultLeaderboard = String()
    
    
    
    public class func sharedInstance() -> GameCenterHelper {
        return GameCenterHelperInstance
    }
    
    func authenticateLocalPlayer(){
        let localPlayer :GKLocalPlayer = GKLocalPlayer.local
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                // 1. Show login if player is not logged in
                ViewController?.present(ViewController!, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                // 2. Player is already authenticated & logged in, load game center
                self.gcEnabled = true
                
                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer, error) in
                    if error != nil { print(error)
                    } else { self.gcDefaultLeaderboard = leaderboardIdentifer! }
                })
                
            } else {
                // 3. Game center is not enabled on the users device
                self.gcEnabled = false
                print("Local player could not be authenticated!")
                print(error)
            }
        }
    }
    
    func showDefaultLeaderboard() {
        
        let viewController = GKGameCenterViewController(leaderboardID: gcDefaultLeaderboard, playerScope: .global, timeScope: .allTime)
        viewController.gameCenterDelegate = viewDelegate
        
        viewDelegate?.present(viewController, animated: true, completion: nil)
    }
    
    func showLeaderboards(){
        
        let viewController = GKGameCenterViewController(state: .leaderboards)
        viewController.gameCenterDelegate = viewDelegate
        viewDelegate?.present(viewController, animated: true, completion: nil)
    }
    
    func submitScore(kind: LeaderboardKinds, value: Int) {
        
        let leaderboard = kind.rawValue
        GKLeaderboard.submitScore(value, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [leaderboard]) {error in }
        
    }

}

private let GameCenterHelperInstance = GameCenterHelper()
