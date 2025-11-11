# Singular SDK Integration Guide

## Overview
The Singular SDK has been integrated into The Pendulum app for tracking ads, installs, and game-specific events including "smart way of pendulum levels balanced" as requested.

## Integration Status
- ✅ Singular SDK added via Swift Package Manager
- ✅ Test configuration created (SingularTestConfiguration.swift)
- ✅ Test UI created (SingularTestViewController.swift)
- ✅ Game-specific tracker created (SingularTracker.swift)
- ⏳ Awaiting API credentials from Singular dashboard

## Key Events Tracked

### 1. Downloads & Installs
```swift
// Track app install with device info
SingularTracker.trackInstall()

// Track download completion
SingularTracker.trackDownloadCompleted(source: "app_store")
```

### 2. Pendulum Level Balanced (Smart Tracking)
The system intelligently tracks pendulum balancing with multiple metrics:
```swift
SingularTracker.trackLevelBalanced(
    level: 5,
    balanceTime: 45.2,  // seconds
    score: 5000,
    attempts: 3
)
```

This tracks:
- **Performance efficiency**: score/time ratio
- **Difficulty classification**: easy/medium/hard/expert
- **Perfect balance achievement**: balance time > 60 seconds
- **Virtual currency earned**: for premium levels
- **Timestamp and device info**

### 3. Additional Game Events
- Session start/end with duration
- Achievements unlocked
- In-app purchases
- Tutorial progress
- Error tracking

## Setup Instructions

### 1. Add Your Singular Credentials
Edit `SingularTestConfiguration.swift`:
```swift
let config = SingularConfig(
    apiKey: "YOUR_API_KEY",      // Replace with your key
    andSecret: "YOUR_SECRET"      // Replace with your secret
)
```

### 2. Create Bridging Header (if needed)
Create `The Pendulum-Bridging-Header.h`:
```objc
#import <Singular/Singular.h>
```

Add to build settings:
- Objective-C Bridging Header: `$(PROJECT_DIR)/The Pendulum/The Pendulum-Bridging-Header.h`

### 3. Initialize on App Launch
In `AppDelegate.swift` or app initialization:
```swift
SingularTestConfiguration.initializeSingular()
```

### 4. Test the Integration
1. Run the app
2. Go to Settings → Developer Tools
3. Find "Test Singular SDK" option
4. Use the test UI to verify tracking

## Testing Pendulum Level Tracking
The test UI includes a "Track Level Balanced" button that simulates:
- Random level (1-10)
- Random balance time (10-120 seconds)
- Random score (1000-10000)
- Random attempts (1-5)

## Viewing Analytics
1. Log into your Singular dashboard
2. Navigate to Analytics → Events
3. Look for these event names:
   - `app_install`
   - `download_completed`
   - `pendulum_level_balanced`
   - `achievement_unlocked`
   - `session_start` / `session_end`

## Smart Level Balancing Metrics
The pendulum level tracking provides intelligent insights:

### Efficiency Score
- Calculated as: score / balance_time
- Higher efficiency = better performance

### Difficulty Adaptation
- Levels 1-3: Easy
- Levels 4-6: Medium  
- Levels 7-9: Hard
- Levels 10+: Expert

### Perfect Balance Detection
- Automatically detects when balance time > 60 seconds
- Triggers achievement tracking
- Provides retention insights

### Revenue Attribution
- Premium levels (>5) track virtual currency
- Coins earned = score / 100
- Helps measure monetization potential

## Production Checklist
- [ ] Obtain API Key and Secret from Singular
- [ ] Update credentials in SingularTestConfiguration.swift
- [ ] Remove test/placeholder code
- [ ] Add production event tracking throughout app
- [ ] Configure SKAdNetwork if needed
- [ ] Set up deep link handling
- [ ] Test with real ad campaigns

## Support
- Singular Documentation: https://support.singular.net/hc/en-us
- SDK Issues: Check Xcode console for initialization logs
- Integration Help: Use test UI to verify each tracking method