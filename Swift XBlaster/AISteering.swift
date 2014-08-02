//
//  AISteering.swift
//  Swift XBlaster
//
//  Created by Edward Kenworthy on 12/06/2014.
//  Copyright (c) 2014 Himeji Heavy Industry. All rights reserved.
//

import SpriteKit
import GLKit

//func CGPointAdd(point1:CGPoint, point2:CGPoint) -> CGPoint {CGPointMake(point1.x + point2.x, point1.y + point2.y)}
//func CGPointSubtract(point1:CGPoint, point2:CGPoint) -> CGPoint {CGPointMake(point1.x - point2.x, point1.y - point2.y)}
func CGPointMultiplyScalar(point:CGPoint, value:CGFloat) -> CGPoint {return CGPointMake(point.x * value, point.y * value)}

class AISteering
{
    var _entity:Entity
    var _waypoint:CGPoint
    let _maxVelocity:CGFloat = 5.0
    let _maxSteeringForce:CGFloat = 0.03
    let _waypointRadius:CGFloat = 50.0
    var _waypointReached = false;
    var _faceDirectionOfTravel = false;
    var _currentDirection = CGPointZero
    
    init(entity:Entity, waypoint:CGPoint)
    {
        _waypoint = waypoint
        _entity = entity
    }
    
    func update(delta:CFTimeInterval)
    {
        // Get the entities current position
        var currentPosition = _entity.position
    
        // Work out the direction to the waypoint from where the entity currently is
        var desiredDirection = CGPointSubtract(_waypoint, currentPosition);
    
        // Calculate the distance from the entity to the waypoint
        var distanceToWaypoint = hypotf(desiredDirection.x, desiredDirection.y);
    
        // Update the desired location based on the maxVelocity that has been defined and distance to the waypoint
        desiredDirection = CGPointMultiplyScalar(desiredDirection, _maxVelocity / distanceToWaypoint);
    
        // Calculate the steering force needed to turn towards the waypoint
        var force = CGPointSubtract(desiredDirection, _currentDirection);
        var steeringForce = CGPointMultiplyScalar(force, _maxSteeringForce / _maxVelocity);

        // Calculate the direction for the entity based on the direction and steering force that can be applied
        _currentDirection = CGPointAdd(_currentDirection, steeringForce);

        // The final position for the entity is calculated by adding the current position of the entity to the direction
        // Update the position of the entity based on the steering calculations that have been performed
        _entity.position = CGPointAdd(currentPosition, _currentDirection);

        // Rotate the entity to face in the direction of travel if that property has been set
        if (_faceDirectionOfTravel)
        {
            _entity.zRotation = -(atan2f(CGFloat(_entity.position.x) - CGFloat(currentPosition.x), CGFloat(_entity.position.y) - CGFloat(currentPosition.y)));
        }
    
        // If the entity is within the waypointRadius then set the waypoint reached flag
        if (distanceToWaypoint < _waypointRadius)
        {
            _waypointReached = true;
        }
    }
    
    func waypointReached() -> Bool
    {
        return _waypointReached
    }
    
    func updateWaypoint(waypoint:CGPoint)
    {
        _waypoint = waypoint;
        _waypointReached = false;
    }
    
    func currentDirection() -> CGPoint
    {
        return _currentDirection
    }
}
