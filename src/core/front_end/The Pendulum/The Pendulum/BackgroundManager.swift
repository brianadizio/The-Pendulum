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
            // AI folder images from asset catalog (16 images)
            imageNames = ["IMG_9322", "IMG_9324", "IMG_9325", "IMG_9326", "IMG_9383", 
                         "IMG_9384", "IMG_9385", "IMG_9386", "IMG_9387", "IMG_9388", 
                         "IMG_9389", "IMG_9390", "IMG_9391", "IMG_9392", "IMG_9393", 
                         "IMG_9394"]
        case .acadia:
            // Acadia folder images from asset catalog (30 images)
            imageNames = ["IMG_9441", "IMG_9444", "IMG_9447", "IMG_9451", "IMG_9476", 
                         "IMG_9479", "IMG_9487", "IMG_9495", "IMG_9500", "IMG_9502", 
                         "IMG_9505", "IMG_9519", "IMG_9520", "IMG_9531", "IMG_9536", 
                         "IMG_9539", "IMG_9543", "IMG_9545", "IMG_9572", "IMG_9579", 
                         "IMG_9581", "IMG_9582", "IMG_9583", "IMG_9584", "IMG_9600", 
                         "IMG_9602", "IMG_9611", "IMG_9630", "IMG_9633", "IMG_9636"]
        case .fluid:
            // Fluid folder images from asset catalog (12 images)
            imageNames = ["IMG_3149", "IMG_3251", "IMG_3252", "IMG_3253", "IMG_3790", 
                         "IMG_5184", "IMG_5185", "IMG_5583", "IMG_9603", "IMG_9604", 
                         "IMG_9794", "IMG_9959"]
        case .immersiveTopology:
            // ImmersiveTopology folder images from asset catalog (63 images)
            imageNames = ["IMG_0042", "IMG_0044", "IMG_5180", "IMG_5187", "IMG_5188", 
                         "IMG_5193", "IMG_5194", "IMG_5200", "IMG_5203", "IMG_5204", 
                         "IMG_5205", "IMG_5208", "IMG_5210", "IMG_5211", "IMG_5212", 
                         "IMG_5215", "IMG_5217", "IMG_5219", "IMG_5224", "IMG_5226", 
                         "IMG_5228", "IMG_5233", "IMG_5234", "IMG_5237", "IMG_5238", 
                         "IMG_5239", "IMG_5555", "IMG_5558", "IMG_5559", "IMG_5560", 
                         "IMG_5561", "IMG_5563", "IMG_5567", "IMG_5569", "IMG_5570", 
                         "IMG_5572", "IMG_5585", "IMG_5587", "IMG_5590", "IMG_5597", 
                         "IMG_5598", "IMG_5603", "IMG_5607", "IMG_5608", "IMG_5609", 
                         "IMG_5612", "IMG_5904", "IMG_6831", "IMG_6833", "IMG_6837", 
                         "IMG_6838", "IMG_6839", "IMG_6842", "IMG_6843", "IMG_6844", 
                         "IMG_6845", "IMG_6846", "IMG_6847", "IMG_6859", "IMG_6867", 
                         "IMG_7058", "IMG_7068", "IMG_7074"]
        case .joshuaTree:
            // Joshua Tree folder images from asset catalog (30 images)
            imageNames = ["IMG_4014", "IMG_4030", "IMG_4037", "IMG_4044", "IMG_4051", 
                         "IMG_4081", "IMG_4082", "IMG_4093", "IMG_4094", "IMG_4095", 
                         "IMG_4096", "IMG_4103", "IMG_4106", "IMG_4114", "IMG_4127", 
                         "IMG_4196", "IMG_4200", "IMG_4216", "IMG_4218", "IMG_4220", 
                         "IMG_4224", "IMG_4225", "IMG_4228", "IMG_4231", "IMG_4233", 
                         "IMG_4239", "IMG_4245", "IMG_4249", "IMG_4254", "IMG_4285"]
        case .outerSpace:
            // Outer Space folder images from asset catalog (29 images)
            imageNames = ["IMG_9352", "IMG_9353", "IMG_9354", "IMG_9355", "IMG_9356",
                         "IMG_9357", "IMG_9358", "IMG_9359", "IMG_9360", "IMG_9361",
                         "IMG_9362", "IMG_9363", "IMG_9364", "IMG_9365", "IMG_9366",
                         "IMG_9367", "IMG_9368", "IMG_9369", "IMG_9370", "IMG_9371",
                         "IMG_9372", "IMG_9373", "IMG_9374", "IMG_9375", "IMG_9376",
                         "IMG_9376 (1)", "IMG_9378", "IMG_9379", "IMG_9380"]
        case .parchment:
            // Parchment folder images from asset catalog (8 images)
            imageNames = ["165102644", "165102644 (1)", "165102644 (2)", "165102644 (3)", 
                         "IMG_6528", "IMG_6529", "IMG_6530", "IMG_9705"]
        case .sachuest:
            // Sachuest folder images from asset catalog (49 images)
            imageNames = ["IMG_1526", "IMG_3198", "IMG_3713", "IMG_3794", "IMG_3797",
                         "IMG_3805", "IMG_3806", "IMG_3809", "IMG_3831", "IMG_4054", 
                         "IMG_4067", "IMG_4112", "IMG_4354", "IMG_4356", "IMG_4664", 
                         "IMG_4741", "IMG_4779", "IMG_4796", "IMG_4818", "IMG_4939", 
                         "IMG_4941", "IMG_5041", "IMG_5118", "IMG_5147", "IMG_5234", 
                         "IMG_5243", "IMG_5278", "IMG_5294", "IMG_5527", "IMG_5638", 
                         "IMG_5669", "IMG_5734", "IMG_5792", "IMG_5939", "IMG_5994", 
                         "IMG_6123", "IMG_6577", "IMG_6589", "IMG_6665", "IMG_7200", 
                         "IMG_7200 (1)", "IMG_7588", "IMG_7871", "IMG_8751", "IMG_9154", 
                         "IMG_9156", "IMG_9696", "IMG_9697", "IMG_9699"]
        case .theMazeGuide:
            // The Maze Guide folder images from asset catalog (29 images)
            imageNames = ["IMG_1189", "IMG_1192", "IMG_1193", "IMG_1194", "IMG_1195", 
                         "IMG_1196", "IMG_1197", "IMG_1198", "IMG_1199", "IMG_1200", 
                         "IMG_1202", "IMG_1203", "IMG_1204", "IMG_1205", "IMG_1207", 
                         "IMG_1208", "IMG_1209", "IMG_1210", "IMG_1211", "IMG_1212", 
                         "IMG_1213", "IMG_1214", "IMG_1215", "IMG_1216", "IMG_1217", 
                         "IMG_1219", "IMG_1220", "IMG_1221", "IMG_1223"]
        case .thePortraits:
            // The Portraits folder images from asset catalog (20 images)
            imageNames = ["IMG_2650", "IMG_2656", "IMG_3101", "IMG_3145", "IMG_3146", 
                         "IMG_3148", "IMG_3149", "IMG_3150", "IMG_3151", "IMG_3229", 
                         "IMG_3251", "IMG_3252", "IMG_3253", "IMG_4824", "IMG_4825", 
                         "IMG_4844", "IMG_4860", "IMG_4861", "IMG_5070", "IMG_6976"]
        case .tsp:
            // TSP folder images from asset catalog (38 images)
            imageNames = ["IMG_0063", "IMG_0064", "IMG_0065", "IMG_0066", "IMG_0068", 
                         "IMG_0069", "IMG_0070", "IMG_0071", "IMG_0072", "IMG_0073", 
                         "IMG_0074", "IMG_0075", "IMG_0076", "IMG_0078", "IMG_0079", 
                         "IMG_0080", "IMG_0081", "IMG_0082", "IMG_0083", "IMG_0084", 
                         "IMG_0085", "IMG_0087", "IMG_0088", "IMG_0089", "IMG_0090", 
                         "IMG_0091", "IMG_0092", "IMG_0093", "IMG_0094", "IMG_0095", 
                         "IMG_0096", "IMG_0097", "IMG_0098", "IMG_0099", "IMG_0100", 
                         "IMG_0101", "IMG_0102", "IMG_0103"]
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