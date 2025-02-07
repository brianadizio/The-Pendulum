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
import StoreKit
import CoreData
@available(iOS 13.0, *)
class AccountViewController: UIViewController {
  
  var EnergySourceLab:String?
  let showDetailSegueIdentifier = "Detail"
  
  var background: [NSManagedObject] = []
  var products: [SKProduct] = []
  var modeD: String = ""
  var currentMode: [NSManagedObject] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    var temp = view.bounds.size
    
    loadMode()
    var mode=currentMode[currentMode.count-1].value(forKey: "currentMode")
    modeD=mode as! String
    
    loadBg()
    var backgroundFlag=background[background.count-1].value(forKey: "bgFlag")
    var backgroundD=backgroundFlag as! Int
    if backgroundD == 0 {
      self.view.backgroundColor = .systemBackground
      
    }
    else if backgroundD == 1{
      var r: Int = Int.random(in: 1..<28)
      //      self.view.backgroundColor = .systemGreen
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
    
    let dashBoardbutton = UIButton()
    dashBoardbutton.frame = CGRect(x: 30, y: 85, width: 100, height: 35)
    dashBoardbutton.backgroundColor = UIColor.systemGray5
    dashBoardbutton.setTitle("Dashboard", for: .normal)
    dashBoardbutton.setTitleColor(.black, for: .normal)
    dashBoardbutton.layer.cornerRadius=6
    dashBoardbutton.titleLabel?.font =  UIFont(name: "TimesNewRomanPSMT" , size: 20)
    dashBoardbutton.addTarget(self, action: #selector(dashboardButtonAction), for: .touchUpInside)
    self.view.addSubview(dashBoardbutton)
    
    let playButton = UIButton()
    playButton.frame = CGRect(x: self.view.frame.size.width-134, y: 85, width: 100, height: 35)
    playButton.backgroundColor = .systemGray5
    playButton.setTitle("Play", for: .normal)
    playButton.addTarget(self, action: #selector(playButtonAction), for: .touchUpInside)
    playButton.layer.cornerRadius=6
    playButton.setTitleColor(.black, for: .normal)
    playButton.titleLabel?.font =  UIFont(name: "TimesNewRomanPSMT" , size: 20)
    self.view.addSubview(playButton)
    
    let comingSoon = UILabel(frame: CGRect(x: self.view.frame.size.width/2-100, y: self.view.frame.size.height/2, width: 200, height: 40))
    //    label1.center = CGPoint(x: 160, y: 285)
    comingSoon.textAlignment = .center
    comingSoon.font = UIFont.init(name: "TimesNewRomanPSMT", size: 28)
    comingSoon.text = String(format: "Coming Soon!")
    comingSoon.layer.cornerRadius=6
    comingSoon.textColor = UIColor.black
    comingSoon.backgroundColor = .systemGray5
    comingSoon.layer.masksToBounds = true
    self.view.addSubview(comingSoon)
    NotificationCenter.default.addObserver(self, selector: #selector(ModesViewConroller.handlePurchaseNotification(_:)),
                                           name: .IAPHelperPurchaseNotification,
                                           object: nil)
    if  let receivedEnergySourceLab = EnergySourceLab {
      mode = receivedEnergySourceLab
      print(mode)
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

    //    self.performSegue(withIdentifier: "unwindToA", sender: self)
    
  }
  
  @objc func dashboardButtonAction(sender: UIButton!) {
    print("Button tapped")
    //          let vc=dashboardViewController()
    //          let vc=ModesViewConroller();
    let vc=DashboardViewController();
    vc.modalPresentationStyle = .fullScreen
    self.present(vc, animated:true, completion: nil)
  }
  
  
//  @objc func surveyButtonAction(sender: UIButton!) {
//    print("Button tapped")
//    //          let vc=dashboardViewController()
//    //          let vc=ModesViewConroller();
////    let vc=SurveyViewController();
//    vc.modalPresentationStyle = .fullScreen
//    self.present(vc, animated:true, completion: nil)
//  }
  
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
  
  
  @objc func playerItemDidReachEnd(notification: NSNotification) {
    
    if let playerItem = notification.object as? AVPlayerItem {
      let a=2
    }
  }
  
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  
}


