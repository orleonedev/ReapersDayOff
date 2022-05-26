//
//  RDOLevelStateSnapshot.swift
//  ReapersDayOff
//
//  Created by Maria Smirnova on 10/05/22.
//

import GameplayKit

/// Encapsulates two entities and their distance apart.
struct EntityDistance {
    let source: GKEntity
    let target: GKEntity
    let distance: Float
}
    
/**
    Stores a snapshot of the state of a level and all of its entities
    (`PlayerBot`s and `TaskBot`s) at a certain point in time.
*/
class RDOLevelStateSnapshot {
    // MARK: Properties
    
    /// A dictionary whose keys are entities, and whose values are entity snapshots for those entities.
    var entitySnapshots: [GKEntity: EntitySnapshot] = [:]
    
    // MARK: Initialization

    /// Initializes a new `LevelStateSnapshot` representing all of the entities in a `LevelScene`.
    init(scene: RDOLevelScene) {
        
        /// Returns the `GKAgent2D` for a `PlayerBot` or `TaskBot`.
        func agentForEntity(entity: GKEntity) -> GKAgent2D {
            if let agent = entity.component(ofType: SoulAgent.self) {
                return agent
            }
            else if let reaper = entity as? Reaper {
                return reaper.agent
            } else if let agent = entity.component(ofType: EnemyAgent.self) {
                return agent
            }
            
            fatalError("All entities in a level must have an accessible associated GKEntity")
        }

        // A dictionary that will contain a temporary array of `EntityDistance` instances for each entity.
        var entityDistances: [GKEntity: [EntityDistance]] = [:]

        // Add an empty array to the dictionary for each entity, ready for population below.
        for entity in scene.entities {
            entityDistances[entity] = []
        }

        /*
            Iterate over all entities in the scene to calculate their distance from other entities.
            `scene.entities` is a `Set`, which does not have integer indexing.
            Because we want to use the current index value from the outer loop as the seed for the inner loop,
            we work with the `Set` index values directly.
        */
        for sourceEntity in scene.entities {
            let sourceIndex = scene.entities.firstIndex(of: sourceEntity)!

            // Retrieve the `GKAgent` for the source entity.
            let sourceAgent = agentForEntity(entity: sourceEntity)
            
            // Iterate over the remaining entities to calculate their distance from the source agent.
            for targetEntity in scene.entities[scene.entities.index(after: sourceIndex) ..< scene.entities.endIndex] {
                // Retrieve the `GKAgent` for the target entity.
                let targetAgent = agentForEntity(entity: targetEntity)
                
                // Calculate the distance between the two agents.
                let dx = targetAgent.position.x - sourceAgent.position.x
                let dy = targetAgent.position.y - sourceAgent.position.y
                let distance = hypotf(dx, dy)

                // Save this distance to both the source and target entity distance arrays.
                entityDistances[sourceEntity]!.append(EntityDistance(source: sourceEntity, target: targetEntity, distance: distance))
                entityDistances[targetEntity]!.append(EntityDistance(source: targetEntity, target: sourceEntity, distance: distance))

            }
        }
        
        // Determine the number of "good" `TaskBot`s and "bad" `TaskBot`s in the scene.
//        let souls = scene.entities.reduce(([])) {
//
//            (workingArrays: (souls: [Soul]), thisEntity: GKEntity) -> [Soul] in
//
//            // Try to cast this entity as a `TaskBot`, and skip this entity if the cast fails.
//            guard let thisSoul = thisEntity as? Soul else { return workingArrays }
//
//            // Add this `TaskBot` to the appropriate working array based on whether it is "good" or not.
////            if thisTaskBot.isGood {
////                return (workingArrays.goodBots + [thisTaskBot], workingArrays.badBots)
////            }
////            else {
////                return (workingArrays.goodBots, workingArrays.badBots + [thisTaskBot])
////            }
//
//        }
        
//        let soulPercentage = Float(badTaskBots.count) / Float(goodTaskBots.count + badTaskBots.count)
        
        // Create and store an entity snapshot in the `entitySnapshots` dictionary for each entity.
//        for entity in scene.entities {
//            let entitySnapshot = EntitySnapshot(soulPercentage: soulPercentage, proximityFactor: scene.levelConfiguration.proximityFactor, entityDistances: entityDistances[entity]!)
//            entitySnapshots[entity] = entitySnapshot
//        }

    }
    
}

class EntitySnapshot {
    // MARK: Properties
    
    /// Percentage of `TaskBot`s in the level that are bad.
    let soulPercentage: Float
    
    /// The factor used to normalize distances between characters for 'fuzzy' logic.
    let proximityFactor: Float
    
    /// Distance to the `PlayerBot` if it is targetable.
    let reaperTarget: (target: Reaper, distance: Float)?
    
    /// The nearest "good" `TaskBot`.
//    let nearestGoodTaskBotTarget: (target: TaskBot, distance: Float)?
    
    /// A sorted array of distances from this entity to every other entity in the level.
    let entityDistances: [EntityDistance]
    
    // MARK: Initialization
    
    init(soulPercentage: Float, proximityFactor: Float, entityDistances: [EntityDistance]) {
        self.soulPercentage = soulPercentage
        self.proximityFactor = proximityFactor

        // Sort the `entityDistances` array by distance (nearest first), and store the sorted version.
        self.entityDistances = entityDistances.sorted {
            return $0.distance < $1.distance
        }
        
        var reaperTarget: (target: Reaper, distance: Float)?
//        var nearestGoodTaskBotTarget: (target: TaskBot, distance: Float)?
        
        /*
            Iterate over the sorted `entityDistances` array to find the `PlayerBot`
            (if it is targetable) and the nearest "good" `TaskBot`.
        */
        for entityDistance in self.entityDistances {
            if let target = entityDistance.target as? Reaper, reaperTarget == nil && target.isFleeable {
                reaperTarget = (target: target, distance: entityDistance.distance)
            }
//            else if let target = entityDistance.target as? TaskBot, nearestGoodTaskBotTarget == nil && target.isGood {
//                nearestGoodTaskBotTarget = (target: target, distance: entityDistance.distance)
//            }

            // Stop iterating over the array once we have found both the `PlayerBot` and the nearest good `TaskBot`.
//            if playerBotTarget != nil && nearestGoodTaskBotTarget != nil {
//                break
//            }
        }
        
        self.reaperTarget = reaperTarget
//        self.nearestGoodTaskBotTarget = nearestGoodTaskBotTarget
    }
}

