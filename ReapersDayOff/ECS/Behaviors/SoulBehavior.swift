//
//  SoulBehavior.swift
//  ReapersDayOff
//
//  Created by Maria Smirnova on 05/05/22.
//

import SpriteKit
import GameplayKit

class SoulBehavior: GKBehavior {
    
    // MARK: Behavior factory methods
    
    /// Constructs a behavior to hunt a `TaskBot` or `PlayerBot` via a computed path.
    static func behaviorAndPathPoints(forAgent agent: GKAgent2D, fleeAgent target: GKAgent2D, pathRadius: Float, inScene scene: RDOLevelScene) -> (behavior: GKBehavior, pathPoints: [CGPoint]) {
        let behavior = SoulBehavior()
        
        // Add basic goals to reach the `TaskBot`'s maximum speed and avoid obstacles.
        behavior.addTargetSpeedGoal(speed: agent.maxSpeed)
        behavior.addAvoidObstaclesGoal(forScene: scene)
        behavior.addFleeReaperGoal(forScene: scene)

        // Find any nearby "bad" TaskBots to flock with.
//        let agentsToFlockWith: [GKAgent2D] = scene.entities.compactMap { entity in
//            if let soul = entity as? Soul, soul.agent !== agent && soul.distanceToAgent(otherAgent: agent) <= GameplayConfiguration.Flocking.agentSearchDistanceForFlocking {
//                return soul.agent
//            }
//
//            return nil
//        }
        
//        if !agentsToFlockWith.isEmpty {
//            // Add flocking goals for any nearby "bad" `TaskBot`s.
//            let separationGoal = GKGoal(toSeparateFrom: agentsToFlockWith, maxDistance: GameplayConfiguration.Flocking.separationRadius, maxAngle: GameplayConfiguration.Flocking.separationAngle)
//            behavior.setWeight(GameplayConfiguration.Flocking.separationWeight, for: separationGoal)
//
//            let alignmentGoal = GKGoal(toAlignWith: agentsToFlockWith, maxDistance: GameplayConfiguration.Flocking.alignmentRadius, maxAngle: GameplayConfiguration.Flocking.alignmentAngle)
//            behavior.setWeight(GameplayConfiguration.Flocking.alignmentWeight, for: alignmentGoal)
//
//            let cohesionGoal = GKGoal(toCohereWith: agentsToFlockWith, maxDistance: GameplayConfiguration.Flocking.cohesionRadius, maxAngle: GameplayConfiguration.Flocking.cohesionAngle)
//            behavior.setWeight(GameplayConfiguration.Flocking.cohesionWeight, for: cohesionGoal)
//        }

        // Add goals to follow a calculated path from the `TaskBot` to its target.
        let pathPoints = behavior.addGoalsToFollowPath(from: agent.position, to: target.position, pathRadius: pathRadius, inScene: scene )
        
        // Return a tuple containing the new behavior, and the found path points for debug drawing.
        return (behavior, pathPoints)
    }
    /// Constructs a behavior to return to the start of a `TaskBot` patrol path.
    static func behaviorAndPathPoints(forAgent agent: GKAgent2D, returningToPoint endPoint: SIMD2<Float>, pathRadius: Float, inScene scene: RDOLevelScene) -> (behavior: GKBehavior, pathPoints: [CGPoint]) {
        let behavior = SoulBehavior()
        
        // Add basic goals to reach the `TaskBot`'s maximum speed and avoid obstacles.
        behavior.addTargetSpeedGoal(speed: agent.maxSpeed)
        behavior.addAvoidObstaclesGoal(forScene: scene)
        behavior.addFleeReaperGoal(forScene: scene)
        
        // Add goals to follow a calculated path from the `TaskBot` to the start of its patrol path.
        let pathPoints = behavior.addGoalsToFollowPath(from: agent.position, to: endPoint, pathRadius: pathRadius, inScene: scene)

        // Return a tuple containing the new behavior, and the found path points for debug drawing.
        return (behavior, pathPoints)
    }
    
