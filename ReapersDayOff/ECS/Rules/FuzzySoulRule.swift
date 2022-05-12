//
//  FuzzySoulRule.swift
//  ReapersDayOff
//
//  Created by Maria Smirnova on 10/05/22.
//

import GameplayKit

class FuzzySoulRule: GKRule {
    // MARK: Properties
    
    var snapshot: EntitySnapshot!
    
    func grade() -> Float { return 0.0 }
    
    let fact: Fact
    
    // MARK: Initializers
    
    init(fact: Fact) {
        self.fact = fact
        
        super.init()
        
        // Set the salience so that 'fuzzy' rules will evaluate first.
        salience = Int.max
    }
    
    // MARK: GPRule Overrides
    
    override func evaluatePredicate(in system: GKRuleSystem) -> Bool {
        snapshot = system.state["snapshot"] as? EntitySnapshot
        
        if grade() >= 0.0 {
            return true
        }
        
        return false
    }
    
    override func performAction(in system: GKRuleSystem) {
        system.assertFact(fact.rawValue as NSObject, grade: grade())
    }
}

