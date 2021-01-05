//
//  GameScene.swift
//  Project11
//
//  Created by Adnann Muratovic on 04/01/2021.
//  Copyright © 2021 Adnann Muratovic. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
	
	var scoreLabel: SKLabelNode!
	
	var score = 0 {
		didSet {
			scoreLabel.text = "Score: \(score)"
		}
	}
	
	var editLabel: SKLabelNode!
	
	var editingMode: Bool = false {
		didSet {
			if editingMode {
				editLabel.text = "Done"
			} else {
				editLabel.text = "Edit"
			}
		}
	}
	
	// Challenge #1
	var balls = ["ballBlue", "ballCyan", "ballYellow", "ballPurple", "ballGreen", "ballRed", "ballGrey"]
	
	var numberOfBalls = 0
	
	override func didMove(to view: SKView) {
		// load File called background
		let background = SKSpriteNode(imageNamed: "background")
		// position on center of the screen
		background.position = CGPoint(x: 512, y: 384)
		// Blend modes determine how a node is draw "just draw it, ignoring any alpha values,"
		background.blendMode = .replace
		// Draw this behind everything else
		background.zPosition = -1
		// add noode to the current screen
		addChild(background)
		
		scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
		scoreLabel.text = "Score: 0"
		scoreLabel.horizontalAlignmentMode = .right
		scoreLabel.position = CGPoint(x: 980, y: 700)
		addChild(scoreLabel)
		
		editLabel = SKLabelNode(fontNamed: "Chalkduster")
		editLabel.text = "Edit"
		editLabel.position = CGPoint(x: 80, y: 700)
		addChild(editLabel)
		
		// adds a physics body to the whole scene that is a line on each edge, effectively acting like a container for the scene
		physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
		physicsWorld.contactDelegate = self
		
		makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
		makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
		makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
		makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
		
		makeBouncer(at: CGPoint(x: 0, y: 0))
		makeBouncer(at: CGPoint(x: 256, y: 0))
		makeBouncer(at: CGPoint(x: 512, y: 0))
		makeBouncer(at: CGPoint(x: 768, y: 0))
		makeBouncer(at: CGPoint(x: 1024, y: 0))
		
		
	}
	// Whan user touch device
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		// pull out any of the screen touches from the touch set
		guard let touch = touches.first else { return }
		// Find where the screen was touched in relation self
		let location = touch.location(in: self)
		let object = nodes(at: location)
		
		if object.contains(editLabel) {
			editingMode.toggle()
		} else if editingMode {
			// Create box
			let size = CGSize(width: Int.random(in: 16...128), height: 16)
			let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
			box.zRotation = CGFloat.random(in: 0...3)
			box.position = location
			
			box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
			box.physicsBody?.isDynamic = false
			addChild(box)
		} else {
			// Generate a node filled with a random color at size
			// Challenge #1
			let ball = SKSpriteNode(imageNamed: balls.randomElement() ?? "")
			// add circular physics to this ball, because using rectangles would look strange
			ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
			// giving the ball's physics body a restitution (bounciness) level of 0.4, where values are from 0 to 1.
			ball.physicsBody?.restitution = 0.4
			ball.physicsBody!.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
			ball.name = "ball"
			
			// Challenge #2
			ball.position = CGPoint(x: location.x, y: 758)
			
			// Challenge #3
			if numberOfBalls > 5 {
				if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
					fireParticles.position = location
					addChild(fireParticles)
				}
				
				return
			}
			
			addChild(ball)
	}
}

func makeBouncer(at position: CGPoint) {
	let bouncer = SKSpriteNode(imageNamed: "bouncer")
	bouncer.position = position
	bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
	// When it's false (as we're setting it) the object will still collide with other things, but it won't ever be moved as a result.
	bouncer.physicsBody?.isDynamic = false
	addChild(bouncer)
}

func makeSlot(at position: CGPoint, isGood: Bool) {
	var slotBase: SKSpriteNode
	var slotGlow: SKSpriteNode
	
	if isGood {
		slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
		slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
		slotBase.name = "good"
	} else {
		slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
		slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
		slotBase.name = "bad"
	}
	
	slotBase.position = position
	slotGlow.position = position
	
	slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
	slotBase.physicsBody?.isDynamic = false
	
	addChild(slotBase)
	addChild(slotGlow)
	
	// Angles are specified in radians, not degrees. This is true in UIKit too. 360 degrees is equal to the value of 2 x Pi – that is, the mathematical value π. Therefore π radians is equal to 180 degrees.
	let spin = SKAction.rotate(byAngle: .pi, duration: 10)
	
	// When you create an action it will execute once. If you want it to run forever, you create another action to wrap the first using the repeatForever() method, then run that.
	let spinForever = SKAction.repeatForever(spin)
	
	// Run Animation
	slotGlow.run(spinForever)
}

func collisionBetween(ball: SKNode, object: SKNode) {
	if object.name == "good" {
		destroy(ball: ball)
		score += 1
	} else if object.name == "bad" {
		destroy(ball: ball)
		score -= 1
	}
}

func destroy(ball: SKNode) {
	// Add Animation
	if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
		fireParticles.position = ball.position
		addChild(fireParticles)
	}
	// removes a node from your node tree
	ball.removeFromParent()
}

func didBegin(_ contact: SKPhysicsContact) {
	guard let nodeA = contact.bodyA.node else { return }
	guard let nodeB = contact.bodyB.node else { return }
	
	if nodeA.name == "ball" {
		collisionBetween(ball: nodeA, object: nodeB)
	} else if nodeB.name == "ball" {
		collisionBetween(ball: nodeB, object: nodeA)
		}
	}
}
