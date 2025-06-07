import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

// Firebase Debug Helper
class FirebaseDebugHelper {
    
    static func runComprehensiveDebug(completion: @escaping (String) -> Void) {
        var debugReport = "🔍 FIREBASE COMPREHENSIVE DEBUG REPORT\n"
        debugReport += "=====================================\n\n"
        
        // 1. Check Firebase App Configuration
        debugReport += "1️⃣ FIREBASE APP CONFIGURATION:\n"
        if let app = FirebaseApp.app() {
            debugReport += "✅ Firebase app exists\n"
            debugReport += "• Name: \(app.name)\n"
            debugReport += "• Options: \(app.options.debugDescription)\n"
            debugReport += "• Project ID: \(app.options.projectID ?? "nil")\n"
            debugReport += "• Google App ID: \(app.options.googleAppID)\n"
            debugReport += "• Database URL: \(app.options.databaseURL ?? "nil")\n"
            debugReport += "• Storage Bucket: \(app.options.storageBucket ?? "nil")\n"
            debugReport += "• API Key exists: \(app.options.apiKey != nil ? "Yes" : "No")\n"
        } else {
            debugReport += "❌ Firebase app is nil!\n"
        }
        
        // 2. Check Auth Configuration
        debugReport += "\n2️⃣ AUTH CONFIGURATION:\n"
        let auth = Auth.auth()
        debugReport += "• Auth instance exists: \(auth != nil ? "Yes" : "No")\n"
        debugReport += "• Current user: \(auth.currentUser?.uid ?? "nil")\n"
        debugReport += "• Auth state: \(auth.currentUser != nil ? "Signed in" : "Not signed in")\n"
        
        // 3. Check Firestore Configuration
        debugReport += "\n3️⃣ FIRESTORE CONFIGURATION:\n"
        let db = Firestore.firestore()
        let settings = db.settings
        debugReport += "• Firestore instance exists: Yes\n"
        debugReport += "• Host: \(settings.host)\n"
        debugReport += "• SSL enabled: \(settings.isSSLEnabled)\n"
        debugReport += "• Persistence enabled: \(settings.isPersistenceEnabled)\n"
        debugReport += "• Cache size: \(settings.cacheSizeBytes) bytes\n"
        
        // 4. Test Network Connectivity to Firebase
        debugReport += "\n4️⃣ NETWORK CONNECTIVITY TEST:\n"
        testNetworkConnectivity { networkResult in
            debugReport += networkResult
            
            // 5. Test Auth with Detailed Error Info
            debugReport += "\n5️⃣ DETAILED AUTH TEST:\n"
            Auth.auth().signInAnonymously { authResult, error in
                if let error = error as NSError? {
                    debugReport += "❌ Auth Error Details:\n"
                    debugReport += "• Error Domain: \(error.domain)\n"
                    debugReport += "• Error Code: \(error.code)\n"
                    debugReport += "• Error Description: \(error.localizedDescription)\n"
                    debugReport += "• User Info: \(error.userInfo)\n"
                    
                    // Check specific error codes
                    if error.code == 17020 {
                        debugReport += "• Diagnosis: Network error - Firebase Auth cannot reach servers\n"
                        debugReport += "• Possible causes:\n"
                        debugReport += "  - No internet connection\n"
                        debugReport += "  - Firewall blocking Firebase\n"
                        debugReport += "  - Incorrect bundle ID in GoogleService-Info.plist\n"
                        debugReport += "  - Firebase project not properly configured\n"
                    }
                } else if let user = authResult?.user {
                    debugReport += "✅ Auth Success:\n"
                    debugReport += "• User ID: \(user.uid)\n"
                    debugReport += "• Is Anonymous: \(user.isAnonymous)\n"
                }
                
                // 6. Test Firestore with Detailed Error Info
                debugReport += "\n6️⃣ DETAILED FIRESTORE TEST:\n"
                
                // First, try to enable network
                db.enableNetwork { error in
                    if let error = error {
                        debugReport += "• Network enable error: \(error.localizedDescription)\n"
                    } else {
                        debugReport += "• Network enabled successfully\n"
                    }
                    
                    // Try a simple write
                    let testDoc = [
                        "test": true,
                        "timestamp": FieldValue.serverTimestamp(),
                        "client_time": Date().timeIntervalSince1970
                    ] as [String : Any]
                    
                    db.collection("debug_test").addDocument(data: testDoc) { error in
                        if let error = error as NSError? {
                            debugReport += "❌ Firestore Error Details:\n"
                            debugReport += "• Error Domain: \(error.domain)\n"
                            debugReport += "• Error Code: \(error.code)\n"
                            debugReport += "• Error Description: \(error.localizedDescription)\n"
                            debugReport += "• User Info: \(error.userInfo)\n"
                            
                            // Check if it's offline
                            if error.localizedDescription.contains("offline") {
                                debugReport += "• Diagnosis: Firestore is offline\n"
                                debugReport += "• This usually means:\n"
                                debugReport += "  - Initial connection to Firestore failed\n"
                                debugReport += "  - Check if 'firestore.googleapis.com' is accessible\n"
                                debugReport += "  - Verify project ID matches in console\n"
                            }
                        } else {
                            debugReport += "✅ Firestore write successful!\n"
                        }
                        
                        // 7. Check Bundle ID Match
                        debugReport += "\n7️⃣ BUNDLE ID CHECK:\n"
                        if let bundleID = Bundle.main.bundleIdentifier {
                            debugReport += "• App Bundle ID: \(bundleID)\n"
                            debugReport += "• ⚠️ Make sure this matches Firebase Console configuration\n"
                        }
                        
                        // 8. Additional Diagnostics
                        debugReport += "\n8️⃣ ADDITIONAL INFO:\n"
                        debugReport += "• iOS Version: \(UIDevice.current.systemVersion)\n"
                        debugReport += "• Device Model: \(UIDevice.current.model)\n"
                        
                        #if targetEnvironment(simulator)
                        debugReport += "• Simulator: Yes\n"
                        #else
                        debugReport += "• Simulator: No (Physical Device)\n"
                        #endif
                        
                        #if DEBUG
                        debugReport += "• Build Configuration: DEBUG\n"
                        #else
                        debugReport += "• Build Configuration: RELEASE\n"
                        #endif
                        
                        completion(debugReport)
                    }
                }
            }
        }
    }
    
