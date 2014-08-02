//
//  Enemy.swift
//  Swift XBlaster
//
//  Created by Edward Kenworthy on 12/06/2014.
//  Copyright (c) 2014 Himeji Heavy Industry. All rights reserved.
//

import SpriteKit

func RandomFloatRange(min:CGFloat, max:CGFloat) -> CGFloat
{
    return ((CGFloat(arc4random()) / 0xFFFFFFFF) * (max - min) + min)
}

class Enemy : Entity
{    
    // Type
    /*class*/ let _texture:SKTexture = Enemy.generateTexture()
    
    class func generateTexture() -> SKTexture
    {
        var enemyShip = SKLabelNode(fontNamed: "Arial")
        enemyShip.name = "enemyship"
        enemyShip.fontSize = 20
        enemyShip.fontColor = SKColor.whiteColor()
        enemyShip.text = "(=⚇=)"

        var textureView = SKView()
        var texture = textureView.textureFromNode(enemyShip)
        texture.filteringMode = .Nearest
        
        return texture
    }
    
    /*class*/ let _damageAction = SKAction.sequence([  SKAction.colorizeWithColor(SKColor.redColor(), colorBlendFactor:1.0, duration:0.0),
                                                                SKAction.colorizeWithColorBlendFactor(0.0, duration:1.0)])
    /*class*/ let _hitLeftAction =  SKAction.sequence([SKAction.rotateToAngle(DegreesToRadians(-15), duration:0.25), SKAction.rotateToAngle(0, duration:0.5)])
    /*class*/ let _hitRightAction = SKAction.sequence([SKAction.rotateToAngle(DegreesToRadians(15), duration:0.25), SKAction.rotateToAngle(0, duration:0.5)])
    /*class*/ let _moveBackAction = SKAction.moveByX(0, y:20, duration:0.25)

    // sequence of two groups
    /*class*/ let _scoredLabelAction = SKAction.sequence([
        // first groups is the "label appears" effect. It should scare to 1 over 0 seconds (resetting the scale to 1), fade in over 0 seconds (resetting alpha to 0), fade in over 0.5 seconds (the "real" fade-in), and move 20 points up along the y-axis over 0.5 seconds.
                                                            SKAction.group([SKAction.scaleTo(1.0, duration: 0),
                                                                            SKAction.fadeOutWithDuration(0),
                                                                            SKAction.fadeInWithDuration(0.5),
                                                                            SKAction.moveByX(0, y:20, duration:0.5)]),
        // the second group is the "label disappears" effect. It should move by 40 along the y axis over 1 second and fade out over 1 second.
                                                            SKAction.group([SKAction.fadeOutWithDuration(1.0),
                                                                            SKAction.moveByX(0, y:40, duration:1.0)]),
        // and finally remove the label
                                                            SKAction.removeFromParent()]);
    
    /*class*/ let _score = 225
    /*class*/ let _damageTakenPerShot = 5
    /*class*/ let _healthMeterText = "________"
    
    override /*class*/ func getTexture() -> SKTexture
    {
        return _texture
    }

    // Instance
    
    var _aiSteering:AISteering?
    let _scoredLabel = SKLabelNode(fontNamed:"Thirteen Pixel Fonts") // used to show the amount scored when the enemy is killed

    init(texture:SKTexture?, color:UIColor?, size:CGSize)
        /* LOL WUT?!? */
    {
        super.init(texture: texture, color: color, size: size)
    }

    init(pos:CGPoint)
    {
        super.init(pos:pos)
        
        name = "enemy"
        
        // Setup the steering AI to move to that waypoint
        _aiSteering = AISteering(entity: self, waypoint:CGPointMake(RandomFloatRange(50, 200), RandomFloatRange(50, 550)))
        
        // Setup the enemies health
        var healthMeterNode:SKLabelNode = SKLabelNode(fontNamed:"Arial")
        healthMeterNode.text = _healthMeterText
        healthMeterNode.name = "healthMeter"
        healthMeterNode.fontSize = 10
        healthMeterNode.fontColor = SKColor.greenColor()
        healthMeterNode.position = CGPointMake(0, 15)

        addChild(healthMeterNode)
        
        _health = 100
        _maxHealth = 100
        
        configureCollisionBody()
        
        // setup the "scored" label
        _scoredLabel.text = "\(_score)"
        _scoredLabel.name = "scoredLabel"
        _scoredLabel.fontSize = 25
        _scoredLabel.fontColor = SKColor(   red:0.5,
                                            green:1.0,
                                            blue:1.0,
                                            alpha:1.0)
    }

