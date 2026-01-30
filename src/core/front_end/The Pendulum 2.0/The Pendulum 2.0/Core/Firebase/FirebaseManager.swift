// FirebaseManager.swift
// The Pendulum 2.0
// Singleton manager for Firebase authentication and cloud storage

import Foundation
import Combine
import FirebaseCore
import FirebaseAuth
import FirebaseStorage

// MARK: - Auth Method Enum
enum FirebaseAuthMethod: String, Codable {
    case anonymous = "anonymous"
    case apple = "apple"
    case email = "email"
    case none = "none"
}

// MARK: - Pending Upload
struct PendingUpload: Codable {
    let sessionId: String
    let csvPath: String
    let metadataPath: String
    let timestamp: Date
}

// MARK: - Firebase Manager
class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()

    // MARK: - Published Properties

    @Published private(set) var isSignedIn: Bool = false
    @Published private(set) var authMethod: FirebaseAuthMethod = .none
    @Published private(set) var displayName: String?
    @Published private(set) var email: String?
    @Published private(set) var isUploading: Bool = false
    @Published private(set) var lastUploadDate: Date?
    @Published private(set) var pendingUploadCount: Int = 0

    // MARK: - Computed Properties

    var currentUser: User? {
        Auth.auth().currentUser
    }

    var uid: String? {
        Auth.auth().currentUser?.uid
    }

    var isAnonymous: Bool {
        Auth.auth().currentUser?.isAnonymous ?? true
    }

    // MARK: - Storage References

    private var storageRef: StorageReference {
        Storage.storage().reference()
    }

    /// Base path for current user's data
    private var userStorageRef: StorageReference? {
        guard let uid = uid else { return nil }
        return storageRef.child("users/\(uid)")
    }

    // Storage path constants (for future AI models / exports)
    static let sessionsPath = "sessions"
    static let profilePath = "profile"
    static let aiModelsPath = "ai_models"
    static let exportsPath = "exports"

    // MARK: - Private Properties

    private var authStateListener: AuthStateDidChangeListenerHandle?
    private var cancellables = Set<AnyCancellable>()

    // UserDefaults keys
    private enum Keys {
        static let authMethod = "firebase_auth_method"
        static let lastUploadDate = "firebase_last_upload_date"
        static let pendingUploads = "firebase_pending_uploads"
        static let displayName = "firebase_display_name"
        static let email = "firebase_email"
    }

    // MARK: - Initialization

    private init() {
        loadCachedState()
    }

    private func loadCachedState() {
        if let methodString = UserDefaults.standard.string(forKey: Keys.authMethod),
           let method = FirebaseAuthMethod(rawValue: methodString) {
            authMethod = method
        }
        lastUploadDate = UserDefaults.standard.object(forKey: Keys.lastUploadDate) as? Date
        displayName = UserDefaults.standard.string(forKey: Keys.displayName)
        email = UserDefaults.standard.string(forKey: Keys.email)
        pendingUploadCount = getPendingUploads().count
    }

    // MARK: - Configuration

    /// Call this from App init to configure Firebase
    func configure() {
        FirebaseApp.configure()
        setupAuthStateListener()
    }

    private func setupAuthStateListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            self.isSignedIn = user != nil
            self.displayName = user?.displayName
            self.email = user?.email

            // Cache display info
            UserDefaults.standard.set(user?.displayName, forKey: Keys.displayName)
            UserDefaults.standard.set(user?.email, forKey: Keys.email)

            if let user = user {
                if user.isAnonymous {
                    self.updateAuthMethod(.anonymous)
                }
                // For non-anonymous users, authMethod is set during sign-in flow
            } else {
                self.updateAuthMethod(.none)
            }
        }
    }

    private func updateAuthMethod(_ method: FirebaseAuthMethod) {
        authMethod = method
        UserDefaults.standard.set(method.rawValue, forKey: Keys.authMethod)
    }

    // MARK: - Anonymous Auth

    /// Sign in anonymously (called automatically at app launch)
    func signInAnonymously() async {
        // If already signed in (restored session), skip
        if Auth.auth().currentUser != nil {
            print("Firebase: Already signed in as \(Auth.auth().currentUser?.uid ?? "unknown")")
            // Retry any pending uploads
            await retryFailedUploads()
            return
        }

        do {
            let result = try await Auth.auth().signInAnonymously()
            print("Firebase: Signed in anonymously as \(result.user.uid)")
            updateAuthMethod(.anonymous)
        } catch {
            print("Firebase: Anonymous sign-in failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Apple Sign-In

    /// Link Apple credential to current anonymous account
    func linkAppleCredential(_ credential: AuthCredential) async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw FirebaseError.notSignedIn
        }

        do {
            let result = try await currentUser.link(with: credential)
            print("Firebase: Linked Apple credential to \(result.user.uid)")
            updateAuthMethod(.apple)
            displayName = result.user.displayName
            email = result.user.email
        } catch let error as NSError {
            // If credential already linked to another account, sign in directly
            if error.code == AuthErrorCode.credentialAlreadyInUse.rawValue {
                if let updatedCredential = error.userInfo[AuthErrorUserInfoUpdatedCredentialKey] as? AuthCredential {
                    let result = try await Auth.auth().signIn(with: updatedCredential)
                    print("Firebase: Signed in with existing Apple account \(result.user.uid)")
                    updateAuthMethod(.apple)
                    displayName = result.user.displayName
                    email = result.user.email
                    return
                }
            }
            throw error
        }
    }

    // MARK: - Email/Password Auth

    /// Link email/password credential to current anonymous account
    func linkEmailPassword(email: String, password: String) async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw FirebaseError.notSignedIn
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: password)

        do {
            let result = try await currentUser.link(with: credential)
            print("Firebase: Linked email credential to \(result.user.uid)")
            updateAuthMethod(.email)
            self.displayName = result.user.displayName
            self.email = result.user.email
        } catch let error as NSError {
            // If email already in use, try signing in instead
            if error.code == AuthErrorCode.credentialAlreadyInUse.rawValue ||
               error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                let result = try await Auth.auth().signIn(with: credential)
                print("Firebase: Signed in with existing email account \(result.user.uid)")
                updateAuthMethod(.email)
                self.displayName = result.user.displayName
                self.email = result.user.email
                return
            }
            throw error
        }
    }

    /// Sign in with existing email/password (not linking)
    func signInWithEmail(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        print("Firebase: Signed in with email as \(result.user.uid)")
        updateAuthMethod(.email)
        self.displayName = result.user.displayName
        self.email = result.user.email
    }

    /// Create a new email/password account
    func createAccount(email: String, password: String) async throws {
        // If currently anonymous, link instead of creating new
        if let currentUser = Auth.auth().currentUser, currentUser.isAnonymous {
            try await linkEmailPassword(email: email, password: password)
            return
        }

        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        print("Firebase: Created email account \(result.user.uid)")
        updateAuthMethod(.email)
        self.displayName = result.user.displayName
        self.email = result.user.email
    }

    // MARK: - Sign Out

    /// Sign out and re-authenticate anonymously
    func signOut() async {
        do {
            try Auth.auth().signOut()
            print("Firebase: Signed out")

            // Clear cached state
            UserDefaults.standard.removeObject(forKey: Keys.displayName)
            UserDefaults.standard.removeObject(forKey: Keys.email)
            displayName = nil
            email = nil

            // Re-sign in anonymously
            await signInAnonymously()
        } catch {
            print("Firebase: Sign out failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Storage Upload

    /// Upload a session CSV file to Firebase Storage
    func uploadSessionCSV(fileURL: URL, sessionId: String) async throws {
        guard let userRef = userStorageRef else {
            throw FirebaseError.notSignedIn
        }

        isUploading = true
        defer { isUploading = false }

        let csvRef = userRef.child("\(Self.sessionsPath)/\(sessionId).csv")
        let metadata = StorageMetadata()
        metadata.contentType = "text/csv"

        do {
            _ = try await csvRef.putFileAsync(from: fileURL, metadata: metadata)
            print("Firebase: Uploaded CSV for session \(sessionId)")
        } catch {
            print("Firebase: Failed to upload CSV: \(error.localizedDescription)")
            throw error
        }
    }

    /// Upload session metadata JSON to Firebase Storage
    func uploadSessionMetadata(_ sessionMetadata: SessionMetadata, sessionId: String) async throws {
        guard let userRef = userStorageRef else {
            throw FirebaseError.notSignedIn
        }

        let metaRef = userRef.child("\(Self.sessionsPath)/\(sessionId)_meta.json")
        let storageMetadata = StorageMetadata()
        storageMetadata.contentType = "application/json"

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(sessionMetadata)

        do {
            _ = try await metaRef.putDataAsync(data, metadata: storageMetadata)
            print("Firebase: Uploaded metadata for session \(sessionId)")
        } catch {
            print("Firebase: Failed to upload metadata: \(error.localizedDescription)")
            throw error
        }
    }

    /// Upload both CSV and metadata for a completed session
    func uploadSession(csvURL: URL, metadataURL: URL, sessionId: String) async {
        isUploading = true

        do {
            // Upload CSV
            try await uploadSessionCSV(fileURL: csvURL, sessionId: sessionId)

            // Upload metadata
            if let data = try? Data(contentsOf: metadataURL) {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                if let metadata = try? decoder.decode(SessionMetadata.self, from: data) {
                    try await uploadSessionMetadata(metadata, sessionId: sessionId)
                }
            }

            // Update last upload date
            lastUploadDate = Date()
            UserDefaults.standard.set(lastUploadDate, forKey: Keys.lastUploadDate)

            // Remove from pending queue if it was there
            removePendingUpload(sessionId: sessionId)

            isUploading = false
            print("Firebase: Session \(sessionId) fully uploaded")
        } catch {
            isUploading = false
            print("Firebase: Upload failed for session \(sessionId), queuing for retry")
            addPendingUpload(sessionId: sessionId, csvPath: csvURL.path, metadataPath: metadataURL.path)
        }
    }

    // MARK: - Retry Queue

    /// Get all pending uploads from UserDefaults
    func getPendingUploads() -> [PendingUpload] {
        guard let data = UserDefaults.standard.data(forKey: Keys.pendingUploads) else {
            return []
        }
        return (try? JSONDecoder().decode([PendingUpload].self, from: data)) ?? []
    }

    /// Add a failed upload to the retry queue
    private func addPendingUpload(sessionId: String, csvPath: String, metadataPath: String) {
        var pending = getPendingUploads()

        // Don't add duplicates
        guard !pending.contains(where: { $0.sessionId == sessionId }) else { return }

        pending.append(PendingUpload(
            sessionId: sessionId,
            csvPath: csvPath,
            metadataPath: metadataPath,
            timestamp: Date()
        ))

        if let data = try? JSONEncoder().encode(pending) {
            UserDefaults.standard.set(data, forKey: Keys.pendingUploads)
        }
        pendingUploadCount = pending.count
    }

    /// Remove a successfully uploaded session from the retry queue
    private func removePendingUpload(sessionId: String) {
        var pending = getPendingUploads()
        pending.removeAll { $0.sessionId == sessionId }

        if let data = try? JSONEncoder().encode(pending) {
            UserDefaults.standard.set(data, forKey: Keys.pendingUploads)
        }
        pendingUploadCount = pending.count
    }

    /// Retry all pending uploads
    func retryFailedUploads() async {
        let pending = getPendingUploads()
        guard !pending.isEmpty else { return }

        print("Firebase: Retrying \(pending.count) pending uploads")

        for upload in pending {
            let csvURL = URL(fileURLWithPath: upload.csvPath)
            let metadataURL = URL(fileURLWithPath: upload.metadataPath)

            // Only retry if files still exist
            guard FileManager.default.fileExists(atPath: upload.csvPath) else {
                removePendingUpload(sessionId: upload.sessionId)
                continue
            }

            await uploadSession(csvURL: csvURL, metadataURL: metadataURL, sessionId: upload.sessionId)
        }
    }

    // MARK: - Storage Helpers (for AIManager and other callers)

    /// Return a StorageReference for an arbitrary path (e.g. "users/{uid}/ai_models/file.json")
    func storageRef(for path: String) -> StorageReference {
        return storageRef.child(path)
    }

    /// Convenience metadata for JSON uploads
    func jsonMetadata() -> StorageMetadata {
        let meta = StorageMetadata()
        meta.contentType = "application/json"
        return meta
    }

    // MARK: - Cleanup

    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
}

// MARK: - Firebase Error
enum FirebaseError: LocalizedError {
    case notSignedIn
    case uploadFailed(String)
    case authFailed(String)

    var errorDescription: String? {
        switch self {
        case .notSignedIn:
            return "Not signed in to Firebase"
        case .uploadFailed(let message):
            return "Upload failed: \(message)"
        case .authFailed(let message):
            return "Authentication failed: \(message)"
        }
    }
}
