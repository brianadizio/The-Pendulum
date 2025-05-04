import Foundation
import UIKit

/// Manages application settings and their effects on the simulation
class SettingsManager {
    // Singleton instance
    static let shared = SettingsManager()
    
    // Keys for UserDefaults
    private struct Keys {
        static let graphics = "setting_Graphics"
        static let metrics = "setting_Metrics"
        static let sounds = "setting_Sounds"
        static let backgrounds = "setting_Backgrounds"
    }
    
    // Default values
    private struct Defaults {
        static let graphics = "Standard"
        static let metrics = "Basic"
        static let sounds = "Standard"
        static let backgrounds = "Default"
    }
    
    // MARK: - Settings Accessors
    
    /// Current graphics setting
    var graphics: String {
        get { UserDefaults.standard.string(forKey: Keys.graphics) ?? Defaults.graphics }
        set { UserDefaults.standard.set(newValue, forKey: Keys.graphics) }
    }
    
    /// Current metrics setting
    var metrics: String {
        get { UserDefaults.standard.string(forKey: Keys.metrics) ?? Defaults.metrics }
        set { UserDefaults.standard.set(newValue, forKey: Keys.metrics) }
    }
    
    /// Current sounds setting
    var sounds: String {
        get { UserDefaults.standard.string(forKey: Keys.sounds) ?? Defaults.sounds }
        set { UserDefaults.standard.set(newValue, forKey: Keys.sounds) }
    }
    
    /// Current backgrounds setting
    var backgrounds: String {
        get { UserDefaults.standard.string(forKey: Keys.backgrounds) ?? Defaults.backgrounds }
        set { UserDefaults.standard.set(newValue, forKey: Keys.backgrounds) }
    }
    
    // MARK: - Settings Effects
    
    /// Apply graphics settings to the perturbation effects
    func applyGraphicsSettings(to perturbationEffects: PerturbationEffects) {
        switch graphics {
        case "High Definition":
            perturbationEffects.particleQuality = .high
            perturbationEffects.particleCount = 1.5 // 150% of normal
            perturbationEffects.effectDuration = 1.2 // 20% longer
            
        case "Low Power":
            perturbationEffects.particleQuality = .low
            perturbationEffects.particleCount = 0.5 // 50% of normal
            perturbationEffects.effectDuration = 0.8 // 20% shorter
            
        case "Simplified":
            perturbationEffects.particleQuality = .low
            perturbationEffects.particleCount = 0.7 // 70% of normal
            perturbationEffects.useSimplifiedEffects = true
            
        case "Detailed":
            perturbationEffects.particleQuality = .high
            perturbationEffects.particleCount = 1.2 // 120% of normal
            perturbationEffects.useAdvancedShading = true
            
        case "Experimental":
            perturbationEffects.particleQuality = .high
            perturbationEffects.particleCount = 2.0 // 200% of normal
            perturbationEffects.useExperimentalEffects = true
            
        default: // "Standard"
            perturbationEffects.particleQuality = .medium
            perturbationEffects.particleCount = 1.0 // Normal
            perturbationEffects.effectDuration = 1.0 // Normal
            perturbationEffects.useSimplifiedEffects = false
            perturbationEffects.useAdvancedShading = false
            perturbationEffects.useExperimentalEffects = false
        }
    }
    
    /// Apply metrics settings to the view model
    func applyMetricsSettings(to viewModel: PendulumViewModel) {
        switch metrics {
        case "Advanced":
            viewModel.showAdvancedMetrics = true
            viewModel.showBasicMetrics = true
            viewModel.recordTrajectory = true
            
        case "Scientific":
            viewModel.showAdvancedMetrics = true
            viewModel.showBasicMetrics = true
            viewModel.showRawData = true
            viewModel.recordTrajectory = true
            viewModel.useScientificNotation = true
            
        case "Educational":
            viewModel.showAdvancedMetrics = true
            viewModel.showBasicMetrics = true
            viewModel.showHints = true
            viewModel.recordTrajectory = true
            
        case "Detailed":
            viewModel.showAdvancedMetrics = true
            viewModel.showBasicMetrics = true
            viewModel.showRawData = true
            viewModel.recordFullTrajectory = true
            
        case "Performance":
            viewModel.showPerformanceMetrics = true
            viewModel.showBasicMetrics = true
            
        default: // "Basic"
            viewModel.showAdvancedMetrics = false
            viewModel.showBasicMetrics = true
            viewModel.showRawData = false
            viewModel.recordTrajectory = false
            viewModel.useScientificNotation = false
            viewModel.showHints = false
            viewModel.recordFullTrajectory = false
            viewModel.showPerformanceMetrics = false
        }
    }
    
