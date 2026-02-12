# The Golden Mode

## Technical Documentation — The Maze 3.0

---

## Overview

The Golden Mode is a reactive third maze mode that uses external biometric and behavioral data streams to build a **10-dimensional digital signature** of the user's current state, then selects mazes from the existing 50,863-maze catalog that best match that signature. Each maze is classified by its predicted cognitive-emotional **impact**, and multi-maze **session arcs** track how impact evolves across a play session. After 20+ sessions, an on-device **CoreML classifier** learns which signature-maze combinations produce the best outcomes and takes over maze selection from the rule-based bootstrap system.

**Entry points:** Modes tab (GoldenModeCard) or Integration tab (connection status)

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Data Sources                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │ Apple Health  │  │ The Pendulum │  │ Gameplay History  │  │
│  │ (HealthKit)   │  │ (CSV/Firebase)│  │ (MazePlayHistory)│  │
│  └──────┬───────┘  └──────┬───────┘  └────────┬─────────┘  │
│         │                 │                    │            │
│         ▼                 ▼                    ▼            │
│  ┌─────────────────────────────────────────────────────┐    │
│  │           GoldenModeService (core brain)            │    │
│  │  buildSignature() → selectMaze() → predictImpact() │    │
│  └────────────────────────┬────────────────────────────┘    │
│                           │                                 │
│              ┌────────────┴────────────┐                    │
│              ▼                         ▼                    │
│  ┌───────────────────┐    ┌────────────────────────┐        │
│  │  Tier 1: Rules    │    │  Tier 2: CoreML        │        │
│  │  (immediate)      │    │  (after 20 sessions)   │        │
│  │  scoreMaze()      │    │  GoldenModeMLService   │        │
│  └───────────────────┘    └────────────────────────┘        │
│                           │                                 │
│              ┌────────────┴────────────┐                    │
│              ▼                         ▼                    │
│  ┌───────────────────┐    ┌────────────────────────┐        │
│  │  Play Session     │    │  Post-Maze Report      │        │
│  │  GoldenModeOverlay│    │  "How did that feel?"  │        │
│  │  SignatureReader   │    │  → recordOutcome()     │        │
│  │  DataTicker        │    │  → ML training data    │        │
│  └───────────────────┘    └────────────────────────┘        │
└─────────────────────────────────────────────────────────────┘
```

---

## The Digital Signature

A 10-dimensional normalized (0-1) vector representing the user's current psychophysiological state. Built by `GoldenModeService.buildSignature()`.

### Dimensions

| # | Dimension | Source | Normalization |
|---|-----------|--------|---------------|
| 1 | **Energy Level** | Steps + Active Calories (HealthKit) | steps/10000 + calories/500, averaged |
| 2 | **Cardio State** | Heart Rate + HRV (HealthKit) | HR optimal at 70 bpm; HRV/80ms |
| 3 | **Rest State** | Sleep hours (HealthKit) | hours/8.0 |
| 4 | **Mindfulness** | Mindful minutes today (HealthKit) | minutes/30.0 |
| 5 | **Balance Stability** | % time balanced (Pendulum) | Direct percentage |
| 6 | **Reaction Speed** | Average reaction time (Pendulum) | Inverted: faster = higher |
| 7 | **Motor Control** | Angle variance (Pendulum) | Inverted: lower variance = higher |
| 8 | **Maze Efficiency** | Swipes/optimal ratio (gameplay) | Capped at 1.0 |
| 9 | **Exploration Tendency** | Actual-to-optimal swipe ratio (gameplay) | (ratio - 1.0) / 2.0 |
| 10 | **Session Consistency** | Inverse coefficient of variation (gameplay) | 1.0 - CV |

**Signature Strength:** Fraction of dimensions with data > 0.01 (e.g., 7/10 = 70%)

**Key properties:**
- `vector: [Double]` — The raw 10D array
- `strength: Double` — 0-1, how many dimensions are populated
- `activeDimensions: Int` — Count of non-zero dimensions
- `similarity(to:) -> Double` — Cosine similarity to another signature

**File:** `Models/DigitalSignature.swift`

---

## Impact Classification

Each maze is classified by its predicted cognitive-emotional impact based on TDA (Topological Data Analysis) metrics.

### Impact Types

| Type | Icon | Color | TDA Indicators |
|------|------|-------|----------------|
| **Focus** | scope | Azure | Low dead ends, clear path, moderate complexity (2-6) |
| **Challenge** | flame.fill | Rose | High tortuosity, many dead ends, large complexity |
| **Flow** | wind | Violet | Medium complexity (3-7), balanced branching, moderate density |
| **Calm** | leaf.fill | Green | Small complexity, low entropy, few dead ends |
| **Curiosity** | magnifyingglass | Gold | High branching, many paths, high entropy |
| **Frustration** | exclamationmark.triangle.fill | Rose (dark) | Very high tortuosity + dead-end ratio, complexity > 7 |
| **Mastery** | crown.fill | Gold (dark) | Matches user's average complexity (within delta < 5) |
| **Growth** | arrow.up.right | Green (dark) | Slightly harder than user's comfort zone |

Classification is done by `MazeImpact.classify(from:userAvgComplexity:)` which scores each type against the maze's TDA metrics and picks the highest-scoring primary and secondary impact.

**File:** `Models/MazeImpact.swift`

---

## Session Arcs

A `SessionArc` tracks the sequence of predicted impacts across a Golden Mode session:

```
calm → focus → challenge → flow → mastery
```

Properties:
- `impacts: [ImpactType]` — Predicted impact per maze
- `selfReports: [ImpactType?]` — User's self-reported impact (nil if skipped)
- `dominantImpact` — Most frequent impact in the session
- `predictionAccuracy` — % of predictions matching self-reports

Displayed as colored dots in `SessionArcBar` within the `SignatureReaderView`.

---

## Data Sources

### Apple Health (HealthKit)

Connected via the Integration tab. Provides dimensions 1-4 (energy, cardio, rest, mindfulness).

**Service:** `HealthKitService.shared`

Reads: steps, active calories, heart rate, HRV, sleep hours/quality, mindful minutes, resting heart rate.

### The Pendulum

A balance-tracking app. Data imported via CSV or synced from Firebase Storage (`gs://thependulum2.firebasestorage.app`).

