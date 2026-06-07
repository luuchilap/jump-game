import SpriteKit

class PlatformSpawner {
    private(set) var lastY: CGFloat
    private(set) var lastX: CGFloat
    private let sceneWidth: CGFloat
    private var difficulty: Double = 0.0

    init(startY: CGFloat, sceneWidth: CGFloat) {
        self.lastY = startY
        self.lastX = sceneWidth / 2 // Vị trí X của platform khởi đầu
        self.sceneWidth = sceneWidth
    }

    @discardableResult
    func spawnNext(in parent: SKNode) -> PlatformNode {
        let gapY = CGFloat.random(
            in: GameConstants.minGapY...GameConstants.maxGapY
        )
        let newY = lastY + gapY
        let margin: CGFloat = GameConstants.platformWidth / 2 + 10
        
        var newX: CGFloat = 0
        // Đảm bảo platform mới có toạ độ X cách platform cũ ít nhất bằng chiều rộng quả trứng (khoảng 40px)
        // để tránh trường hợp đè lên nhau cùng một trục dọc.
        repeat {
            newX = CGFloat.random(in: margin...(sceneWidth - margin))
        } while abs(newX - lastX) < 40

        // Chọn loại platform theo xác suất
        let platform = makePlatform()
        platform.position = CGPoint(x: newX, y: newY)
        platform.configure()

        // Moving platform - nhanh dần theo difficulty
        if let moving = platform as? MovingPlatform {
            // Tốc độ random trực tiếp trong khoảng 50 đến 150 (có cộng thêm chút độ khó theo thời gian)
            let baseSpeed = Double.random(in: 50.0...150.0)
            let finalSpeed = min(baseSpeed + difficulty * 30, Double(GameConstants.maxMoveSpeed + 150))
            moving.startMoving(in: sceneWidth, speed: CGFloat(finalSpeed))
        }

        parent.addChild(platform)
        lastY = newY
        lastX = newX
        return platform
    }

    func increaseDifficulty() {
        difficulty += GameConstants.difficultyStep
    }

    private func makePlatform() -> PlatformNode {
        let crumbleChance = min(
            GameConstants.crumbleChanceBase + difficulty * 0.04,
            0.55
        )

        let roll = Double.random(in: 0...1)
        if roll < crumbleChance {
            return CrumblingPlatform(color: .gray, size: platformSize())
        } else {
            return MovingPlatform(color: .cyan, size: platformSize())
        }
    }

    private func platformSize() -> CGSize {
        CGSize(width: GameConstants.platformWidth, height: GameConstants.platformHeight)
    }
}
