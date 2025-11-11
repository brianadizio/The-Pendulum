import Testing
@testable import The_Pendulum
import Foundation

@Suite("NumericalODESolvers Tests")
struct NumericalODESolversTests {
    
    // MARK: - Test Functions
    
    // Simple linear ODE: dy/dt = -y
    func linearDecay(t: Double, y: [Double]) -> Double {
        return -y[0]
    }
    
    // Simple growth ODE: dy/dt = y
    func exponentialGrowth(t: Double, y: [Double]) -> Double {
        return y[0]
    }
    
    // Harmonic oscillator: d²x/dt² = -x (as two first-order ODEs)
    // dx/dt = v, dv/dt = -x
    func harmonicOscillatorPosition(t: Double, vars: [Double]) -> Double {
        return vars[1] // velocity
    }
    
    func harmonicOscillatorVelocity(t: Double, vars: [Double]) -> Double {
        return -vars[0] // -position
    }
    
    // MARK: - Simple Euler Tests
    
    @Test func testSimpleEulerLinearDecay() async throws {
        let stepSize = 0.01
        let t0 = 0.0
        let y0 = [1.0]
        let functions = [linearDecay]
        
        // One step
        let y1 = simpleEuler(stepSize, t0, y0, functions: functions)
        
        // For dy/dt = -y, analytical solution is y = e^(-t)
        // After one step: y ≈ y0 + (-y0) * dt = y0(1 - dt)
        let expected = y0[0] * (1 - stepSize)
        
        #expect(abs(y1[0] - expected) < 1e-10)
    }
    
    @Test func testSimpleEulerMultipleVariables() async throws {
        let stepSize = 0.01
        let t0 = 0.0
        let vars0 = [1.0, 0.0] // position = 1, velocity = 0
        let functions = [harmonicOscillatorPosition, harmonicOscillatorVelocity]
        
        let vars1 = simpleEuler(stepSize, t0, vars0, functions: functions)
        
        // Position should change by velocity * dt = 0
        #expect(abs(vars1[0] - 1.0) < 1e-10)
        
        // Velocity should change by -position * dt = -1 * 0.01
        #expect(abs(vars1[1] - (-0.01)) < 1e-10)
    }
    
    @Test func testSimpleEulerStability() async throws {
        let stepSize = 0.1
        let t0 = 0.0
        var y = [1.0]
        let functions = [linearDecay]
        
        // Run for 100 steps
        for _ in 0..<100 {
            y = simpleEuler(stepSize, t0, y, functions: functions)
        }
        
        // Solution should decay but remain positive
        #expect(y[0] > 0)
        #expect(y[0] < 1.0)
    }
    
    // MARK: - Improved Euler Tests
    
    @Test func testImprovedEulerLinearDecay() async throws {
        let stepSize = 0.01
        let t0 = 0.0
        let y0 = [1.0]
        let functions = [linearDecay]
        
        let y1 = improvedEuler(stepSize, t0, y0, functions: functions)
        
        // Improved Euler should be more accurate than simple Euler
        let simpleResult = simpleEuler(stepSize, t0, y0, functions: functions)
        let analyticalSolution = exp(-stepSize)
        
        let improvedError = abs(y1[0] - analyticalSolution)
        let simpleError = abs(simpleResult[0] - analyticalSolution)
        
        #expect(improvedError < simpleError)
    }
    
    @Test func testImprovedEulerHarmonicOscillator() async throws {
        let stepSize = 0.01
        let t0 = 0.0
        let vars0 = [1.0, 0.0] // Start at position 1, velocity 0
        let functions = [harmonicOscillatorPosition, harmonicOscillatorVelocity]
        
        var vars = vars0
        let steps = 100
        
        // Run simulation
        for _ in 0..<steps {
            vars = improvedEuler(stepSize, t0, vars, functions: functions)
        }
        
        // Check energy conservation (should be approximately conserved)
        let initialEnergy = vars0[0] * vars0[0] + vars0[1] * vars0[1]
        let finalEnergy = vars[0] * vars[0] + vars[1] * vars[1]
        
        #expect(abs(finalEnergy - initialEnergy) < 0.1)
    }
    
    // MARK: - Runge-Kutta 4 Tests
    
    @Test func testRK4LinearDecay() async throws {
        let stepSize = 0.1
        let t0 = 0.0
        let y0 = [1.0]
        let functions = [linearDecay]
        
        let y1 = rK4(stepSize, t0, y0, functions: functions)
        
        // RK4 should be very accurate
        let analyticalSolution = exp(-stepSize)
        let error = abs(y1[0] - analyticalSolution)
        
        #expect(error < 1e-6)
    }
    
