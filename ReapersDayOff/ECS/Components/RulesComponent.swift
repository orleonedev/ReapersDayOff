//
//  RulesComponent.swift
//  ReapersDayOff
//
//  Created by Maria Smirnova on 11/05/22.
//

import GameplayKit

protocol RulesComponentDelegate: AnyObject {
    // Called whenever the rules component finishes evaluating its rules.
    func rulesComponent(rulesComponent: RulesComponent, didFinishEvaluatingRuleSystem ruleSystem: GKRuleSystem)
}

class RulesComponent: GKComponent {
    // MARK: Properties
    
    weak var delegate: RulesComponentDelegate?
    
    var ruleSystem: GKRuleSystem
    
    /// The amount of time that has passed since the `TaskBot` last evaluated its rules.
    private var timeSinceRulesUpdate: TimeInterval = 0.0
    
    // MARK: Initializers
    
    override init() {
        ruleSystem = GKRuleSystem()
        super.init()
    }
    
    init(rules: [GKRule]) {
        ruleSystem = GKRuleSystem()
        ruleSystem.add(rules)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: GKComponent Life Cycle
    
    override func update(deltaTime seconds: TimeInterval) {
        timeSinceRulesUpdate += seconds
        
        if timeSinceRulesUpdate < GameplayConfiguration.Soul.rulesUpdateWaitDuration { return }
        
        timeSinceRulesUpdate = 0.0
        
        if let soul = entity as? Soul,
            let level = soul.component(ofType: RenderComponent.self)?.node.scene as? RDOLevelScene,
            let entitySnapshot = level.entitySnapshotForEntity(entity: soul)
        {

            ruleSystem.reset()
            
            ruleSystem.state["snapshot"] = entitySnapshot
        
            ruleSystem.evaluate()
            
            delegate?.rulesComponent(rulesComponent: self, didFinishEvaluatingRuleSystem: ruleSystem)
        }
    }
}

