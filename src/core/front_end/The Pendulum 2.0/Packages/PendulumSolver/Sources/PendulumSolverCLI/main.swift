import Foundation
import PendulumSolver

/// Command-line interface for testing the Pendulum Solver
@main
struct PendulumSolverCLI {

    static func main() {
        print("Pendulum Solver - Capability Assessment")
        print("========================================")
        print("")

        let solver = HybridPendulumSolver()
        solver.setMode(.demo)

        // Physics parameters matching the game
        let mass = solver.physicsConfig.mass
        let length = solver.physicsConfig.length
        let gravity = solver.physicsConfig.gravity
        let damping = solver.physicsConfig.damping
        let spring = solver.physicsConfig.springConstant
        let Iz = solver.physicsConfig.momentOfInertia
        let forceScale = solver.physicsConfig.forceScale
        let dt = 0.002  // 500Hz physics (match game's RK4 step)

        let denom = mass * length * length + Iz
        let ka = (mass * length * gravity) / denom
        let ks = spring / denom
        let kb = damping / denom
        let kj = forceScale / denom

        print("Physics: gravity=\(gravity), mass=\(mass), length=\(length)")
        print("Derived: ka=\(String(format: "%.3f", ka)), ks=\(String(format: "%.3f", ks)), kb=\(String(format: "%.3f", kb))")
        print("")

        // Test 1: Small perturbation
        testScenario(
            name: "Small perturbation (5.7°)",
            initialAngle: 0.1,
            initialVelocity: 0.0,
            solver: solver, dt: dt, ka: ka, ks: ks, kb: kb, kj: kj,
            duration: 5.0
        )

        // Test 2: Medium perturbation
        testScenario(
            name: "Medium perturbation (17.2°)",
            initialAngle: 0.3,
            initialVelocity: 0.0,
            solver: solver, dt: dt, ka: ka, ks: ks, kb: kb, kj: kj,
            duration: 5.0
        )

        // Test 3: Large perturbation
        testScenario(
            name: "Large perturbation (28.6°)",
            initialAngle: 0.5,
            initialVelocity: 0.0,
            solver: solver, dt: dt, ka: ka, ks: ks, kb: kb, kj: kj,
            duration: 5.0
        )

        // Test 4: Near-failure (57.3° = 1 radian)
        testScenario(
            name: "Near-failure (57.3°)",
            initialAngle: 1.0,
            initialVelocity: 0.0,
            solver: solver, dt: dt, ka: ka, ks: ks, kb: kb, kj: kj,
            duration: 5.0
        )

        // Test 5: Extreme (74.5° = crash threshold)
        testScenario(
            name: "At crash threshold (74.5°)",
            initialAngle: 1.3,
            initialVelocity: 0.0,
            solver: solver, dt: dt, ka: ka, ks: ks, kb: kb, kj: kj,
            duration: 5.0
        )

        // Test 6: Moving fast
        testScenario(
            name: "Fast velocity (angle=11.5°, vel=3 rad/s)",
            initialAngle: 0.2,
            initialVelocity: 3.0,
            solver: solver, dt: dt, ka: ka, ks: ks, kb: kb, kj: kj,
            duration: 5.0
        )

        // Test 7: Worst case - large angle + velocity
        testScenario(
            name: "Worst case (45° + 2 rad/s velocity)",
            initialAngle: 0.785,
            initialVelocity: 2.0,
            solver: solver, dt: dt, ka: ka, ks: ks, kb: kb, kj: kj,
            duration: 5.0
        )

        // Test 8: Random disturbances over time
        testWithDisturbances(
            name: "60-second run with random disturbances",
            solver: solver, dt: dt, ka: ka, ks: ks, kb: kb, kj: kj,
            duration: 60.0
        )

        // Test 9: Sustained balance
        testScenario(
            name: "Sustained balance from rest (300 seconds)",
            initialAngle: 0.05,
            initialVelocity: 0.0,
            solver: solver, dt: dt, ka: ka, ks: ks, kb: kb, kj: kj,
            duration: 300.0
        )

        print("")
        print("Assessment complete.")
    }

