import SpriteKit

class MovingPlatform: PlatformNode {
    func startMoving(in sceneWidth: CGFloat, speed: CGFloat) {
        let margin: CGFloat = GameConstants.platformWidth / 2 + 10
        let minX = margin
        let maxX = sceneWidth - margin
        let currentX = self.position.x
        
        // Thời gian di chuyển full màn hình (từ trái qua phải)
        let fullDuration = TimeInterval((maxX - minX) / speed)
        
        let moveRight = SKAction.moveTo(x: maxX, duration: fullDuration)
        let moveLeft = SKAction.moveTo(x: minX, duration: fullDuration)
        let fullCycle = SKAction.sequence([moveLeft, moveRight])
        let repeatFull = SKAction.repeatForever(fullCycle)
        
        // Thời gian di chuyển từ vị trí hiện tại ra rìa phải
        let initialDuration = TimeInterval((maxX - currentX) / speed)
        let moveInitialRight = SKAction.moveTo(x: maxX, duration: initialDuration)
        
        // Random hướng đi ban đầu
        if Bool.random() {
            let initialLeftDuration = TimeInterval((currentX - minX) / speed)
            let moveInitialLeft = SKAction.moveTo(x: minX, duration: initialLeftDuration)
            let sequenceLeft = SKAction.sequence([moveRight, moveLeft])
            let repeatLeft = SKAction.repeatForever(sequenceLeft)
            run(SKAction.sequence([moveInitialLeft, repeatLeft]))
        } else {
            run(SKAction.sequence([moveInitialRight, repeatFull]))
        }
    }
}
