/// Copyright (c) 2023 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import UIKit
import SpriteKit
import AVKit
import CoreData
import SwiftUI
@available(iOS 13.0, *)
class DashboardViewController: UIViewController, UIScrollViewDelegate {
  
  var EnergySourceLab:String?
  let showDetailSegueIdentifier = "Detail"
  
  var background: [NSManagedObject] = []
  var MetricsThisMaze: [NSManagedObject] = []
  var MetricsAll: [NSManagedObject] = []
  var currentMode: [NSManagedObject] = []
  var modeD: String = ""
  
  var scrollView: UIScrollView = {
//    let obj = UIScrollView()
    let obj = UIScrollView(frame: .zero)
    obj.translatesAutoresizingMaskIntoConstraints = false
    obj.backgroundColor = .systemBackground
    return obj
  }()
  
  var scrollContainer: UIView = {
    let obj = UIView()
    obj.translatesAutoresizingMaskIntoConstraints = false
    obj.backgroundColor = .clear
//    obj.frame.size.height = 500
//    obj.frame.size.width = 500
    return obj
  }()
  
  var scrollContainerHorizontal: UIView = {
    let obj = UIView()
    obj.translatesAutoresizingMaskIntoConstraints = false
    obj.backgroundColor = .gray
    obj.frame.origin.y=300
    obj.frame.size.height = 200
    obj.frame.size.width = 800
    return obj
  }()
  
    override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .systemGray
    
      loadMode()
      var mode=currentMode[currentMode.count-1].value(forKey: "currentMode")
      modeD=mode as! String
      var modeName=currentMode[currentMode.count-1].value(forKey: "currentModeName")
      var modeNameD=modeName as! String
      loadBg()
      var backgroundFlag=background[background.count-1].value(forKey: "bgFlag")
      var backgroundD=backgroundFlag as! Int
      if backgroundD == 0 {
        self.view.backgroundColor = .systemBackground
      }
      else if backgroundD == 1{
        var r: Int = Int.random(in: 1..<28)
        //            contentView.view.backgroundColor = .systemGreen
        self.view.addBackground(imageName: "Sachuest/Sachuest\(r).jpeg", contentMode: .scaleToFill)
      }
      else if backgroundD == 2 {
        var r: Int = Int.random(in: 1..<28)
        self.view.addBackground(imageName: "OuterSpace/OuterSpace\(r).jpeg", contentMode: .scaleToFill)
      }
      else if backgroundD == 3 {
        var r: Int = Int.random(in: 1..<8)
        self.view.addBackground(imageName: "FluidGray/fluidbw\(r).jpg", contentMode: .scaleToFill)
      }
      else if backgroundD == 4 {
        var r: Int = Int.random(in: 1..<12)
        self.view.addBackground(imageName: "AI/AI\(r).jpeg", contentMode: .scaleToFill)
      }
      
    load(name: modeD)
      
      var MetricsAllDim1N = [Any]()
      
      var MetricsAllDim1 = [Double]()
      var MetricsAllDim2 = [Double]()
      var MetricsAllDim3 = [Double]()
      var MetricsAllDim4 = [Double]()
      var MetricsAllDim5 = [Double]()
      var MetricsAllDim6 = [Double]()
      var MetricsAllDim7 = [Double]()
      var MetricsAllDim8 = [Double]()
      var MetricsAllDim9 = [Double]()
      var MetricsAllDimDate = [Double]()
      var MetricsAllDimLat = [Double]()
      var MetricsAllDimLong = [Double]()
      var MetricsAllDimRM = [Int]()
      var MetricsThisDim1 = [Double]()
      var MetricsThisDim2 = [Double]()
      var MetricsThisDim3 = [Double]()
      var MetricsThisDim4 = [Double]()
      var MetricsThisDim5 = [Double]()
      var MetricsThisDim6 = [Double]()
      var MetricsThisDim7 = [Double]()
      var MetricsThisDim8 = [Double]()
      var MetricsThisDim9 = [Double]()
      var MetricsThisDimDate = [Double]()
      var MetricsThisDimLat = [Double]()
      var MetricsThisDimLong = [Double]()
      var MetricsThisDimRM = [Int]()
      
      print(MetricsAll.count)
      if MetricsAll.count>0{
        for val in MetricsAll{
          MetricsAllDim1N.append(val.value(forKey: "pcaDim1") as! Double)
          MetricsAllDim1.append(val.value(forKey: "pcaDim1") as! Double)
          MetricsAllDim2.append(val.value(forKey: "pcaDim2") as! Double)
          MetricsAllDim3.append(val.value(forKey: "pcaDim3") as! Double)
          MetricsAllDim4.append(val.value(forKey: "pcaDim4") as! Double)
          MetricsAllDim5.append(val.value(forKey: "pcaDim5") as! Double)
          MetricsAllDim6.append(val.value(forKey: "pcaDim6") as! Double)
          MetricsAllDim7.append(val.value(forKey: "pcaDim7") as! Double)
          MetricsAllDim8.append(val.value(forKey: "pcaDim8") as! Double)
          MetricsAllDim9.append(val.value(forKey: "pcaDim9") as! Double)
          MetricsAllDimDate.append(val.value(forKey: "datenum") as! Double)
          MetricsAllDimLat.append(val.value(forKey: "latitude") as! Double)
          MetricsAllDimLong.append(val.value(forKey: "longitude") as! Double)
          MetricsAllDimRM.append(val.value(forKey: "rM") as! Int)
        }
        for val in MetricsThisMaze{
          MetricsThisDim1.append(val.value(forKey: "dim1") as! Double)
          MetricsThisDim2.append(val.value(forKey: "dim2") as! Double)
          MetricsThisDim3.append(val.value(forKey: "dim3") as! Double)
          MetricsThisDim4.append(val.value(forKey: "dim4") as! Double)
          MetricsThisDim5.append(val.value(forKey: "dim5") as! Double)
          MetricsThisDim6.append(val.value(forKey: "dim6") as! Double)
          MetricsThisDim7.append(val.value(forKey: "dim7") as! Double)
          MetricsThisDim8.append(val.value(forKey: "dim8") as! Double)
          MetricsThisDim9.append(val.value(forKey: "dim9") as! Double)
          MetricsThisDimDate.append(val.value(forKey: "datenum") as! Double)
          MetricsThisDimLat.append(val.value(forKey: "latitude") as! Double)
          MetricsThisDimLong.append(val.value(forKey: "longitude") as! Double)
          MetricsThisDimRM.append(val.value(forKey: "rM") as! Int)
        }
      }
      
