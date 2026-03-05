import Foundation

/// Pure Swift MPC Controller for pendulum balancing
///
/// Implements Model Predictive Control using finite-horizon LQR
/// (Riccati recursion) for real-time performance.
///
/// This is a pure Swift implementation that can optionally be replaced
/// with a C bridge to MATLAB-compiled code for higher performance.
public class MPCController {

    // MARK: - Properties

    private var physics: HybridPendulumSolver.PhysicsConfig
    private var mpc: HybridPendulumSolver.MPCConfig

    // Derived physics constants
    private var ka: Double = 0  // Gravity torque constant
    private var ks: Double = 0  // Spring constant (normalized)
    private var kb: Double = 0  // Damping constant (normalized)
    private var kj: Double = 0  // Control gain (normalized)

    // Discrete-time state-space matrices
    private var Ad: [[Double]] = [[1, 0], [0, 1]]
    private var Bd: [Double] = [0, 0]

    // LQR gain (computed via Riccati)
    private var K: [Double] = [0, 0]

    // MARK: - Initialization

    public init(physics: HybridPendulumSolver.PhysicsConfig,
                mpc: HybridPendulumSolver.MPCConfig) {
        self.physics = physics
        self.mpc = mpc
        updateDerivedConstants()
        discretize()
        computeLQRGain()
    }

    // MARK: - Public Methods

    /// Update configuration and recompute gains
    public func updateConfig(_ newMpc: HybridPendulumSolver.MPCConfig) {
        self.mpc = newMpc
        computeLQRGain()
    }

    /// Solve MPC for current state
    /// - Parameter state: Current pendulum state
    /// - Returns: Optimal control input
    public func solve(state: HybridPendulumSolver.PendulumState) -> Double {
        let delta = state.angleFromVertical
        let omega = state.thetaDot

        // Apply LQR control law: u = -K * x
        var u = -(K[0] * delta + K[1] * omega)

        // Apply constraints
        u = max(-mpc.uMax, min(mpc.uMax, u))

        return u
    }

    /// Get predicted trajectory for visualization
    /// - Parameters:
    ///   - state: Current state
    ///   - steps: Number of prediction steps
    /// - Returns: Array of predicted states
    public func predictTrajectory(state: HybridPendulumSolver.PendulumState,
                                   steps: Int = 20) -> [HybridPendulumSolver.PendulumState] {
        var predictions: [HybridPendulumSolver.PendulumState] = []
        var x = [state.angleFromVertical, state.thetaDot]
        var t = state.time

        for _ in 0..<steps {
            let u = -(K[0] * x[0] + K[1] * x[1])
            let uClamped = max(-mpc.uMax, min(mpc.uMax, u))

            // x_next = Ad * x + Bd * u
            let x0_next = Ad[0][0] * x[0] + Ad[0][1] * x[1] + Bd[0] * uClamped
            let x1_next = Ad[1][0] * x[0] + Ad[1][1] * x[1] + Bd[1] * uClamped

            x = [x0_next, x1_next]
            t += mpc.dt

            predictions.append(HybridPendulumSolver.PendulumState(
                theta: .pi + x[0],
                thetaDot: x[1],
                time: t
            ))
        }

        return predictions
    }

    // MARK: - Private Methods

    private func updateDerivedConstants() {
        let denom = physics.mass * pow(physics.length, 2) + physics.momentOfInertia
        ka = (physics.mass * physics.length * physics.gravity) / denom
        ks = physics.springConstant / denom
        kb = physics.damping / denom
        kj = physics.forceScale / denom
    }

    private func discretize() {
        // Continuous state-space:
        // A = [0, 1; -(ka+ks), -kb]
        // B = [0; kj]

        let a21 = -(ka + ks)
        let a22 = -kb
        let dt = mpc.dt

        // Simple Euler discretization (good enough for small dt)
        // Ad = I + A*dt
        Ad[0][0] = 1.0
        Ad[0][1] = dt
        Ad[1][0] = a21 * dt
        Ad[1][1] = 1.0 + a22 * dt

        // Bd = B * dt
        Bd[0] = 0
        Bd[1] = kj * dt
    }

    private func computeLQRGain() {
        // Finite-horizon LQR via Riccati recursion
        // Iterate backwards from N to compute optimal gain K

        let N = mpc.horizonSteps
        let qAngle = mpc.qAngle
        let qVel = mpc.qVelocity
        let r = mpc.rControl

        // Terminal cost P_N = Qf (scaled Q)
        var P: [[Double]] = [
            [qAngle * 10, 0],
            [0, qVel * 10]
        ]

        // Backward Riccati recursion
        for _ in stride(from: N - 1, through: 0, by: -1) {
            // Compute components
            let BPB = Bd[0] * P[0][0] * Bd[0] +
                      Bd[0] * P[0][1] * Bd[1] +
                      Bd[1] * P[1][0] * Bd[0] +
                      Bd[1] * P[1][1] * Bd[1]

            let denom = r + BPB

            // B'PA
            let BPA0 = Bd[0] * (P[0][0] * Ad[0][0] + P[0][1] * Ad[1][0]) +
                       Bd[1] * (P[1][0] * Ad[0][0] + P[1][1] * Ad[1][0])
            let BPA1 = Bd[0] * (P[0][0] * Ad[0][1] + P[0][1] * Ad[1][1]) +
                       Bd[1] * (P[1][0] * Ad[0][1] + P[1][1] * Ad[1][1])

            // K = (R + B'PB)^{-1} B'PA
            K[0] = BPA0 / denom
            K[1] = BPA1 / denom

            // A'PA
            let APA00 = Ad[0][0] * (P[0][0] * Ad[0][0] + P[0][1] * Ad[1][0]) +
                        Ad[1][0] * (P[1][0] * Ad[0][0] + P[1][1] * Ad[1][0])
            let APA01 = Ad[0][0] * (P[0][0] * Ad[0][1] + P[0][1] * Ad[1][1]) +
                        Ad[1][0] * (P[1][0] * Ad[0][1] + P[1][1] * Ad[1][1])
            let APA10 = Ad[0][1] * (P[0][0] * Ad[0][0] + P[0][1] * Ad[1][0]) +
                        Ad[1][1] * (P[1][0] * Ad[0][0] + P[1][1] * Ad[1][0])
            let APA11 = Ad[0][1] * (P[0][0] * Ad[0][1] + P[0][1] * Ad[1][1]) +
                        Ad[1][1] * (P[1][0] * Ad[0][1] + P[1][1] * Ad[1][1])

            // A'PB
            let APB0 = Ad[0][0] * (P[0][0] * Bd[0] + P[0][1] * Bd[1]) +
                       Ad[1][0] * (P[1][0] * Bd[0] + P[1][1] * Bd[1])
            let APB1 = Ad[0][1] * (P[0][0] * Bd[0] + P[0][1] * Bd[1]) +
                       Ad[1][1] * (P[1][0] * Bd[0] + P[1][1] * Bd[1])

            // P = Q + A'PA - A'PB * K
            P[0][0] = qAngle + APA00 - APB0 * K[0]
            P[0][1] = APA01 - APB0 * K[1]
            P[1][0] = APA10 - APB1 * K[0]
            P[1][1] = qVel + APA11 - APB1 * K[1]
        }
    }
}