**Service:** `PendulumDataService.shared`

**CSV format:** 10Hz data, 12 columns:
```
timestamp, angle, angleVelocity, pushDirection, pushMagnitude,
isBalanced, level, energy, gameMode, score, balanceThreshold, reactionTime
```

**Extracted metrics:**
- `averageBalancePercent` — % of samples where isBalanced == true
- `averageReactionTime` — Mean reaction time in seconds
- `angleVariance` — Variance of angle values (motor control proxy)
- `totalSessions` / `lastSessionDate`

**File:** `Services/PendulumDataService.swift`

### Gameplay History

Automatically populated from `MazePlayHistoryService.shared.records`. Uses the 20 most recent records.

**File:** `Services/GoldenModeService.swift` (lines 114-148)

---

## Maze Selection

### Tier 1: Rule-Based Scoring (immediate)

`GoldenModeService.scoreMaze(_:for:)` maps signature dimensions to TDA metrics:

| Signature Dimension | Maze Property | Mapping |
|---------------------|---------------|---------|
| Energy Level | Complexity score | High energy → complex mazes |
| Cardio State | Complexity score | High stress → simpler/calmer mazes |
| Rest State | Difficulty (1-4) | Good sleep → harder mazes |
| Balance Stability | Maze type | Stable → space-filling; Unstable → goal-based |
| Exploration Tendency | Branch points + dead ends | High exploration → more branching |
| Maze Efficiency | Tortuosity | Efficient players → more tortuous paths |

Each mapping produces a 0-1 fit score weighted by importance. The final score is the weighted average.

**Selection process:**
1. Sample mazes from multiple categories (general, easy, medium, hard)
2. Score each against the current signature
3. Sort by score descending
4. Pick randomly from the top 5 (avoids repetition)

### Tier 2: ML-Based Selection (after 20+ sessions)

`GoldenModeMLService` trains two on-device models using Apple's Create ML:

| Model | Type | Target | Features |
|-------|------|--------|----------|
| **Performance Regressor** | MLBoostedTreeRegressor | Performance (swipes/optimal) | 10D signature + 8D TDA |
| **Impact Classifier** | MLBoostedTreeClassifier | Self-reported impact type | 10D signature + 8D TDA |

**Training triggers:** After 20+ training rows, and every 10 new rows thereafter.

**Important:** CreateML is only available on physical iOS devices (not the Simulator). Training is gated behind `#if canImport(CreateML)`. CoreML inference works everywhere.