      print("Printing Last 5 NSManagedObject")
      print(MetricsAllDim1N)
      print("\n")
      print("Printing Metrics All")
      print(MetricsAllDim1)
      print(MetricsAllDim2)
      print(MetricsAllDim3)
      print(MetricsAllDim4)
      print(MetricsAllDim5)
      print(MetricsAllDim6)
      print(MetricsAllDim7)
      print(MetricsAllDim8)
      print(MetricsAllDim9)
      print(MetricsAllDimDate)
      print(MetricsAllDimLat)
      print(MetricsAllDimLong)
      print(MetricsAllDimRM)
      print("\n")
      print("Printing Metrics Immersed Circle")
      
      print(MetricsThisDim1)
      print(MetricsThisDim2)
      print(MetricsThisDim3)
      print(MetricsThisDim4)
      print(MetricsThisDim5)
      print(MetricsThisDim6)
      print(MetricsThisDim7)
      print(MetricsThisDim8)
      print(MetricsThisDim9)
      print(MetricsThisDimDate)
      print(MetricsThisDimLat)
      print(MetricsThisDimLong)
      print(MetricsThisDimRM)
      
      
//      let metricsAllContentInput = [average(metricsByMazes: MetricsAllDim1), average(metricsByMazes: MetricsAllDim2), average(metricsByMazes: MetricsAllDim3), average(metricsByMazes: MetricsAllDim4), average(metricsByMazes: MetricsAllDim5), average(metricsByMazes: MetricsAllDim6), average(metricsByMazes: MetricsAllDim7) , average(metricsByMazes: MetricsAllDim8), 3.0, 4.0]
//
//      let metricsAllContentStringInput = ["X\nLength\n", "X\nCycles\n", "X\nDegree\n", "X\nComplexity\n", "X\nVoids\n",
//                                       "X\nGeodesic\n", "X\nTime\n", "X\nPercentage\n","X\nSwipes",
//      "X\nMazes\n"]
//     
//     let metricsThisContentInput = [average(metricsByMazes: MetricsAllDim1), average(metricsByMazes: MetricsAllDim2), average(metricsByMazes: MetricsAllDim3), average(metricsByMazes: MetricsAllDim4), average(metricsByMazes: MetricsAllDim5), average(metricsByMazes: MetricsAllDim6),
//                                     1.0, 2.0, 3.0, 4.0]
//      let metricsThisContentStringInput = ["Average\nLength\n", "Average\nCycles\n", "Average\nDegree\n", "Average\nComplexity\n", "Average\nVoids\n",
//                                       "Average\nGeodesic\n", "Average\nTime\n", "Average\nPercentage\n","Average\nSwipes\n",
//                                       "Number of\nMazes\n"]
//      
//      let contentView = UIHostingController(rootView: ContentViewDashboard(metricsThisContent: metricsThisContentInput, metricsAllContent: metricsAllContentInput, metricsContentString: metricsThisContentStringInput))
//      
//      //      contentView.frame
////      contentViewThis.view.frame = CGRect(x: 400 , y: 400 , width: 400, height: 400)
//      addChildViewController(contentView)
//      contentView.view.backgroundColor = .clear
//      self.view.addSubview(contentView.view)
//      
//      contentView.view.translatesAutoresizingMaskIntoConstraints = false
//      NSLayoutConstraint.activate([
//        contentView.view.widthAnchor.constraint(equalTo: view.widthAnchor),
//        contentView.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1.25),
////        contentViewThis.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
////        contentViewThis.view.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//      ])
//    
////      contentView.view.backgroundColor = .yellow
// 
      
      view.addSubview(scrollView)
      scrollView.addSubview(scrollContainer)
  //    scrollView.backgroundColor = UIColor(patternImage: UIImage(imageLiteralResourceName: "Sachuest/Sachuest\(1).jpeg"));
      NSLayoutConstraint.activate([
        scrollView.topAnchor.constraint(equalTo: view.topAnchor),
        scrollView.leadingAnchor.constraint (equalTo: view.leadingAnchor),
        scrollView.trailingAnchor.constraint (equalTo: view.trailingAnchor),
        scrollView.bottomAnchor.constraint (equalTo: view.bottomAnchor)])
                   
