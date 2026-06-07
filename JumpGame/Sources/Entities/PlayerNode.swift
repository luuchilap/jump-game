import SpriteKit

class PlayerNode: SKNode {
    enum JumpState { case grounded, airborne }
    private(set) var jumpState: JumpState = .airborne
    
    let playerSize = CGSize(width: 36, height: 46)
    private var visualNode: SKShapeNode!
    private var trailEmitter: SKEmitterNode!

    func configure() {
        // Đồ hoạ: Quả trứng Neon
        let rect = CGRect(origin: CGPoint(x: -playerSize.width/2, y: -playerSize.height/2), size: playerSize)
        visualNode = SKShapeNode(ellipseIn: rect)
        visualNode.fillColor = .white
        visualNode.strokeColor = .yellow
        visualNode.lineWidth = 3
        visualNode.glowWidth = 4.0 // Toả sáng
        
        // Thêm hạt lấp lánh bên trong
        let core = SKShapeNode(ellipseIn: rect.insetBy(dx: 10, dy: 14))
        core.fillColor = .yellow
        core.strokeColor = .clear
        visualNode.addChild(core)
        
        addChild(visualNode)
        
        // Hiệu ứng Particle Trail đuôi sao chổi bằng Code (Không cần file .sks)
        setupTrail()

        // Vật lý
        // Dùng hình elip cho physics body để mượt hơn khi chạm góc
        physicsBody = SKPhysicsBody(circleOfRadius: playerSize.width / 2)
        physicsBody?.isDynamic         = true
        physicsBody?.allowsRotation    = false
        physicsBody?.restitution       = 0.0    // KHÔNG NẢY
        physicsBody?.friction          = 1.0    // Max friction
        physicsBody?.linearDamping     = 0.0
        physicsBody?.categoryBitMask   = PhysicsCategory.player
        physicsBody?.contactTestBitMask = PhysicsCategory.platform | PhysicsCategory.killZone
        physicsBody?.collisionBitMask  = 0 // Tắt va chạm vật lý mặc định
    }
    
    private func setupTrail() {
        trailEmitter = SKEmitterNode()
        trailEmitter.particleTexture = createParticleTexture()
        trailEmitter.particleBirthRate = 0
        trailEmitter.particleLifetime = 0.5
        trailEmitter.particlePositionRange = CGVector(dx: 10, dy: 10)
        trailEmitter.particleSpeed = 20
        trailEmitter.particleSpeedRange = 10
        trailEmitter.emissionAngleRange = .pi / 4
        trailEmitter.particleAlpha = 0.8
        trailEmitter.particleAlphaSpeed = -1.6
        trailEmitter.particleScale = 0.5
        trailEmitter.particleScaleSpeed = -0.5
        trailEmitter.particleColorBlendFactor = 1.0
        trailEmitter.particleColor = .yellow
        trailEmitter.particleBlendMode = .add
        trailEmitter.targetNode = self.scene // Để hạt rơi rớt lại phía sau chứ không bám theo trứng
        
        addChild(trailEmitter)
    }
    
    private func createParticleTexture() -> SKTexture {
        let size = CGSize(width: 8, height: 8)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return SKTexture() }
        context.setFillColor(UIColor.white.cgColor)
        context.fillEllipse(in: CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return SKTexture(image: image)
    }

    func jump(velocity: CGVector) {
        guard jumpState == .grounded else { return }
        jumpState = .airborne
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = true
        physicsBody?.velocity = velocity
        
        // Bật vệt lửa khi nhảy
        trailEmitter.targetNode = self.scene
        trailEmitter.particleBirthRate = 150
        // Hướng hạt phun ngược với vận tốc để tạo cảm giác phản lực
        trailEmitter.emissionAngle = velocity.dy > 0 ? -.pi / 2 : .pi / 2
        
        // Hiệu ứng bóp méo (Squash and Stretch) tạo cảm giác lấy đà bật nhảy
        let stretch = SKAction.scaleX(to: 0.8, y: 1.2, duration: 0.1)
        let normal = SKAction.scaleX(to: 1.0, y: 1.0, duration: 0.2)
        visualNode.run(.sequence([stretch, normal]))
    }

    func land() {
        guard jumpState == .airborne else { return }
        jumpState = .grounded
        physicsBody?.velocity = .zero 
        physicsBody?.affectedByGravity = false
        physicsBody?.isDynamic = false 
        
        // Tắt vệt lửa
        trailEmitter.particleBirthRate = 0
        
        // Hiệu ứng núng nính khi tiếp đất (Squash and Stretch)
        let squash = SKAction.scaleX(to: 1.3, y: 0.7, duration: 0.05)
        let bounce = SKAction.scaleX(to: 0.9, y: 1.1, duration: 0.1)
        let normal = SKAction.scaleX(to: 1.0, y: 1.0, duration: 0.1)
        visualNode.run(.sequence([squash, bounce, normal]))
    }
    
    func fall() {
        jumpState = .airborne
        physicsBody?.affectedByGravity = true
        physicsBody?.isDynamic = true
        
        trailEmitter.targetNode = self.scene
        trailEmitter.particleBirthRate = 80
        trailEmitter.emissionAngle = .pi / 2
    }
}
