//
//  Entity.swift
//  Swift XBlaster
//
//  Created by Edward Kenworthy on 05/06/2014.
//  Copyright (c) 2014 Himeji Heavy Industry. All rights reserved.
//

//import Foundation
//import UIKit
import SpriteKit

func DegreesToRadians(d:CGFloat) -> CGFloat {return CGFloat(M_PI) * d / 180.0}
func RadiansToDegrees(r:CGFloat) -> CGFloat {return r * 180.0 / CGFloat(M_PI)}

class Entity : SKSpriteNode
{
    enum ColliderType : UInt32
    {
        case Player  = 1
        case Enemy   = 2
        case Bullet  = 4
        case Powerup = 8
    }
    
    /*class*/ func getTexture() -> SKTexture?
    {
        // overidden by sub-classes
        return nil
    }

    var _direction = CGPointZero
    var _health = 0
    var _maxHealth = 0

    init(texture:SKTexture?, color:UIColor?, size:CGSize)
    /* LOL WUT?!? */
    {
        super.init(texture: texture, color: color, size: size)
    }

    init(pos:CGPoint)
    {
        super.init()
        texture = self.getTexture()
        size = self.texture.size()
        position = pos
    }
    
    func update(delta:CFTimeInterval)
    {
        // overriden by sub-classes
    }

    func configureCollisionBody()
    {
    // Overridden by a subclass
    }
    
    func collidedWith(body:SKPhysicsBody, contact:SKPhysicsContact)
    {
    // Overridden by a subclass
    }
    
}