    static func simulateStep(
        theta: Double, thetaDot: Double, u: Double,
        dt: Double, ka: Double, ks: Double, kb: Double, kj: Double
    ) -> (Double, Double) {
        // RK4 integration of nonlinear pendulum dynamics
        // theta'' = ka*sin(theta) - ks*theta - kb*theta' + kj*u

        func derivatives(_ th: Double, _ thDot: Double) -> (Double, Double) {
            let thDDot = ka * sin(th) - ks * th - kb * thDot + kj * u
            return (thDot, thDDot)
        }

        let (k1a, k1b) = derivatives(theta, thetaDot)
        let (k2a, k2b) = derivatives(theta + 0.5*dt*k1a, thetaDot + 0.5*dt*k1b)
        let (k3a, k3b) = derivatives(theta + 0.5*dt*k2a, thetaDot + 0.5*dt*k2b)
        let (k4a, k4b) = derivatives(theta + dt*k3a, thetaDot + dt*k3b)

        let newTheta = theta + dt/6.0 * (k1a + 2*k2a + 2*k3a + k4a)
        let newThetaDot = thetaDot + dt/6.0 * (k1b + 2*k2b + 2*k3b + k4b)

        return (newTheta, newThetaDot)
    }

    static func testScenario(
        name: String,
        initialAngle: Double,
        initialVelocity: Double,
        solver: HybridPendulumSolver,
        dt: Double, ka: Double, ks: Double, kb: Double, kj: Double,
        duration: Double
    ) {
        var theta = Double.pi + initialAngle
        var thetaDot = initialVelocity
        let steps = Int(duration / dt)
        var maxAngle = abs(initialAngle)
        var balanced = true
        var settleTime: Double? = nil
        var crashTime: Double? = nil
        var totalEnergy = 0.0

        for step in 0..<steps {
            let t = Double(step) * dt
            let control = solver.computeControl(theta: theta, thetaDot: thetaDot)

            // Full nonlinear RK4 simulation
            let (newTheta, newThetaDot) = simulateStep(
                theta: theta, thetaDot: thetaDot, u: control,
                dt: dt, ka: ka, ks: ks, kb: kb, kj: kj
            )
            theta = newTheta
            thetaDot = newThetaDot

            let angle = abs(theta - .pi)
            if angle > maxAngle { maxAngle = angle }
            totalEnergy += abs(control) * dt

            // Check crash
            if angle > 1.3 {
                balanced = false
                crashTime = t
                break
            }

            // Check if settled (within 2 degrees for 0.5 seconds)
            if settleTime == nil && angle < 0.035 && abs(thetaDot) < 0.1 {
                settleTime = t
            } else if angle >= 0.035 || abs(thetaDot) >= 0.1 {
                settleTime = nil
            }
        }

        let maxAngleDeg = maxAngle * 180.0 / .pi
        let result = balanced ? "BALANCED" : "CRASHED at \(String(format: "%.2f", crashTime ?? 0))s"
        let settle = settleTime.map { String(format: "%.2f", $0) + "s" } ?? "never"

        print("[\(result)] \(name)")
        print("  Max angle: \(String(format: "%.1f", maxAngleDeg))°, Settle time: \(settle), Energy used: \(String(format: "%.2f", totalEnergy))")
        print("")
    }

    static func testWithDisturbances(
        name: String,
        solver: HybridPendulumSolver,
        dt: Double, ka: Double, ks: Double, kb: Double, kj: Double,
        duration: Double
    ) {
        var theta = Double.pi + 0.05
        var thetaDot = 0.0
        let steps = Int(duration / dt)
        var maxAngle = 0.05
        var balanced = true
        var crashes = 0
        var disturbanceCount = 0

        for step in 0..<steps {
            let t = Double(step) * dt
            let control = solver.computeControl(theta: theta, thetaDot: thetaDot)

            // Apply random disturbances every 2-5 seconds
            var disturbance = 0.0
            if step % Int(2.0 / dt) == 0 && t > 0.5 {
                // Random kick: ±0.3 rad velocity or ±0.2 rad angle shift
                if Bool.random() {
                    thetaDot += Double.random(in: -2.0...2.0)
                } else {
                    theta += Double.random(in: -0.3...0.3)
                }
                disturbanceCount += 1
            }

            let (newTheta, newThetaDot) = simulateStep(
                theta: theta, thetaDot: thetaDot, u: control + disturbance,
                dt: dt, ka: ka, ks: ks, kb: kb, kj: kj
            )
            theta = newTheta
            thetaDot = newThetaDot

            let angle = abs(theta - .pi)
            if angle > maxAngle { maxAngle = angle }

            if angle > 1.3 {
                crashes += 1
                // Reset after crash
                theta = .pi + Double.random(in: -0.1...0.1)
                thetaDot = 0
            }
        }

        let maxAngleDeg = maxAngle * 180.0 / .pi
        let survivalRate = Double(steps - crashes) / Double(steps) * 100

        print("[\(crashes == 0 ? "PERFECT" : "\(crashes) CRASHES")] \(name)")
        print("  Duration: \(Int(duration))s, Disturbances: \(disturbanceCount), Max angle: \(String(format: "%.1f", maxAngleDeg))°, Survival: \(String(format: "%.1f", survivalRate))%")
        print("")
    }
}
