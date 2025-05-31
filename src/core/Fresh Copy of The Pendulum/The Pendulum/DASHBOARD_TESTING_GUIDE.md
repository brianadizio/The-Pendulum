# Dashboard Testing Guide

## Overview

The Dashboard Testing System provides comprehensive tools to validate, test, and simulate gameplay data for The Pendulum's analytics dashboard. This ensures that the dashboard displays accurate, meaningful data across all time ranges and player profiles.

## Components

### 1. DashboardDataValidator
Validates metrics and chart data for correctness and consistency.

### 2. GameplayDataSimulator  
Generates realistic gameplay data for different player profiles and time periods.

### 3. DashboardTestingViewController
Visual interface for testing and inspecting dashboard data.

### 4. DashboardCalculationsTests
Unit tests for all metric calculations.

## Quick Start

### Running Tests Programmatically

```swift
// Quick validation of current data
DashboardTestingCoordinator.quickTest()

// Generate sample data for testing
DashboardTestingCoordinator.generateSampleData()

// Run comprehensive test suite
DashboardTestingCoordinator.runAllTests()
```

### Using the Visual Testing Interface

1. Add to your tab bar or navigation:
```swift
let testingVC = DashboardTestingViewController()
navigationController?.pushViewController(testingVC, animated: true)
```

2. Use the interface to:
   - Generate sample data
   - Validate current metrics
   - Simulate gameplay sessions
   - Inspect validation results

## Validation Checks

### Metric Validations
- **Stability Score**: 0-100 range, no NaN/Inf values
- **Efficiency Rating**: 0-100 range, no NaN/Inf values
- **Directional Bias**: -1.0 to 1.0 range
- **Reaction Time**: Positive values, warning if > 5s
- **Player Style**: Must be a known style

### Chart Data Validations
- Data and label counts must match
- No NaN or Infinite values
- Chart-specific validations (e.g., positive angle variance)

### Cross-Validations
- Stability score should correlate with angle variance
- Efficiency should make sense given force applied
- Learning curve should generally show improvement

## Simulation Profiles

### Beginner
- Low stability (30%)
- High variance
- Slower reactions
- More overcorrections

### Intermediate
- Moderate stability (60%)
- Balanced performance
- Average reaction times

### Expert
- High stability (85%)
- Minimal force usage
- Quick, precise corrections
- Low overcorrection rate

### Erratic
- Inconsistent performance
- High directional bias
- Frequent overcorrections

### Improver
- Shows clear improvement over time
- Good for testing learning curves

## Testing Scenarios

### 1. Sanity Check Current Data
```swift
let coordinator = DashboardTestingCoordinator()
let report = coordinator.generateTestReport()
print(report)
```

### 2. Simulate Year of Gameplay
```swift
let simulator = GameplayDataSimulator()
let yearProgression = [
    (.beginner, 2),     // 2 months
    (.improver, 4),     // 4 months
    (.intermediate, 4), // 4 months  
    (.expert, 2)        // 2 months
]
let sessions = simulator.simulateYearOfGameplay(profileProgression: yearProgression)
```

### 3. Test Specific Edge Cases
```swift
// Perfect player
let perfectParams = GameplayDataSimulator.SimulationParameters(
    baseStability: 95.0,
    stabilityVariance: 2.0,
    reactionTimeBase: 0.1,
    forceMultiplier: 0.5
)
simulator.simulateGameplay(profile: .custom(parameters: perfectParams), duration: 300, levels: 5)
```

## Visual Inspection Checklist

When visually inspecting the dashboard:

1. **Summary Cards**
   - [ ] All values display correctly
   - [ ] No "NaN" or "undefined" values
   - [ ] Values are in expected ranges
   - [ ] Colors indicate valid/invalid states

2. **Charts**
   - [ ] Data points align with labels
   - [ ] No visual glitches or overlaps
   - [ ] Smooth transitions between time ranges
   - [ ] Legends and titles are correct

3. **Time Range Switching**
   - [ ] Data updates appropriately
   - [ ] No data from wrong time periods
   - [ ] Aggregations make sense

4. **Phase Space Chart**
   - [ ] Trajectories look realistic
   - [ ] Different levels show progression
   - [ ] No impossible physics states

## Common Issues and Solutions

### Issue: NaN Values in Metrics
**Cause**: Division by zero or invalid calculations
**Solution**: Check for empty buffers or zero denominators

### Issue: Metrics Don't Match Gameplay
**Cause**: Data not being tracked properly
**Solution**: Verify AnalyticsManager is tracking during gameplay

### Issue: Charts Show Wrong Time Period
**Cause**: Time range selection not updating data
**Solution**: Check timeRangeChanged handler implementation

### Issue: Validation Warnings but Data Looks Correct
**Cause**: Thresholds may need adjustment
**Solution**: Review validation rules for your game balance

## Running Unit Tests

```bash
# Run all dashboard tests
xcodebuild test -scheme "The Pendulum" -only-testing:The_PendulumTests/DashboardCalculationsTests

# Run specific test
xcodebuild test -scheme "The Pendulum" -only-testing:The_PendulumTests/DashboardCalculationsTests/testStabilityScoreCalculation
```

## Integration with CI/CD

Add to your CI pipeline:

```yaml
- name: Run Dashboard Tests
  run: |
    xcodebuild test -scheme "The Pendulum" \
      -destination 'platform=iOS Simulator,name=iPhone 14' \
      -only-testing:The_PendulumTests/DashboardCalculationsTests
```

## Performance Considerations

- Simulation generates realistic data but is computationally intensive
- Run long-term simulations on background queues
- Batch Core Data operations for better performance
- Clear old test data periodically to maintain performance

## Future Enhancements

1. **Automated Visual Testing**
   - Screenshot comparison for charts
   - Automated UI testing for dashboard

2. **More Simulation Profiles**
   - Child player profile
   - Accessibility-focused profiles
   - Custom difficulty curves

3. **Export Test Reports**
   - PDF generation
   - CSV export for analysis
   - Integration with analytics platforms