    private static func testNetworkConnectivity(completion: @escaping (String) -> Void) {
        var result = ""
        
        // Test basic internet connectivity
        let url = URL(string: "https://www.google.com")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                result += "• Internet connectivity: ❌ Failed (\(error.localizedDescription))\n"
            } else {
                result += "• Internet connectivity: ✅ Working\n"
            }
            
            // Test Firebase endpoints
            let firebaseAuthURL = URL(string: "https://identitytoolkit.googleapis.com/v1/accounts")!
            let firebaseTask = URLSession.shared.dataTask(with: firebaseAuthURL) { data, response, error in
                if let httpResponse = response as? HTTPURLResponse {
                    result += "• Firebase Auth endpoint: \(httpResponse.statusCode == 404 ? "✅ Reachable" : "❌ Status \(httpResponse.statusCode)")\n"
                } else if let error = error {
                    result += "• Firebase Auth endpoint: ❌ Unreachable (\(error.localizedDescription))\n"
                }
                
                // Test Firestore endpoint
                let firestoreURL = URL(string: "https://firestore.googleapis.com")!
                let firestoreTask = URLSession.shared.dataTask(with: firestoreURL) { data, response, error in
                    if let httpResponse = response as? HTTPURLResponse {
                        result += "• Firestore endpoint: \(httpResponse.statusCode < 500 ? "✅ Reachable" : "❌ Status \(httpResponse.statusCode)")\n"
                    } else if let error = error {
                        result += "• Firestore endpoint: ❌ Unreachable (\(error.localizedDescription))\n"
                    }
                    
                    completion(result)
                }
                firestoreTask.resume()
            }
            firebaseTask.resume()
        }
        task.resume()
    }
}