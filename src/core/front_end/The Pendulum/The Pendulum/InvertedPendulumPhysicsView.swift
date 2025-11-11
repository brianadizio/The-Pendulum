import UIKit
import WebKit

class InvertedPendulumPhysicsView: UIView {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let webView = WKWebView()
    private var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        loadContent()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        loadContent()
    }
    
    private func setupView() {
        backgroundColor = FocusCalendarTheme.backgroundColor
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Setup title
        titleLabel = FocusCalendarTheme.createTitleLabel("Inverted Pendulum Physics")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // Setup web view for LaTeX rendering
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = self
        webView.backgroundColor = FocusCalendarTheme.backgroundColor
        contentView.addSubview(webView)
        
        // Setup data sources button
        let dataSourcesButton = FocusCalendarTheme.createTextButton("Data Sources: Brandeis Graybiel Lab")
        dataSourcesButton.addTarget(self, action: #selector(openDataSources), for: .touchUpInside)
        dataSourcesButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dataSourcesButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            webView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            webView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            webView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            webView.heightAnchor.constraint(equalToConstant: 2000), // Will be adjusted dynamically
            
            dataSourcesButton.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 30),
            dataSourcesButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dataSourcesButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func loadContent() {
        let htmlContent = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <script type="text/javascript" async
              src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/MathJax.js?config=TeX-MML-AM_CHTML">
            </script>
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    padding: 0;
                    margin: 0;
                    background-color: \(colorToHex(FocusCalendarTheme.backgroundColor));
                    color: \(colorToHex(FocusCalendarTheme.primaryTextColor));
                    line-height: 1.6;
                }
                .equation {
                    margin: 20px 0;
                    text-align: center;
                    overflow-x: auto;
                }
                h2 {
                    color: \(colorToHex(FocusCalendarTheme.accentGold));
                    font-size: 1.4em;
                    margin-top: 30px;
                    margin-bottom: 15px;
                }
                h3 {
                    color: \(colorToHex(FocusCalendarTheme.primaryTextColor));
                    font-size: 1.2em;
                    margin-top: 20px;
                    margin-bottom: 10px;
                }
                p {
                    margin: 10px 0;
                }
                .parameter {
                    background-color: \(colorToHex(FocusCalendarTheme.cardBackgroundColor));
                    padding: 10px;
                    margin: 10px 0;
                    border-radius: 8px;
                    border-left: 3px solid \(colorToHex(FocusCalendarTheme.accentGold));
                }
                .section {
                    margin: 20px 0;
                }
            </style>
        </head>
        <body>
            <div class="section">
                <h2>Inverted Pendulum Dynamics</h2>
                <p>The inverted pendulum is a classic control problem in physics and engineering. The system consists of a mass <em>m</em> at the end of a rigid rod of length <em>l</em>, pivoted at the bottom and free to rotate in a vertical plane.</p>
                
                <h3>Equation of Motion</h3>
                <p>The dynamics of the inverted pendulum are governed by the following second-order differential equation:</p>
                <div class="equation">
                    $$I\\ddot{\\theta} = mgl\\sin(\\theta) - b\\dot{\\theta} - k(\\theta - \\pi) + \\tau$$
                </div>
                
                <div class="parameter">
                    <strong>Where:</strong><br>
                    • <em>I</em> = Moment of inertia<br>
                    • <em>θ</em> = Angular displacement from vertical (radians)<br>
                    • <em>m</em> = Mass of the pendulum bob<br>
                    • <em>g</em> = Gravitational acceleration (9.81 m/s²)<br>
                    • <em>l</em> = Length of the pendulum rod<br>
                    • <em>b</em> = Damping coefficient<br>
                    • <em>k</em> = Spring constant (restoring force)<br>
                    • <em>τ</em> = Applied torque (control input)
                </div>
            </div>
            
            <div class="section">
                <h2>State Space Representation</h2>
                <p>For numerical integration, we convert this to a first-order system:</p>
                <div class="equation">
                    $$\\begin{cases}
                    \\dot{\\theta} = \\omega \\\\
                    \\dot{\\omega} = \\frac{1}{I}[mgl\\sin(\\theta) - b\\omega - k(\\theta - \\pi) + \\tau]
                    \\end{cases}$$
                </div>
                <p>This allows us to use Runge-Kutta methods for accurate numerical integration.</p>
            </div>
            
            <div class="section">
                <h2>Control Strategy</h2>
                <p>The pendulum is controlled through applied torque τ, which in the game represents the player's input:</p>
                <div class="equation">
                    $$\\tau = F \\cdot l \\cdot \\cos(\\theta)$$
                </div>
                <p>Where <em>F</em> is the applied force and the cosine term accounts for the effective torque based on the pendulum angle.</p>
                
                <h3>Stability Regions</h3>
                <p>The pendulum is considered "balanced" when:</p>
                <div class="equation">
                    $$|\\theta - \\pi| < \\theta_{threshold}$$
                </div>
                <p>Where <em>θ<sub>threshold</sub></em> varies by level (typically 0.3 to 0.1 radians).</p>
            </div>
            
            <div class="section">
                <h2>Numerical Integration</h2>
                <p>We use a 4th-order Runge-Kutta method for solving the differential equations:</p>
                <div class="equation">
                    $$\\begin{align}
                    k_1 &= f(t_n, y_n) \\\\
                    k_2 &= f(t_n + \\frac{h}{2}, y_n + \\frac{h}{2}k_1) \\\\
                    k_3 &= f(t_n + \\frac{h}{2}, y_n + \\frac{h}{2}k_2) \\\\
                    k_4 &= f(t_n + h, y_n + hk_3) \\\\
                    y_{n+1} &= y_n + \\frac{h}{6}(k_1 + 2k_2 + 2k_3 + k_4)
                    \\end{align}$$
                </div>
                <p>With adaptive timestep control to maintain accuracy.</p>
            </div>
            
            <div class="section">
                <h2>Perturbation System</h2>
                <p>The game includes environmental perturbations that affect the pendulum dynamics:</p>
                
                <h3>Impulse Perturbations</h3>
                <p>Sudden force applications that directly modify angular velocity:</p>
                <div class="equation">
                    $$\\omega_{new} = \\omega_{old} + \\frac{F_{impulse} \\cdot \\Delta t}{ml}$$
                </div>
                
                <h3>Wind Perturbations</h3>
                <p>Continuous forces that create additional torque:</p>
                <div class="equation">
                    $$\\tau_{wind} = F_{wind} \\cdot l \\cdot \\sin(\\omega_{wind} \\cdot t + \\phi)$$
                </div>
                
                <h3>Earthquake Perturbations</h3>
                <p>Base excitation that modifies the effective gravitational force:</p>
                <div class="equation">
                    $$g_{effective} = g + A_{earthquake} \\cdot \\sin(\\omega_{earthquake} \\cdot t)$$
                </div>
            </div>
            
            <div class="section">
                <h2>Game Physics Parameters</h2>
                <div class="parameter">
                    <strong>Default Values:</strong><br>
                    • Mass (m): 0.5 kg<br>
                    • Length (l): 1.0 m<br>
                    • Damping (b): 0.05 N⋅m⋅s/rad<br>
                    • Spring constant (k): 0.1 N⋅m/rad<br>
                    • Gravity (g): 9.81 m/s²<br>
                    • Moment of inertia (I): ml²/3 (rod approximation)
                </div>
                
                <p>These parameters change with each level to increase difficulty progressively.</p>
            </div>
            
            <div class="section">
                <h2>Balance Detection Algorithm</h2>
                <p>The game continuously monitors the pendulum state to detect balance and falls:</p>
                <ol>
                    <li>Check angle deviation: |θ - π| < threshold</li>
                    <li>Check angular velocity: |ω| < ω<sub>max</sub></li>
                    <li>Track consecutive balance time</li>
                    <li>Award points based on balance duration and precision</li>
                </ol>
                
                <h3>Scoring Formula</h3>
                <div class="equation">
                    $$Score = \\int_0^t (1 - \\frac{|\\theta - \\pi|}{\\theta_{max}}) \\cdot multiplier \\, dt$$
                </div>
            </div>
            
            <div class="section">
                <h2>Advanced Topics</h2>
                
                <h3>Linearized Model</h3>
                <p>Near the upright position (θ ≈ π), we can linearize the system:</p>
                <div class="equation">
                    $$\\ddot{\\phi} = \\frac{mg l}{I}\\phi - \\frac{b}{I}\\dot{\\phi} - \\frac{k}{I}\\phi + \\frac{\\tau}{I}$$
                </div>
                <p>Where φ = θ - π (deviation from upright).</p>
                
                <h3>Energy Conservation</h3>
                <p>The total energy of the system is:</p>
                <div class="equation">
                    $$E = \\frac{1}{2}I\\omega^2 + mgl(1 - \\cos(\\theta)) + \\frac{1}{2}k(\\theta - \\pi)^2$$
                </div>
                <p>This is monitored to ensure physical realism.</p>
            </div>
        </body>
        </html>
        """
        
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }
    
    @objc private func openDataSources() {
        if let url = URL(string: "https://www.brandeis.edu/graybiel/") {
            UIApplication.shared.open(url)
        }
    }
    
    private func colorToHex(_ color: UIColor) -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
    }
}

// MARK: - WKNavigationDelegate
extension InvertedPendulumPhysicsView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Adjust height after content loads
        webView.evaluateJavaScript("document.body.scrollHeight") { [weak self] (height, error) in
            if let height = height as? CGFloat {
                self?.updateWebViewHeight(height)
            }
        }
    }
    
    private func updateWebViewHeight(_ height: CGFloat) {
        for constraint in webView.constraints {
            if constraint.firstAttribute == .height {
                constraint.constant = height + 50 // Add some padding
                break
            }
        }
    }
}