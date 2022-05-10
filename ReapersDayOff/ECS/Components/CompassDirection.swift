//
//  CompassDirection.swift
//  ReapersDayOff
//
//  Created by Maria Smirnova on 05/05/22.
//

import CoreGraphics

/// The different directions that an animated character can be facing.
enum CompassDirection: Int {
    case east = 0, northEast
    case north, northWest
    case west, southWest
    case south, southEast
    
    /// Convenience array of all available directions.
    static let allDirections: [CompassDirection] =
        [
            .east, .northEast,
            .north, .northWest,
            .west, .southWest,
            .south, .southEast
        ]
    
    /// The angle of rotation that the orientation represents.
    var zRotation: CGFloat {
        // Calculate the number of radians between each direction.
        let stepSize = CGFloat.pi * 2 / CGFloat(CompassDirection.allDirections.count)
        
        return CGFloat(self.rawValue) * stepSize
    }
    
    /// Creates a new `FacingDirection` for a given `zRotation` in radians.
    init(zRotation: CGFloat) {
        let twoPi = Double.pi * 2
        
        // Normalize the node's rotation.
        let rotation = (Double(zRotation) + twoPi).truncatingRemainder(dividingBy: twoPi)
        
        // Convert the rotation of the node to a percentage of a circle.
        let orientation = rotation / twoPi
        
        // Scale the percentage to a value between 0 and 15.
        let rawFacingValue = round(orientation * 8.0).truncatingRemainder(dividingBy: 8.0)
        
        // Select the appropriate `CompassDirection` based on its members' raw values, which also run from 0 to 15.
        self = CompassDirection(rawValue: Int(rawFacingValue))!
    }
    
    init(string: String) {
        switch string {
            case "North":
                self = .north
                
            case "NorthEast":
                self = .northEast
                
            case "East":
                self = .east
                
            case "SouthEast":
                self = .southEast
                
            case "South":
                self = .south
                
            case "SouthWest":
                self = .southWest
                
            case "West":
                self = .west
                
            case "NorthWest":
                self = .northWest
                
            default:
                fatalError("Unknown or unsupported string - \(string)")
        }
    }
}

