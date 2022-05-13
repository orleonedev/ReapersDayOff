//
//  ContactNode.swift
//  ReapersDayOff
//
//  Created by Maria Smirnova on 12/05/22.
//

import UIKit
import SpriteKit
import GameplayKit
 
class ContactNode: SKShapeNode, GKAgentDelegate {
         
    var agent = GKAgent2D()
     
    //  MARK: Agent Delegate
    func agentWillUpdate(agent: GKAgent) {
        if let agent2D = agent as? GKAgent2D {
            agent2D.position = SIMD2<Float>(Float(position.x), Float(position.y))
        }
    }
     
    func agentDidUpdate(agent: GKAgent) {
        if let agent2D = agent as? GKAgent2D {
            self.position = CGPoint(x: CGFloat(agent2D.position.x), y: CGFloat(agent2D.position.y))
        }
    }
}
