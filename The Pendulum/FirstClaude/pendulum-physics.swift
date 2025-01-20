import Foundation
// PendulumPhysics.swift
struct PendulumState {
    var theta: Double       // Angular position
    var thetaDot: Double   // Angular velocity
    var time: Double       // Current simulation time
}

class PendulumPhysics {
    // System parameters from myiptype8.m
    let mass: Double
    let length: Double
    let gravity: Double = 9.81
    let damping: Double
    let springConstant: Double
    let momentOfInertia: Double
    let timeStep: Double = 1.0/60.0 // 60Hz simulation
    
    init(mass: Double = 1.0, length: Double = 1.0, damping: Double = 0.1, 
         springConstant: Double = 10.0, momentOfInertia: Double = 1.0) {
        self.mass = mass
        self.length = length
        self.damping = damping
        self.springConstant = springConstant 
        self.momentOfInertia = momentOfInertia
    }
    
    func derivatives(_ t: Double, state: [Double]) -> [(Double, [Double]) -> Double] {
        let ka = (mass * length * gravity) / (mass * length * length + momentOfInertia)
        let ks = springConstant / (mass * length * length + momentOfInertia)
        let kb = damping / (mass * length * length + momentOfInertia)
        
        return [
            // θ' = ω 
            { (_, state) in state[1] },
            // ω' = ka*sin(θ) - ks*θ - kb*ω
            { (_, state) in 
                ka * sin(state[0]) - ks * state[0] - kb * state[1]
            }
        ]
    }
    
    func step(from currentState: PendulumState) -> PendulumState {
        let solver = ODEScheme.rungeKutta.scheme
        let currentValues = [currentState.theta, currentState.thetaDot]
        let newValues = solver(timeStep, currentState.time, currentValues, 
                               derivatives(currentState.time, state: currentValues))
        
        return PendulumState(
            theta: newValues[0],
            thetaDot: newValues[1],
            time: currentState.time + timeStep
        )
    }
}
