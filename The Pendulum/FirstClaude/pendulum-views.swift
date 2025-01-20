// InvertedPendulumViews.swift
import SwiftUI

@available(iOS 14.0, *)
struct PendulumView: View {
    @StateObject var viewModel = InvertedPendulumViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                // Pendulum visualization
                ZStack {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 10, height: 10)
                    
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addLine(to: CGPoint(
                            x: viewModel.pendulumEndX * 100,  // Scale up for visualization
                            y: viewModel.pendulumEndY * 100
                        ))
                    }
                    .stroke(Color.black, lineWidth: 3)
                    
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 20, height: 20)
                        .position(x: viewModel.pendulumEndX * 100,
                                y: viewModel.pendulumEndY * 100)
                }
                .frame(width: 300, height: 300)
                .background(Color.white)
                .border(Color.gray)
                
                // Controls
                VStack(spacing: 20) {
                    HStack {
                      if #available(iOS 15.0, *) {
                        Button(action: {
                          if viewModel.isSimulating {
                            viewModel.stopSimulation()
                          } else {
                            viewModel.startSimulation()
                          }
                        }) {
                          Text(viewModel.isSimulating ? "Stop" : "Start")
                            .frame(width: 100)
                        }
                        .buttonStyle(.borderedProminent)
                      } else {
                        // Fallback on earlier versions
                      }
                        
                      if #available(iOS 15.0, *) {
                        Button(action: {
                          viewModel.resetSimulation()
                        }) {
                          Text("Reset")
                            .frame(width: 100)
                        }
                        .buttonStyle(.bordered)
                      } else {
                        // Fallback on earlier versions
                      }
                    }
                    
                    // Parameter controls
                    ParameterSlider(value: $viewModel.mass,
                                  range: 0.1...5.0,
                                  label: "Mass (kg)")
                    
                    ParameterSlider(value: $viewModel.length,
                                  range: 0.1...2.0,
                                  label: "Length (m)")
                    
                    ParameterSlider(value: $viewModel.springConstant,
                                  range: 0...50.0,
                                  label: "Spring Constant")
                    
                    ParameterSlider(value: $viewModel.damping,
                                  range: 0...1.0,
                                  label: "Damping")
                    
                    ParameterSlider(value: $viewModel.driveFrequency,
                                  range: 0...10.0,
                                  label: "Drive Frequency (Hz)")
                    
                    ParameterSlider(value: $viewModel.driveAmplitude,
                                  range: 0...5.0,
                                  label: "Drive Amplitude")
                    
                    ParameterSlider(value: $viewModel.simulationSpeed,
                                  range: 0.1...2.0,
                                  label: "Simulation Speed")
                }
                .padding()
            }
            .navigationTitle("Inverted Pendulum")
        }
    }
}

struct ParameterSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let label: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(label): \(value, specifier: "%.2f")")
            Slider(value: $value, in: range)
        }
    }
}
