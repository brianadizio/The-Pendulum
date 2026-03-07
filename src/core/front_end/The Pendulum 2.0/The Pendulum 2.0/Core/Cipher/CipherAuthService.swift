//
//  CipherAuthService.swift
//  The Pendulum 2.0
//
//  HTTP client for The Golden Cipher transaction-bound authentication API.
//

import Foundation

@MainActor
final class CipherAuthService {
    static let shared = CipherAuthService()

    // MARK: - Configuration

    /// Base URL for the Cipher API. Update after Cloud Run deployment.
    var baseURL: String {
        get { UserDefaults.standard.string(forKey: "cipherBaseURL") ?? "https://golden-cipher-1022881794950.us-east1.run.app" }
        set { UserDefaults.standard.set(newValue, forKey: "cipherBaseURL") }
    }

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {
        encoder.keyEncodingStrategy = .convertToSnakeCase
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    // MARK: - Request/Response Models

    struct TransactionRequest: Codable {
        let actionDescription: String
        let actionType: String
        let tier: Int
    }

    struct ChallengeRequest: Codable {
        let userId: String
        let modalityHint: String?
        let transaction: TransactionRequest?
    }

    struct TransactionSeed: Codable {
        let seedValue: Int
        let seedHex: String
        let s1Position: Double
        let tier: Int
    }

    struct LevelSpec: Codable {
        let game: String
        let seed: TransactionSeed
        let difficulty: Double
        let timeLimit: Double?
        let parameters: [String: Double]
        // parameters keys for pendulum:
        //   balance_threshold, hold_duration, initial_angle,
        //   mass, length, damping, gravity, spring_constant,
        //   jiggle_intensity
    }

    struct ChallengeResponse: Codable {
        let challengeId: String
        let userId: String?
        let acceptedModalities: [String]?
        let message: String?
        let transactionBound: Bool
        let levelSpec: LevelSpec?
        let levelSpecs: [LevelSpec]?
        let expiresAt: String?
    }

    struct PendulumSessionPayload: Codable {
        let sessionId: String
        let swings: [SwingPayload]
        let peaks: [PeakPayload]
        let completionTime: Double?
        let balanceTime: Double?
        let averageAngle: Double?
        let maxAngle: Double?
        let levelConfig: LevelConfigPayload?
    }

    struct SwingPayload: Codable {
        let timestamp: Double
        let angle: Double
        let angularVelocity: Double
        let appliedForce: Double?
    }

    struct PeakPayload: Codable {
        let timestamp: Double
        let peakAngle: Double
        let direction: String  // "left" or "right"
    }

    struct LevelConfigPayload: Codable {
        let balanceThreshold: Double
        let balanceRequiredTime: Double
        let initialPerturbation: Double
        let massMultiplier: Double
        let lengthMultiplier: Double
        let dampingValue: Double
        let gravityMultiplier: Double
        let springConstantValue: Double
    }

    struct VerifyRequest: Codable {
        let challengeId: String
        let modality: String
        let pendulumSession: PendulumSessionPayload
    }

    struct AuthResult: Codable, Identifiable {
        let decision: String  // "ACCEPT", "REJECT", "UNCERTAIN"
        let confidence: Double
        let transactionBound: Bool
        let s1BindingScore: Double?

        var id: String { "\(decision)-\(confidence)" }
    }

    // MARK: - Enrollment Models

    struct EnrollStartRequest: Codable {
        let userId: String
        let targetSessions: Int
    }

    struct EnrollStartResponse: Codable {
        let enrollmentId: String
        let targetSessions: Int
    }

    struct EnrollSessionRequest: Codable {
        let enrollmentId: String
        let modality: String
        let pendulumSession: PendulumSessionPayload
    }

    struct EnrollSessionResponse: Codable {
        let status: String?
    }

    struct EnrollFinalizeRequest: Codable {
        let enrollmentId: String
    }

    struct EnrollFinalizeResponse: Codable {
        let userId: String
        let templateId: String
        let modalities: [String]
    }

    // MARK: - Ingest Model

    struct IngestRequest: Codable {
        let userId: String
        let templateId: String?
        let pendulumSession: PendulumSessionPayload
    }

    // MARK: - Device Registration

    struct RegisterDeviceRequest: Codable {
        let userId: String
        let deviceToken: String
        let platform: String
        let appId: String
    }

    struct RegisterDeviceResponse: Codable {
        let status: String?
    }

    // MARK: - API Calls

    func requestChallenge(
        userId: String,
        action: String,
        actionType: String,
        tier: Int = 1,
        modalityHint: String = "pendulum"
    ) async throws -> ChallengeResponse {
        let body = ChallengeRequest(
            userId: userId,
            modalityHint: modalityHint,
            transaction: TransactionRequest(
                actionDescription: action,
                actionType: actionType,
                tier: tier
            )
        )
        return try await post("/authenticate/challenge", body: body)
    }

    func verify(
        challengeId: String,
        session: PendulumSessionPayload
    ) async throws -> AuthResult {
        let body = VerifyRequest(
            challengeId: challengeId,
            modality: "pendulum",
            pendulumSession: session
        )
        return try await post("/authenticate/verify", body: body)
    }

    func startEnrollment(userId: String, sessions: Int = 30) async throws -> EnrollStartResponse {
        let body = EnrollStartRequest(userId: userId, targetSessions: sessions)
        return try await post("/enroll/start", body: body)
    }

    func submitEnrollmentSession(
        enrollmentId: String,
        session: PendulumSessionPayload
    ) async throws {
        let body = EnrollSessionRequest(
            enrollmentId: enrollmentId,
            modality: "pendulum",
            pendulumSession: session
        )
        let _: EnrollSessionResponse = try await post("/enroll/session", body: body)
    }

    func finalizeEnrollment(enrollmentId: String) async throws -> EnrollFinalizeResponse {
        let body = EnrollFinalizeRequest(enrollmentId: enrollmentId)
        return try await post("/enroll/finalize", body: body)
    }

    func ingestSession(userId: String, templateId: String? = nil, session: PendulumSessionPayload) async throws {
        let body = IngestRequest(userId: userId, templateId: templateId, pendulumSession: session)
        try await postIgnoringResponse("/ingest/pendulum", body: body)
    }

    func registerDevice(userId: String, fcmToken: String) async throws {
        let body = RegisterDeviceRequest(
            userId: userId,
            deviceToken: fcmToken,
            platform: "ios",
            appId: "com.goldenenterprise.pendulum"
        )
        let _: RegisterDeviceResponse = try await post("/users/register-device", body: body)
    }

    // MARK: - HTTP

    private func postIgnoringResponse<T: Encodable>(_ path: String, body: T) async throws {
        guard let url = URL(string: baseURL + path) else {
            throw CipherError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)
        request.timeoutInterval = 30

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            let msg = String(data: data, encoding: .utf8) ?? "Unknown"
            throw CipherError.serverError(statusCode: code, message: msg)
        }
    }

    private func post<T: Encodable, R: Decodable>(_ path: String, body: T) async throws -> R {
        guard let url = URL(string: baseURL + path) else {
            throw CipherError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)
        request.timeoutInterval = 30

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            let msg = String(data: data, encoding: .utf8) ?? "Unknown"
            throw CipherError.serverError(statusCode: code, message: msg)
        }

        return try decoder.decode(R.self, from: data)
    }

    enum CipherError: LocalizedError {
        case invalidURL
        case serverError(statusCode: Int, message: String)

        var errorDescription: String? {
            switch self {
            case .invalidURL: return "Invalid Cipher API URL"
            case .serverError(let code, let msg): return "Cipher API error \(code): \(msg)"
            }
        }
    }
}