      let scrollContentGuide = scrollView.contentLayoutGuide
      let scrollFrameGuide = scrollView.frameLayoutGuide
      NSLayoutConstraint.activate([
//        scrollContainer.leadingAnchor.constraint (equalTo: scrollContentGuide.leadingAnchor),
//        scrollContainer.trailingAnchor.constraint (equalTo: scrollContentGuide.trailingAnchor),
        scrollContainer.topAnchor.constraint (equalTo: scrollContentGuide.topAnchor),
        scrollContainer.bottomAnchor.constraint (equalTo: scrollContentGuide.bottomAnchor),
      //for dynamic vertical scrolling
        scrollContainer.leadingAnchor.constraint (equalTo: scrollFrameGuide.leadingAnchor),
        scrollContainer.trailingAnchor.constraint(equalTo: scrollFrameGuide.trailingAnchor),
        scrollContainer.heightAnchor.constraint (equalToConstant: 1500)])
//
        //for dynamic horizontal scrolling 
//        scrollContainer.topAnchor.constraint(equalTo: scrollFrameGuide.topAnchor),
//        scrollContainer.bottomAnchor.constraint(equalTo: scrollFrameGuide.bottomAnchor),
//        scrollContainer.widthAnchor.constraint(equalToConstant: 800)])
      scrollView.backgroundColor = .clear
      
      

      
      let informationButton = UIButton()
      informationButton.frame = CGRect(x: self.view.frame.size.width-134, y: 85, width: 100, height: 35)
      informationButton.backgroundColor = .systemGray5
      informationButton.setTitle("Information", for: .normal)
      informationButton.addTarget(self, action: #selector(informationButtonAction), for: .touchUpInside)
      informationButton.layer.cornerRadius=6
      informationButton.setTitleColor(.black, for: .normal)
      informationButton.titleLabel?.font =  UIFont(name: "TimesNewRomanPSMT" , size: 20)
      self.view.addSubview(informationButton)
      
      let accountButton = UIButton()
      accountButton.frame = CGRect(x: 30, y: 85, width: 100, height: 35)
      accountButton.backgroundColor = .systemGray5
      accountButton.setTitle("Account", for: .normal)
      accountButton.addTarget(self, action: #selector(accountButtonAction), for: .touchUpInside)
      accountButton.layer.cornerRadius=6
      accountButton.setTitleColor(.black, for: .normal)
      accountButton.titleLabel?.font =  UIFont(name: "TimesNewRomanPSMT" , size: 20)
      self.view.addSubview(accountButton)
      
      let playButton = UIButton()
      playButton.frame = CGRect(x: self.view.frame.size.width-134, y: 145, width: 100, height: 35)
      playButton.backgroundColor = .systemGray5
      playButton.setTitle("Play", for: .normal)
      playButton.addTarget(self, action: #selector(playButtonAction), for: .touchUpInside)
      playButton.layer.cornerRadius=6
      playButton.setTitleColor(.black, for: .normal)
      playButton.titleLabel?.font =  UIFont(name: "TimesNewRomanPSMT" , size: 20)
      self.view.addSubview(playButton)
      
//      let surveyButton = UIButton()
//      surveyButton.frame = CGRect(x: 30, y: 145, width: 100, height: 35)
//      surveyButton.backgroundColor = .systemGray5
//      surveyButton.setTitle("Survey", for: .normal)
//      surveyButton.addTarget(self, action: #selector(surveyButtonAction), for: .touchUpInside)
//      surveyButton.layer.cornerRadius=6
//      surveyButton.setTitleColor(.black, for: .normal)
//      surveyButton.titleLabel?.font =  UIFont(name: "TimesNewRomanPSMT" , size: 20)
//      self.view.addSubview(surveyButton)
      
      let instructionsButton = UIButton()
      instructionsButton.frame = CGRect(x: 30, y: 145, width: 100, height: 35)
      instructionsButton.backgroundColor = .systemGray5
      instructionsButton.setTitle("Instructions", for: .normal)
      instructionsButton.addTarget(self, action: #selector(instructionsButtonAction), for: .touchUpInside)
      instructionsButton.layer.cornerRadius=6
      instructionsButton.setTitleColor(.black, for: .normal)
      instructionsButton.titleLabel?.font =  UIFont(name: "TimesNewRomanPSMT" , size: 20)
      self.view.addSubview(instructionsButton)
      
      
      
      let labelLastMaze = UILabel(frame: CGRect(x: 45+20, y: 150, width: 275, height: 40))
      //    label1.center = CGPoint(x: 160, y: 285)
      labelLastMaze.textAlignment = .center
      labelLastMaze.font = UIFont.init(name: "TimesNewRomanPSMT", size: 28)
      labelLastMaze.text = String(format: "Last Maze Played")
      labelLastMaze.backgroundColor = .systemGray5
      labelLastMaze.layer.cornerRadius=6
      labelLastMaze.layer.masksToBounds = true
//      self.view.addSubview(labelMaze)
      self.scrollView.addSubview(labelLastMaze)
      
            let labelLast1 = UILabel(frame: CGRect(x: 20+20, y: 150+50, width: 100, height: 35))
            //    label1.center = CGPoint(x: 160, y: 285)
            labelLast1.textAlignment = .center
            labelLast1.font = UIFont.init(name: "TimesNewRomanPSMT", size: 18)
            if MetricsAllDim1.count>0 {
              labelLast1.text = String(format: "Length\n%d", Int(MetricsAllDim1[MetricsAllDim1.count-1]))
            }
            labelLast1.numberOfLines = 0;
            //      backgroundButton.setImage(UIImage(named: "bg"), for: .normal)
            labelLast1.frame = CGRectMake(
              labelLast1.frame.origin.x, labelLast1.frame.origin.y,
              labelLast1.frame.size.width, 75);
            labelLast1.backgroundColor = .systemGray5
            labelLast1.layer.cornerRadius=6
            labelLast1.layer.masksToBounds = true
//            self.view.addSubview(labelLast1)
      self.scrollView.addSubview(labelLast1)
      
            let labelLast2 = UILabel(frame: CGRect(x: 130+20, y: 150+50, width: 100, height: 35))
            //    label2.center = CGPoint(x: 160, y: 285)
            labelLast2.textAlignment = .center
            labelLast2.font = UIFont.init(name: "TimesNewRomanPSMT", size: 18)
            if MetricsAllDim1.count>0 {
              labelLast2.text = String(format: "Cycles\n%d", Int(MetricsAllDim2[MetricsAllDim2.count-1]))
            }
            labelLast2.numberOfLines = 0;
            labelLast2.layer.cornerRadius=6
            labelLast2.frame = CGRectMake(
              labelLast2.frame.origin.x, labelLast2.frame.origin.y,
              labelLast2.frame.size.width, 75);
            labelLast2.backgroundColor = .systemGray5
            labelLast2.layer.masksToBounds = true
//            self.view.addSubview(labelLast2)
                  self.scrollView.addSubview(labelLast2)
      
            let labelLast3 = UILabel(frame: CGRect(x: 240+20, y: 150+50, width: 100, height: 35))
            //    label3.center = CGPoint(x: 160, y: 285)
            labelLast3.textAlignment = .center
            labelLast3.font = UIFont.init(name: "TimesNewRomanPSMT", size: 18)
            if MetricsAllDim1.count>0 {
              labelLast3.text = String(format: "Degree\n%f", MetricsAllDim3[MetricsAllDim3.count-1])
            }
            labelLast3.numberOfLines = 0;
            labelLast3.layer.cornerRadius=6
            labelLast3.frame = CGRectMake(
              labelLast3.frame.origin.x, labelLast3.frame.origin.y,
              labelLast3.frame.size.width, 75);
            labelLast3.backgroundColor = .systemGray5
            labelLast3.layer.masksToBounds = true
//            self.view.addSubview(labelLast3)
                  self.scrollView.addSubview(labelLast3)
      
            let labelLast4 = UILabel(frame: CGRect(x: 20+20, y: 285, width: 100, height: 35))
            //    label4.center = CGPoint(x: 160, y: 285)
            labelLast4.textAlignment = .center
            labelLast4.font = UIFont.init(name: "TimesNewRomanPSMT", size: 18)
            if MetricsAllDim1.count>0 {
              labelLast4.text = String(format: "Complexity\n%f", MetricsAllDim4[MetricsAllDim4.count-1])
            }
            labelLast4.numberOfLines = 0;
            labelLast4.layer.cornerRadius=6
            labelLast4.frame = CGRectMake(
              labelLast4.frame.origin.x, labelLast4.frame.origin.y,
              labelLast4.frame.size.width, 75);
            labelLast4.backgroundColor = .systemGray5
            labelLast4.layer.masksToBounds = true
//            self.view.addSubview(labelLast4)
                  self.scrollView.addSubview(labelLast4)
      
            let labelLast5 = UILabel(frame: CGRect(x: 130+20, y: 285, width: 100, height: 35))
            //    label5.center = CGPoint(x: 160, y: 285)
            labelLast5.textAlignment = .center
            labelLast5.font = UIFont.init(name: "TimesNewRomanPSMT", size: 18)
            if MetricsAllDim1.count>0 {
              labelLast5.text = String(format: "Voids\n%d", Int(MetricsAllDim5[MetricsAllDim5.count-1]))
            }
            labelLast5.numberOfLines = 0;
            labelLast5.layer.cornerRadius=6
            labelLast5.frame = CGRectMake(
              labelLast5.frame.origin.x, labelLast5.frame.origin.y,
              labelLast5.frame.size.width, 75);
            labelLast5.backgroundColor = .systemGray5
            labelLast5.layer.masksToBounds = true
//            self.view.addSubview(labelLast5)
                  self.scrollView.addSubview(labelLast5)
      
            let labelLast6 = UILabel(frame: CGRect(x: 240+20, y: 285, width: 100, height: 35))
            //    label6.center = CGPoint(x: 160, y: 285)
            labelLast6.textAlignment = .center
            labelLast6.font = UIFont.init(name: "TimesNewRomanPSMT", size: 18)
            if MetricsAllDim1.count>0 {
              labelLast6.text = String(format: "Geodesic\n%f", 100*MetricsAllDim6[MetricsAllDim6.count-1])
            }
            labelLast6.numberOfLines = 0;
            labelLast6.layer.cornerRadius=6
            labelLast6.frame = CGRectMake(
              labelLast6.frame.origin.x, labelLast6.frame.origin.y,
              labelLast6.frame.size.width, 75);
            labelLast6.backgroundColor = .systemGray5
            labelLast6.layer.masksToBounds = true
//            self.view.addSubview(labelLast6)
                  self.scrollView.addSubview(labelLast6)
      
            let labelLast7 = UILabel(frame: CGRect(x: 20+20, y: 370, width: 100, height: 35))
            //    label6.center = CGPoint(x: 160, y: 285)
            labelLast7.textAlignment = .center
            labelLast7.font = UIFont.init(name: "TimesNewRomanPSMT", size: 18)
            if MetricsAllDim1.count>0 {
              labelLast7.text = String(format: "Maze Time\n%f", MetricsAllDim7[MetricsAllDim7.count-1])
            }
            labelLast7.numberOfLines = 0;
            labelLast7.layer.cornerRadius=6
            labelLast7.frame = CGRectMake(
              labelLast7.frame.origin.x, labelLast7.frame.origin.y,
              labelLast7.frame.size.width, 75);
            labelLast7.backgroundColor = .systemGray5
            labelLast7.layer.masksToBounds = true
//            self.view.addSubview(labelLast6)
                  self.scrollView.addSubview(labelLast7)
      
            let labelLast8 = UILabel(frame: CGRect(x: 130+20, y: 370, width: 100, height: 35))
            //    label6.center = CGPoint(x: 160, y: 285)
            labelLast8.textAlignment = .center
            labelLast8.font = UIFont.init(name: "TimesNewRomanPSMT", size: 18)
            if MetricsAllDim1.count>0 {
              labelLast8.text = String(format: "Percentage\n%f", 100*MetricsAllDim8[MetricsAllDim8.count-1])
            }
            labelLast8.numberOfLines = 0;
            labelLast8.layer.cornerRadius=6
            labelLast8.frame = CGRectMake(
              labelLast8.frame.origin.x, labelLast8.frame.origin.y,
              labelLast8.frame.size.width, 75);
            labelLast8.backgroundColor = .systemGray5
            labelLast8.layer.masksToBounds = true
//            self.view.addSubview(labelLast6)
                  self.scrollView.addSubview(labelLast8)
      
            let labelLast9 = UILabel(frame: CGRect(x: 240+20, y: 370, width: 100, height: 35))
            //    label6.center = CGPoint(x: 160, y: 285)
            labelLast9.textAlignment = .center
            labelLast9.font = UIFont.init(name: "TimesNewRomanPSMT", size: 18)
            if MetricsAllDim1.count>0 {
              labelLast9.text = String(format: "Swipes\n%f", MetricsAllDim9[MetricsAllDim9.count-1])
            }
            labelLast9.numberOfLines = 0;
            labelLast9.layer.cornerRadius=6
            labelLast9.frame = CGRectMake(
              labelLast9.frame.origin.x, labelLast9.frame.origin.y,
              labelLast9.frame.size.width, 75);
            labelLast9.backgroundColor = .systemGray5
            labelLast9.layer.masksToBounds = true
//            self.view.addSubview(labelLast6)
                  self.scrollView.addSubview(labelLast9)
      
      
      
      
      let labelMaze = UILabel(frame: CGRect(x: 80+20-50, y: 420+50, width: 300, height: 40))
      //    label1.center = CGPoint(x: 160, y: 285)
      labelMaze.textAlignment = .center
      labelMaze.font = UIFont.init(name: "TimesNewRomanPSMT", size: 28)
      labelMaze.text = String(format: modeNameD)
      labelMaze.backgroundColor = .systemGray5
      labelMaze.layer.cornerRadius=6
      labelMaze.layer.masksToBounds = true
//      self.view.addSubview(labelMaze)
      self.scrollView.addSubview(labelMaze)
      
            let labelAll1 = UILabel(frame: CGRect(x: 20+20, y: 470+50, width: 100, height: 35))
            //    label1.center = CGPoint(x: 160, y: 285)
            labelAll1.textAlignment = .center
            labelAll1.font = UIFont.init(name: "TimesNewRomanPSMT", size: 18)
            if MetricsAllDim1.count>0 {
              labelAll1.text = String(format: "Average\nLength\n%d", Int(round(average(metricsByMazes: MetricsThisDim1))))
            }
            labelAll1.numberOfLines = 0;
            //      backgroundButton.setImage(UIImage(named: "bg"), for: .normal)
            labelAll1.frame = CGRectMake(
              labelAll1.frame.origin.x, labelAll1.frame.origin.y,
              labelAll1.frame.size.width, 75);
            labelAll1.backgroundColor = .systemGray5
            labelAll1.layer.cornerRadius=6
            labelAll1.layer.masksToBounds = true
//            self.view.addSubview(labelAll1)
      self.scrollView.addSubview(labelAll1)
      
            let labelAll2 = UILabel(frame: CGRect(x: 130+20, y: 470+50, width: 100, height: 35))
            //    label2.center = CGPoint(x: 160, y: 285)
            labelAll2.textAlignment = .center
            labelAll2.font = UIFont.init(name: "TimesNewRomanPSMT", size: 18)
            if MetricsAllDim1.count>0 {
              labelAll2.text = String(format: "Average\nCycles\n%d", Int(round(average(metricsByMazes: MetricsThisDim2))))
            }
            labelAll2.numberOfLines = 0;
            labelAll2.layer.cornerRadius=6
            labelAll2.frame = CGRectMake(
              labelAll2.frame.origin.x, labelAll2.frame.origin.y,
              labelAll2.frame.size.width, 75);
            labelAll2.backgroundColor = .systemGray5
            labelAll2.layer.masksToBounds = true
//            self.view.addSubview(labelAll2)
                  self.scrollView.addSubview(labelAll2)
      
            let labelAll3 = UILabel(frame: CGRect(x: 240+20, y: 470+50, width: 100, height: 35))
            //    label3.center = CGPoint(x: 160, y: 285)
            labelAll3.textAlignment = .center
            labelAll3.font = UIFont.init(name: "TimesNewRomanPSMT", size: 18)
            if MetricsAllDim1.count>0 {
              labelAll3.text = String(format: "Average\nDegree\n%f", average(metricsByMazes: MetricsThisDim3))
            }
            labelAll3.numberOfLines = 0;
            labelAll3.layer.cornerRadius=6
            labelAll3.frame = CGRectMake(
              labelAll3.frame.origin.x, labelAll3.frame.origin.y,
              labelAll3.frame.size.width, 75);
            labelAll3.backgroundColor = .systemGray5
            labelAll3.layer.masksToBounds = true
//            self.view.addSubview(labelAll3)
                  self.scrollView.addSubview(labelAll3)
      
            let labelAll4 = UILabel(frame: CGRect(x: 20+20, y: 570+35, width: 100, height: 35))
            //    label4.center = CGPoint(x: 160, y: 285)
            labelAll4.textAlignment = .center
            labelAll4.font = UIFont.init(name: "TimesNewRomanPSMT", size: 18)
            if MetricsAllDim1.count>0 {
              labelAll4.text = String(format: "Average\nComplexity\n%f", average(metricsByMazes: MetricsThisDim4))
            }
            labelAll4.numberOfLines = 0;
            labelAll4.layer.cornerRadius=6
            labelAll4.frame = CGRectMake(
              labelAll4.frame.origin.x, labelAll4.frame.origin.y,
              labelAll4.frame.size.width, 75);
            labelAll4.backgroundColor = .systemGray5
            labelAll4.layer.masksToBounds = true
//            self.view.addSubview(labelAll4)
                  self.scrollView.addSubview(labelAll4)
      
            let labelAll5 = UILabel(frame: CGRect(x: 130+20, y: 570+35, width: 100, height: 35))
            //    label5.center = CGPoint(x: 160, y: 285)
            labelAll5.textAlignment = .center
            labelAll5.font = UIFont.init(name: "TimesNewRomanPSMT", size: 18)
            if MetricsAllDim1.count>0 {
              labelAll5.text = String(format: "Average\nVoids\n%d", Int(round(average(metricsByMazes: MetricsThisDim5))))
            }
            labelAll5.numberOfLines = 0;
            labelAll5.layer.cornerRadius=6
            labelAll5.frame = CGRectMake(
              labelAll5.frame.origin.x, labelAll5.frame.origin.y,
              labelAll5.frame.size.width, 75);
            labelAll5.backgroundColor = .systemGray5
            labelAll5.layer.masksToBounds = true
//            self.view.addSubview(labelAll5)
                  self.scrollView.addSubview(labelAll5)
      
            let labelAll6 = UILabel(frame: CGRect(x: 240+20, y: 570+35, width: 100, height: 35))
            //    label6.center = CGPoint(x: 160, y: 285)
            labelAll6.textAlignment = .center
            labelAll6.font = UIFont.init(name: "TimesNewRomanPSMT", size: 18)
            if MetricsAllDim6.count>0 {
              labelAll6.text = String(format: "Average\nGeodesic\n%f", 100*average(metricsByMazes: MetricsThisDim6))
            }
            labelAll6.numberOfLines = 0;
            labelAll6.layer.cornerRadius=6
            labelAll6.frame = CGRectMake(
              labelAll6.frame.origin.x, labelAll6.frame.origin.y,
              labelAll6.frame.size.width, 75);
            labelAll6.backgroundColor = .systemGray5
            labelAll6.layer.masksToBounds = true
//            self.view.addSubview(labelAll6)
                  self.scrollView.addSubview(labelAll6)
      
            let labelAll7 = UILabel(frame: CGRect(x: 20+20, y: 670+20, width: 100, height: 35))
            //    label6.center = CGPoint(x: 160, y: 285)
            labelAll7.textAlignment = .center
            labelAll7.font = UIFont.init(name: "TimesNewRomanPSMT", size: 18)
            if MetricsAllDim7.count>0 {
              labelAll7.text = String(format: "Average\nMaze Time\n%f", average(metricsByMazes: MetricsThisDim7))
            }
            labelAll7.numberOfLines = 0;
            labelAll7.layer.cornerRadius=6
            labelAll7.frame = CGRectMake(
              labelAll7.frame.origin.x, labelAll7.frame.origin.y,
              labelAll7.frame.size.width, 75);
            labelAll7.backgroundColor = .systemGray5
            labelAll7.layer.masksToBounds = true
//            self.view.addSubview(labelAll6)
                  self.scrollView.addSubview(labelAll7)
      
            let labelAll8 = UILabel(frame: CGRect(x: 130+20, y: 670+20, width: 100, height: 35))
            //    label6.center = CGPoint(x: 160, y: 285)
            labelAll8.textAlignment = .center
            labelAll8.font = UIFont.init(name: "TimesNewRomanPSMT", size: 18)
            if MetricsAllDim8.count>0 {
              labelAll8.text = String(format: "Average\nPercentage\n%f", 100*average(metricsByMazes: MetricsThisDim8))
            }
            labelAll8.numberOfLines = 0;
            labelAll8.layer.cornerRadius=6
            labelAll8.frame = CGRectMake(
              labelAll8.frame.origin.x, labelAll8.frame.origin.y,
              labelAll8.frame.size.width, 75);
            labelAll8.backgroundColor = .systemGray5
            labelAll8.layer.masksToBounds = true
//            self.view.addSubview(labelAll6)
                  self.scrollView.addSubview(labelAll8)
      
            let labelAll9 = UILabel(frame: CGRect(x: 240+20, y: 670+20, width: 100, height: 35))
            //    label6.center = CGPoint(x: 160, y: 285)
            labelAll9.textAlignment = .center
            labelAll9.font = UIFont.init(name: "TimesNewRomanPSMT", size: 18)
            if MetricsAllDim9.count>0 {
              labelAll9.text = String(format: "Average\nSwipes\n%f", average(metricsByMazes: MetricsThisDim9))
            }
            labelAll9.numberOfLines = 0;
            labelAll9.layer.cornerRadius=6
            labelAll9.frame = CGRectMake(
              labelAll9.frame.origin.x, labelAll9.frame.origin.y,
              labelAll9.frame.size.width, 75);
            labelAll9.backgroundColor = .systemGray5
            labelAll9.layer.masksToBounds = true
//            self.view.addSubview(labelAll6)
                  self.scrollView.addSubview(labelAll9)
      
            let labelAll10 = UILabel(frame: CGRect(x: 80+20, y: 770+5, width: 200, height: 35))
            //    label6.center = CGPoint(x: 160, y: 285)
            labelAll10.textAlignment = .center
            labelAll10.font = UIFont.init(name: "TimesNewRomanPSMT", size: 18)
            if MetricsAllDim9.count>0 {
              labelAll10.text = String(format: "Number of\nMazes\n%d", MetricsThisDim9.count)
            }
            labelAll10.numberOfLines = 0;
            labelAll10.layer.cornerRadius=6
            labelAll10.frame = CGRectMake(
              labelAll10.frame.origin.x, labelAll10.frame.origin.y,
              labelAll10.frame.size.width, 75);
            labelAll10.backgroundColor = .systemGray5
            labelAll10.layer.masksToBounds = true
//            self.view.addSubview(labelAll6)
            self.scrollView.addSubview(labelAll10)
      
      //    Number of Mazes? Cannot average
      //    let label7 = UILabel(frame: CGRect(x: self.view.frame.size.width-125, y: 300, width: 100, height: 35))
      //    label7.center = CGPoint(x: 160, y: 285)
      //    label7.textAlignment = .center
      //    label7.font = UIFont.init(name: "TimesNewRomanPSMT", size: 20)
      //    label7.text = String(format: "%f", average(metricsByMazes: MetricsAllDim1))
      //     self.view.addSubview(label7)
      //    Time Solving Maze
      //    let label8 = UILabel(frame: CGRect(x: self.view.frame.size.width-125, y: 300, width: 100, height: 35))
      //    label8.center = CGPoint(x: 160, y: 285)
      //    label8.textAlignment = .center
      //    label8.font = UIFont.init(name: "TimesNewRomanPSMT", size: 20)
      //    label8.text = String(format: "%f", average(metricsByMazes: MetricsAllDim1))
      //     self.view.addSubview(label8)
      
      let labelAll = UILabel(frame: CGRect(x: 100+20, y: 870, width: 150, height: 40))
      //    label1.center = CGPoint(x: 160, y: 285)
      labelAll.textAlignment = .center
      labelAll.font = UIFont.init(name: "TimesNewRomanPSMT", size: 28)
      labelAll.text = String(format: "All Mazes")
      labelAll.backgroundColor = .systemGray5
      labelAll.layer.cornerRadius=6
      labelAll.layer.masksToBounds = true
      self.view.addSubview(labelAll)
      self.scrollView.addSubview(labelAll)

      let label1 = UILabel(frame: CGRect(x: 20+20, y: 870+50, width: 100, height: 35))
      //    label1.center = CGPoint(x: 160, y: 285)
      label1.textAlignment = .center
      label1.font = UIFont.init(name: "TimesNewRomanPSMT", size: 18)
      if MetricsAllDim1.count>0 {
        label1.text = String(format: "Average\nLength\n%d", Int(round(average(metricsByMazes: MetricsAllDim1))))
      }
      label1.numberOfLines = 0;
      label1.layer.cornerRadius=6
      label1.frame = CGRectMake(
        label1.frame.origin.x, label1.frame.origin.y,
        label1.frame.size.width, 75);
      label1.backgroundColor = .systemGray5
      label1.layer.masksToBounds = true
//      self.view.addSubview(label1)
            self.scrollView.addSubview(label1)
      
      let label2 = UILabel(frame: CGRect(x: 130+20, y: 870+50, width: 100, height: 35))
      //    label2.center = CGPoint(x: 160, y: 285)
      label2.textAlignment = .center
      label2.font = UIFont.init(name: "TimesNewRomanPSMT", size: 18)
      if MetricsAllDim1.count>0 {
        label2.text = String(format: "Average\nCycles\n%d", Int(round(average(metricsByMazes: MetricsAllDim2))))
      }
      label2.numberOfLines = 0;
      label2.layer.cornerRadius=6
      label2.frame = CGRectMake(
        label2.frame.origin.x, label2.frame.origin.y,
        label2.frame.size.width, 75);
      label2.backgroundColor = .systemGray5
      label2.layer.masksToBounds = true
//      self.view.addSubview(label2)
            self.scrollView.addSubview(label2)
      
      let label3 = UILabel(frame: CGRect(x: 240+20, y: 870+50, width: 100, height: 35))
      //    label3.center = CGPoint(x: 160, y: 285)
      label3.textAlignment = .center
      label3.font = UIFont.init(name: "TimesNewRomanPSMT", size: 18)
      if MetricsAllDim1.count>0 {
        label3.text = String(format: "Average\nDegree\n%f", average(metricsByMazes: MetricsAllDim3))
      }
      label3.numberOfLines = 0;
      label3.layer.cornerRadius=6
      label3.frame = CGRectMake(
        label3.frame.origin.x, label3.frame.origin.y,
        label3.frame.size.width, 75);
      label3.backgroundColor = .systemGray5
      label3.layer.masksToBounds = true
//      self.view.addSubview(label3)
            self.scrollView.addSubview(label3)
      
      let label4 = UILabel(frame: CGRect(x: 20+20, y: 1010, width: 100, height: 35))
      //    label4.center = CGPoint(x: 160, y: 285)
      label4.textAlignment = .center
      label4.font = UIFont.init(name: "TimesNewRomanPSMT", size:  18)
      if MetricsAllDim1.count>0 {
        label4.text = String(format: "Average\nComplexity\n%f", average(metricsByMazes: MetricsAllDim4))
      }
      label4.numberOfLines = 0;
      label4.layer.cornerRadius=6
      label4.frame = CGRectMake(
        label4.frame.origin.x, label4.frame.origin.y,
        label4.frame.size.width, 75);
      label4.backgroundColor = .systemGray5
      label4.layer.masksToBounds = true
//      self.view.addSubview(label4)
            self.scrollView.addSubview(label4)
      
      let label5 = UILabel(frame: CGRect(x: 130+20, y: 1010, width: 100, height: 35))
      //    label5.center = CGPoint(x: 160, y: 285)
      label5.textAlignment = .center
      label5.font = UIFont.init(name: "TimesNewRomanPSMT", size: 18)
      if MetricsAllDim1.count>0 {
        label5.text = String(format: "Average\nVoids\n%d", Int(round(average(metricsByMazes: MetricsAllDim5))))
      }
      label5.layer.cornerRadius=6
      label5.numberOfLines = 0;
      label5.frame = CGRectMake(
        label5.frame.origin.x, label5.frame.origin.y,
        label5.frame.size.width, 75);
      label5.backgroundColor = .systemGray5
      label5.layer.masksToBounds = true
//      self.view.addSubview(label5)
            self.scrollView.addSubview(label5)
      
      let label6 = UILabel(frame: CGRect(x: 240+20, y: 1010, width: 100, height: 35))
      //    label6.center = CGPoint(x: 160, y: 285)
      label6.textAlignment = .center
      label6.font = UIFont.init(name: "TimesNewRomanPSMT", size: 18)
      if MetricsAllDim1.count>0 {
        label6.text = String(format: "Average\nGeodesic\n%f", 100*average(metricsByMazes: MetricsAllDim6))
      }
      label6.layer.cornerRadius=6
      label6.numberOfLines = 0;
      label6.frame = CGRectMake(
        label6.frame.origin.x, label6.frame.origin.y,
        label6.frame.size.width, 75);
      label6.backgroundColor = .systemGray5
      label6.layer.masksToBounds = true
//      self.view.addSubview(label6)
      self.scrollView.addSubview(label6)
      
      let label7 = UILabel(frame: CGRect(x: 20+20, y: 1095, width: 100, height: 35))
      //    label6.center = CGPoint(x: 160, y: 285)
      label7.textAlignment = .center
      label7.font = UIFont.init(name: "TimesNewRomanPSMT", size: 18)
      if MetricsAllDim1.count>0 {
        label7.text = String(format: "Average\nMaze Time\n%f", average(metricsByMazes: MetricsAllDim7))
      }
      label7.numberOfLines = 0;
      label7.layer.cornerRadius=6
      label7.frame = CGRectMake(
        label7.frame.origin.x, label7.frame.origin.y,
        label7.frame.size.width, 75);
      label7.backgroundColor = .systemGray5
      label7.layer.masksToBounds = true
//            self.view.addSubview(labelAll6)
            self.scrollView.addSubview(label7)

      let label8 = UILabel(frame: CGRect(x: 130+20, y: 1095, width: 100, height: 35))
      //    label6.center = CGPoint(x: 160, y: 285)
      label8.textAlignment = .center
      label8.font = UIFont.init(name: "TimesNewRomanPSMT", size: 18)
      if MetricsAllDim1.count>0 {
        label8.text = String(format: "Average\nPercentage\n%f", 100*average(metricsByMazes: MetricsAllDim8))
      }
      label8.numberOfLines = 0;
      label8.layer.cornerRadius=6
      label8.frame = CGRectMake(
        label8.frame.origin.x, label8.frame.origin.y,
        label8.frame.size.width, 75);
      label8.backgroundColor = .systemGray5
      label8.layer.masksToBounds = true
//            self.view.addSubview(labelAll6)
            self.scrollView.addSubview(label8)

      let label9 = UILabel(frame: CGRect(x: 240+20, y: 1095, width: 100, height: 35))
      //    label6.center = CGPoint(x: 160, y: 285)
      label9.textAlignment = .center
      label9.font = UIFont.init(name: "TimesNewRomanPSMT", size: 18)
      if MetricsAllDim1.count>0 {
        label9.text = String(format: "Average\nSwipes\n%f", average(metricsByMazes: MetricsAllDim9))
      }
      label9.numberOfLines = 0;
      label9.layer.cornerRadius=6
      label9.frame = CGRectMake(
        label9.frame.origin.x, label9.frame.origin.y,
        label9.frame.size.width, 75);
      label9.backgroundColor = .systemGray5
      label9.layer.masksToBounds = true
//            self.view.addSubview(labelAll6)
            self.scrollView.addSubview(label9)

      let label10 = UILabel(frame: CGRect(x: 80+20, y: 1180, width: 200, height: 35))
      //    label6.center = CGPoint(x: 160, y: 285)
      label10.textAlignment = .center
      label10.font = UIFont.init(name: "TimesNewRomanPSMT", size: 18)
      if MetricsAllDim1.count>0 {
        label10.text = String(format: "Number of\nMazes\n%d", MetricsAllDim1.count)
      }
      label10.numberOfLines = 0;
      label10.layer.cornerRadius=6
      label10.frame = CGRectMake(
        label10.frame.origin.x, label10.frame.origin.y,
        label10.frame.size.width, 75);
      label10.backgroundColor = .systemGray5
      label10.layer.masksToBounds = true
//            self.view.addSubview(labelAll6)
      self.scrollView.addSubview(label10)
      
    }

    @objc func informationButtonAction(sender: UIButton!) {
      print("Button tapped")
      //          let vc=dashboardViewController()
      //          let vc=ModesViewConroller();
      let vc=InformationViewController();
      vc.modalPresentationStyle = .fullScreen
      self.present(vc, animated:true, completion: nil)
    }
    
    @objc func playButtonAction(sender: UIButton!) {
      print("Button tapped")
      //          let vc=dashboardViewController()
      //          let vc=ModesViewConroller();
      
      if modeD=="MetricsImmersedCircle"{
        let vc=GameViewControllerMainMaze();
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated:true, completion: nil)
      }
      else if modeD=="MetricsFluidFlow" {
        let vc=GameViewControllerFluidFlowMaze();
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated:true, completion: nil)
      } else if modeD=="MetricsGravity" {
        let vc=GameViewControllerGravityMaze();
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated:true, completion: nil)
      } else if modeD=="MetricsBirds" {
        let vc=GameViewControllerBirdsMaze();
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated:true, completion: nil)
      } 
    }
    
    @objc func accountButtonAction(sender: UIButton!) {
      print("Button tapped")
      //          let vc=dashboardViewController()
      //          let vc=ModesViewConroller();
      let vc=AccountViewController();
      vc.modalPresentationStyle = .fullScreen
      self.present(vc, animated:true, completion: nil)
    }
    
