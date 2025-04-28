// GameViewController.swift
import UIKit
import SpriteKit

class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create and configure a SKView
        let skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Show debug info
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        // Create and present the pendulum scene
        let scene = PendulumScene(size: view.bounds.size)
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
        
        // Add the SKView to the view hierarchy
        view.addSubview(skView)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}