    override func update(delta:CFTimeInterval)
    {
        if let ai = _aiSteering
        {
            // Check to see if we have reached the current waypoint and if so set the next one
            if (ai.waypointReached())
            {
                ai.updateWaypoint( CGPointMake(RandomFloatRange(100, self.scene.size.width - 100),
                                                        RandomFloatRange(100, self.scene.size.height - 100)))
            }
            // Update the steering AI which will position the entity based on randomly generated waypoints
            ai.update(delta)
        }
        // Update the health meter
        var healthMeter = self.childNodeWithName("healthMeter") as SKLabelNode
        healthMeter.text = _healthMeterText.substringToIndex(Int(CGFloat(_health) / 100.0 * CGFloat(countElements(_healthMeterText))))
        
        healthMeter.fontColor = SKColor(red:(2.0 * (1.0 - CGFloat(_health) / 100)),
                                        green:(2.0 * CGFloat(_health) / 100),
                                        blue:0,
                                        alpha:1.0)
    }
    
    override func configureCollisionBody()
    {
        physicsBody = SKPhysicsBody(rectangleOfSize: self.frame.size)
        physicsBody.affectedByGravity = false

    // Set the category of the physics object that will be used for collisions
        physicsBody.categoryBitMask = ColliderType.Enemy.toRaw()

    // We want to know when a collision happens but we dont want the bodies to actually react to each other so we
    // set the collisionBitMask to 0
        physicsBody.collisionBitMask = 0

    // Make sure we get told about these collisions
        physicsBody.contactTestBitMask = ColliderType.Player.toRaw() | ColliderType.Bullet.toRaw();
    }
    
    override func collidedWith(body:SKPhysicsBody, contact:SKPhysicsContact)
    {
//        NSLog("Enemy collided!")

        // Get the contact point at which the bodies collided
        let localContactPoint:CGPoint = scene.convertPoint(contact.contactPoint, toNode:self)
        
        // Remove all the current actions. Their current effect on the enemy ship will remain unchanged so the new action
        // will transition smoothly to the new action
        removeAllActions()

        // Depending on which side the enemy was hit, rotate the ship
        if (localContactPoint.x < 0)
        {
            runAction(_hitLeftAction)
        }
        else
        {
            runAction(_hitRightAction)
        }
    
        // Set up an action that will make the entity flash red with damage
        self.runAction(_damageAction)
    
        // If the entity is moving down the screen then make the ship slow down by moving it back a little with an action
        if let ai = _aiSteering
        {
            if (ai.currentDirection().y < 0)
            {
                self.runAction(_moveBackAction)
            }
        }
        // Reduce the health of the enemy ship
        _health -= _damageTakenPerShot
    
        // If the enemies health is now below 0 then add the enemyDeath emitter to the scene and reset the enemies position to off screen
        if (_health <= 0)
        {
            (scene as GameScene).increaseScoreBy(_score)

            // Create a "new" enemy by re-using the old one.
            _health = _maxHealth;

            _scoredLabel.position = position
            _scoredLabel.removeAllActions()
            (scene as GameScene)._hudLayerNode.addChild(_scoredLabel)
            _scoredLabel.runAction(_scoredLabelAction)
            
            // Now position the entity above the top of the screen so it can fly into view
            position = CGPointMake(RandomFloatRange(100, scene.size.width - 100), scene.size.height + 50)
            runAction(SKAction.moveTo(CGPointMake(RandomFloatRange(100, scene.size.width - 100), scene.size.height + 50), duration: 0))
        }
    }
}

