# The Pendulum: Perturbation System and Settings

## Overview

The new Perturbation System adds dynamic forces to the pendulum, simulating real-world conditions like wind, impacts, and environmental factors. This enhances the challenge and realism of the simulation.

The Settings tab provides a way to customize the visual and performance aspects of the simulation.

## New Features

### Perturbation System

1. **Multiple Perturbation Types**
   - **Impulse**: Sudden, strong forces at random intervals
   - **Sine Wave**: Smooth oscillating forces
   - **Data-Driven**: Forces from pre-recorded data
   - **Random**: Small, unpredictable noise
   - **Compound**: Combinations of multiple types

2. **Visual Feedback**
   - Warning indicators for upcoming perturbations
   - Particle effects showing force direction and magnitude
   - Screen shake for strong impacts

3. **Progressive Challenge**
   - Level-specific perturbation profiles
   - Increasing complexity at higher levels
   - Different perturbation patterns in various modes

### Settings Tab

1. **Graphics Settings**
   - Controls particle quality and complexity
   - Options for high definition or low power modes
   - Experimental visual options

2. **Metrics Settings**
   - Basic to advanced data displays
   - Scientific notation for precision data
   - Performance metrics options

3. **Sound Settings**
   - Standard, enhanced, or minimal audio
   - Educational sound cues option
   - Realistic physics-based sounds

4. **Background Settings**
   - Default clean background
   - Grid patterns for reference
   - Dark or light modes
   - Gradient variations

## Implementation Details

### Files Added

1. `PerturbationManager.swift`: Core manager for all perturbation types
2. `PerturbationEffects.swift`: Visual effects for perturbations
3. `SettingsManager.swift`: Manages user settings and their application
4. `ImpulseParticle.sks`: Particle template for impulse forces
5. `WindParticle.sks`: Particle template for gentle forces
6. `PerturbationData.csv`: Sample data for data-driven perturbations
7. `PerturbationTutorial.txt`: Documentation for users

### Code Structure

- **Factory Pattern**: Used for creating level-specific perturbation profiles
- **Observer Pattern**: Settings applied throughout the app via centralized manager
- **Composite Pattern**: Complex perturbations built from simpler ones

### Settings Integration

The Settings tab is fully integrated with UserDefaults for persistence and a centralized SettingsManager that applies configurations to:

- PendulumViewModel
- PendulumScene
- PerturbationEffects

## How to Use

### For Players

1. **Experience Perturbations**:
   - Start with Level 1 for gentle perturbations
   - Watch for warning indicators before impulse forces
   - Try to balance despite increasingly complex forces

2. **Customize the Experience**:
   - Use the Settings tab to adjust graphics quality
   - Set metrics detail level to your preference
   - Choose sound and background options

### For Developers

1. **Adding New Perturbation Types**:
   - Extend the `PerturbationType` enum
   - Implement processing logic in `PerturbationManager`
   - Add visual effects in `PerturbationEffects`

2. **Creating Custom Profiles**:
   - Use the factory methods in `PerturbationProfile`
   - Combine different perturbation types
   - Tune strength and frequency parameters

3. **Extending Settings**:
   - Add new options to the Settings tab UI
   - Implement application logic in `SettingsManager`
   - Connect to relevant components

## Future Enhancements

1. **Custom Graphics**:
   - Replace placeholder option buttons with themed graphics
   - Enhance particle effects with custom textures
   
2. **Advanced Perturbations**:
   - Machine learning-based perturbation patterns
   - Real-time data feeds for environmental simulations
   - User-created perturbation sequences

3. **Expanded Settings**:
   - Control panel for fine-tuning perturbation parameters
   - Save and load custom configurations
   - Shared configuration profiles

## Credits

Implemented for Golden Enterprise Solutions by Claude