import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

// Firebase Firestore Test Extension
extension FirebaseTestConfiguration {
    
    // Test Firestore operations
    static func testFirestoreOperations() {
        print("💾 Testing Cloud Firestore Operations...")
        
        let db = Firestore.firestore()
        
        // Test data
        let testData: [String: Any] = [
            "timestamp": FieldValue.serverTimestamp(),
            "message": "Firebase Firestore test from The Pendulum",
            "platform": "iOS",
            "testTime": Date().timeIntervalSince1970
        ]
        
        // Write test data to Firestore
        db.collection("test_data").addDocument(data: testData) { error in
            if let error = error {
                print("❌ Firestore write failed: \(error.localizedDescription)")
            } else {
                print("✅ Firestore write successful!")
                
                // Read it back
                db.collection("test_data")
                    .order(by: "timestamp", descending: true)
                    .limit(to: 1)
                    .getDocuments { querySnapshot, error in
                        if let error = error {
                            print("❌ Firestore read failed: \(error.localizedDescription)")
                        } else if let document = querySnapshot?.documents.first {
                            print("✅ Firestore read successful!")
                            print("Document ID: \(document.documentID)")
                            print("Data: \(document.data())")
                        }
                    }
            }
        }
    }
    
    // Initialize Firebase with Firestore
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
        
        // Configure Firestore settings if needed
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true // Enable offline persistence
        Firestore.firestore().settings = settings
        print("✅ Firestore configured with offline persistence")
        
        // Test Auth availability
        if Auth.auth().currentUser == nil {
            print("ℹ️ No user currently signed in")
        } else {
            print("✅ User already signed in: \(Auth.auth().currentUser?.uid ?? "unknown")")
        }
        
        print("🎉 Firebase with Firestore initialization completed!")
    }
}