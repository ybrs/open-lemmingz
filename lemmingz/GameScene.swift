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
    case Enter = 4
    case Exit = 8
}

class Hero: SKSpriteNode {
    var _running = false
    var _direction = CGRectEdge.MaxXEdge
    
    var running : Bool {
        get {
            return self._running
        }
        set (newValue) {
            if self._running == newValue {
                return
            }
            
            self._running = newValue
            
            updateActions()
        }
    }
    
    var direction: CGRectEdge {
        get {
            return _direction
        }
        set (newDirection) {
            if self._direction == newDirection {
                return
            }
            
            self._direction = newDirection
            updateActions()
        }
    }
    
    func updateActions() {
        if !self._running {
            self.removeActionForKey("running")
            self.removeActionForKey("run")
        } else if self.parent != nil {
            let heroAtlas = SKTextureAtlas(named: "sprites.atlas")

            if self.direction == .MaxXEdge {
                let hero_run_anim = SKAction.animateWithTextures([
                    heroAtlas.textureNamed("sprite_01"),
                    heroAtlas.textureNamed("sprite_02"),
                    heroAtlas.textureNamed("sprite_03")
                    ], timePerFrame: 0.06)

                let run = SKAction.repeatActionForever(hero_run_anim)
                self.runAction(run, withKey: "running")
            } else if self.direction == .MinXEdge {
                let hero_run_anim = SKAction.animateWithTextures([
                    heroAtlas.textureNamed("sprite_17"),
                    heroAtlas.textureNamed("sprite_18"),
                    heroAtlas.textureNamed("sprite_19")
                    ], timePerFrame: 0.06)

                let run = SKAction.repeatActionForever(hero_run_anim)
                self.runAction(run, withKey: "running")
            }
            
            
            let delta = self.direction == CGRectEdge.MinXEdge ? -50 : 50;
            let move = SKAction.moveBy(CGVector(dx: delta, dy: 0), duration: 1)
            let moveForever = SKAction.repeatActionForever(move)
            self.runAction(moveForever, withKey: "move")
        }
    }
   
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var enterNode: SKSpriteNode!
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */

        self.physicsWorld.gravity = CGVectorMake(0.0, -2.0)
        self.physicsWorld.contactDelegate = self
        
        view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]

        loadLevel()
        for i in 1...50 {
            let wait = SKAction.waitForDuration(Double(i) / 2)
            let action = SKAction.runBlock({
                self.addSprites()
                NSLog("runnnnnnnnn")
            })
            self.runAction(SKAction.sequence([wait, action]))
        }
        
    }
    
    func didEndContact(contact: SKPhysicsContact) {
//        NSLog("%@", contact.bodyA)
//        NSLog("%@", contact.bodyB)
//        NSLog("%@", NSStringFromCGPoint(contact.contactPoint))
//        NSLog("%@", NSStringFromCGVector(contact.contactNormal))
//        NSLog("%f", contact.collisionImpulse)
        
        let hero:SKNode = contact.bodyB.node!
        if hero.actionForKey("run") == nil {
            hero.removeActionForKey("run")
            
            hero.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
//        NSLog("%@", contact.bodyA)
//        NSLog("%@", contact.bodyB)
//        NSLog("%@", NSStringFromCGPoint(contact.contactPoint))
//        NSLog("begin contact %@", NSStringFromCGVector(contact.contactNormal))
//        NSLog("%f", contact.collisionImpulse)
        
        let node:SKNode = contact.bodyB.node!
        let nodeB:SKNode = contact.bodyA.node!
        
        if nodeB.name == "exit" {
            node.removeFromParent()
            return
        }
        
        if let hero = node as? Hero {
            if hero.name == "hero" {
                if contact.contactNormal.dy == 1 {
                    NSLog("same direction no change")
                    hero.running = true
                } else if contact.contactNormal.dx == -1  {
                    // Hit by right
                    NSLog("change direction right")
                    hero.direction = CGRectEdge.MinXEdge
                    
                } else if contact.contactNormal.dx == 1 {
                    NSLog("change direction left")
                    
                    hero.direction = CGRectEdge.MaxXEdge
                }
            }
        }
        
    }
    
    func addSprites(){
        let heroAtlas = SKTextureAtlas(named: "sprites.atlas")
        let hero = Hero(texture: heroAtlas.textureNamed("sprite_01"))
        hero.direction = CGRectEdge.MaxXEdge
        hero.name = "hero"
        hero.position = self.enterNode.position
        hero.size = CGSize(width: 32, height: 32)
        hero.physicsBody = SKPhysicsBody(circleOfRadius: 14)
        
        hero.physicsBody!.categoryBitMask = CollisionTypes.Player.rawValue
        hero.physicsBody!.contactTestBitMask = CollisionTypes.Wall.rawValue | CollisionTypes.Exit.rawValue
        hero.physicsBody!.collisionBitMask = CollisionTypes.Wall.rawValue
        
        
        hero.physicsBody!.dynamic = true
        hero.physicsBody!.allowsRotation = false
        hero.physicsBody!.restitution = 0.0
        hero.physicsBody!.linearDamping = 0
        hero.physicsBody!.friction = 0
        hero.zPosition = 1.0

//        hero.physicsBody!.velocity = CGVectorMake(100, 0)
//        hero.physicsBody!.applyImpulse(CGVectorMake(0.1, 0.1))

        
        
        addChild(hero)

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
                            node.name = "exit"
                            node.position = position
                            
                            node.size = CGSize(width: blockSize, height: blockSize)
                            
                            node.physicsBody = SKPhysicsBody(rectangleOfSize: node.size)
                            node.physicsBody!.categoryBitMask = CollisionTypes.Exit.rawValue
                            node.physicsBody!.dynamic = false
                            addChild(node)
                            
                        } else if letter == "E"  {
                            // load star
                            self.enterNode = SKSpriteNode(imageNamed: "entrance")
                            self.enterNode.position = position
                            
                            self.enterNode.size = CGSize(width: blockSize, height: blockSize)
                            
                            self.enterNode.physicsBody = SKPhysicsBody(rectangleOfSize: self.enterNode.size)
                            self.enterNode.physicsBody!.categoryBitMask = CollisionTypes.Enter.rawValue
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
