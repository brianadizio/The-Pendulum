import UIKit

/// A simple view that can play a sequence of images as an animation
class AnimatedImageView: UIImageView {
    
    private var imageSequence: [UIImage] = []
    private var currentIndex = 0
    private var animationTimer: Timer?
    
    /// Initialize with an array of images
    convenience init(images: [UIImage]) {
        self.init(frame: .zero)
        self.imageSequence = images
        self.image = images.first
        self.contentMode = .scaleAspectFit
    }
    
    /// Load images from bundle with a base name and count
    /// Example: "burst_" with count 10 loads burst_0.png through burst_9.png
    convenience init(imageBaseName: String, count: Int) {
        var images: [UIImage] = []
        for i in 0..<count {
            if let image = UIImage(named: "\(imageBaseName)\(i)") {
                images.append(image)
            }
        }
        self.init(images: images)
    }
    
    /// Start the animation
    func startAnimating(duration: TimeInterval = 1.0, repeatCount: Int = 1) {
        guard !imageSequence.isEmpty else { return }
        
        currentIndex = 0
        let frameInterval = duration / Double(imageSequence.count)
        var framesShown = 0
        let totalFrames = imageSequence.count * repeatCount
        
        animationTimer?.invalidate()
        animationTimer = Timer.scheduledTimer(withTimeInterval: frameInterval, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            self.image = self.imageSequence[self.currentIndex]
            self.currentIndex = (self.currentIndex + 1) % self.imageSequence.count
            framesShown += 1
            
            if framesShown >= totalFrames {
                timer.invalidate()
                self.animationTimer = nil
                self.onAnimationComplete?()
            }
        }
    }
    
    /// Stop the animation
    override func stopAnimating() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    /// Completion handler
    var onAnimationComplete: (() -> Void)?
    
    deinit {
        stopAnimating()
    }
}

/// Example usage for tab transitions
extension AnimatedImageView {
    
    /// Creates a burst animation view that plays once and removes itself
    static func createBurstAnimation(at point: CGPoint, in view: UIView, imageBaseName: String = "tab_burst_", imageCount: Int = 15) {
        let animatedView = AnimatedImageView(imageBaseName: imageBaseName, count: imageCount)
        animatedView.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        animatedView.center = point
        animatedView.alpha = 0.9
        
        view.addSubview(animatedView)
        
        animatedView.onAnimationComplete = {
            UIView.animate(withDuration: 0.2, animations: {
                animatedView.alpha = 0
            }) { _ in
                animatedView.removeFromSuperview()
            }
        }
        
        animatedView.startAnimating(duration: 0.5, repeatCount: 1)
    }
}