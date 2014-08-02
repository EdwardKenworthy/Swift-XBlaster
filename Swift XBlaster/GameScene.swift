//
//  GameScene.swift
//  Swift XBlaster
//
//  Created by Edward Kenworthy on 04/06/2014.
//  Copyright (c) 2014 Himeji Heavy Industry. All rights reserved.
//

import SpriteKit

func CGPointSubtract(point1:CGPoint, point2:CGPoint) -> CGPoint {return CGPointMake(point1.x - point2.x, point1.y - point2.y)}
func CGPointAdd(point1:CGPoint, point2:CGPoint) -> CGPoint {return CGPointMake(point1.x + point2.x, point1.y + point2.y)}
func Clamp(value:CGFloat, min:CGFloat, max:CGFloat) -> CGFloat {return (value < min ? min : value > max ? max : value)}

class GameScene: SKScene, SKPhysicsContactDelegate
{
    let _playerLayerNode = SKNode()
    let _bulletLayerNode = SKNode()
    let _enemyLayerNode = SKNode()
    let _hudLayerNode = SKNode()

//    let _fontName = "Thirteen Pixel Fonts"
    
    let _scoreFlashAction = SKAction.sequence([
                                SKAction.scaleTo(1.5, duration: 0.1),
                                SKAction.scaleTo(1.0, duration: 0.1)])

    var _moveBulletAction:SKAction?
    
    let _healthBar = "==================================================="
    let _playerHealthLabel = SKLabelNode(fontNamed:"Thirteen Pixel Fonts")
    
    // 1
    let scoreLabel = SKLabelNode(fontNamed:"Thirteen Pixel Fonts")
    var _score:Int = 0
    
    var _playerShip = PlayerShip(pos: CGPointZero)
    var _deltaPoint = CGPointZero
    
    // Bullets
    var _bulletInterval:NSTimeInterval = 0.0
    var _lastUpdateTime:CFTimeInterval?
    var _dt:NSTimeInterval = 0
    
    enum GameState:Int
    {
        case GAME_RUNNING = 0, GAME_OVER
    }
    var _gameState:GameState = GameState.GAME_RUNNING
    
    /* GAME OVER */
    var _gameOverLabel = SKLabelNode(fontNamed:"Thirteen Pixel Fonts")
    var _tapScreenLabel = SKLabelNode(fontNamed:"Thirteen Pixel Fonts")
    let _gameOverPulse = SKAction.repeatActionForever( SKAction.sequence([  SKAction.fadeOutWithDuration(1.0),
                                                                            SKAction.fadeInWithDuration(1.0)]))
    
    init(size: CGSize)
    {
        super.init(size: size)
        
        // Configure the physics world
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
        setupSceneLayers()
        setupUI()
        setupEntities()
        
        if (!_moveBulletAction?)
        {
            _moveBulletAction = SKAction.sequence([ SKAction.moveToY(self.size.height, duration: 1.5),
                                                    SKAction.removeFromParent()])
        }
    }
    
    func setupEntities()
    {
        _playerShip.position = CGPointMake(self.size.width / 2.0, 100)
        _playerLayerNode.addChild(_playerShip)

        for i in 0..3
        {
            var x:CGFloat = RandomFloatRange(50.0, self.size.width - 50.0);
            var y:CGFloat = self.size.height - 150
            NSLog("Adding enemy @(\(x), \(y))")
            _enemyLayerNode.addChild(Enemy(pos: CGPointMake(x, y)))
        }
        
    }
    
    func setupSceneLayers()
    {
        self.addChild(_playerLayerNode)
        self.addChild(_bulletLayerNode)
        self.addChild(_enemyLayerNode)
        self.addChild(_hudLayerNode) // because this is added last, it is at the top
    }

