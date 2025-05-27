import UIKit

// Background Manager for dynamic background switching
class BackgroundManager {
    
    // Singleton instance
    static let shared = BackgroundManager()
    
    // Available background folders
    enum BackgroundFolder: String, CaseIterable {
        case none = "None"
        case ai = "AI"
        case acadia = "Acadia"
        case fluid = "Fluid"
        case immersiveTopology = "Immersive Topology"
        case joshuaTree = "Joshua Tree"
        case outerSpace = "Outer Space"
        case parchment = "Parchment"
        case sachuest = "Sachuest"
        case theMazeGuide = "The Maze Guide"
        case thePortraits = "The Portraits"
        case tsp = "TSP"
        
        var folderName: String {
            switch self {
            case .none: return ""
            case .ai: return "AI"
            case .acadia: return "Acadia"
            case .fluid: return "Fluid"
            case .immersiveTopology: return "ImmersiveTopology"
            case .joshuaTree: return "JoshuaTree"
            case .outerSpace: return "OuterSpace"
            case .parchment: return "Parchment"
            case .sachuest: return "Sachuest"
            case .theMazeGuide: return "TheMazeGuide"
            case .thePortraits: return "ThePortraits"
            case .tsp: return "TSP"
            }
        }
    }
    
    // Theme colors enum for perturbation effects
    enum ThemeColors {
        case golden
        case sunset
        case ocean
        case forest
    }
    
    // Current selected folder
    private var currentFolder: BackgroundFolder = .none
    
    // Cache of available images per folder
    private var imageCache: [BackgroundFolder: [String]] = [:]
    
    // Background image views for smooth transitions
    private var backgroundImageViews: [UIView: UIImageView] = [:]
    
    private init() {
        loadImageCache()
    }
    
    // Load available images for each folder
    private func loadImageCache() {
        for folder in BackgroundFolder.allCases {
            guard folder != .none else { continue }
            
            // In a real app, you'd scan the folder in the bundle
            // For now, we'll use placeholder image names
            imageCache[folder] = getImagesForFolder(folder)
        }
    }
    
    // Get image names for a specific folder
    private func getImagesForFolder(_ folder: BackgroundFolder) -> [String] {
        guard folder != .none else { return [] }
        
        var imageNames: [String] = []
        let folderPath = folder.folderName
        
        // Get all files in the asset catalog for this folder
        // Using the actual image names from the asset catalog
        switch folder {
        case .none:
            return []
        case .ai:
            // Actual AI folder images from asset catalog
            imageNames = ["IMG_9322", "IMG_9324", "IMG_9325"]
        case .acadia:
            // Actual Acadia folder images from asset catalog
            imageNames = ["IMG_9441", "IMG_9444"]
        case .fluid:
            // Actual Fluid folder images from asset catalog
            imageNames = ["IMG_3149", "IMG_3251", "IMG_3252"]
        case .immersiveTopology:
            // Actual ImmersiveTopology folder images from asset catalog
            imageNames = ["IMG_0042", "IMG_0044", "IMG_5180"]
        case .joshuaTree:
            // Actual Joshua Tree folder images from asset catalog
            imageNames = ["IMG_4014", "IMG_4030", "IMG_4037"]
        case .outerSpace:
            // Actual Outer Space folder images from asset catalog
            imageNames = ["IMG_9352", "IMG_9353", "IMG_9354", "IMG_9355", "IMG_9356",
                         "IMG_9357", "IMG_9358", "IMG_9359", "IMG_9360", "IMG_9361",
                         "IMG_9362", "IMG_9363", "IMG_9364", "IMG_9365", "IMG_9366",
                         "IMG_9367", "IMG_9368", "IMG_9369", "IMG_9370", "IMG_9371",
                         "IMG_9372", "IMG_9373", "IMG_9374", "IMG_9375", "IMG_9376",
                         "IMG_9376 (1)", "IMG_9378", "IMG_9379", "IMG_9380"]
        case .parchment:
            // Actual Parchment folder images from asset catalog (4 unique images)
            imageNames = ["165102644", "165102644 (1)", "165102644 (2)", "165102644 (3)"]
        case .sachuest:
            // Actual Sachuest folder images from asset catalog (8 unique images)
            imageNames = ["IMG_1526", "IMG_3198", "IMG_3713", "IMG_3794", "IMG_3797",
                         "IMG_3805", "IMG_3806", "IMG_3809"]
        case .theMazeGuide:
            // Actual The Maze Guide folder images from asset catalog (3 unique images)
            imageNames = ["IMG_1189", "IMG_1192", "IMG_1193"]
        case .thePortraits:
            // Actual The Portraits folder images from asset catalog (3 unique images)
            imageNames = ["IMG_2650", "IMG_2656", "IMG_3101"]
        case .tsp:
            // Actual TSP folder images from asset catalog (3 unique images)
            imageNames = ["IMG_0063", "IMG_0064", "IMG_0065"]
        }
        
        return imageNames
    }
    
    // Get current folder
    func getCurrentFolder() -> BackgroundFolder {
        return currentFolder
    }
    
    // Update background mode from settings
    func updateBackgroundMode(_ mode: String) {
        if let folder = BackgroundFolder.allCases.first(where: { $0.rawValue == mode }) {
            currentFolder = folder
            print("BackgroundManager: Updated mode to \(mode) (folder: \(folder.folderName))")
        } else {
            print("BackgroundManager: Failed to find folder for mode: \(mode)")
        }
    }
    
