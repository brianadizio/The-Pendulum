# Core Data Schema for Control Tracking

## New Entities to Add

### 1. **ControlSession** Entity
Tracks overall control session data and user preferences.

**Attributes:**
- `sessionId` (UUID, Required): Unique identifier for the control session
- `controlType` (String, Required): "push", "slider", "gyroscope", "swipe", "tilt", "tap"
- `startDate` (Date, Required): When the control session began
- `endDate` (Date, Optional): When the control session ended
- `totalDuration` (Double, Required): Total session duration in seconds
- `totalForceApplications` (Int32, Required): Number of force applications
- `averageForceStrength` (Double, Required): Average force magnitude applied
- `maxForceStrength` (Double, Required): Maximum force applied in session
- `sensitivity` (Double, Required): Control sensitivity setting (0.1-1.0)
- `deviceOrientation` (String, Required): "portrait", "landscape_left", "landscape_right"
- `gameLevel` (Int32, Required): Game level during the session
- `gameMode` (String, Required): "progressive", "quasi_periodic", etc.

**Relationships:**
- `controlInputs` (One-to-Many): Related ControlInput entities
- `playSession` (Many-to-One): Related PlaySession entity

### 2. **ControlInput** Entity
Tracks individual control inputs and their effects.

**Attributes:**
- `inputId` (UUID, Required): Unique identifier for the input
- `timestamp` (Date, Required): When the input occurred
- `controlType` (String, Required): Type of control used
- `inputData` (String, Required): JSON string containing control-specific data
- `forceApplied` (Double, Required): Actual force applied to pendulum
- `direction` (String, Required): "left", "right", "up", "down", "none"
- `pendulumAngle` (Double, Required): Pendulum angle at time of input (radians)
- `pendulumVelocity` (Double, Required): Angular velocity at time of input
- `responseTime` (Double, Required): Time from input to force application (ms)
- `effectivenessScore` (Double, Optional): How effective the input was (0.0-1.0)

**Relationships:**
- `controlSession` (Many-to-One): Related ControlSession entity

### 3. **ControlPreferences** Entity
Stores user preferences for different control types.

**Attributes:**
- `userId` (String, Optional): User ID if authenticated
- `deviceId` (String, Required): Device identifier
- `controlType` (String, Required): Control type these preferences apply to
- `sensitivity` (Double, Required): Preferred sensitivity (0.1-1.0)
- `isEnabled` (Bool, Required): Whether this control type is enabled
- `customSettings` (String, Optional): JSON string for control-specific settings
- `lastUsed` (Date, Optional): When this control type was last used
- `totalUsageTime` (Double, Required): Total time spent using this control
- `proficiencyLevel` (Double, Required): User skill level with this control (0.0-1.0)
- `createdDate` (Date, Required): When preferences were first created
- `updatedDate` (Date, Required): When preferences were last updated

### 4. **MotionCalibration** Entity
Stores calibration data for motion-based controls (gyroscope, tilt).

**Attributes:**
- `calibrationId` (UUID, Required): Unique calibration identifier
- `deviceId` (String, Required): Device identifier
- `controlType` (String, Required): "gyroscope" or "tilt"
- `calibrationDate` (Date, Required): When calibration was performed
- `baselineX` (Double, Required): Baseline X-axis reading
- `baselineY` (Double, Required): Baseline Y-axis reading
- `baselineZ` (Double, Required): Baseline Z-axis reading
- `sensitivityMultiplier` (Double, Required): Calibrated sensitivity
- `deadZone` (Double, Required): Motion threshold to ignore noise
- `maxRange` (Double, Required): Maximum expected motion range
- `isActive` (Bool, Required): Whether this calibration is currently active

## Control-Specific Input Data Schemas

### Push Control
```json
{
  "buttonType": "left" | "right",
  "touchLocation": {"x": 100, "y": 200},
  "touchPressure": 0.5,
  "holdDuration": 0.25
}
```

### Slider Control
```json
{
  "sliderValue": 0.75,
  "sliderPosition": {"x": 150, "y": 300},
  "deltaFromPrevious": 0.1,
  "velocity": 2.5
}
```

### Gyroscope Control
```json
{
  "pitch": -0.2,
  "roll": 0.15,
  "yaw": 0.05,
  "rotationRate": {"x": 0.1, "y": -0.05, "z": 0.02},
  "gravity": {"x": 0.0, "y": -1.0, "z": 0.1},
  "calibrated": true
}
```

### Swipe Control
```json
{
  "startLocation": {"x": 100, "y": 200},
  "endLocation": {"x": 200, "y": 180},
  "velocity": 850.5,
  "distance": 102.5,
  "direction": "right",
  "duration": 0.12
}
```

### Tilt Control
```json
{
  "deviceAttitude": {"pitch": 0.1, "roll": -0.05, "yaw": 0.0},
  "gravityVector": {"x": 0.1, "y": -0.99, "z": 0.05},
  "tiltAngle": 5.7,
  "tiltDirection": "left",
  "smoothedValue": 0.3
}
```

### Tap Control
```json
{
  "tapLocation": {"x": 160, "y": 240},
  "tapCount": 1,
  "tapForce": 0.8,
  "tapDuration": 0.05,
  "quadrant": "top_right"
}
```

## Analytics Enhancement

### New Metrics to Track
- **Control Efficiency**: Success rate per control type
- **Learning Curve**: Improvement over time per control type
- **Preference Patterns**: Which controls users prefer for different levels
- **Device Orientation Impact**: How orientation affects control performance
- **Multi-Control Usage**: Users who switch between control types
- **Accessibility**: Control types that work better for different user needs

### Performance Indicators
- **Input Latency**: Time from user input to physics response
- **Precision**: How accurately users can control the pendulum
- **Consistency**: Variation in control effectiveness
- **Fatigue Factors**: How performance changes over time
- **Error Recovery**: How well different controls help recover from mistakes

## Firebase Integration

### Firestore Collections Structure
```
users/{userId}/controlSessions/{sessionId}
users/{userId}/controlPreferences/{controlType}
users/{userId}/motionCalibrations/{calibrationId}
globalStats/controlUsage/{date}
```

### Sync Strategy
- **Real-time**: Control preferences and calibrations
- **Batch**: Control sessions and detailed input data
- **Analytics**: Aggregated statistics for leaderboards and insights

## Migration Strategy

### Phase 1: Core Data Model Update
1. Add new entities to PendulumScoreData.xcdatamodeld
2. Create NSManagedObject subclasses
3. Update CoreDataManager with new methods

### Phase 2: Control Implementation
1. Implement each control type with data tracking
2. Integrate with existing force application system
3. Add UI for control selection and calibration

### Phase 3: Analytics Integration
1. Update AnalyticsManager for control tracking
2. Add control-specific achievement triggers
3. Implement Firebase sync for control data

This schema provides comprehensive tracking while maintaining performance and enabling rich analytics for improving the control experience.