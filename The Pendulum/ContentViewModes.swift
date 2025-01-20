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

struct ContentViewModes: View {
  var metricsThisContent: [Double] = []
  var metricsAllContent: [Double] = []
  var metricsContentString: [String] = []
  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      HStack(spacing: 20) {
        ForEach(0..<2) {i in
          VStack(spacing: 10) {
//            ModeButton(title: "Start Test") {
//              //                      print("Button tapped")
//              //                      //        let vc=dashboardViewController()
//              //                      let vc=GameViewControllerMainMaze();
//              //                      vc.modalPresentationStyle = .fullScreen
//              //                      self.present(vc, animated:true, completion: nil)
//            }
            

                // uncomment and add the below button for dismissing the modal
                // Button("Cancel") {
                //       NotificationCenter.default.post(name: Notification.Name(rawValue: "dismissModal"), object: nil)
                //        }
            }
          }
        }
      }
    }
  }
    
    
    //  struct ContentViewModes_Previews: PreviewProvider {
    //    static var previews: some View {
    //      if #available(iOS 14.0, *) {
    //        ContentViewModes(metricsThisContent: [], metricsAllContent: [])
    //      } else {
    //        // Fallback on earlier versions
    //      }
    //    }
    //  }
    //
    //struct LabelViewModes: View {
    //    var text: String
    //
    //    @State private var height: CGFloat = .zero
    //
    //    var body: some View {
    //        InternalLabelViewModes(text: text, dynamicHeight: $height)
    //            .frame(minHeight: height)
    //    }
    //
    //    struct InternalLabelViewModes: UIViewRepresentable {
    //        var text: String
    //        @Binding var dynamicHeight: CGFloat
    //
    //        func makeUIView(context: Context) -> UIButton {
    //          let button = UIButton()
    //          button.frame = CGRect(x: 37, y: 85, width: 150, height: 35)
    //          button.backgroundColor = .systemGray5
    //          button.setTitle("Immersed Circle", for: .normal)
    //          button.addTarget(self, action: #selector(immersedCircleButtonAction), for: .touchUpInside)
    //          button.layer.cornerRadius=6
    //          button.setTitleColor(.black, for: .normal)
    //          button.titleLabel?.font =  UIFont(name: "TimesNewRomanPSMT" , size: 20)
    //            return button
    //        }
    //
    //        func updateUIView(_ uiView: UILabel, context: Context) {
    //            uiView.text = text
    //
    //          DispatchQueue.main.async {
    //            dynamicHeight = uiView.sizeThatFits(CGSize(width: uiView.bounds.width, height: CGFloat.greatestFiniteMagnitude)).height
    //            //
    //          }
    //        }
    //    }
    //}
    
    
    struct ModeButton: UIViewRepresentable {
      let title: String
      let action: () -> ()
      
      var ntModeButton = UIButton()//NTPillButton(type: .filled, title: "Start Test")
      
      func makeCoordinator() -> Coordinator { Coordinator(self) }
      
      class Coordinator: NSObject {
        var parent: ModeButton
        
        init(_ modeButton: ModeButton) {
          self.parent = modeButton
          super.init()
        }
        
        @objc func doAction(_ sender: Any) {
          self.parent.action()
        }
      }
      
      func makeUIView(context: Context) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(self.title, for: .normal)
        button.addTarget(context.coordinator, action: #selector(Coordinator.doAction(_ :)), for: .touchDown)
        button.frame = CGRect(x: 37, y: 85, width: 150, height: 35)
        button.backgroundColor = .systemGray5
        button.setTitle("Immersed Circle", for: .normal)
        //        button.addTarget(self, action: #selector(immersedCircleButtonAction), for: .touchUpInside)
        button.layer.cornerRadius=6
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font =  UIFont(name: "TimesNewRomanPSMT" , size: 20)
        return button
      }
      
      func updateUIView(_ uiView: UIButton, context: Context) {}
    }

    
    

