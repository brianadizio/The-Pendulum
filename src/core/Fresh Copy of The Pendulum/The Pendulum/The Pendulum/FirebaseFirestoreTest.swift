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
}