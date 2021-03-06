//
//  SoulBehavior.swift
//  ReapersDayOff
//
//  Created by Maria Smirnova on 05/05/22.
//

import SpriteKit
import GameplayKit

class SoulBehavior: GKBehavior {
    
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
    
    /// Adds goals to follow and stay on a path.
    private func addFollowAndStayOnPathGoals(for path: GKPath) {
        // The "follow path" goal tries to keep the agent facing in a forward direction when it is on this path.
        setWeight(1.0, for: GKGoal(toFollow: path, maxPredictionTime: GameplayConfiguration.Soul.maxPredictionTimeWhenFollowingPath, forward: true))

        // The "stay on path" goal tries to keep the agent on the path within the path's radius.
        setWeight(1.0, for: GKGoal(toStayOn: path, maxPredictionTime: GameplayConfiguration.Soul.maxPredictionTimeWhenFollowingPath))
    }
}
