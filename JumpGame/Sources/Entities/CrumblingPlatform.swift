import SpriteKit

class CrumblingPlatform: MovingPlatform {
    private var hasTriggered = false

    func triggerIfNeeded(onCrumbled: @escaping () -> Void) {
        guard !hasTriggered else { return }
        hasTriggered = true

        // Rung lắc nhẹ nhấp nháy để không xung đột với hành động moveTo (di chuyển qua lại) của MovingPlatform
        let blinkCycle = SKAction.sequence([
            .fadeAlpha(to: 0.3, duration: 0.1),
            .fadeAlpha(to: 1.0, duration: 0.1)
        ])
        
        let durationBeforeFade = GameConstants.crumbleDelay - 0.2
        let count = max(1, Int(durationBeforeFade / 0.2))
        let blink = SKAction.repeat(blinkCycle, count: count)

        let collapse = SKAction.sequence([
            blink,
            .fadeOut(withDuration: 0.2),
            .run(onCrumbled),
            .removeFromParent()
        ])
        run(collapse)
    }
}
