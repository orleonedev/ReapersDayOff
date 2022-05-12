//
//  RDORules.swift
//  ReapersDayOff
//
//  Created by Maria Smirnova on 10/05/22.
//

import GameplayKit

enum Fact: String {
    // Fuzzy rules pertaining to the proportion of "bad" bots in the level.
    case soulPercentageLow = "SoulPercentageLow"
    case soulPercentageMedium = "SoulPercentageMedium"
    case soulPercentageHigh = "SoulPercentageHigh"

    // Fuzzy rules pertaining to this `TaskBot`'s proximity to the `PlayerBot`.
    case reaperNear = "ReaperNear"
    case reaperMedium = "ReaperMedium"
    case reaperFar = "ReaperFar"

    // Fuzzy rules pertaining to this `TaskBot`'s proximity to the nearest "good" `TaskBot`.
//    case goodTaskBotNear = "GoodTaskBotNear"
//    case goodTaskBotMedium = "GoodTaskBotMedium"
//    case goodTaskBotFar = "GoodTaskBotFar"
}

/// Asserts whether the number of "bad" `TaskBot`s is considered "low".
class SoulPercentageLowRule: FuzzySoulRule {
    // MARK: Properties
    
    override func grade() -> Float {
        return max(0.0, 1.0 - 3.0 * snapshot.soulPercentage)
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .soulPercentageLow) }
}

/// Asserts whether the number of "bad" `TaskBot`s is considered "medium".
class SoulPercentageMediumRule: FuzzySoulRule {
    // MARK: Properties
    
    override func grade() -> Float {
        if snapshot.soulPercentage <= 1.0 / 3.0 {
            return min(1.0, 3.0 * snapshot.soulPercentage)
        }
        else {
            return max(0.0, 1.0 - (3.0 * snapshot.soulPercentage - 1.0))
        }
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .soulPercentageMedium) }
}

/// Asserts whether the number of "bad" `TaskBot`s is considered "high".
class SoulPercentageHighRule: FuzzySoulRule {
    // MARK: Properties
    
    override func grade() -> Float {
        return min(1.0, max(0.0, (3.0 * snapshot.soulPercentage - 1)))
    }
    
    // MARK: Initializers
    
    init() { super.init(fact: .soulPercentageHigh) }
}

/// Asserts whether the `PlayerBot` is considered to be "near" to this `TaskBot`.
//class ReapertNearRule: FuzzySoulRule {
//    // MARK: Properties
//
//    override func grade() -> Float {
//        guard let distance = snapshot.reaperTarget?.distance else { return 0.0 }
//        let oneThird = snapshot.proximityFactor / 3
//        return (oneThird - distance) / oneThird
//    }
//
//    // MARK: Initializers
//    
//    init() { super.init(fact: .reaperNear) }
//}

/// Asserts whether the `PlayerBot` is considered to be at a "medium" distance from this `TaskBot`.
//class ReaperMediumRule: FuzzySoulRule {
//    // MARK: Properties
//
//    override func grade() -> Float {
//        guard let distance = snapshot.reaperTarget?.distance else { return 0.0 }
//        let oneThird = snapshot.proximityFactor / 3
//        return 1 - (abs(distance - oneThird) / oneThird)
//    }
//
//    // MARK: Initializers
//
//    init() { super.init(fact: .reaperMedium) }
//}

/// Asserts whether the `PlayerBot` is considered to be "far" from this `TaskBot`.
//class ReaperFarRule: FuzzySoulRule {
//    // MARK: Properties
//
//    override func grade() -> Float {
//        guard let distance = snapshot.reaperTarget?.distance else { return 0.0 }
//        let oneThird = snapshot.proximityFactor / 3
//        return (distance - oneThird) / oneThird
//    }
//
//    // MARK: Initializers
//
//    init() { super.init(fact: .reaperFar) }
//}

// MARK: TaskBot Proximity Rules

/// Asserts whether the nearest "good" `TaskBot` is considered to be "near" to this `TaskBot`.
//class GoodTaskBotNearRule: FuzzyTaskBotRule {
//    // MARK: Properties
//
//    override func grade() -> Float {
//        guard let distance = snapshot.nearestGoodTaskBotTarget?.distance else { return 0.0 }
//        let oneThird = snapshot.proximityFactor / 3
//        return (oneThird - distance) / oneThird
//    }
//
//    // MARK: Initializers
//
//    init() { super.init(fact: .goodTaskBotNear) }
//}

/// Asserts whether the nearest "good" `TaskBot` is considered to be at a "medium" distance from this `TaskBot`.
//class GoodTaskBotMediumRule: FuzzyTaskBotRule {
//    // MARK: Properties
//
//    override func grade() -> Float {
//        guard let distance = snapshot.nearestGoodTaskBotTarget?.distance else { return 0.0 }
//        let oneThird = snapshot.proximityFactor / 3
//        return 1 - (abs(distance - oneThird) / oneThird)
//    }
//
//    // MARK: Initializers
//
//    init() { super.init(fact: .goodTaskBotMedium) }
//}

/// Asserts whether the nearest "good" `TaskBot` is considered to be "far" from this `TaskBot`.
//class GoodTaskBotFarRule: FuzzyTaskBotRule {
//    // MARK: Properties
//
//    override func grade() -> Float {
//        guard let distance = snapshot.nearestGoodTaskBotTarget?.distance else { return 0.0 }
//        let oneThird = snapshot.proximityFactor / 3
//        return (distance - oneThird) / oneThird
//    }
//
//    // MARK: Initializers
//
//    init() { super.init(fact: .goodTaskBotFar) }
//}

