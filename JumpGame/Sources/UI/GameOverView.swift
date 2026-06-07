import SwiftUI

struct GameOverView: View {
    @Bindable var gameState: GameState
    @State private var appear = false

    var body: some View {
        ZStack {
            // Nền làm mờ nhẹ toàn màn hình
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .backdropFilter(radius: 5) // Tuỳ chọn thêm blur nếu iOS hỗ trợ
            
            VStack(spacing: 30) {
                // Tiêu đề Game Over
                Text("GAME OVER")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red, .orange],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .red.opacity(0.5), radius: 10, x: 0, y: 4)
                
                // Thẻ điểm số (Glass Card)
                VStack(spacing: 20) {
                    VStack(spacing: 5) {
                        Text("SCORE")
                            .font(.subheadline.bold())
                            .foregroundColor(.white.opacity(0.7))
                            .tracking(2)
                        
                        Text("\(gameState.score)")
                            .font(.system(size: 56, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                        .padding(.horizontal, 40)
                    
                    VStack(spacing: 5) {
                        Text("BEST")
                            .font(.caption.bold())
                            .foregroundColor(.yellow.opacity(0.8))
                            .tracking(2)
                        
                        Text("\(gameState.highScore)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.yellow)
                    }
                }
                .padding(.vertical, 30)
                .padding(.horizontal, 50)
                .background(.ultraThinMaterial) // Kính mờ xịn xò của Apple
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1) // Viền sáng Inner Glow
                )
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                
                // Nút Try Again
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        gameState.gameID = UUID()
                        gameState.phase = .playing
                        gameState.score = 0
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("TRY AGAIN")
                            .font(.headline.bold())
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 16)
                    .frame(width: 220)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .clipShape(Capsule())
                    .shadow(color: .white.opacity(0.3), radius: 10, x: 0, y: 4)
                }
                .padding(.top, 10)
            }
            .offset(y: appear ? 0 : 50)
            .opacity(appear ? 1 : 0)
            .scaleEffect(appear ? 1 : 0.9)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                appear = true
            }
        }
    }
}

// Extension nhỏ để hỗ trợ blur nếu cần
extension View {
    func backdropFilter(radius: CGFloat) -> some View {
        self.background(BlurView(style: .systemUltraThinMaterialDark))
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