//    @objc func surveyButtonAction(sender: UIButton!) {
//      print("Button tapped")
//      //          let vc=dashboardViewController()
//      //          let vc=ModesViewConroller();
//      let vc=SurveyViewController();
//      vc.modalPresentationStyle = .fullScreen
//      self.present(vc, animated:true, completion: nil)
//    }
  
  @objc func instructionsButtonAction(sender: UIButton!) {
    print("Button tapped")
    //          let vc=dashboardViewController()
    //          let vc=ModesViewConroller();
    let vc=InstructionsViewController();
    vc.modalPresentationStyle = .fullScreen
    self.present(vc, animated:true, completion: nil)
  }
    
    func load(name: String) {
      guard let appDelegate =
              UIApplication.shared.delegate as? AppDelegate else {
        return
      }
      let managedContext =
      appDelegate.persistentContainer.viewContext
      //2
      let fetchRequest1 =
      NSFetchRequest<NSManagedObject>(entityName: name)
      let fetchRequest2 =
      NSFetchRequest<NSManagedObject>(entityName: "MetricsAll")
      do {
        MetricsThisMaze = try managedContext.fetch(fetchRequest1)
        MetricsAll = try managedContext.fetch(fetchRequest2)
      } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
      }
    }

    func average(metricsByMazes: [Double])->Double {
      let sum = metricsByMazes.reduce(0, +)
      let average=sum/Double(metricsByMazes.count)
      return average
    }
    
    @objc func playerItemDidReachEnd(notification: NSNotification) {
      
      if let playerItem = notification.object as? AVPlayerItem {
        let a=2
      }
    }
    
    func loadBg() {
      guard let appDelegate =
              UIApplication.shared.delegate as? AppDelegate else {
        return
      }
      let managedContext =
      appDelegate.persistentContainer.viewContext
      let fetchRequest1 =
      NSFetchRequest<NSManagedObject>(entityName: "Background")
      do {
        background = try managedContext.fetch(fetchRequest1)
      } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
      }
    }
    
  
    func loadMode() {
      guard let appDelegate =
              UIApplication.shared.delegate as? AppDelegate else {
        return
      }
      let managedContext =
      appDelegate.persistentContainer.viewContext
      let fetchRequest1 =
      NSFetchRequest<NSManagedObject>(entityName: "CurrentMode")
      do {
        currentMode = try managedContext.fetch(fetchRequest1)
      } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
      }
    }
    
    
    func saveMode(mode: String) {
      guard let appDelegate =
              UIApplication.shared.delegate as? AppDelegate else {
        return
      }
      let managedContext =
      appDelegate.persistentContainer.viewContext
      let entity1 =
      NSEntityDescription.entity(forEntityName: "CurrentMode",
                                 in: managedContext)!
      let currentModeEntity = NSManagedObject(entity: entity1,
                                              insertInto: managedContext)
      currentModeEntity.setValue(mode, forKeyPath: "currentMode")
      do {
        try managedContext.save()
        currentMode.append(currentModeEntity)
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }
    
    
    override var prefersStatusBarHidden: Bool {
      return true
    }
    
  }

extension UIView {
    func addBackground(imageName: String, contentMode: UIView.ContentMode) {
        // setup the UIImageView
        let backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
        backgroundImageView.image = UIImage(named: imageName)
        backgroundImageView.contentMode = contentMode
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(backgroundImageView)
      sendSubviewToBack(backgroundImageView)

        // adding NSLayoutConstraints
        let leadingConstraint = NSLayoutConstraint(item: backgroundImageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0)
        let trailingConstraint = NSLayoutConstraint(item: backgroundImageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        let topConstraint = NSLayoutConstraint(item: backgroundImageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: backgroundImageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)

        NSLayoutConstraint.activate([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
    }
}

final class CustomView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        (layer as! CAGradientLayer).colors = [UIColor.yellow, UIColor.orange, UIColor.blue].map({ $0.cgColor })
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 2000, height: 2000)
    }
}