    // Apply a random background to a view
    func applyRandomBackground(to view: UIView, animated: Bool = true) {
        print("[BackgroundManager] applyRandomBackground called for \(type(of: view)) with folder: \(currentFolder.rawValue)")
        
        guard currentFolder != .none else {
            print("[BackgroundManager] Current folder is None, removing background")
            removeBackground(from: view)
            // Restore the original background color
            view.backgroundColor = UIColor.goldenBackground
            return
        }
        
        // Get random image from current folder
        guard let images = imageCache[currentFolder], !images.isEmpty else {
            print("[BackgroundManager] No images found for folder: \(currentFolder.rawValue)")
            return
        }
        
        let randomImage = images.randomElement()!
        print("[BackgroundManager] Selected random image: \(randomImage)")
        
        // Create or get the background image view
        let backgroundImageView = getOrCreateBackgroundImageView(for: view)
        
        // Make the view's background clear so we can see the image
        view.backgroundColor = .clear
        print("[BackgroundManager] View background color set to clear")
        
        // Load the image
        var foundImage: UIImage? = nil
        
        // Try direct name first
        if let image = UIImage(named: randomImage) {
            foundImage = image
            print("BackgroundManager: Found image with name: \(randomImage)")
        } else {
            // Try with folder prefix (asset catalog style)
            let imageName = "\(currentFolder.folderName)/\(randomImage)"
            if let image = UIImage(named: imageName) {
                foundImage = image
                print("BackgroundManager: Found image with folder path: \(imageName)")
            } else {
                // For asset catalog images in a folder, also try the name directly if the folder name is part of the bundle
                print("BackgroundManager: Could not find image: \(randomImage) or \(imageName)")
                print("BackgroundManager: Available images in \(currentFolder.rawValue): \(images)")
            }
        }
        
        if let image = foundImage {
            if animated {
                UIView.transition(with: backgroundImageView,
                                  duration: 0.5,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    backgroundImageView.image = image
                })
            } else {
                backgroundImageView.image = image
            }
        } else {
            // No image found, remove the background
            print("BackgroundManager: No image found, removing background for \(type(of: view))")
            removeBackground(from: view)
        }
    }
    
    // Get or create background image view for a view
    private func getOrCreateBackgroundImageView(for view: UIView) -> UIImageView {
        if let existingImageView = backgroundImageViews[view] {
            print("[BackgroundManager] Using existing image view for \(type(of: view))")
            return existingImageView
        }
        
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.alpha = 1.0
        imageView.isHidden = false
        
        // Add as the bottom-most subview
        view.insertSubview(imageView, at: 0)
        
        // Store reference
        backgroundImageViews[view] = imageView
        
        print("[BackgroundManager] Created new background image view for \(type(of: view))")
        print("[BackgroundManager] Image view frame: \(imageView.frame)")
        print("[BackgroundManager] Image view is hidden: \(imageView.isHidden)")
        print("[BackgroundManager] Image view alpha: \(imageView.alpha)")
        print("[BackgroundManager] Parent view subviews count: \(view.subviews.count)")
        
        return imageView
    }
    
    // Remove background from view
    func removeBackground(from view: UIView) {
        if let imageView = backgroundImageViews[view] {
            UIView.animate(withDuration: 0.3, animations: {
                imageView.alpha = 0
            }) { _ in
                imageView.removeFromSuperview()
                self.backgroundImageViews.removeValue(forKey: view)
            }
        }
    }
    
    // Apply backgrounds to all tabs
    func applyBackgroundToAllTabs(in viewController: PendulumViewController) {
        print("[BackgroundManager] applyBackgroundToAllTabs called")
        
        let views = [
            viewController.simulationView,
            viewController.dashboardView,
            viewController.modesView,
            viewController.integrationView,
            viewController.parametersView,
            viewController.settingsView
        ]
        
        for (index, view) in views.enumerated() {
            print("[BackgroundManager] Processing view \(index): \(type(of: view))")
            applyRandomBackground(to: view)
            
            // Make sure child views don't block the background
            print("[BackgroundManager] Clearing backgrounds for \(view.subviews.count) subviews")
            for subview in view.subviews {
                if subview != backgroundImageViews[view] {
                    if subview.backgroundColor == UIColor.goldenBackground {
                        print("[BackgroundManager] Clearing golden background from subview: \(type(of: subview))")
                        subview.backgroundColor = .clear
                    }
                }
            }
        }
        
        print("[BackgroundManager] Finished applying backgrounds to all tabs")
    }
    
    // Cycle background on specific events
    func cycleBackground(for view: UIView) {
        applyRandomBackground(to: view, animated: true)
    }
    
    // Clean up resources
    func cleanup() {
        for (_, imageView) in backgroundImageViews {
            imageView.removeFromSuperview()
        }
        backgroundImageViews.removeAll()
    }
    
    // Get theme colors based on current folder
    func getThemeColors() -> ThemeColors {
        switch currentFolder {
        case .sachuest, .acadia, .outerSpace, .fluid:
            return .ocean
        case .joshuaTree, .ai:
            return .sunset
        case .immersiveTopology, .theMazeGuide:
            return .forest
        case .parchment, .thePortraits, .tsp, .none:
            return .golden
        }
    }
}