    /// Apply sound settings to the scene
    func applySoundSettings(to scene: PendulumScene) {
        switch sounds {
        case "Enhanced":
            scene.soundVolume = 1.0
            scene.useSpatialAudio = true
            scene.useAdvancedSoundEffects = true
            
        case "Minimal":
            scene.soundVolume = 0.5
            scene.useMinimalSounds = true
            
        case "Realistic":
            scene.soundVolume = 1.0
            scene.useRealisticSounds = true
            
        case "None":
            scene.soundVolume = 0.0
            
        case "Educational":
            scene.soundVolume = 1.0
            scene.useEducationalSoundCues = true
            
        default: // "Standard"
            scene.soundVolume = 0.8
            scene.useSpatialAudio = false
            scene.useAdvancedSoundEffects = false
            scene.useMinimalSounds = false
            scene.useRealisticSounds = false
            scene.useEducationalSoundCues = false
        }
    }
    
    /// Apply background settings to the scene
    func applyBackgroundSettings(to scene: PendulumScene) {
        switch backgrounds {
        case "Grid":
            scene.backgroundColor = .white
            scene.showGrid = true
            
        case "Dark":
            scene.backgroundColor = .black
            scene.foregroundColor = .white
            
        case "Light":
            scene.backgroundColor = .white
            scene.foregroundColor = .black
            
        case "Gradient":
            scene.useGradientBackground = true
            
        case "None":
            scene.backgroundColor = .clear
            
        default: // "Default"
            scene.backgroundColor = .white
            scene.showGrid = false
            scene.useGradientBackground = false
            scene.foregroundColor = .black
        }
    }
    
    /// Apply all settings to the simulation
    func applyAllSettings(to viewModel: PendulumViewModel, scene: PendulumScene, effects: PerturbationEffects) {
        applyGraphicsSettings(to: effects)
        applyMetricsSettings(to: viewModel)
        applySoundSettings(to: scene)
        applyBackgroundSettings(to: scene)
    }
    
    /// Initialize with default values if needed
    init() {
        // Set defaults if not already set
        if UserDefaults.standard.string(forKey: Keys.graphics) == nil {
            graphics = Defaults.graphics
        }
        if UserDefaults.standard.string(forKey: Keys.metrics) == nil {
            metrics = Defaults.metrics
        }
        if UserDefaults.standard.string(forKey: Keys.sounds) == nil {
            sounds = Defaults.sounds
        }
        if UserDefaults.standard.string(forKey: Keys.backgrounds) == nil {
            backgrounds = Defaults.backgrounds
        }
    }
}

// MARK: - Particle Quality

/// Quality level for particle effects
enum ParticleQuality {
    case low, medium, high
}

/// Class to hold effect settings until we modify PerturbationEffects directly
class EffectSettings {
    static let shared = EffectSettings()
    
    var particleQuality: ParticleQuality = .medium
    var particleCount: Double = 1.0
    var effectDuration: Double = 1.0
    var useSimplifiedEffects: Bool = false
    var useAdvancedShading: Bool = false
    var useExperimentalEffects: Bool = false
    
    private init() {}
}

// Extension to define getters/setters that use the EffectSettings class
extension PerturbationEffects {
    var particleQuality: ParticleQuality {
        get { return EffectSettings.shared.particleQuality }
        set { EffectSettings.shared.particleQuality = newValue }
    }
    
    var particleCount: Double {
        get { return EffectSettings.shared.particleCount }
        set { EffectSettings.shared.particleCount = newValue }
    }
    
    var effectDuration: Double {
        get { return EffectSettings.shared.effectDuration }
        set { EffectSettings.shared.effectDuration = newValue }
    }
    
    var useSimplifiedEffects: Bool {
        get { return EffectSettings.shared.useSimplifiedEffects }
        set { EffectSettings.shared.useSimplifiedEffects = newValue }
    }
    
    var useAdvancedShading: Bool {
        get { return EffectSettings.shared.useAdvancedShading }
        set { EffectSettings.shared.useAdvancedShading = newValue }
    }
    
