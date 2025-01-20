//
// From SwiftUI by Example by Paul Hudson
// https://www.hackingwithswift.com/quick-start/swiftui
//
// You're welcome to use this code for any purpose,
// commercial or otherwise, with or without attribution.
//

import SwiftUI

//var MetricsThisMaze: [NSManagedObject] = []
//var MetricsAll: [NSManagedObject] = []

struct ContentViewDashboard: View {
  var metricsThisContent: [Double] = []
  var metricsAllContent: [Double] = []
  var metricsContentString: [String] = []
  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 20) {
        ForEach(0..<5) {i in
                    VStack(spacing: 10) {
                      ForEach(0..<5) {j in
//                                      Text("\(($0)*5+i+1)")
                        if j<2{
                          LabelViewDashboard(text: String(format: metricsContentString[((j)*5+i)] + "%f", metricsThisContent[(j)*5+i]))
                            .frame(width: 100, height: 75)
                          //                          .backgroundColor(.systemGray5)
                        } else if j==2 {
                          Text("")
                          .frame(width: 100, height: 100)
                        } else {
                          LabelViewDashboard(text: String(format: metricsContentString[((j-3)*5+i)] + "%f", metricsAllContent[(j-3)*5+i]))
                            .frame(width: 100, height: 75)
                          
                        }
                      }
                    }
        }
      }
    }
  }
}
  
  struct ContentViewDashboard_Previews: PreviewProvider {
    static var previews: some View {
      ContentViewDashboard(metricsThisContent: [], metricsAllContent: [])
    }
  }
  
struct LabelViewDashboard: View {
    var text: String

    @State private var height: CGFloat = .zero

    var body: some View {
        InternalLabelViewDashboard(text: text, dynamicHeight: $height)
            .frame(minHeight: height)
    }

    struct InternalLabelViewDashboard: UIViewRepresentable {
        var text: String
        @Binding var dynamicHeight: CGFloat

        func makeUIView(context: Context) -> UILabel {
            let label = UILabel()
          label.textAlignment = .center
          label.font = UIFont.init(name: "TimesNewRomanPSMT", size: 18)
//            if MetricsAllDim1D.count>0 {
//            label.text = String(format: "Average\nLength\n")
//            }
            label.numberOfLines = 0
            label.frame = CGRectMake(
            label.frame.origin.x, label.frame.origin.y,
            label.frame.size.width, 75);
            label.backgroundColor = .systemGray5
            label.layer.cornerRadius=6
            label.layer.masksToBounds = true
            label.lineBreakMode = .byWordWrapping
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

            return label
        }

        func updateUIView(_ uiView: UILabel, context: Context) {
            uiView.text = text

          DispatchQueue.main.async {
            dynamicHeight = uiView.sizeThatFits(CGSize(width: uiView.bounds.width, height: CGFloat.greatestFiniteMagnitude)).height
            //
          }
        }
    }
}
