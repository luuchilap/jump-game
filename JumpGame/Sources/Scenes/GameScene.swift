import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    // Dependencies
    var gameState: GameState!

    // Nodes
    private var player: PlayerNode!
    private var cameraNode: SKCameraNode!
    private var killZone: SKNode!

    // Managers
    private var spawner: PlatformSpawner!
    private var score = 0
    private var highestY: CGFloat = 0
    private var highestPlatformY: CGFloat = 150
    
    // Variables for deferred physics update
    private var pendingLand = false
    private var platformToStick: PlatformNode?
    
    // Slingshot variables
    private var touchStartLocation: CGPoint?
    private var trajectoryDots: [SKShapeNode] = []

    // MARK: - Setup
    override func didMove(to view: SKView) {
        backgroundColor = .black
        physicsWorld.gravity = CGVector(dx: 0, dy: GameConstants.gravity)
        physicsWorld.contactDelegate = self

        setupCamera()
        setupPlayer()
        setupKillZone()
        setupTrajectoryDots()
        setupInitialPlatforms()
    }

    private func setupCamera() {
        cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(cameraNode)
        camera = cameraNode
    }

    private func setupPlayer() {
        player = PlayerNode()
        player.position = CGPoint(x: size.width / 2, y: 150)
        player.configure()
        addChild(player)
        highestY = player.position.y
        highestPlatformY = player.position.y
    }

    private func setupKillZone() {
        killZone = SKNode()
        // Do chiều cao killzone là 1000 (nửa trên là 500), ta phải dịch tâm xuống 500 + 200 = 700 pixel để mép trên của nó cách player 200 pixel.
        killZone.position = CGPoint(x: size.width / 2, y: player.position.y - 700)
        // Tạo KillZone cực lớn (dày 1000, rộng x10) để chống lọt (tunneling) do tốc độ rơi quá cao
        let body = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 10, height: 1000))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.killZone
        body.contactTestBitMask = PhysicsCategory.player
        body.collisionBitMask = 0
        killZone.physicsBody = body
        addChild(killZone)
    }

    private func setupTrajectoryDots() {
        for _ in 0..<20 {
            let dot = SKShapeNode(circleOfRadius: 3)
            dot.fillColor = .white
            dot.alpha = 0
            dot.zPosition = 100 // Đảm bảo vẽ nổi lên trên mọi vật thể
            addChild(dot)
            trajectoryDots.append(dot)
        }
    }

    private func setupInitialPlatforms() {
        spawner = PlatformSpawner(startY: 100, sceneWidth: size.width)
        let startPlatform = PlatformNode(color: .white, size: CGSize(
            width: GameConstants.platformWidth * 1.5,
            height: GameConstants.platformHeight
        ))
        startPlatform.position = CGPoint(x: size.width / 2, y: 120)
        startPlatform.configure()
        addChild(startPlatform)
        
        for _ in 0..<12 { spawner.spawnNext(in: self) }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        // Chỉ cho phép kéo bắn khi trứng đang đứng trên platform
        if player.jumpState == .grounded {
            touchStartLocation = touch.location(in: self)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let startPos = touchStartLocation else { return }
        let currentPos = touch.location(in: self)
        
        let launchVelocity = calculateLaunchVelocity(start: startPos, current: currentPos)
        drawTrajectory(velocity: launchVelocity)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let startPos = touchStartLocation else { return }
        let currentPos = touch.location(in: self)
        
        touchStartLocation = nil
        clearTrajectory()
        
        let dx = startPos.x - currentPos.x
        let dy = startPos.y - currentPos.y
        let rawDistance = sqrt(dx * dx + dy * dy)
        
        // Chỉ nhảy nếu kéo đủ xa (tránh chạm nhầm)
        if rawDistance > 15 {
            // Reparent trứng về cảnh chính trước khi bắn
            if player.parent != self && player.parent != nil {
                let scenePos = self.convert(player.position, from: player.parent!)
                player.removeFromParent()
                self.addChild(player)
                player.position = scenePos
            }
            let launchVelocity = calculateLaunchVelocity(start: startPos, current: currentPos)
            player.jump(velocity: launchVelocity)
        }
    }
    
    private func calculateLaunchVelocity(start: CGPoint, current: CGPoint) -> CGVector {
        let dx = start.x - current.x
        let dy = start.y - current.y
        
        let rawDistance = sqrt(dx * dx + dy * dy)
        let distance = min(rawDistance, GameConstants.maxDragDistance)
        
        let angle = atan2(dy, dx)
        let cappedDx = cos(angle) * distance
        let cappedDy = sin(angle) * distance
        
        return CGVector(dx: cappedDx * GameConstants.dragMultiplier,
                        dy: cappedDy * GameConstants.dragMultiplier)
    }

    private func drawTrajectory(velocity: CGVector) {
        // Lực hấp dẫn của SpriteKit (xấp xỉ bằng gravity * 150)
        let gravity = physicsWorld.gravity.dy * 150.0 
        let dt: CGFloat = 1.0 / 60.0 // Giả lập bước nhảy 1 frame
        
        var currentP = player.parent?.convert(player.position, to: self) ?? player.position
        var currentV = velocity
        
        for (i, dot) in trajectoryDots.enumerated() {
            dot.alpha = 1.0 - (CGFloat(i) / CGFloat(trajectoryDots.count))
            dot.position = currentP
            
            // Tính trước 4 khung hình cho mỗi dấu chấm để rải chấm bi đều và xa hơn
            for _ in 0..<4 {
                currentV.dy += gravity * dt
                currentP.x += currentV.dx * dt
                currentP.y += currentV.dy * dt
                
                // Giả lập va chạm với tường vô hình (khúc xạ) y hệt như hàm update()
                if currentP.x < 0 {
                    currentP.x = 0
                    currentV.dx *= -0.8
                } else if currentP.x > size.width {
                    currentP.x = size.width
                    currentV.dx *= -0.8
                }
            }
        }
    }
    
    private func clearTrajectory() {
        for dot in trajectoryDots {
            dot.alpha = 0
        }
    }

    override func update(_ currentTime: TimeInterval) {
        guard gameState.phase == .playing else { return }
        
        moveCamera()
        moveKillZone()
        spawnMoreIfNeeded()
        updateScore()
        removeOffscreenPlatforms()
        
        // Cập nhật giới hạn màn hình (Tường vô hình 2 bên)
        if player.parent == self || player.parent == nil { // Chỉ xử lý khi đang bay
            if player.position.x < 0 {
                player.position.x = 0
                player.physicsBody?.velocity.dx *= -0.8 // Nảy dội lại
            } else if player.position.x > size.width {
                player.position.x = size.width
                player.physicsBody?.velocity.dx *= -0.8
            }
        }
    }

    override func didEvaluateActions() {
        super.didEvaluateActions()
        // Hàm tính toán bù trừ thủ công đã được xoá bỏ hoàn toàn, 
        // nhờ kĩ thuật reparent, SpriteKit sẽ tự động di chuyển egg cùng với platform!
    }
    
    override func didSimulatePhysics() {
        super.didSimulatePhysics()
        
        if pendingLand {
            pendingLand = false
            player.land() // Tắt isDynamic
            
            if let platformNode = platformToStick {
                if let oldParent = player.parent, oldParent != platformNode {
                    // Biến egg thành một node con của platformNode, 
                    // egg sẽ tự động nhận chuyển động của platform mà không cần tính dx dy nữa!
                    let localPos = platformNode.convert(player.position, from: oldParent)
                    player.removeFromParent()
                    platformNode.addChild(player)
                    
                    // Set toạ độ Y của egg cho khớp với mặt phẳng của platform
                    let targetY = (platformNode.platformSize.height / 2) + (player.playerSize.height / 2)
                    player.position = CGPoint(x: localPos.x, y: targetY)
                } else if player.parent == platformNode {
                    let targetY = (platformNode.platformSize.height / 2) + (player.playerSize.height / 2)
                    player.position.y = targetY
                }
                
                // Track điểm cao nhất bằng toạ độ của platform (trong hệ trục của scene)
                let platformSceneY = platformNode.parent?.convert(platformNode.position, to: self).y ?? platformNode.position.y
                if platformSceneY > highestPlatformY {
                    highestPlatformY = platformSceneY
                }

                if let crumbling = platformNode as? CrumblingPlatform {
                    crumbling.triggerIfNeeded { [weak self, weak player] in
                        guard let self = self, let player = player else { return }
                        // Khi platform bị phá huỷ, tách egg ra để nó rớt tự do
                        if player.parent == crumbling {
                            let scenePos = self.convert(player.position, from: crumbling)
                            player.removeFromParent()
                            self.addChild(player)
                            player.position = scenePos
                            player.fall()
                        }
                    }
                }
            }
            platformToStick = nil
        }
    }

    private func moveCamera() {
        let targetY = highestPlatformY + GameConstants.cameraLeadY
        if targetY > cameraNode.position.y {
            // Kéo camera mượt mà (smooth lerp) thay vì giật cục
            cameraNode.position.y += (targetY - cameraNode.position.y) * 0.1
        }
    }

    private func moveKillZone() {
        // Mép trên của killzone (nằm ở y + 500 do độ dày 1000) sẽ cách platform cao nhất 200 pixel.
        killZone.position.y = highestPlatformY - 700
    }

    private func spawnMoreIfNeeded() {
        let topVisible = cameraNode.position.y + size.height / 2
        while spawner.lastY < topVisible + 200 {
            spawner.spawnNext(in: self)
        }
    }

    private func updateScore() {
        // Nếu player đang là child của platform, phải convert toạ độ về scene
        let playerSceneY = player.parent?.convert(player.position, to: self).y ?? player.position.y
        if playerSceneY > highestY {
            let gained = Int((playerSceneY - highestY) / 10)
            if gained > 0 {
                highestY = playerSceneY
                score += gained
                gameState.score = score
                if score % 10 == 0 { spawner.increaseDifficulty() }
            }
        }
    }

    private func removeOffscreenPlatforms() {
        enumerateChildNodes(withName: "platform") { [weak self] node, _ in
            guard let self = self else { return }
            // Ngay khi lên được platform 2, platform 1 (và các platform dưới đó) sẽ bốc hơi ngay lập tức
            if node.position.y < self.highestPlatformY - 50 {
                node.removeFromParent()
            }
        }
    }

    // MARK: - Collision
    func didBegin(_ contact: SKPhysicsContact) {
        let (a, b) = sorted(contact)

        // Player vs Platform
        if a.categoryBitMask == PhysicsCategory.player,
           b.categoryBitMask == PhysicsCategory.platform {
            let platformNode = b.node as! PlatformNode
            
            // Xử lý va chạm thủ công 100%
            if player.physicsBody!.velocity.dy <= 0 {
                // Đang rơi xuống: Bắt dính vào mặt trên của platform
                // Cho phép lún tối đa 30 pixels (bù trừ sai số xuyên thấu do tốc độ cao của SpriteKit)
                let penetrationMargin: CGFloat = 30.0
                if player.position.y > platformNode.position.y - penetrationMargin {
                    // Chỉ đánh dấu lại, đẩy toàn bộ xử lý sang didSimulatePhysics để tránh lỗi của SpriteKit
                    pendingLand = true
                    platformToStick = platformNode
                }
            } else {
                // Đang bay lên: Cụng đầu vào đáy platform
                // Nếu vị trí của trứng thấp hơn platform, nghĩa là nó đang chui từ dưới lên
                let hitBottomMargin: CGFloat = 10.0
                if player.position.y < platformNode.position.y - hitBottomMargin {
                    // Phản lực dội ngược (khúc xạ) y hệt như đập đầu vào trần nhà
                    player.physicsBody!.velocity.dy *= -0.6
                }
            }
        }

        // Player vs KillZone
        if (a.categoryBitMask == PhysicsCategory.player &&
            b.categoryBitMask == PhysicsCategory.killZone) ||
           (b.categoryBitMask == PhysicsCategory.player &&
            a.categoryBitMask == PhysicsCategory.killZone) {
            triggerGameOver()
        }
    }

    private func triggerGameOver() {
        if gameState.phase != .gameOver {
            gameState.updateHighScore()
            gameState.phase = .gameOver
        }
    }

    private func sorted(_ contact: SKPhysicsContact) -> (SKPhysicsBody, SKPhysicsBody) {
        contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask
            ? (contact.bodyA, contact.bodyB)
            : (contact.bodyB, contact.bodyA)
    }
}
