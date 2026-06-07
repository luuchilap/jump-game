import SwiftUI
import SpriteKit

struct ContentView: View {
    @State private var sceneID = UUID() // Use this to reset the scene
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            SpriteView(scene: gameScene, options: [.ignoresSiblingOrder])
                .ignoresSafeArea()
                .id(sceneID)
        }
    }
    
    var gameScene: SKScene {
        let scene = GameScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .aspectFill
        scene.restartAction = {
            // Reset scene by changing ID
            sceneID = UUID()
        }
        return scene
    }
}
