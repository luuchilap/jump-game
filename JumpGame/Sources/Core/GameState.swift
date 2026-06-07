import SwiftUI

enum GamePhase { case menu, playing, gameOver }

@Observable
class GameState {
    var phase: GamePhase = .menu
    var gameID: UUID = UUID()
    var score: Int = 0
    var highScore: Int = UserDefaults.standard.integer(forKey: "highScore")

    func updateHighScore() {
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "highScore")
        }
    }
}
