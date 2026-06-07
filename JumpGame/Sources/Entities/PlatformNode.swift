import SpriteKit

class PlatformNode: SKSpriteNode {
    func configure() {
        name = "platform"
        texture?.filteringMode = .nearest
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic          = false
        physicsBody?.restitution        = 0.0
        physicsBody?.friction           = 1.0
        physicsBody?.categoryBitMask    = PhysicsCategory.platform
        physicsBody?.contactTestBitMask = PhysicsCategory.player
        // Chỉ va chạm từ TRÊN xuống (one-way platform), nhưng phần lớn xử lý trong code
        physicsBody?.collisionBitMask   = PhysicsCategory.player
    }
}
