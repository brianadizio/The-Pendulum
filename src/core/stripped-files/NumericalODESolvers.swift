// NumericalODESolvers.swift
// Based on Kieran Brown's Components "Numerical ODE Solvers"
// https://kieranb662.github.io/blog/2020/04/22/Numerical-ODE-Methods

import Foundation

/// # Eulers Method
/// Uses simple finite difference with no trial steps
/// Each call to this function performs one step. This implies that the `simpleEuler` function is meant to be used as part of a larger solve.
/// - parameters:
///        - stepSize: The increment to increase the independent variable by each iteration
///        - independentVariable: This is the current value the independent variable
///        - dependentVariables: These are the current values of all dependencies of the derivative functions
///        - functions: An array of references to derivative functions.
///
/// - returns
///     The new values of the `dependentVariables` computed at the next step.
/// - important: The `dependentVariables` array and `functions` array must have the same number of elements
///              and be in corresponding order.
func simpleEuler(_ stepSize: Double,
                 _ independentVariable: Double,
                 _ dependentVariables: [Double],
                 functions: [(Double, [Double]) -> Double]) -> [Double] {
    var newValues = [Double]()
    functions.enumerated().forEach { (i, f) in
        newValues.append( dependentVariables[i] + f(independentVariable, dependentVariables)*stepSize)
    }
    return newValues
}


/// # Improved Eulers Method
/// Makes use of a trial step and then averages the trial and real step values.
/// - parameters:
///        - stepSize: The increment to increase the independent variable by each iteration
///        - independentVariable: This is the current value the independent variable
///        - dependentVariables: These are the current values of all dependencies of the derivative functions
///        - functions: An array of references to derivative functions.
///
/// - returns
///     The new values of the `dependentVariables` computed at the next step.
/// - important: The `dependentVariables` array and `functions` array must have the same number of elements
///              and be in corresponding order.
func improvedEuler(_ stepSize: Double,
                   _ independentVariable: Double,
                   _ dependentVariables: [Double],
                   functions: [(Double, [Double]) -> Double]) -> [Double] {
    var trialValues = [Double]()
    functions.enumerated().forEach { (i, f) in
        trialValues.append( dependentVariables[i] + f(independentVariable, dependentVariables)*stepSize)
    }
    var newValues = [Double]()
    functions.enumerated().forEach { (i, f) in
        newValues.append(dependentVariables[i] + (f(independentVariable, trialValues) + f(independentVariable, dependentVariables))*stepSize/2)
    }
    return newValues
}

/// # Runge Kutta 4th Order
///
/// Approximates the solutions to differential equations using the 4th order Runge-Kutta numerical scheme.
///
///  let `f(t, x)` be any differential equation depending on `t` and `x`
///  Then:
///
///   let `k1 = Δt*f(t, x)`
///   let `k2 = Δt*f(t + Δt/2, x + k1/2)`
///   let `k3 = Δt*f(t + Δt/2, x + k2/2)`
///   let `k4 = Δt*f(t + Δt, x + k3)`
///
///   let `Δf = (k1 + 2*k2 + 2*k3 + k4)/6`
///
///   let `fnew  = f + Δf`
///
/// - parameters:
///        - stepSize: The increment to increase the independent variable by each iteration
///        - independentVariable: This is the current value the independent variable
///        - dependentVariables: These are the current values of all dependencies of the derivative functions
///        - functions: An array of references to derivative functions.
///
/// - returns
///     The new values of the `dependentVariables` computed at the next step.
/// - important: The `dependentVariables` array and `functions` array must have the same number of elements
///              and be in corresponding order.
///
func rK4(_ stepSize: Double,
         _ independentVariable: Double,
         _ dependentVariables: [Double],
         functions: [(Double, [Double]) -> Double]) -> [Double] {
    var k1: [Double] = []
    functions.forEach { (f) in
        k1.append(stepSize*f(independentVariable, dependentVariables))
    }
    var k2: [Double] = []
    functions.forEach { (f) in
        let newD = dependentVariables.enumerated().map { (index, nd)  in
            nd + k1[index]/2
        }
        k2.append(stepSize*f(independentVariable + stepSize/2, newD))
    }
    var k3: [Double] = []
    functions.forEach { (f) in
        let newD = dependentVariables.enumerated().map { (index, nd)  in
            nd + k2[index]/2
        }
        k3.append(stepSize*f(independentVariable + stepSize/2, newD))
    }
    var k4: [Double] = []
    functions.forEach { (f) in
        let newD = dependentVariables.enumerated().map { (index, nd)  in
            nd + k3[index]
        }
        k4.append(stepSize*f(independentVariable + stepSize, newD))
    }
    
    var kTot: [Double] = []
    for index in 0..<dependentVariables.count {
        kTot.append((k1[index] + 2*k2[index] + 2*k3[index] + k4[index])/6)
    }
    
    var newValues: [Double] = []
    
    for index in 0..<dependentVariables.count {
        newValues.append(dependentVariables[index] + kTot[index])
    }
    
    return newValues
}

/// An enumeration that serves as an interface for accessing the different ODESchemes.
enum ODEScheme: Int, CaseIterable, Identifiable, Hashable {
    case rungeKutta
    case euler
    case improvedEuler
    
    var scheme: (Double, Double, [Double], [(Double, [Double]) -> Double]) -> [Double] {
        switch self {
            
        case .rungeKutta:
            return rK4(_:_:_:functions:)
        case .euler:
            return simpleEuler(_:_:_:functions:)
        case .improvedEuler:
            return improvedEuler(_:_:_:functions:)
        }
    }
    
    var name: String {
        switch self {
            
        case .rungeKutta:
            return "Runge-Kutta"
        case .euler:
            return "Euler"
        case .improvedEuler:
            return "Improved Euler"
        }
    }
    
    var id: Int {rawValue}
}