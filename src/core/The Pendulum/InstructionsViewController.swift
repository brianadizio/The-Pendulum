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
class InstructionsViewController: UIViewController {
  
  var EnergySourceLab:String?
  let showDetailSegueIdentifier = "Detail"
  
  var background: [NSManagedObject] = []
  var products: [SKProduct] = []
  var modeD: String = ""
  var currentMode: [NSManagedObject] = []
  
  var scrollView: UIScrollView = {
    let obj = UIScrollView()
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
    
    let comingSoon = UILabel(frame: CGRect(x: self.view.frame.size.width/2-185, y: self.view.frame.size.height/2-250, width: 370, height: 375))
    //    label1.center = CGPoint(x: 160, y: 285)
    comingSoon.textAlignment = .center
    comingSoon.font = UIFont.init(name: "TimesNewRomanPSMT", size: 20)
    comingSoon.text = String(format: "Instructions: \n\n1. Swipe the ball up, down, left, or right.\n\n2. Color as many blocks as you can.\n\n3. You can go over colored or gray blocks.\n\n4. Double tap to load the next maze.\n\nChange the background with the        symbol. \n\nChange swiping method with the        symbol. \n\nMore Maze Modes and Styles coming soon!")
    comingSoon.layer.cornerRadius=10
    comingSoon.textColor = UIColor.black
    comingSoon.backgroundColor = .systemGray5
    comingSoon.numberOfLines=0
    comingSoon.layer.masksToBounds = true
    scrollView.addSubview(comingSoon)
    
    // "This percentage is multiplied by each metric \nto give you average scores on the Dashboard.\n\n"
    let bgIcon = UIButton()
    bgIcon.frame = CGRect(x: self.view.frame.width/2+77, y: self.view.frame.height/2-14, width: 40, height: 40)
    bgIcon.backgroundColor = UIColor.systemGray5
    bgIcon.setImage(UIImage(named: "bg"), for: .normal)
    bgIcon.setTitleColor(.black, for: .normal)
    bgIcon.layer.cornerRadius=6
    bgIcon.titleLabel?.font =  UIFont(name: "TimesNewRomanPSMT" , size: 20)
//    bgIcon.addTarget(self, action: #selector(backgroundButtonAction), for: .touchUpInside)
    scrollView.addSubview(bgIcon)
//
    // "This percentage is multiplied by each metric \nto give you average scores on the Dashboard.\n\n"
    let swipeIcon = UIButton()
    swipeIcon.frame = CGRect(x: self.view.frame.width/2+83, y: self.view.frame.height/2+32, width: 28, height: 28)
    swipeIcon.backgroundColor = UIColor.systemGray5
    swipeIcon.setImage(UIImage(named: "swipe"), for: .normal)
    swipeIcon.setTitleColor(.black, for: .normal)
    swipeIcon.layer.cornerRadius=6
    swipeIcon.titleLabel?.font =  UIFont(name: "TimesNewRomanPSMT" , size: 20)
//    bgIcon.addTarget(self, action: #selector(backgroundButtonAction), for: .touchUpInside)
    scrollView.addSubview(swipeIcon)
//    var bgIcon  = UIImage(named: "bg")
////    var bgIcon = self.resizeImage(image: UIImage(named: "bg")!, targetSize: CGSizeMake(20.0, 20.0))
////    var image = UIImage()
//    var imageView = UIImageView(frame: CGRectMake(view.frame.size.width/2, view.frame.size.height/2, 20, 20))
//            imageView.image = bgIcon
//    var bgIconView = UIImageView(image: bgIcon)
//    self.view.addSubview(bgIconView)

//    var icon1 = SKSpriteNode(imageNamed: "dimensions")
//    icon1.size = bgIcon1.size
//    icon1.position = bgIcon1.position
////    icon1.position.y = icon1.position.y + icon1.position.y/2
//    icon1.setScale(0.91)
////    addChild(bgIcon1)
//    addChild(icon1)
    
    let journey = UILabel(frame: CGRect(x: self.view.frame.size.width/2-185, y: self.view.frame.size.height/2+170, width: 370, height: 400))
    //    label1.center = CGPoint(x: 160, y: 285)
    journey.textAlignment = .center
    journey.font = UIFont.init(name: "TimesNewRomanPSMT", size: 20)
    journey.text = String(format: "Your Journey: \n\nEach maze is a thought, by playing your are creating your digital mind. the goal of the game is search for resonant frequencies, when your mind's Connectivity blows up from a circle into a big tangled explosion. By harmonizing mind and body with these rhythms, you'll get your Spirit, the collection of your mind and body, to a balanced state, at the Golden Mean.  At the Golden Mean, your body and your mind, will uniquely flow with The Word, frequency as emotion.")
    journey.layer.cornerRadius=10
    journey.textColor = UIColor.black
    journey.backgroundColor = .systemGray5
    journey.numberOfLines=0
    journey.layer.masksToBounds = true
    scrollView.addSubview(journey)
    

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
//    let vc=SurveyViewController();
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
  
  func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
      let size = image.size
      
      let widthRatio  = targetSize.width  / size.width
      let heightRatio = targetSize.height / size.height
      
      // Figure out what our orientation is, and use that to form the rectangle
      var newSize: CGSize
      if(widthRatio > heightRatio) {
          newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
      } else {
          newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
      }
      
      // This is the rect that we've calculated out and this is what is actually used below
      let rect = CGRect(origin: .zero, size: newSize)
      
      // Actually do the resizing to the rect using the ImageContext stuff
      UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
      image.draw(in: rect)
      let newImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      
      return newImage
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  
}