    @Test func testRK4HarmonicOscillator() async throws {
        let stepSize = 0.01
        let t0 = 0.0
        let vars0 = [1.0, 0.0]
        let functions = [harmonicOscillatorPosition, harmonicOscillatorVelocity]
        
        var vars = vars0
        let periods = 2.0
        let steps = Int(periods * 2 * Double.pi / stepSize)
        
        // Run for 2 complete periods
        for _ in 0..<steps {
            vars = rK4(stepSize, t0, vars, functions: functions)
        }
        
        // Should return close to initial position after 2 periods
        #expect(abs(vars[0] - vars0[0]) < 0.01)
        #expect(abs(vars[1] - vars0[1]) < 0.01)
    }
    
    @Test func testRK4AccuracyComparison() async throws {
        let stepSize = 0.1
        let t0 = 0.0
        let y0 = [1.0]
        let functions = [exponentialGrowth]
        
        // Run one step with each method
        let eulerResult = simpleEuler(stepSize, t0, y0, functions: functions)
        let improvedResult = improvedEuler(stepSize, t0, y0, functions: functions)
        let rk4Result = rK4(stepSize, t0, y0, functions: functions)
        
        // Analytical solution: y = e^t
        let analytical = exp(stepSize)
        
        let eulerError = abs(eulerResult[0] - analytical)
        let improvedError = abs(improvedResult[0] - analytical)
        let rk4Error = abs(rk4Result[0] - analytical)
        
        // RK4 should be most accurate
        #expect(rk4Error < improvedError)
        #expect(improvedError < eulerError)
    }
    
    // MARK: - ODEScheme Enum Tests
    
    @Test func testODESchemeCount() async throws {
        #expect(ODEScheme.allCases.count == 3)
    }
    
    @Test func testODESchemeName() async throws {
        #expect(ODEScheme.rungeKutta.name == "Runge-Kutta")
        #expect(ODEScheme.euler.name == "Euler")
        #expect(ODEScheme.improvedEuler.name == "Improved Euler")
    }
    
    @Test func testODESchemeSchemeProperty() async throws {
        let stepSize = 0.01
        let t0 = 0.0
        let y0 = [1.0]
        let functions = [linearDecay]
        
        // Test that scheme property returns correct function
        let rk4Scheme = ODEScheme.rungeKutta.scheme
        let rk4Direct = rK4(stepSize, t0, y0, functions: functions)
        let rk4ViaScheme = rk4Scheme(stepSize, t0, y0, functions)
        
        #expect(rk4Direct[0] == rk4ViaScheme[0])
    }
    
    @Test func testODESchemeIdentifiable() async throws {
        #expect(ODEScheme.rungeKutta.id == ODEScheme.rungeKutta.rawValue)
        #expect(ODEScheme.euler.id == ODEScheme.euler.rawValue)
        #expect(ODEScheme.improvedEuler.id == ODEScheme.improvedEuler.rawValue)
    }
    
    // MARK: - Edge Cases
    
    @Test func testZeroStepSize() async throws {
        let stepSize = 0.0
        let t0 = 0.0
        let y0 = [1.0]
        let functions = [linearDecay]
        
        let result = rK4(stepSize, t0, y0, functions: functions)
        
        // With zero step size, value shouldn't change
        #expect(result[0] == y0[0])
    }
    
    @Test func testNegativeStepSize() async throws {
        let stepSize = -0.01
        let t0 = 0.0
        let y0 = [1.0]
        let functions = [linearDecay]
        
        let result = simpleEuler(stepSize, t0, y0, functions: functions)
        
        // Negative step size should work (backward integration)
        #expect(result[0] > y0[0]) // Since dy/dt = -y, going backward increases y
    }
    
    @Test func testEmptyFunctions() async throws {
        let stepSize = 0.01
        let t0 = 0.0
        let y0: [Double] = []
        let functions: [(Double, [Double]) -> Double] = []
        
        let result = rK4(stepSize, t0, y0, functions: functions)
        
        #expect(result.isEmpty)
    }
    
    @Test func testLargeStepSize() async throws {
        let stepSize = 10.0 // Very large step
        let t0 = 0.0
        let y0 = [1.0]
        let functions = [linearDecay]
        
        // Simple Euler with large step can go negative
        let eulerResult = simpleEuler(stepSize, t0, y0, functions: functions)
        #expect(eulerResult[0] < 0) // 1 + (-1) * 10 = -9
        
        // RK4 should handle better but still might go negative
        let rk4Result = rK4(stepSize, t0, y0, functions: functions)
        // RK4 is more stable but with such a large step, behavior is unpredictable
        #expect(rk4Result[0] != y0[0])
    }
}