import SwiftUI
import SpriteKit

struct ParticleTestView: View {
    @State private var currentLevel = 1
    
    var scene: SKScene {
        let scene = ParticleTestScene()
        scene.currentLevel = currentLevel
        scene.scaleMode = .resizeFill
        return scene
    }
    
    var body: some View {
        VStack {
            Text("Particle Effects Test")
                .font(.title)
                .padding()
            
            Text("Current Level: \(currentLevel)")
                .font(.headline)
            
            SpriteView(scene: scene)
                .frame(height: 400)
                .background(Color.black)
            
            HStack {
                Button("Previous Level") {
                    if currentLevel > 1 {
                        currentLevel -= 1
                    }
                }
                .padding()
                
                Button("Show Effect") {
                    if let testScene = scene as? ParticleTestScene {
                        testScene.showLevelCompletionEffect(level: currentLevel)
                    }
                }
                .padding()
                
                Button("Next Level") {
                    currentLevel += 1
                }
                .padding()
            }
            
            Text("Tap 'Show Effect' to see the particle animation for the current level")
                .font(.caption)
                .padding()
        }
    }
}

class ParticleTestScene: SKScene {
    var currentLevel = 1
    
    override func didMove(to view: SKView) {
        backgroundColor = .darkGray
    }
    
    func showLevelCompletionEffect(level: Int) {
        let centerPosition = CGPoint(x: frame.midX, y: frame.midY)
        DynamicParticleManager.createLevelCompletionEffect(for: level, at: centerPosition, in: self)
    }
}

#Preview {
    ParticleTestView()
}