// PendulumViewModel.swift
import SwiftUI
import SpriteKit

class PendulumViewModel: ObservableObject {
    @Published var currentState = PendulumState(theta: 0.05, thetaDot: 0, time: 0)
    @Published var simulationError: Double = 0
    @Published var isRunning = false
    
    private let simulation = PendulumSimulation()
    private var timer: Timer?
    
    func startSimulation() {
        Task {
            do {
                try await simulation.loadSimulationData()
                
                DispatchQueue.main.async { [weak self] in
                    self?.isRunning = true
                    self?.timer = Timer.scheduledTimer(withTimeInterval: 0.002, repeats: true) { [weak self] _ in
                        self?.step()
                    }
                }
            } catch {
                print("Failed to load simulation data: \(error)")
            }
        }
    }
    
    private func step() {
        currentState = simulation.step()
        simulationError = simulation.compareWithReference()
    }
    
    func stopSimulation() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
}