    static func behaviorAndPathPoints(forAgent agent: GKAgent2D, fleeAgent target: GKAgent2D, pathRadius: Float, inScene scene: RDOLevelScene) {
        let behavior = SoulBehavior()
        
        
    }
    
//    (forAgent agent: GKAgent2D, fleeAgent target: GKAgent2D, pathRadius: Float, inScene scene: RDOLevelScene) -> (behavior: GKBehavior, pathPoints: [CGPoint])
    
    /// Constructs a behavior to patrol a path of points, avoiding obstacles along the way.
    static func behavior(forAgent agent: GKAgent2D, fleeAgent target: GKAgent2D, patrollingPathWithPoints patrolPathPoints: [CGPoint], pathRadius: Float, inScene scene: RDOLevelScene) -> GKBehavior {
        let behavior = SoulBehavior()
        
        // Add basic goals to reach the `TaskBot`'s maximum speed and avoid obstacles.
        behavior.addTargetSpeedGoal(speed: agent.maxSpeed)
        behavior.addAvoidObstaclesGoal(forScene: scene)
        behavior.addGoalsToFollowPath(from: agent.position, to: target.position, pathRadius: 20, inScene: scene)
        behavior.addFleeReaperGoal(forScene: scene)
        // Convert the patrol path to an array of `float2`s.
        
        let pathVectorPoints = patrolPathPoints.map { SIMD2<Float>($0) }
        
        // Create a cyclical (closed) `GKPath` from the provided path points with the requested path radius.
        // GKPath(points: &pathVectorPoints, radius: <#T##Float#>, cyclical: <#T##Bool#>)
        let path = GKPath(points: pathVectorPoints, radius: pathRadius, cyclical: true)

        // Add "follow path" and "stay on path" goals for this path.
        behavior.addFollowAndStayOnPathGoals(for: path)

        return behavior
    }
    
    private func extrudedObstaclesContaining(point: SIMD2<Float>, inScene scene: RDOLevelScene) -> [GKPolygonObstacle] {
        /*
            Add a small fudge factor (+5) to the extrusion radius to make sure
            we're including all obstacles.
        */
        let extrusionRadius = Float(GameplayConfiguration.Soul.pathfindingGraphBufferRadius) + 5

        /*
            Return only the polygon obstacles which contain the specified point.
            
            Note: This creates a bounding box around the polygon obstacle to check
            for intersection. This is appropriate for DemoBots, but in your game a
            more specific check may be necessary.
        */
        return scene.polygonObstacles.filter { obstacle in
            // Retrieve all vertices for the polygon obstacle.
            let range = 0..<obstacle.vertexCount
            
            let polygonVertices = range.map { obstacle.vertex(at: $0) }
            guard !polygonVertices.isEmpty else { return false }
            
            let maxX = polygonVertices.max { $0.x < $1.x }!.x + extrusionRadius
            let maxY = polygonVertices.max { $0.y < $1.y }!.y + extrusionRadius
            
            let minX = polygonVertices.min { $0.x < $1.x }!.x - extrusionRadius
            let minY = polygonVertices.min { $0.y < $1.y }!.y - extrusionRadius
            
            return (point.x > minX && point.x < maxX) && (point.y > minY && point.y < maxY)
        }
    }
    
