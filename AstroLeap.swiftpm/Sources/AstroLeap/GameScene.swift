import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: SKShapeNode!
    var cameraNode: SKCameraNode!
    
    var restartAction: (() -> Void)?
    
    var isGameOver = false
    var score = 0
    var scoreLabel: SKLabelNode!
    
    let playerCategory: UInt32 = 0x1 << 0
    let platformCategory: UInt32 = 0x1 << 1
    let deadZoneCategory: UInt32 = 0x1 << 2
    
    var lastPlatformY: CGFloat = 0
    var currentPlatform: SKNode?
    var platformLastX: CGFloat = 0
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1.0)
        
        // Physics Setup
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self
        
        // Camera Setup
        cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
        self.camera = cameraNode
        addChild(cameraNode)
        
        setupUI()
        setupDeadZone()
        setupPlayer()
        
        // Tọa độ bệ phóng ban đầu an toàn
        let startPlatform = SKShapeNode(rectOf: CGSize(width: 200, height: 20), cornerRadius: 5)
        startPlatform.fillColor = .darkGray
        startPlatform.position = CGPoint(x: size.width/2, y: size.height/4 - 20)
        startPlatform.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 200, height: 20))
        startPlatform.physicsBody?.isDynamic = false
        startPlatform.physicsBody?.categoryBitMask = platformCategory
        startPlatform.physicsBody?.collisionBitMask = playerCategory
        addChild(startPlatform)
        
        lastPlatformY = player.position.y
        for _ in 0..<5 {
            spawnPlatform()
        }
    }
    
    func setupUI() {
        scoreLabel = SKLabelNode(fontNamed: "Courier-Bold")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: 0, y: size.height/2 - 50)
        scoreLabel.zPosition = 100
        cameraNode.addChild(scoreLabel)
    }
    
    func setupDeadZone() {
        let deadZone = SKNode()
        // Cố định bên dưới camera một khoảng
        deadZone.position = CGPoint(x: 0, y: -size.height/2 - 100)
        deadZone.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 2, height: 50))
        deadZone.physicsBody?.isDynamic = false
        deadZone.physicsBody?.categoryBitMask = deadZoneCategory
        deadZone.physicsBody?.contactTestBitMask = playerCategory
        deadZone.physicsBody?.collisionBitMask = 0
        cameraNode.addChild(deadZone)
    }
    
    func setupPlayer() {
        // Vẽ nhân vật phi hành gia đơn giản
        player = SKShapeNode(circleOfRadius: 15)
        player.fillColor = .cyan
        player.strokeColor = .white
        player.position = CGPoint(x: size.width/2, y: size.height/4)
        player.zPosition = 10
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: 15)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.restitution = 0.0 // Không nảy
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.collisionBitMask = platformCategory
        player.physicsBody?.contactTestBitMask = platformCategory | deadZoneCategory
        
        addChild(player)
    }
    
    func spawnPlatform() {
        let platformWidth = CGFloat.random(in: 60...120)
        let platform = SKShapeNode(rectOf: CGSize(width: platformWidth, height: 20), cornerRadius: 5)
        platform.fillColor = .gray
        platform.strokeColor = .lightGray
        
        let randomX = CGFloat.random(in: platformWidth/2...size.width - platformWidth/2)
        lastPlatformY += CGFloat.random(in: 120...180)
        platform.position = CGPoint(x: randomX, y: lastPlatformY)
        
        platform.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: platformWidth, height: 20))
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.categoryBitMask = platformCategory
        platform.physicsBody?.collisionBitMask = playerCategory
        
        // Tất cả các hành tinh đều di chuyển để luôn có thể nhảy tới
        let duration = Double.random(in: 3.0...5.0)
        let moveLeft = SKAction.moveTo(x: platformWidth/2, duration: duration)
        let moveRight = SKAction.moveTo(x: size.width - platformWidth/2, duration: duration)
        // Bắt đầu di chuyển ngẫu nhiên hướng trái hoặc phải
        let sequence = Bool.random() ? SKAction.sequence([moveLeft, moveRight]) : SKAction.sequence([moveRight, moveLeft])
        platform.run(SKAction.repeatForever(sequence))
        
        addChild(platform)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGameOver else {
            restartAction?()
            return
        }
        
        // Chỉ cho phép nhảy khi đang dính trên bục (currentPlatform != nil)
        // hoặc khi đang bắt đầu game (vận tốc Y ~ 0)
        let isResting = (currentPlatform != nil) || (abs(player.physicsBody?.velocity.dy ?? 0) < 1.0)
        
        if isResting {
            player.physicsBody?.isDynamic = true // Mở lại vật lý
            player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 35))
            currentPlatform = nil // Tách khỏi bệ
            score += 1
            scoreLabel.text = "Score: \(score)"
            spawnPlatform()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else { return }
        
        // Tự động Game Over nếu bóng rơi khỏi màn hình
        if player.position.y < cameraNode.position.y - size.height/2 - 50 {
            gameOver()
        }
        
        // One-way platform: Chỉ va chạm khi rơi xuống, xuyên qua khi bay lên
        if let velocityY = player.physicsBody?.velocity.dy {
            if velocityY > 0 {
                player.physicsBody?.collisionBitMask = 0
            } else {
                player.physicsBody?.collisionBitMask = platformCategory
            }
        }
        
        // Camera theo dõi người chơi đi lên
        if player.position.y > cameraNode.position.y {
            cameraNode.position.y = player.position.y
        }
        
        // Dọn dẹp hành tinh rớt lại phía sau để giải phóng RAM
        for node in children {
            if node.physicsBody?.categoryBitMask == platformCategory {
                if node.position.y < cameraNode.position.y - size.height {
                    node.removeFromParent()
                }
            }
        }
    }
    
    override func didEvaluateActions() {
        if let platform = currentPlatform {
            let deltaX = platform.position.x - platformLastX
            player.position.x += deltaX
            platformLastX = platform.position.x
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if contactMask == (playerCategory | deadZoneCategory) {
            gameOver()
        }
        
        if contactMask == (playerCategory | platformCategory) {
            let platformNode = (contact.bodyA.categoryBitMask == platformCategory) ? contact.bodyA.node : contact.bodyB.node
            
            // Lệnh tối cao: Chỉ cần chạm bục (khi đang rơi hoặc ở đỉnh điểm) là bắt dính NGAY LẬP TỨC
            if let velocityY = player.physicsBody?.velocity.dy, velocityY < 15.0 {
                if let platform = platformNode {
                    if currentPlatform != platform {
                        currentPlatform = platform
                        platformLastX = platform.position.x
                        
                        // Khóa chặt bóng vào bục (vô hiệu hóa hoàn toàn vật lý để không thể rơi/trượt)
                        player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                        player.physicsBody?.isDynamic = false
                    }
                }
            }
        }
    }
    
    func gameOver() {
        if isGameOver { return }
        isGameOver = true
        player.physicsBody?.isDynamic = false
        
        let gameOverLabel = SKLabelNode(fontNamed: "Courier-Bold")
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.fontSize = 40
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: 0, y: 0)
        gameOverLabel.zPosition = 100
        cameraNode.addChild(gameOverLabel)
        
        let tapLabel = SKLabelNode(fontNamed: "Courier")
        tapLabel.text = "Tap to restart"
        tapLabel.fontSize = 20
        tapLabel.fontColor = .white
        tapLabel.position = CGPoint(x: 0, y: -40)
        tapLabel.zPosition = 100
        cameraNode.addChild(tapLabel)
    }
}
