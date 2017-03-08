//
//  GameScene.swift
//  FlappyBird
//
//  Created by smbss on 01/12/15.
//  Copyright (c) 2015 smbss. All rights reserved.
//

import SpriteKit

// SKPhysicsContactDelegate is needed so we can use collision methods
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var score = 0
    
    // In games labels are created as SKLabelNode()
    var scoreLabel = SKLabelNode()
    var gameoverLabel = SKLabelNode()
    
    // Creating sprites for the bird, background and pipes
    var bird = SKSpriteNode()
    var bg = SKSpriteNode()
    var pipe1 = SKSpriteNode()
    var pipe2 = SKSpriteNode()
    var ground = SKNode()
    // Everything we put on screen is a node but since the ground will be invisible and have no image we can create it as SKNode instead of SkSpriteNode
    
    // Creating the var that will group the moving objects in the game (without the bird) so that we can easily stop them when the game is over
    var movingObjects = SKSpriteNode()
    // At the beginning movingObjects will have nothing, but we will add the childs to movingObjects instead of self
    
    // Creating the var that will group the labels and add or remove them
    var labelContainer = SKSpriteNode()
    
    enum ColliderType: UInt32 {
        // When using enums in games we should only use values for the cases that double each time.
        // For example here we have 1, 2 and 4 but the next ones would be 8, 16, 32... This allows easy collider groups identification - More info: Google!
        
        case bird = 1
        case object = 2
        case gap = 4
        
    }
    
    var gameOver = false
    
    func makebg() {
        // Creating the texture for the background
        let bgTexture = SKTexture(imageNamed: "bg.png")
        // Creating the action that will move the background
        let movebg = SKAction.moveBy(x: -bgTexture.size().width, y: 0, duration: 9)
        // In the first parameter we enter how many pixels we want to move in the x axis (negative to move to the left side).The second parameter is the same but for y.
        // The duration is the interval of time in which we want this movement to happen
        
        // This will move the background from the extreme left to the extreme right - like it was a threadmill
        let replacebg = SKAction.moveBy(x: bgTexture.size().width, y: 0, duration: 0)
        // We want it to happen instantly so duratin = 0 and the pixels moved in x has to be = to the size of the background
        
        // Making the background animation go forever
        let movebgForever = SKAction.repeatForever(SKAction.sequence([movebg, replacebg]))
        
        // Combining different backgrounds so that there are no missing images as background between the sequence created below that animates the background
        for i in 0 ..< 3 {
            // Defining the sprite node(background) based on the texture
            bg = SKSpriteNode(texture: bgTexture)
            
            // Defining the position of the background
            bg.position = CGPoint(x: bgTexture.size().width/2 + bgTexture.size().width * CGFloat(i), y: self.frame.midY)
            
            // We need to define the size for the background
            bg.size.height = self.frame.height
            
            // Defining the position of the layer of this sprite
            bg.zPosition = -1
            
            // Adding the action to the sprite
            bg.run(movebgForever)
            
            movingObjects.addChild(bg)
        }
        
    }
    
    // This is the equivalent of ViewDidLoad:
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        // Set the contactDelegate to the GameScene:
        self.physicsWorld.contactDelegate = self
        // physicsWorld is where we can change the settings of the physics in our world
        
        self.addChild(movingObjects)
        self.addChild(labelContainer)
        
        // Adding the background, bird and ground
        makebg()
        makeBird()
        makeGround()
        
        self.addChild(ground)
        self.addChild(bird)
        
        // Creating the timer to spawn pipes every 2 seconds
        _ = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(GameScene.makePipes), userInfo: nil, repeats: true)
        
        makeLabel(node: scoreLabel, text: "0", fontSize: 60, x: self.frame.midX, y: self.frame.height - 70)
        // y: ... - 70 = -fontSize(60) - 10
        self.addChild(scoreLabel)
        
    }
    
    func makeBird() {
        // The order of the code for each sprite is important here because they will act as layers. It seems that the ones added on top are the ones that stay on top but you can also use (spritename).zPosition and force the positioning of the labels
        
        // First we create the texture(image) for our bird
        let birdTexture = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        
        // Creating the animation from textures:
        let animation = SKAction.animate(with: [birdTexture, birdTexture2], timePerFrame: 0.1)
        // SKActions allow us to do things with our nodes, in this case animate it
        // In the first entry we need to add an array with all the textures we want to use
        // In the second entry we enter the time interval between each animation, in this case 0.1 seconds
        // This animation will only happen one time
        
        // To make the animation go forever we need to add this action:
        let makeBirdFlap = SKAction.repeatForever(animation)
        
        // Defining the sprite node(bird) based on the texture
        bird = SKSpriteNode(texture: birdTexture)
        
        // Setting the position of the sprite in the screen:
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        // We define it by centering it in x and y, to do it we use CGRectGetMid(x or y) and refer to the frame of the GameScene
        
        // Adding the repeatActionForever to the bird sprite:
        bird.run(makeBirdFlap)
        
        // Defining the position of the layer of this sprite
        bird.zPosition = 1
        
        // Creating a physic body property with the form of a circle and the radius of half the heigh of the bird's image
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture2.size().height/2)
        // We are sure that physicsBody will exist because bird is type SKSpriteNode and it contains that property
        
        // Making the bird not affected by gravity (we will make it affected as soon as touches began)
        bird.physicsBody!.isDynamic = false
        
        // Avoiding the bird from rotating
        bird.physicsBody?.allowsRotation = false
        
        // Assigning a category to the bird's phyricsBody and making it type Collider
        bird.physicsBody?.categoryBitMask = ColliderType.bird.rawValue
        // We add .rawValue so that we can compare both sides without converting types
        
        // Creating the mask that will detect contact
        bird.physicsBody?.contactTestBitMask = ColliderType.object.rawValue
        
        // CollisionBitMask is used to detect trespassing after contact
        bird.physicsBody?.collisionBitMask = ColliderType.object.rawValue
        // If we used ColliderType.Bird.rawValue the bird would pass through the ground when falling and would only not trespass physicsBodies with BitMasks of type Bird
        
        
    }
    
    func makeGround() {
        // Positioning the ground to start at the bottom left of the screen
        ground.position = CGPoint(x: 0, y: 0)
        // Making the ground a rectangle with the width of the screen and 1 pixel of height
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: 1))
        // Making the ground not affected by gravity
        ground.physicsBody?.isDynamic = false
        
        // Defining the same masks we did above for the bird
        ground.physicsBody?.categoryBitMask = ColliderType.object.rawValue
        ground.physicsBody?.contactTestBitMask = ColliderType.object.rawValue
        ground.physicsBody?.collisionBitMask = ColliderType.object.rawValue
        // Since physicsBody?.contactTestBitMask is equal in both bird and ground, this will allow us to detect a contact between the these two objects
    }
    
    func makePipes() {
        // Defining the gap size
        let gapHeight = bird.size.height * 2.75
        
        // Randomly casting gaps for each set of pipes
        let movementAmount = arc4random() % UInt32(self.frame.size.height/2)
        // arc4random() retrieves a random number between 0 and 1
        // % will make arc4random generate a random number up to half of the screen size
        // arc4random is a UInt32 and self.frame.size.height is CGFloat so we need to convert one to another
        
        // Making the actual variable that we will use to change the position of the pipes
        // We will subtract 1/4 of the screen heigh so that the two pipes will always be visible
        let pipeOffset = CGFloat(movementAmount) - self.frame.size.height/4
        // In this case we convert movementAmount from UInt32 to CGFloat so that we can use it later as a number of pixels to define a position
        
        let movePipes = SKAction.moveBy(x: -self.frame.size.width * 2, y: 0, duration: TimeInterval(self.frame.size.width/100))
        // We need to make the duration of this animation in function of the screen size so that it is not too fast for some screens
        // After some experimenting self.frame.size/100 is a good duration for this animation
        
        let removePipes = SKAction.removeFromParent()
        let moveAndRemovePipes = SKAction.sequence([movePipes, removePipes])
        
        let pipe1Texture = SKTexture(imageNamed: "pipe1.png")
        pipe1 = SKSpriteNode(texture: pipe1Texture)
        pipe1.position = CGPoint(x: self.frame.midX + self.frame.size.width, y: self.frame.midY + pipe1Texture.size().height/2 + gapHeight/2 + pipeOffset)
        pipe1.zPosition = 2
        pipe1.run(moveAndRemovePipes)
        pipe1.physicsBody = SKPhysicsBody(rectangleOf: pipe1Texture.size())
        pipe1.physicsBody?.isDynamic = false
        
        
        // Defining the same masks we did above for the bird and ground
        pipe1.physicsBody?.categoryBitMask = ColliderType.object.rawValue
        pipe1.physicsBody?.contactTestBitMask = ColliderType.object.rawValue
        pipe1.physicsBody?.collisionBitMask = ColliderType.object.rawValue
        
        movingObjects.addChild(pipe1)
        
        let pipe2Texture = SKTexture(imageNamed: "pipe2.png")
        pipe2 = SKSpriteNode(texture: pipe2Texture)
        pipe2.position = CGPoint(x: self.frame.midX + self.frame.size.width, y: self.frame.midY - pipe2Texture.size().height/2 - gapHeight/2 + pipeOffset)
        pipe2.zPosition = 2
        pipe2.run(moveAndRemovePipes)
        pipe2.physicsBody = SKPhysicsBody(rectangleOf: pipe2Texture.size())
        pipe2.physicsBody?.isDynamic = false
        
        // Defining the same masks we did above for the bird and ground
        pipe2.physicsBody?.categoryBitMask = ColliderType.object.rawValue
        pipe2.physicsBody?.contactTestBitMask = ColliderType.object.rawValue
        pipe2.physicsBody?.collisionBitMask = ColliderType.object.rawValue
        
        movingObjects.addChild(pipe2)
        
        // Creating the var that will increase the user's score based on contact with the gap between pipes
        let gap = SKNode()
        gap.position = CGPoint(x: self.frame.midX + self.frame.size.width, y: self.frame.midY + pipeOffset)
        gap.run(moveAndRemovePipes)
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipe1.size.width/2, height: gapHeight))
        gap.physicsBody?.isDynamic = false
        
        // Creating the masks for the gap
        gap.physicsBody?.categoryBitMask = ColliderType.gap.rawValue
        gap.physicsBody?.contactTestBitMask = ColliderType.bird.rawValue
        gap.physicsBody?.collisionBitMask = ColliderType.gap.rawValue
        // We need to define a specific type for the gap, then we set the contactMask to Bird so that it can detect when there is a contact with the bird, but we left the collisionMark = gap type so that the bird can pass trough it
        
        movingObjects.addChild(gap)
    }
    
    func makeLabel(node: SKLabelNode, text: String, fontSize: CGFloat, x: CGFloat, y: CGFloat) {
        // Creating the score label
        node.fontName = "Helvetica"
        node.fontSize = fontSize
        node.text = text
        node.position = CGPoint(x: x, y: y)
        node.zPosition = 3
    }
    
    // This is the method that we use to do something when a contact is detected
    func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == ColliderType.gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.gap.rawValue {
            
            score += 1
            
            scoreLabel.text = String(score)
            
        } else {
            
            // By adding this if statement we prevent the label from being added more than once - resulting in a error
            guard gameOver else {
                
                print("We have contact!", terminator: "")
                
                gameOver = true
                
                // Setting the speed of everything in the game field to 0
                self.speed = 0
                
                makeLabel(node: gameoverLabel, text: "Game Over! Tap to play again.", fontSize: 30, x: self.frame.midX, y: self.frame.midY)
                labelContainer.addChild(gameoverLabel)
                return
            }
            
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        
        if gameOver == false {
            
            // Making the bird be affected by gravity
            bird.physicsBody!.isDynamic = true
            
            // Setting the birds initial velocity to 0 - If we don't do it the velocity of the bird falling for the gravity will mess up with the velocity of the impulse
            bird.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            
            // Setting the impulse to be 0 in x and 50 in y
            bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 50))
            
        } else {
            // If gameOver == True we want to reset the game:
            
            score = 0
            scoreLabel.text = "0"
            
            bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            
            movingObjects.removeAllChildren()
            
            makebg()
            
            self.speed = 1
            
            gameOver = false
            
            labelContainer.removeAllChildren()
            
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
}