    private func connectedNode(forPoint point: SIMD2<Float>, onObstacleGraphInScene scene: RDOLevelScene) -> GKGraphNode2D? {
        // Create a graph node for this point.
        let pointNode = GKGraphNode2D(point: point)
        
        // Try to connect this node to the graph.
        scene.graph.connectUsingObstacles(node: pointNode)

        /*
            Check to see if we were able to connect the node to the graph.
            If not, this means that the point is inside the buffer zone of an obstacle
            somewhere in the level. We can't pathfind to a point that is off-graph,
            so we try to find the nearest point that is on the graph, and pathfind
            to there instead.
        */
        if pointNode.connectedNodes.isEmpty {
            // The previous connection attempt failed, so remove the node from the graph.
            scene.graph.remove([pointNode])
        
            // Search the graph for all intersecting obstacles.
            let intersectingObstacles = extrudedObstaclesContaining(point: point, inScene: scene)
        
            /*
                Connect this node to the graph ignoring the buffer radius of any
                obstacles that the point is currently intersecting.
            */
            scene.graph.connectUsingObstacles(node: pointNode, ignoringBufferRadiusOf: intersectingObstacles)
        
            // If still no connection could be made, return `nil`.
            if pointNode.connectedNodes.isEmpty {
                scene.graph.remove([pointNode])
                return nil
            }
        }
        
        return pointNode
    }
    
    private func addGoalsToFollowPath(from startPoint: SIMD2<Float>, to endPoint: SIMD2<Float>, pathRadius: Float, inScene scene: RDOLevelScene) -> [CGPoint] {
        
        // Convert the provided `CGPoint`s into nodes for the `GPGraph`.
        guard let startNode = connectedNode(forPoint: startPoint, onObstacleGraphInScene: scene),
             let endNode = connectedNode(forPoint: endPoint, onObstacleGraphInScene: scene) else { return [] }
        
        // Remove the "start" and "end" nodes when exiting this scope.
        defer { scene.graph.remove([startNode, endNode]) }
        
        // Find a path between these two nodes.
        let pathNodes = scene.graph.findPath(from: startNode, to: endNode) as! [GKGraphNode2D]
        
        // A valid `GKPath` can not be created if fewer than 2 path nodes were found, return.
        guard pathNodes.count > 1 else { return [] }
        
        // Create a new `GKPath` from the found nodes with the requested path radius.
        let path = GKPath(graphNodes: pathNodes, radius: pathRadius)
        
        // Add "follow path" and "stay on path" goals for this path.
        addFollowAndStayOnPathGoals(for: path)
        
        // Convert the `GKGraphNode2D` nodes into `CGPoint`s for debug drawing.
        let pathPoints = pathNodes.map { CGPoint($0.position) }
        return pathPoints
    }
    
    /// Adds a goal to avoid all polygon obstacles in the scene.
    private func addAvoidObstaclesGoal(forScene scene: RDOLevelScene) {
        setWeight(1.0, for: GKGoal(toAvoid: scene.polygonObstacles, maxPredictionTime: GameplayConfiguration.Soul.maxPredictionTimeForObstacleAvoidance))
    }
    
    private func addFleeReaperGoal(forScene scene: RDOLevelScene) {
        setWeight(0.5, for: GKGoal(toFleeAgent: scene.reaper.agent))
    }
    
//    private func addAvoidReaperGoal(forScene scene: RDOLevelScene) {
//        setWeight(1.5, for: GKGoal(toAvoid: scene.reaper, maxPredictionTime: GameplayConfiguration.Soul.maxPredictionTimeForReaperAvoidance))
//    }
    
    /// Adds a goal to attain a target speed.
    private func addTargetSpeedGoal(speed: Float) {
        setWeight(1.0, for: GKGoal(toReachTargetSpeed: speed))
    }
    
    /// Adds goals to follow and stay on a path.
    private func addFollowAndStayOnPathGoals(for path: GKPath) {
        // The "follow path" goal tries to keep the agent facing in a forward direction when it is on this path.
        setWeight(0.5, for: GKGoal(toFollow: path, maxPredictionTime: GameplayConfiguration.Soul.maxPredictionTimeWhenFollowingPath, forward: true))

        // The "stay on path" goal tries to keep the agent on the path within the path's radius.
        setWeight(0.5, for: GKGoal(toStayOn: path, maxPredictionTime: GameplayConfiguration.Soul.maxPredictionTimeWhenFollowingPath))
    }
}
