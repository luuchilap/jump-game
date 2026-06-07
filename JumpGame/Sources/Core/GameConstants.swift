import Foundation

enum GameConstants {
    // Physics
    static let gravity:        CGFloat = -15.0
    
    // Slingshot variables
    static let maxDragDistance: CGFloat = 200.0
    static let dragMultiplier:  CGFloat = 6.0

    // Platform generation
    static let minGapY:        CGFloat = 250
    static let maxGapY:        CGFloat = 300
    static let platformWidth:  CGFloat = 80
    static let platformHeight: CGFloat = 16

    // Difficulty scaling
    static let difficultyStep: CGFloat = 0.08   // tăng mỗi 10 điểm
    static let maxMoveSpeed:   CGFloat = 120.0

    // Camera
    static let cameraLeadY:    CGFloat = 200    // camera đi trước player

    // Crumbling
    static let crumbleDelay:   TimeInterval = 7.0
    static let crumbleChanceBase: Double = 0.15  // 15% ban đầu
}
