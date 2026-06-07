import SwiftUI

struct HUDView: View {
    var gameState: GameState

    var body: some View {
        VStack {
            HStack {
                Text("Score: \(gameState.score)")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding()
                Spacer()
            }
            Spacer()
        }
    }
}