    func setupUI()
    {
        let barHeight:CGFloat = 45
        let backgroundSize = CGSizeMake(self.size.width, barHeight)
        
        let backgroundColor = SKColor(red: 0, green: 0, blue: 0.05, alpha: 1.0)
        let hudBarBackground = SKSpriteNode(color: backgroundColor, size: backgroundSize)

        hudBarBackground.position = CGPointMake(0.0, self.size.height - barHeight)
        hudBarBackground.anchorPoint = CGPointZero
        _hudLayerNode.addChild(hudBarBackground)
        
        // 2
        scoreLabel.fontSize = 20.0
        scoreLabel.text = "Score: 0"
        scoreLabel.name = "scoreLabel"
        // 3
        scoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        // 4
        scoreLabel.position = CGPointMake(  self.size.width / 2,
                                            self.size.height - scoreLabel.frame.size.height)
        // 5
        _hudLayerNode.addChild(scoreLabel)
        
        // Bounce the score
        scoreLabel.runAction(SKAction.repeatAction(_scoreFlashAction, count: 10))
        
        setupHealthBar(barHeight)
        
        setupGameOver()
    }
    
    func setupHealthBar(barHeight:CGFloat)
    {
        //2
        let playerHealthBackground = SKLabelNode(fontNamed:"Thirteen Pixel Fonts")
        playerHealthBackground.name = "playerHealthBackground"
        playerHealthBackground.fontColor = SKColor.darkGrayColor()
        playerHealthBackground.fontSize = 10
        playerHealthBackground.text = _healthBar
        
        //3
        playerHealthBackground.horizontalAlignmentMode = .Left
        playerHealthBackground.verticalAlignmentMode = .Top
        playerHealthBackground.position = CGPointMake(0.0,
            CGFloat(self.size.height) - barHeight + CGFloat(playerHealthBackground.frame.size.height))
        _hudLayerNode.addChild(playerHealthBackground)
        
        //4
        _playerHealthLabel.name = "playerHealth"
        _playerHealthLabel.fontColor = SKColor.whiteColor()
        _playerHealthLabel.fontSize = 10
        _playerHealthLabel.text = _healthBar
        _playerHealthLabel.horizontalAlignmentMode = .Left
        _playerHealthLabel.verticalAlignmentMode = .Top
        _playerHealthLabel.position = CGPointMake(0.0,
            CGFloat(self.size.height) - barHeight + CGFloat(_playerHealthLabel.frame.size.height))
        _hudLayerNode.addChild(_playerHealthLabel)
    }

    func setupGameOver()
    {
        _gameOverLabel.name = "gameOver";
        _gameOverLabel.fontSize = 40.0
        _gameOverLabel.fontColor = SKColor.whiteColor()
        _gameOverLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        _gameOverLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        _gameOverLabel.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)
        _gameOverLabel.text = "GAME OVER"
        
