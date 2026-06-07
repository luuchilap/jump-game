import SpriteKit

class PlatformNode: SKNode {
    let platformColor: UIColor
    let platformSize: CGSize
    var visualNode: SKShapeNode!
    
    init(color: UIColor, size: CGSize) {
        self.platformColor = color
        self.platformSize = size
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() {
        name = "platform"
        
        // Đồ hoạ: Viền bo tròn + Phát sáng
        let rect = CGRect(origin: CGPoint(x: -platformSize.width/2, y: -platformSize.height/2), size: platformSize)
        visualNode = SKShapeNode(rect: rect, cornerRadius: 8)
        visualNode.fillColor = platformColor.withAlphaComponent(0.8)
        visualNode.strokeColor = platformColor
        visualNode.lineWidth = 2
        visualNode.glowWidth = 3.0 // Hiệu ứng Neon
        addChild(visualNode)

        // Vật lý
        physicsBody = SKPhysicsBody(rectangleOf: platformSize)
        physicsBody?.isDynamic          = false
        physicsBody?.restitution        = 0.0
        physicsBody?.friction           = 1.0
        physicsBody?.categoryBitMask    = PhysicsCategory.platform
        physicsBody?.contactTestBitMask = PhysicsCategory.player
        physicsBody?.collisionBitMask   = PhysicsCategory.player
    }
}
