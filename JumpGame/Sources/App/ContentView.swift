import SwiftUI
import SpriteKit

struct ContentView: View {
    @State private var gameState = GameState()

    var body: some View {
        ZStack {
            // SpriteKit game view
            SpriteView(scene: makeScene())
                .ignoresSafeArea()
                .id(gameState.gameID)

            // SwiftUI overlay theo phase
            switch gameState.phase {
            case .menu:
                MainMenuView(gameState: gameState)
            case .playing:
                HUDView(gameState: gameState)
            case .gameOver:
                GameOverView(gameState: gameState)
            }
        }
        .statusBar(hidden: true)
    }

    private func makeScene() -> GameScene {
        let scene = GameScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .resizeFill
        scene.gameState = gameState
        return scene
    }
}
