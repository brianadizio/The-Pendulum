import Foundation
import FirebaseCore
import FirebaseAnalytics
import FirebaseAuth
import FirebaseCrashlytics
import FirebaseDatabase
import FirebaseFirestore

// Firebase Test Configuration
class FirebaseTestConfiguration {
    
    // Test if Firebase modules are properly imported
    static func testFirebaseImports() -> Bool {
        print("🔥 Testing Firebase imports...")
        print("✅ FirebaseCore imported successfully")
        print("✅ FirebaseAnalytics imported successfully")
        print("✅ FirebaseAuth imported successfully")
        print("✅ FirebaseCrashlytics imported successfully")
        print("✅ FirebaseDatabase imported successfully")
        return true
    }
    
    // Initialize Firebase (call this in AppDelegate)
    static func initializeFirebase() {
        print("🔥 Initializing Firebase...")
        
        // Check if GoogleService-Info.plist exists
        guard let plistPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
            print("❌ GoogleService-Info.plist not found! Please add it to your project.")
            print("📝 Download it from Firebase Console and add it to your Xcode project")
            return
        }
        
        print("✅ GoogleService-Info.plist found at: \(plistPath)")
        
        // Configure Firebase
        FirebaseApp.configure()
        print("✅ Firebase configured successfully")
        
        // Test Analytics
        Analytics.logEvent("firebase_test_init", parameters: [
            "platform": "iOS",
            "test_time": Date().timeIntervalSince1970
        ])
        print("✅ Analytics test event logged")
        
        // Test Auth availability
        if Auth.auth().currentUser == nil {
            print("ℹ️ No user currently signed in")
        } else {
            print("✅ User already signed in: \(Auth.auth().currentUser?.uid ?? "unknown")")
        }
        
        // Test Database reference
        let dbRef = Database.database().reference()
        print("✅ Database reference created: \(dbRef)")
        
        // Test Crashlytics
        Crashlytics.crashlytics().log("Firebase test initialization completed")
        print("✅ Crashlytics test log sent")
        
        print("🎉 Firebase initialization test completed!")
    }
    
    // Initialize Firebase with Firestore (called from AppDelegate)
    static func initializeFirebaseWithFirestore() {
        print("🔥 Initializing Firebase with Firestore...")
        
        // Check if GoogleService-Info.plist exists
        guard let plistPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
            print("❌ GoogleService-Info.plist not found! Please add it to your project.")
            print("📝 Download it from Firebase Console and add it to your Xcode project")
            return
        }
        
        print("✅ GoogleService-Info.plist found at: \(plistPath)")
        
        // Configure Firebase
        FirebaseApp.configure()
        print("✅ Firebase configured successfully")
        
        // Initialize Firestore settings
        let db = Firestore.firestore()
        print("✅ Firestore initialized: \(db)")
        
        print("🎉 Firebase with Firestore initialization completed!")
    }
    
    // Test Firebase functionality
    static func runFirebaseTests() {
        print("\n🧪 Running Firebase functionality tests...\n")
        
        // Test 1: Anonymous Auth
        testAnonymousAuth()
        
        // Test 2: Database Write/Read
        testDatabaseOperations()
        
        // Test 3: Analytics
        testAnalytics()
    }
    
    private static func testAnonymousAuth() {
        print("🔐 Testing Anonymous Authentication...")
        
        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                print("❌ Anonymous auth failed: \(error.localizedDescription)")
            } else if let user = result?.user {
                print("✅ Anonymous auth successful! User ID: \(user.uid)")
            }
        }
    }
    
    private static func testDatabaseOperations() {
        print("💾 Testing Database Operations...")
        
        let testRef = Database.database().reference().child("test_data")
        let testData = [
            "timestamp": ServerValue.timestamp(),
            "message": "Firebase test from The Pendulum",
            "platform": "iOS"
        ] as [String : Any]
        
        // Write test data
        testRef.setValue(testData) { error, ref in
            if let error = error {
                print("❌ Database write failed: \(error.localizedDescription)")
            } else {
                print("✅ Database write successful!")
                
                // Read it back
                ref.getData { error, snapshot in
                    if let error = error {
                        print("❌ Database read failed: \(error.localizedDescription)")
                    } else if let value = snapshot?.value {
                        print("✅ Database read successful: \(value)")
                    }
                }
            }
        }
    }
    
    private static func testAnalytics() {
        print("📊 Testing Analytics...")
        
        // Log custom events
        Analytics.logEvent("pendulum_firebase_test", parameters: [
            "test_type": "integration",
            "timestamp": Date().timeIntervalSince1970
        ])
        
        // Set user properties
        Analytics.setUserProperty("true", forName: "firebase_integrated")
        
        print("✅ Analytics events logged")
    }
}