    var useExperimentalEffects: Bool {
        get { return EffectSettings.shared.useExperimentalEffects }
        set { EffectSettings.shared.useExperimentalEffects = newValue }
    }
}

// MARK: - View Model Settings

/// Class to hold view model settings
class ViewModelSettings {
    static let shared = ViewModelSettings()
    
    var showAdvancedMetrics: Bool = false
    var showBasicMetrics: Bool = true
    var showRawData: Bool = false
    var recordTrajectory: Bool = false
    var useScientificNotation: Bool = false
    var showHints: Bool = false
    var recordFullTrajectory: Bool = false
    var showPerformanceMetrics: Bool = false
    
    private init() {}
}

extension PendulumViewModel {
    var showAdvancedMetrics: Bool {
        get { return ViewModelSettings.shared.showAdvancedMetrics }
        set { ViewModelSettings.shared.showAdvancedMetrics = newValue }
    }
    
    var showBasicMetrics: Bool {
        get { return ViewModelSettings.shared.showBasicMetrics }
        set { ViewModelSettings.shared.showBasicMetrics = newValue }
    }
    
    var showRawData: Bool {
        get { return ViewModelSettings.shared.showRawData }
        set { ViewModelSettings.shared.showRawData = newValue }
    }
    
    var recordTrajectory: Bool {
        get { return ViewModelSettings.shared.recordTrajectory }
        set { ViewModelSettings.shared.recordTrajectory = newValue }
    }
    
    var useScientificNotation: Bool {
        get { return ViewModelSettings.shared.useScientificNotation }
        set { ViewModelSettings.shared.useScientificNotation = newValue }
    }
    
    var showHints: Bool {
        get { return ViewModelSettings.shared.showHints }
        set { ViewModelSettings.shared.showHints = newValue }
    }
    
    var recordFullTrajectory: Bool {
        get { return ViewModelSettings.shared.recordFullTrajectory }
        set { ViewModelSettings.shared.recordFullTrajectory = newValue }
    }
    
    var showPerformanceMetrics: Bool {
        get { return ViewModelSettings.shared.showPerformanceMetrics }
        set { ViewModelSettings.shared.showPerformanceMetrics = newValue }
    }
}

// MARK: - Scene Settings

/// Class to hold scene settings
class SceneSettings {
    static let shared = SceneSettings()
    
    var soundVolume: Double = 0.8
    var useSpatialAudio: Bool = false
    var useAdvancedSoundEffects: Bool = false
    var useMinimalSounds: Bool = false
    var useRealisticSounds: Bool = false
    var useEducationalSoundCues: Bool = false
    var showGrid: Bool = false
    var useGradientBackground: Bool = false
    var foregroundColor: UIColor = .black
    
    private init() {}
}

extension PendulumScene {
    var soundVolume: Double {
        get { return SceneSettings.shared.soundVolume }
        set { SceneSettings.shared.soundVolume = newValue }
    }
    
    var useSpatialAudio: Bool {
        get { return SceneSettings.shared.useSpatialAudio }
        set { SceneSettings.shared.useSpatialAudio = newValue }
    }
    
    var useAdvancedSoundEffects: Bool {
        get { return SceneSettings.shared.useAdvancedSoundEffects }
        set { SceneSettings.shared.useAdvancedSoundEffects = newValue }
    }
    
    var useMinimalSounds: Bool {
        get { return SceneSettings.shared.useMinimalSounds }
        set { SceneSettings.shared.useMinimalSounds = newValue }
    }
    
    var useRealisticSounds: Bool {
        get { return SceneSettings.shared.useRealisticSounds }
        set { SceneSettings.shared.useRealisticSounds = newValue }
    }
    
    var useEducationalSoundCues: Bool {
        get { return SceneSettings.shared.useEducationalSoundCues }
        set { SceneSettings.shared.useEducationalSoundCues = newValue }
    }
    
    var showGrid: Bool {
        get { return SceneSettings.shared.showGrid }
        set { SceneSettings.shared.showGrid = newValue }
    }
    
    var useGradientBackground: Bool {
        get { return SceneSettings.shared.useGradientBackground }
        set { SceneSettings.shared.useGradientBackground = newValue }
    }
    
    var foregroundColor: UIColor {
        get { return SceneSettings.shared.foregroundColor }
        set { SceneSettings.shared.foregroundColor = newValue }
    }
}