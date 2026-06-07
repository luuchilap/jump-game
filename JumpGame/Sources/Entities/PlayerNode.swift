import SpriteKit

class PlayerNode: SKSpriteNode {
    enum JumpState { case grounded, airborne }
    private(set) var jumpState: JumpState = .airborne

    func configure() {
        texture?.filteringMode = .nearest

        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic         = true
        physicsBody?.allowsRotation    = false
        physicsBody?.restitution       = 0.0    // KHÔNG NẢY
        physicsBody?.friction          = 1.0    // Max friction
        physicsBody?.linearDamping     = 0.0
        physicsBody?.categoryBitMask   = PhysicsCategory.player
        physicsBody?.contactTestBitMask = PhysicsCategory.platform | PhysicsCategory.killZone
        physicsBody?.collisionBitMask  = 0 // Tắt va chạm vật lý mặc định, chuyển sang xử lý thủ công 100%
    }

    func jump(velocity: CGVector) {
        guard jumpState == .grounded else { return }
        jumpState = .airborne
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = true
        physicsBody?.velocity = velocity
    }

    func land() {
        jumpState = .grounded
        physicsBody?.velocity = .zero 
        physicsBody?.affectedByGravity = false
        physicsBody?.isDynamic = false 
    }
    
    func fall() {
        jumpState = .airborne
        physicsBody?.affectedByGravity = true
        physicsBody?.isDynamic = true
    }
}
