import SwiftUI

struct MainMenuView: View {
    @Bindable var gameState: GameState
    @State private var isPulsing = false

    var body: some View {
        ZStack {
            // Nền tối tạo chiều sâu
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 50) {
                // Tiêu đề với Gradient Typography và Shadow
                VStack(spacing: 8) {
                    Text("JUMP")
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color(white: 0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .white.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    Text("THE IMPOSSIBLE")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .tracking(8) // Kerning sang trọng
                        .foregroundColor(.yellow)
                        .shadow(color: .yellow.opacity(0.5), radius: 5, x: 0, y: 2)
                }
                .padding(.top, 60)

                Spacer()

                // Nút Start mang phong cách Premium
                Button {
                    // Haptic feedback (tuỳ chọn thêm sau nếu cần)
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        gameState.gameID = UUID()
                        gameState.phase = .playing
                        gameState.score = 0
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "play.fill")
                            .font(.title2.bold())
                        Text("PLAY NOW")
                            .font(.title2.bold().monospaced())
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)
                    .background(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.black)
                    .clipShape(Capsule())
                    // Inner glow / Outer shadow
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
                    .shadow(color: .orange.opacity(0.5), radius: isPulsing ? 20 : 10, x: 0, y: isPulsing ? 10 : 5)
                    .scaleEffect(isPulsing ? 1.05 : 1.0)
                }
                .padding(.bottom, 80)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}