**Training data format (`GoldenTrainingRow`):**
```swift
struct GoldenTrainingRow: Codable {
    let timestamp: Date
    let signatureVector: [Double]      // 10 dimensions
    let tdaVector: [Double]            // 8 TDA dimensions
    let performance: Double            // swipes / optimal (1.0 = perfect)
    let predictedImpact: ImpactType
    let selfReportedImpact: ImpactType?
}
```

**Files:** `Services/GoldenModeMLService.swift`, `Services/GoldenModeService.swift`

---

## UI Components

### ModesView — GoldenModeCard

A gradient card in the Modes tab that launches Golden Mode. Shows:
- Golden sparkle icon with animated gradient background
- Connection status (e.g., "2/3 sources connected")
- Lock icon if no data sources connected, chevron if ready
- Taps call `ModeSelectionManager.selectGoldenMode()`

The standard maze type toggle (`MazeTypeToggle`) uses `MazeType.standardModes` to exclude `.golden` from the toggle.

### PlayView — Golden Mode Integration

When `isGoldenMode` is true:
- `loadGoldenMaze()` builds the signature async, selects a maze, loads it
- `MazeCanvasView` renders with golden color palette (gold walls, paths, ball, trails)
- `GoldenModeOverlay` is layered on top with the signature reader and data ticker
- On completion, standard alert is suppressed; `PostMazeReportSheet` is shown instead
- `loadNextMaze()` branches to `loadGoldenMaze()` for continuous golden play

### GoldenModeOverlay

Layered on the maze canvas during golden mode play:
- **Golden border glow** — Animated pulsing gold gradient stroke
- **SignatureReaderView** — Top-right corner (tap to expand)
- **DataTickerView** — Bottom scrolling bar showing active data values

**File:** `Views/Game/GoldenModeOverlay.swift`

### SignatureReaderView

Two states:
- **Minimized:** Golden circle showing match %, impact icon, pulsing glow. Tap to expand.
- **Expanded:** Full radar chart (10 axes), impact badge with description, session arc bar.

Contains `RadarChartView` (Canvas-based 10-axis spider chart with gold gradient fill) and `SessionArcBar` (horizontal colored dots showing impact progression).

**File:** `Views/Game/SignatureReaderView.swift`

### PostMazeReportSheet

Shown after each golden mode maze completion:
- "How did that feel?" header
- Shows predicted impact for comparison
- 6 impact type buttons in a 2x3 grid (focus, challenge, flow, calm, curiosity, frustration)
- Skip button
- Feeds `GoldenModeService.recordOutcome()` which stores training data for ML

**File:** `Views/Game/PostMazeReportSheet.swift`

### MazeCanvasView — Golden Rendering

When `goldenMode: Bool` is true, the canvas switches to a gold color palette:

| Element | Standard | Golden Mode |
|---------|----------|-------------|
| Walls | `theme.backgroundTertiary` | `Color.spectrum(.gold, level: 9)` |
| Paths | `theme.background` | `Color.spectrum(.gold, level: 1)` |
| Ball | `Color.spectrum(.azure, level: 8)` | `Color.spectrum(.gold, level: 7)` |
| Trail | Azure level 5, 50% opacity | Gold level 5, 50% opacity |
| Visited cells | Azure level 3 | Gold level 3 |

**File:** `Views/Game/MazeCanvasView.swift`

### IntegrationView — Connection Hub

The Integration tab is the central hub for managing data source connections:

- **Apple Health section** — Connect/disconnect, today's health metrics display
- **The Pendulum section** — CSV import via `.fileImporter`, connection status, summary metrics (balance %, reaction time, session count)
- **The Focus Calendar** — Placeholder ("Coming Soon")
- **The Golden Mode status** — Connection checklist for all 3 sources, signature strength indicator (X/3 sources)

**File:** `Views/IntegrationView.swift`

### DashboardView — GoldenModeDashboardCard

Shown when `goldenSessionCount > 0` or `goldenConnectedSources > 0`:

- **Header** with ML status badge ("ML Active" or "X/20" progress)
- **Mini radar chart** (80x80 Canvas-based 10-axis spider chart)
- **Stats column:** Sessions, Sources (X/3), Signature strength (%), Performance (%)
- **Dominant impact** with icon and color
- **Prediction accuracy** percentage
- **ML training progress bar** (gradient gold, X/20 sessions) when ML not yet trained
- Gold gradient border

