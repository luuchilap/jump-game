import SwiftUI

struct HUDView: View {
    var gameState: GameState

    var body: some View {
        VStack {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "star.circle.fill")
                        .foregroundColor(.yellow)
                        .font(.title2)
                        .shadow(color: .yellow.opacity(0.5), radius: 5, x: 0, y: 0)
                    
                    Text("\(gameState.score)")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .contentTransition(.numericText()) // Hiệu ứng số cuộn (chỉ chạy mượt trên iOS 16+)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                .padding(.leading, 20)
                .padding(.top, 50)
                
                Spacer()
            }
            // Thêm animation nhẹ khi điểm thay đổi
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: gameState.score)
            
            Spacer()
        }
    }
}
