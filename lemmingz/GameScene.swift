//
//  GameScene.swift
//  lemmingz
//
//  Created by aybars badur on 1/8/16.
//  Copyright (c) 2016 aybars badur. All rights reserved.
//

import SpriteKit

enum CollisionTypes: UInt32 {
    case Player = 1
    case Wall = 2
    case Star = 4
    case Vortex = 8
    case Finish = 16
}

class GameScene: SKScene {
    
    var enterNode: SKSpriteNode!
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */

        self.physicsWorld.gravity = CGVectorMake(0.0, -0.2)

        
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!"
        myLabel.fontSize = 45
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        
        view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]

        self.addChild(myLabel)
        loadLevel()
        
        addSprites()
        
    }
    
    func addSprites(){
        let heroAtlas = SKTextureAtlas(named: "sprites.atlas")
        let hero = SKSpriteNode(texture: heroAtlas.textureNamed("sprite_01"))
        hero.position = self.enterNode.position
        hero.size = CGSize(width: 32, height: 32)
        hero.physicsBody = SKPhysicsBody(rectangleOfSize: hero.size)
        hero.physicsBody!.categoryBitMask = CollisionTypes.Player.rawValue
        hero.physicsBody!.dynamic = true
        hero.physicsBody!.allowsRotation = false
        hero.physicsBody!.restitution = 1
        hero.physicsBody!.linearDamping = 0
        hero.physicsBody!.friction = 0
        hero.zPosition = 1.0

        hero.physicsBody!.velocity = CGVectorMake(100, 0)
        hero.physicsBody!.applyImpulse(CGVectorMake(0.1, 0.1))

        
        let hero_run_anim = SKAction.animateWithTextures([
            heroAtlas.textureNamed("sprite_01"),
            heroAtlas.textureNamed("sprite_02"),
            heroAtlas.textureNamed("sprite_03")
            ], timePerFrame: 0.06)
        
        let run = SKAction.repeatActionForever(hero_run_anim)
        
        
        
        addChild(hero)
        hero.runAction(run, withKey: "running")

//        let moveRight = SKAction.moveByX(10, y: 0, duration: 20)
//        let moveForever = SKAction.repeatActionForever(moveRight)
//
//        hero.runAction(moveForever)
        
        
    }
    
    func loadLevel() {
        let colHeight = 32
        let blockSize = 32
        
        if let levelPath = NSBundle.mainBundle().pathForResource("level1", ofType: "txt") {
            if let levelString = try? String(contentsOfFile: levelPath, usedEncoding: nil) {
                let lines = levelString.componentsSeparatedByString("\n")
                
                for (row, line) in lines.reverse().enumerate() {
                    for (column, letter) in line.characters.enumerate() {
                        let position = CGPoint(x: (colHeight * column) + colHeight/2, y: (blockSize * row) + 3*blockSize + blockSize/2)
                        NSLog("%@", NSStringFromCGPoint(position))
                        if letter == "x" {
                            // load wall
                            let node = SKSpriteNode(imageNamed: "block")
                            node.position = position
                            
                            node.size = CGSize(width: blockSize, height: blockSize)
                            
                            node.physicsBody = SKPhysicsBody(rectangleOfSize: node.size)
                            node.physicsBody!.categoryBitMask = CollisionTypes.Wall.rawValue
                            node.physicsBody!.dynamic = false
                            node.physicsBody!.friction = 0

                            addChild(node)
                            
                        } else if letter == "D"  {
                            // load door
                            let node = SKSpriteNode(imageNamed: "door")
                            node.position = position
                            
                            node.size = CGSize(width: blockSize, height: blockSize)
                            
                            node.physicsBody = SKPhysicsBody(rectangleOfSize: node.size)
                            node.physicsBody!.categoryBitMask = CollisionTypes.Wall.rawValue
                            node.physicsBody!.dynamic = false
                            addChild(node)
                        } else if letter == "E"  {
                            // load star
                            self.enterNode = SKSpriteNode(imageNamed: "entrance")
                            self.enterNode.position = position
                            
                            self.enterNode.size = CGSize(width: blockSize, height: blockSize)
                            
                            self.enterNode.physicsBody = SKPhysicsBody(rectangleOfSize: self.enterNode.size)
                            self.enterNode.physicsBody!.categoryBitMask = CollisionTypes.Wall.rawValue
                            self.enterNode.physicsBody!.dynamic = false
                            addChild(self.enterNode)

                        } else if letter == "f"  {
                            // load finish
                        }
                    }
                }
            }
        }
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
//        for touch in touches {
//            let location = touch.locationInNode(self)
//            
//            let sprite = SKSpriteNode(imageNamed:"Spaceship")
//            
//            sprite.xScale = 0.5
//            sprite.yScale = 0.5
//            sprite.position = location
//            
//            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
//            
//            sprite.runAction(SKAction.repeatActionForever(action))
//            
//            self.addChild(sprite)
//        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
