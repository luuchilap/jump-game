import SwiftUI

struct MainMenuView: View {
    @Bindable var gameState: GameState

    var body: some View {
        VStack(spacing: 30) {
            Text("JUMP GAME")
                .font(.system(size: 48, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .shadow(radius: 5)

            Button {
                gameState.gameID = UUID()
                gameState.phase = .playing
                gameState.score = 0
            } label: {
                Text("TAP TO START")
                    .font(.title2.bold())
                    .padding()
                    .frame(width: 200)
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.6))
    }
}