        _tapScreenLabel.name = "tapScreen"
        _tapScreenLabel.fontSize = 20.0
        _tapScreenLabel.fontColor = SKColor.whiteColor()
        _tapScreenLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center;
        _tapScreenLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center;
        _tapScreenLabel.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 - 100);
        _tapScreenLabel.text = "Tap Screen To Restart"
    }
    
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!)
    {
        if _gameState == GameState.GAME_OVER {restartGame()}
    }
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!)
    {
        let currentPoint = touches.anyObject().locationInNode(self)
        let previousPoint = touches.anyObject().previousLocationInNode(self)
        _deltaPoint = CGPointSubtract(currentPoint, previousPoint)
    }
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!)
    {
        _deltaPoint = CGPointZero
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!)
    {
        _deltaPoint = CGPointZero
    }
    
    override func update(currentTime: CFTimeInterval)
    {
        //1
        var newPoint = CGPointAdd(_playerShip.position, _deltaPoint)
        
        //2
        newPoint.x = Clamp( newPoint.x,
                            _playerShip.size.width / 2,
                            self.size.width - _playerShip.size.width / 2)
        newPoint.y = Clamp( newPoint.y,
                            _playerShip.size.height / 2,
                            self.size.height - _playerShip.size.height / 2)
        
        //3
        _playerShip.position = newPoint

        if let lastUpdateTime = _lastUpdateTime
        {
            _dt = currentTime - lastUpdateTime
        }
        _lastUpdateTime = currentTime
        
        switch _gameState
        {
            case GameState.GAME_RUNNING: gameRunning()
            case GameState.GAME_OVER: gameOver()
        }
    }
    
    func gameRunning()
    /**
        Called from update whilst the game is in the GAME_RUNNING state
    **/
    {
        // NSLog("Game Running")
        // update enemies
        _enemyLayerNode.enumerateChildNodesWithName("enemy", usingBlock:
            {(enemy:SKNode!, stop:CMutablePointer<ObjCBool>) in
                (enemy as Enemy).update(self._dt)})
    
        // Update player
        //                [_playerShip update:timeDelta];
    
        // Bullets
        _bulletInterval += _dt
        if (_bulletInterval > 0.15)
        {
            //1 Create bullet
            var bullet = Bullet(pos: _playerShip.position)
    
            //2 Add to scene
            _playerLayerNode.addChild(bullet)
    
            //3 Sequence: move up screen, remove from parent
            bullet.runAction(_moveBulletAction)
    
            _bulletInterval = 0
        }
    
        // Update player health
        // Update the healthbar color and length based on the...urm...players health :)
        _playerHealthLabel.fontColor = SKColor( red:CGFloat(2.0 * (1.0 - CGFloat(_playerShip._health) / 100)),
                                                green:CGFloat(2.0 * CGFloat(_playerShip._health) / 100),
                                                blue:0,
                                                alpha:1.0)
        _playerHealthLabel.text = _healthBar.substringToIndex((_playerShip._health * countElements(_healthBar)) / 100)
    
        // If the players health has dropped to <= 0 then set the game state to game over
        if (_playerShip._health <= 0)
        {
            NSLog("_playerShip._health = 0! GAME OVER!")
            _gameState = GameState.GAME_OVER;
        }
    }
    
    func gameOver()
    /**
        Called from update whilst the game is in the GAME_OVER state
    **/
    {
        // If the game over message has not been added to the scene yet then add it
        if !_gameOverLabel.parent?
        {
            NSLog("GAME OVER")
            // Remove the bullets, enemites and player from the scene as the game is over
            _bulletLayerNode.enumerateChildNodesWithName("bullet", usingBlock:
                {(bullet:SKNode!, stop:CMutablePointer<ObjCBool>) in
                    bullet.removeFromParent()})

            _enemyLayerNode.enumerateChildNodesWithName("enemy", usingBlock:
                {(enemy:SKNode!, stop:CMutablePointer<ObjCBool>) in
                    enemy.removeFromParent()})
        
            _playerShip.removeFromParent()
        
            _hudLayerNode.addChild(_gameOverLabel)
            _hudLayerNode.addChild(_tapScreenLabel)
            _tapScreenLabel.runAction(_gameOverPulse)
        }

        // Randomly set the color of the game over label
        var newColor = SKColor( red:CGFloat(RandomFloatRange(0.0, 1.0)),
            green:CGFloat(RandomFloatRange(0.0, 1.0)),
                                blue:CGFloat(RandomFloatRange(0.0, 1.0)),
                                alpha:1.0)
        _gameOverLabel.fontColor = newColor;
    }

    func restartGame()
    {
        // Reset the state of the game
        _gameState = GameState.GAME_RUNNING

        // Set up the entities again and the score
        setupEntities()
        _score = 0;

        // Reset the score and the players health
        let scoreLabel = _hudLayerNode.childNodeWithName("scoreLabel") as SKLabelNode
        scoreLabel.text = "Score: 0"
        _playerShip._health = 100;
        _playerShip.position = CGPointMake(self.frame.size.width / 2, 100);

        // Remove the game over HUD labels
        _hudLayerNode.childNodeWithName("gameOver").removeFromParent()
        _hudLayerNode.childNodeWithName("tapScreen").removeAllActions()
        _hudLayerNode.childNodeWithName("tapScreen").removeFromParent()
    }
    
    func increaseScoreBy(increment:Int)
    {
        _score += increment
        var scoreLabel = _hudLayerNode.childNodeWithName("scoreLabel") as SKLabelNode
        scoreLabel.text = "Score: \(_score)"
        scoreLabel.removeAllActions()
        scoreLabel.runAction(_scoreFlashAction)
    }
    
//    #pragma mark -
//    #pragma mark Physics Contact Delegate

    func didBeginContact(contact:SKPhysicsContact)
    {
//        NSLog("didBeginContact")
        // Grab the first body that has been involved in the collision and call it's collidedWith method
        // allowing it to react to the collision...
        if let entityA = contact.bodyA.node as? Entity
        {
            entityA.collidedWith(contact.bodyB, contact:contact)
        }
    
        // ... and do the same for the second body
        if let entityB = contact.bodyB.node as? Entity
        {
            entityB.collidedWith(contact.bodyA, contact:contact)
        }
    }
}
