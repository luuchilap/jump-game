import SwiftUI

struct GameOverView: View {
    @Bindable var gameState: GameState

    var body: some View {
        VStack(spacing: 20) {
            Text("GAME OVER")
                .font(.largeTitle.bold())
                .foregroundColor(.red)

            Text("Score: \(gameState.score)")
                .font(.title2)
                .foregroundColor(.white)

            Text("Best: \(gameState.highScore)")
                .font(.title3)
                .foregroundColor(.yellow)

            Button {
                gameState.gameID = UUID()
                gameState.phase = .playing
                gameState.score = 0
            } label: {
                Text("TRY AGAIN")
                    .font(.headline)
                    .padding()
                    .frame(width: 150)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.8))
    }
}
