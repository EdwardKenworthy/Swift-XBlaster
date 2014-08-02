//
//  Bullet.swift
//  Swift XBlaster
//
//  Created by Edward Kenworthy on 10/06/2014.
//  Copyright (c) 2014 Himeji Heavy Industry. All rights reserved.
//

//import UIKit
import SpriteKit

/*class*/ let _texture:SKTexture = Bullet.generateTexture() // should be a class member of Bullet

class Bullet : Entity
{
    /********
       Type
    *********/
    class func generateTexture() -> SKTexture
    {
        //2
        var bullet = SKLabelNode(fontNamed: "Arial")
        bullet.name = "bullet"
        bullet.fontSize = 20
        bullet.fontColor = SKColor.whiteColor()
        bullet.text = "."
        
        // 5
        var texture = SKView().textureFromNode(bullet)
        texture.filteringMode = .Nearest
        
        return texture
    }
    
    override /*class*/ func getTexture() -> SKTexture
    {
        return _texture
    }
    /***********
       Instance
    ************/
    init(texture:SKTexture?, color:UIColor?, size:CGSize)
        /* LOL WUT?!? */
    {
        super.init(texture: texture, color: color, size: size)
        self.name = "bulletSprite"
    }
    
    init(pos:CGPoint)
    {
        super.init(pos: pos)
        self.name = "bulletSprite"
        
        configureCollisionBody()
    }
    
    override func configureCollisionBody()
    {
        self.physicsBody = SKPhysicsBody(circleOfRadius:5)
        self.physicsBody.affectedByGravity = false;
    
        // Set the category of the physics object that will be used for collisions
        self.physicsBody.categoryBitMask = ColliderType.Bullet.toRaw()
    
        // We want to know when a collision happens but we dont want the bodies to actually react to each other so we
        // set the collisionBitMask to 0
        self.physicsBody.collisionBitMask = 0;
    
        // Make sure we get told about these collisions
        self.physicsBody.contactTestBitMask = ColliderType.Enemy.toRaw();
    }

    override func collidedWith(body:SKPhysicsBody, contact:SKPhysicsContact)
    {
//        NSLog("Bullet collided")
        self.removeFromParent()
    }
    
}