**File:** `Views/DashboardView.swift` (GoldenModeDashboardCard struct)

---

## File Inventory

### New Files (8)

| Path | Lines | Purpose |
|------|-------|---------|
| `Models/DigitalSignature.swift` | ~128 | 10D user state vector |
| `Models/MazeImpact.swift` | ~202 | Impact types, classification, session arcs |
| `Services/PendulumDataService.swift` | ~210 | CSV import + Firebase sync |
| `Services/GoldenModeService.swift` | ~357 | Core brain: signature, selection, prediction, outcomes |
| `Services/GoldenModeMLService.swift` | ~270 | CoreML training pipeline |
| `Views/Game/SignatureReaderView.swift` | ~270 | Radar chart + impact display |
| `Views/Game/PostMazeReportSheet.swift` | ~90 | Self-report feedback sheet |
| `Views/Game/GoldenModeOverlay.swift` | ~162 | Golden border glow + data ticker |

### Modified Files (8)

| Path | Changes |
|------|---------|
| `Models/MazeModel.swift` | `.golden` MazeType case, `isStandardMode`, `standardModes` |
| `Services/MazeLoader.swift` | `.golden` in switch cases |
| `ViewModels/GameViewModel.swift` | `.golden` in completion + hint switches |
| `ViewModels/DashboardViewModel.swift` | 8 golden mode properties + `loadGoldenModeData()` |
| `Views/ModesView.swift` | GoldenModeCard, `selectGoldenMode()`, standard-only toggle |
| `Views/IntegrationView.swift` | Pendulum, Focus Calendar, Golden Mode status sections |
| `Views/Game/MazeCanvasView.swift` | `goldenMode: Bool` parameter, gold palette |
| `Views/PlayView.swift` | Golden mode state, overlay, report sheet, `loadGoldenMaze()` |

---

## User Flow

```
1. User opens Modes tab
2. Sees "The Golden Mode" card with connection status
3. (If needed) Goes to Integration tab to connect Health / import Pendulum CSV
4. Taps golden card → ModeSelectionManager.selectGoldenMode()
5. PlayView detects golden mode
6. loadGoldenMaze():
   a. buildSignature() — pulls Health, Pendulum, gameplay data
   b. selectMaze() — scores candidates, picks best fit
   c. predictImpact() — classifies cognitive-emotional effect
   d. Loads maze into GameViewModel
7. Play begins:
   - Golden color palette on canvas
   - GoldenModeOverlay shows signature reader + data ticker
   - SignatureReaderView shows match %, impact, session arc
8. Maze completed:
   - PostMazeReportSheet: "How did that feel?" (6 options + skip)
   - recordOutcome() stores training data
   - If ML threshold reached (20+), triggers retraining
9. Next maze auto-loads via loadGoldenMaze()
10. Session arc grows: calm → focus → challenge → flow → ...
```

---

## Key Design Decisions

1. **Two-tier selection** ensures the feature works immediately (Tier 1 rules) while improving over time (Tier 2 ML). No cold-start problem.

2. **MazeType.golden** is a virtual mode — golden mazes are actually `.goalBased` or `.spaceFilling` under the hood. The `.golden` case is excluded from the standard toggle via `standardModes`.

3. **CreateML gated behind `#if canImport(CreateML)`** because it's unavailable in the iOS Simulator. Training only runs on physical devices. Inference via CoreML works everywhere.

4. **Self-report is optional** — users can skip the "How did that feel?" prompt. The ML still trains on performance data even without self-reports.

5. **Session arcs are per-session, not persisted** — `GoldenModeService.resetSession()` clears the arc. Training data rows are persisted to UserDefaults.

6. **Signature is rebuilt per maze** — each `loadGoldenMaze()` call rebuilds the full signature to capture real-time state changes during a session.

---

## Dependencies

- **GoldenTheme** (SPM, local) — `Color.spectrum()`, `.font(.golden())`, `GoldenGeometry`, theme environment
- **IceMazeSolver** (SPM, local) — `IceSlidingEngine` for maze solving/hints
- **HealthKit** — Apple Health data access
- **CoreML** — Model inference (all platforms)
- **CreateML** — Model training (physical devices only, iOS 15+)
- **UniformTypeIdentifiers** — `.commaSeparatedText` for CSV file picker
- **Firebase** — Auth, Storage (Pendulum sync)
