import Foundation

struct PhysicsCategory {
    static let player:   UInt32 = 0b001   // 1
    static let platform: UInt32 = 0b010   // 2
    static let killZone: UInt32 = 0b100   // 4 (rơi xuống đáy = game over)
}
