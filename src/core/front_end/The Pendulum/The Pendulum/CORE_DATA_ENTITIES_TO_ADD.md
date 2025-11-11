# Core Data Entities to Add to PendulumScoreData.xcdatamodeld

## How to Add These Entities

1. Open `PendulumScoreData.xcdatamodeld` in Xcode
2. Click the "+" button at the bottom to add new entities
3. For each entity below, add the entity name and all attributes with exact data types
4. Set relationships as specified

---

## Entity 1: ControlSession

**Entity Name:** `ControlSession`

### Attributes:
| Attribute Name | Data Type | Optional | Default Value |
|----------------|-----------|----------|---------------|
| sessionId | UUID | ❌ No | — |
| controlType | String | ❌ No | — |
| startDate | Date | ❌ No | — |
| endDate | Date | ✅ Yes | — |
| totalDuration | Double | ❌ No | 0 |
| totalForceApplications | Integer 32 | ❌ No | 0 |
| averageForceStrength | Double | ❌ No | 0 |
| maxForceStrength | Double | ❌ No | 0 |
| sensitivity | Double | ❌ No | 0.5 |
| deviceOrientation | String | ❌ No | "portrait" |
| gameLevel | Integer 32 | ❌ No | 1 |
| gameMode | String | ❌ No | "progressive" |

### Relationships:
| Relationship Name | Destination | Type | Delete Rule | Inverse |
|------------------|-------------|------|-------------|---------|
| controlInputs | ControlInput | One-to-Many | Cascade | controlSession |
| playSession | PlaySession | Many-to-One | Nullify | controlSessions |

---

## Entity 2: ControlInput

**Entity Name:** `ControlInput`

### Attributes:
| Attribute Name | Data Type | Optional | Default Value |
|----------------|-----------|----------|---------------|
| inputId | UUID | ❌ No | — |
| timestamp | Date | ❌ No | — |
| controlType | String | ❌ No | — |
| inputData | String | ❌ No | "{}" |
| forceApplied | Double | ❌ No | 0 |
| direction | String | ❌ No | "none" |
| pendulumAngle | Double | ❌ No | 0 |
| pendulumVelocity | Double | ❌ No | 0 |
| responseTime | Double | ❌ No | 0 |
| effectivenessScore | Double | ✅ Yes | — |

### Relationships:
| Relationship Name | Destination | Type | Delete Rule | Inverse |
|------------------|-------------|------|-------------|---------|
| controlSession | ControlSession | Many-to-One | Nullify | controlInputs |

---

## Entity 3: ControlPreferences

**Entity Name:** `ControlPreferences`

### Attributes:
| Attribute Name | Data Type | Optional | Default Value |
|----------------|-----------|----------|---------------|
| userId | String | ✅ Yes | — |
| deviceId | String | ❌ No | — |
| controlType | String | ❌ No | — |
| sensitivity | Double | ❌ No | 0.5 |
| isEnabled | Boolean | ❌ No | YES |
| customSettings | String | ✅ Yes | — |
| lastUsed | Date | ✅ Yes | — |
| totalUsageTime | Double | ❌ No | 0 |
| proficiencyLevel | Double | ❌ No | 0 |
| createdDate | Date | ❌ No | — |
| updatedDate | Date | ❌ No | — |

### Relationships:
None

---

## Entity 4: MotionCalibration

**Entity Name:** `MotionCalibration`

### Attributes:
| Attribute Name | Data Type | Optional | Default Value |
|----------------|-----------|----------|---------------|
| calibrationId | UUID | ❌ No | — |
| deviceId | String | ❌ No | — |
| controlType | String | ❌ No | — |
| calibrationDate | Date | ❌ No | — |
| baselineX | Double | ❌ No | 0 |
| baselineY | Double | ❌ No | 0 |
| baselineZ | Double | ❌ No | 0 |
| sensitivityMultiplier | Double | ❌ No | 1.0 |
| deadZone | Double | ❌ No | 0.05 |
| maxRange | Double | ❌ No | 1.0 |
| isActive | Boolean | ❌ No | YES |

### Relationships:
None

---

## Existing Entity Updates

### Update PlaySession Entity

**Add this relationship to existing PlaySession entity:**

| Relationship Name | Destination | Type | Delete Rule | Inverse |
|------------------|-------------|------|-------------|---------|
| controlSessions | ControlSession | One-to-Many | Cascade | playSession |

---

## Step-by-Step Xcode Instructions

### Adding Entity 1: ControlSession

1. **Open** `PendulumScoreData.xcdatamodeld` in Xcode
2. **Click** the "+" button at the bottom left
3. **Name** the entity: `ControlSession`
4. **Click** the "+" in the Attributes section and add each attribute:
   - `sessionId` → Data Type: `UUID`, Optional: ❌
   - `controlType` → Data Type: `String`, Optional: ❌
   - `startDate` → Data Type: `Date`, Optional: ❌
   - `endDate` → Data Type: `Date`, Optional: ✅
   - `totalDuration` → Data Type: `Double`, Optional: ❌, Default: `0`
   - `totalForceApplications` → Data Type: `Integer 32`, Optional: ❌, Default: `0`
   - `averageForceStrength` → Data Type: `Double`, Optional: ❌, Default: `0`
   - `maxForceStrength` → Data Type: `Double`, Optional: ❌, Default: `0`
   - `sensitivity` → Data Type: `Double`, Optional: ❌, Default: `0.5`
   - `deviceOrientation` → Data Type: `String`, Optional: ❌, Default: `"portrait"`
   - `gameLevel` → Data Type: `Integer 32`, Optional: ❌, Default: `1`
   - `gameMode` → Data Type: `String`, Optional: ❌, Default: `"progressive"`

5. **Add Relationships** (do this after creating all entities):
   - Click "+" in Relationships section
   - `controlInputs` → Destination: `ControlInput`, Type: `One To Many`, Delete Rule: `Cascade`
   - `playSession` → Destination: `PlaySession`, Type: `Many To One`, Delete Rule: `Nullify`

### Adding Entity 2: ControlInput

1. **Click** "+" to add new entity
2. **Name**: `ControlInput`
3. **Add attributes** as listed in the table above
4. **Add relationship**: `controlSession` → `ControlSession`, `Many To One`, `Nullify`

### Adding Entity 3: ControlPreferences

1. **Click** "+" to add new entity
2. **Name**: `ControlPreferences`
3. **Add attributes** as listed in the table above
4. **No relationships needed**

### Adding Entity 4: MotionCalibration

1. **Click** "+" to add new entity
2. **Name**: `MotionCalibration`
3. **Add attributes** as listed in the table above
4. **No relationships needed**

### Update Existing PlaySession Entity

1. **Select** the existing `PlaySession` entity
2. **Add relationship**: `controlSessions` → `ControlSession`, `One To Many`, `Cascade`

---

## After Adding Entities

1. **Save** the Core Data model file
2. **Clean and rebuild** your project
3. The control system will automatically start using these entities to track control data

## Important Notes

- ✅ **Required attributes** are marked with ❌ in the Optional column
- ✅ **Optional attributes** are marked with ✅ in the Optional column
- 🔗 **Relationships** must be set up in both directions (inverse relationships)
- 🗑️ **Delete rules** determine what happens when related objects are deleted
- 📊 **Default values** help ensure data consistency

The control tracking will automatically begin once these entities are added to your Core Data model!