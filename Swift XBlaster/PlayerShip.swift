//
//  PlayerShip.swift
//  Swift XBlaster
//
//  Created by Edward Kenworthy on 05/06/2014.
//  Copyright (c) 2014 Himeji Heavy Industry. All rights reserved.
//

//import Foundation
//import UIKit
import SpriteKit

class PlayerShip : Entity
{
    // Type
    /*class*/ let _texture:SKTexture = PlayerShip.generateTexture()
    
    class func generateTexture() -> SKTexture
    {
        //2
        var mainShip = SKLabelNode(fontNamed: "Arial")
        mainShip.name = "mainship"
        mainShip.fontSize = 20
        mainShip.fontColor = SKColor.whiteColor()
        mainShip.text = "▲"
        // 3
        var wings = SKLabelNode(fontNamed: "Arial")
        wings.name = "wings"
        wings.fontSize = 20
        wings.fontColor = SKColor.whiteColor()
        wings.text = "< >"
        wings.position = CGPointMake(0, 7)
        
        // 4
        wings.zRotation = DegreesToRadians(180)
        
        mainShip.addChild(wings)
        
        // 5
        var textureView = SKView()
        var texture = textureView.textureFromNode(mainShip)
        texture.filteringMode = .Nearest
        
        return texture
    }
    
    override /*class*/ func getTexture() -> SKTexture
    {
        return _texture
    }

    // Instance
    init(texture:SKTexture?, color:UIColor?, size:CGSize)
    /* LOL WUT?!? */
    {
        super.init(texture: texture, color: color, size: size)
        name = "shipSprite"
        _health = 100
    }
    
    init(pos:CGPoint)
    {
        super.init(pos: pos)
        name = "shipSprite"
        _health = 100
        
        configureCollisionBody()
    }

    override func configureCollisionBody()
    {
        // self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:[self childNodeWithName:@"shipSprite"].frame.size];
        physicsBody = SKPhysicsBody(circleOfRadius:15)
        physicsBody.affectedByGravity = false
    
        // Set the category of the physics object that will be used for collisions
        physicsBody.categoryBitMask = ColliderType.Player.toRaw()
    
        // We want to know when a collision happens but we dont want the bodies to actually react to each other so we
        // set the collisionBitMask to 0
        physicsBody.collisionBitMask = 0
    
        // Make sure we get told about these collisions
        physicsBody.contactTestBitMask = ColliderType.Enemy.toRaw()
    }
    
    override func collidedWith(body:SKPhysicsBody, contact:SKPhysicsContact)
    {
        _health -= 5
        if (_health < 0)
        {
            _health = 0
        }
        NSLog("PlayerShip collided! (\(_health))")
    }
}
