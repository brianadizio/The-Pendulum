# Authentication Testing Guide

## Overview
The authentication system has been successfully integrated into The Pendulum app. Users can now sign in to save their progress and sync data across devices.

## How to Test Authentication

### 1. Access Authentication Options
- Launch the app
- Navigate to the **Settings** tab (rightmost tab)
- Look for the **ACCOUNT** section

### 2. Sign In Options
When not signed in, you'll see:
- "Sign In" button in the ACCOUNT section

Clicking "Sign In" will present options for:
- **Email/Password** - Enter credentials or create new account
- **Sign in with Apple** - Use Apple ID (requires device with Apple ID)
- **Continue as Guest** - Anonymous sign in (data not persisted across devices)
- **Google Sign In** - Coming soon (requires additional SDK setup)

### 3. Create New Account
- From Sign In screen, tap "Create Account"
- Enter:
  - Display Name
  - Email address
  - Password (minimum 6 characters)
  - Confirm password
- Tap "Create Account"

### 4. View Authentication Status
- **Settings Tab**: Shows sign in/out options in ACCOUNT section
- **Dashboard Tab**: Shows user status at the top with profile/sign in options

### 5. Sign Out
When signed in:
- Go to Settings → ACCOUNT section
- Tap "Sign Out"
- Confirm sign out

## Authentication Features

### Data Synced When Signed In
- High scores
- Level progress
- Total play time
- Achievements
- Game settings

### Apple Sign In Setup
Apple Sign In works automatically on iOS devices with:
- iOS 13.0 or later
- Apple ID configured on device
- Biometric or passcode authentication enabled

### Anonymous Sign In
- Quick way to test without creating account
- Progress saved locally but not synced
- Can upgrade to full account later

## Troubleshooting

### "Auth Failed" Error
- Check internet connection
- Verify Firebase configuration matches bundle ID
- Ensure valid email format for email sign in

### Apple Sign In Not Working
- Verify device has Apple ID configured
- Check app capabilities in Xcode includes "Sign in with Apple"
- Ensure provisioning profile supports Apple Sign In

### Password Reset
- From Sign In screen, tap "Forgot Password?"
- Enter email address
- Check email for reset link

## Firebase Console
View authenticated users at:
1. Go to Firebase Console
2. Select your project
3. Navigate to Authentication → Users
4. See list of registered users and sign-in providers

## Next Steps
To enable Google Sign In:
1. Add Google Sign-In SDK via Swift Package Manager
2. Configure OAuth client in Firebase Console
3. Add GoogleService-Info.plist if not already present
4. Update Info.plist with URL schemes