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
class SwipingMethodViewController: UIViewController {

 
  //override func loadView() {
    //self.view = SKView()
    //self.view = UIView(frame: UIScreen.main.bounds)
  //}
//  let EnSoString = "Energy Source"
  var EnergySourceLab:String?

  let showDetailSegueIdentifier = "Detail"
  
  var currentMode: [NSManagedObject] = []
  var products: [SKProduct] = []
  var background: [NSManagedObject] = []
  var swipingObjects: [NSManagedObject] = []
  var modeD: String = ""
  var swipingMethodD = 1
  var dashBoardButton = UIButton()
  var modesButton = UIButton()
  var continuousSwiping = UIButton()
  var discreteSwiping = UIButton()
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    var temp = view.bounds.size
    self.view.backgroundColor = .systemGreen
    
//    loadSwiping()
//    var swipingMethod=swipingObjects[swipingObjects.count-1].value(forKey: "swipingMethod")
//    swipingMethodD=swipingMethod as! Int
    
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
    
//    let button = UIButton()
//    button.frame = CGRect(x: self.view.frame.size.width-125, y: 90, width: 100, height: 35)
//    button.backgroundColor = UIColor.yellow
//    button.setTitle("Restore", for: .normal)
//    button.addTarget(self, action: #selector(restoreTapped), for: .touchUpInside)
//    self.view.addSubview(button)
//
//    let buttonBuy = UIButton()
//    buttonBuy.frame = CGRect(x: self.view.frame.size.width-200, y: 200, width: 100, height: 35)
//    buttonBuy.backgroundColor = UIColor.blue
//    buttonBuy.setTitle("Buy", for: .normal)
//    buttonBuy.addTarget(self, action: #selector(buyButtonTapped), for: .touchUpInside)
//    self.view.addSubview(buttonBuy)
    
//    let informationButton = UIButton()
//    informationButton.frame = CGRect(x: self.view.frame.size.width-125, y: 90, width: 100, height: 35)
//    informationButton.backgroundColor = UIColor.yellow
//    informationButton.setTitle("Information", for: .normal)
//    NatureBg.setTitleColor(UIColorFromRGB("F21B3F"), for: .normal)
//    informationButton.addTarget(self, action: #selector(informationButtonAction), for: .touchUpInside)
//    self.view.addSubview(informationButton)
//
//    let accountButton = UIButton()
//    accountButton.frame = CGRect(x: 125, y: 90, width: 100, height: 35)
//    accountButton.backgroundColor = UIColor.blue
//    accountButton.setTitle("Account", for: .normal)
//    NatureBg.setTitleColor(UIColorFromRGB("F21B3F"), for: .normal)
//    accountButton.addTarget(self, action: #selector(accountButtonAction), for: .touchUpInside)
//    self.view.addSubview(accountButton)
//
//    let modesButton = UIButton()
//    modesButton.frame = CGRect(x: self.view.frame.size.width-125, y: 200, width: 100, height: 35)
//    modesButton.backgroundColor = UIColor.yellow
//    modesButton.setTitle("Modes", for: .normal)
//    NatureBg.setTitleColor(UIColorFromRGB("F21B3F"), for: .normal)
//    modesButton.addTarget(self, action: #selector(modesButtonAction), for: .touchUpInside)
//    self.view.addSubview(modesButton)
//
//    let surveyButton = UIButton()
//    surveyButton.frame = CGRect(x: 125, y: 200, width: 100, height: 35)
//    surveyButton.backgroundColor = UIColor.blue
//    surveyButton.setTitle("Survey", for: .normal)
//    NatureBg.setTitleColor(UIColorFromRGB("F21B3F"), for: .normal)
//    surveyButton.addTarget(self, action: #selector(surveyButtonAction), for: .touchUpInside)
//    self.view.addSubview(surveyButton)
    
//    let dashBoardButton = UIButton()
    dashBoardButton.frame = CGRect(x: self.view.frame.size.width/2-100, y: 145, width: 200, height: 35)
    dashBoardButton.backgroundColor = UIColor.systemGray5
    dashBoardButton.setTitleColor(.black, for: .normal)
    dashBoardButton.layer.cornerRadius=6
    dashBoardButton.setTitle("Dashboard", for: .normal)
    dashBoardButton.titleLabel?.font =  UIFont(name: "TimesNewRomanPSMT" , size: 20)
    dashBoardButton.addTarget(self, action: #selector(dashboardButtonAction), for: .touchUpInside)
    self.view.addSubview(dashBoardButton)
    
//    let modesButton = UIButton()
    modesButton.frame = CGRect(x: self.view.frame.size.width/2-100, y: 85, width: 200, height: 35)
    modesButton.backgroundColor = UIColor.systemGray5
    modesButton.setTitleColor(.black, for: .normal)
    modesButton.setTitle("Play", for: .normal)
    modesButton.layer.cornerRadius=6
    modesButton.titleLabel?.font =  UIFont(name: "TimesNewRomanPSMT" , size: 20)
    modesButton.addTarget(self, action: #selector(playButtonAction), for: .touchUpInside)
    self.view.addSubview(modesButton)
    
//    let continuousSwiping = UIButton()
    continuousSwiping.frame = CGRect(x: self.view.frame.size.width/2-100, y: 205, width: 200, height: 35)
    continuousSwiping.backgroundColor = UIColor.systemGray5
    continuousSwiping.setTitleColor(.black, for: .normal)
    continuousSwiping.setTitle("Continuous", for: .normal)
    continuousSwiping.layer.cornerRadius=6
    continuousSwiping.titleLabel?.font =  UIFont(name: "TimesNewRomanPSMT" , size: 20)
    continuousSwiping.addTarget(self, action: #selector(continuousButtonAction), for: .touchUpInside)
    self.view.addSubview(continuousSwiping)
    
//    let discreteSwiping = UIButton()
    discreteSwiping.frame = CGRect(x: self.view.frame.size.width/2-100, y: 265, width: 200, height: 35)
    discreteSwiping.backgroundColor = UIColor.systemGray5
    discreteSwiping.setTitleColor(.black, for: .normal)
    discreteSwiping.setTitle("Discrete", for: .normal)
    discreteSwiping.layer.cornerRadius=6
    discreteSwiping.titleLabel?.font =  UIFont(name: "TimesNewRomanPSMT" , size: 20)
    discreteSwiping.addTarget(self, action: #selector(discreteButtonAction), for: .touchUpInside)
    self.view.addSubview(discreteSwiping)
    
//    let FluidBg = UIButton()
//    FluidBg.frame = CGRect(x: self.view.frame.size.width/2-100, y: 325, width: 200, height: 35)
//    FluidBg.backgroundColor = UIColor.systemGray5
//    FluidBg.setTitle("Fluid", for: .normal)
//    FluidBg.setTitleColor(.black, for: .normal)
//    FluidBg.layer.cornerRadius=6
//    FluidBg.titleLabel?.font =  UIFont(name: "TimesNewRomanPSMT" , size: 20)
//    FluidBg.addTarget(self, action: #selector(fluidButtonAction), for: .touchUpInside)
//    self.view.addSubview(FluidBg)
//    
//    let ArtificialIntelligenceBg = UIButton()
//    ArtificialIntelligenceBg.frame = CGRect(x: self.view.frame.size.width/2-100, y: 385, width: 200, height: 35)
//    ArtificialIntelligenceBg.setTitle("Artificial Intelligence", for: .normal)
//    ArtificialIntelligenceBg.backgroundColor = UIColor.systemGray5
//    ArtificialIntelligenceBg.setTitleColor(.black, for: .normal)
//    ArtificialIntelligenceBg.layer.cornerRadius=6
//    ArtificialIntelligenceBg.titleLabel?.font =  UIFont(name: "TimesNewRomanPSMT" , size: 20)
//    ArtificialIntelligenceBg.addTarget(self, action: #selector(artificialIntelligenceButtonAction), for: .touchUpInside)
//    self.view.addSubview(ArtificialIntelligenceBg)
//    
//    let blankBg = UIButton()
//    blankBg.frame = CGRect(x: self.view.frame.size.width/2-100, y: 445, width: 200, height: 35)
//    blankBg.backgroundColor = UIColor.systemGray5
//    blankBg.setTitle("Blank", for: .normal)
//    blankBg.setTitleColor(.black, for: .normal)
//    blankBg.layer.cornerRadius=6
//    blankBg.titleLabel?.font =  UIFont(name: "TimesNewRomanPSMT" , size: 20)
//    blankBg.addTarget(self, action: #selector(blankActionButton), for: .touchUpInside)
//    self.view.addSubview(blankBg)
    
    
//
//    let buttonRestore = UIButton()
//    button.frame = CGRect(x: self.view.frame.size.width-125, y: 200, width: 100, height: 35)
//    button.backgroundColor = UIColor.blue
//    button.setTitle("Resture", for: .normal)
//    NatureBg.setTitleColor(UIColorFromRGB("F21B3F"), for: .normal)
//    button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
//    self.view.addSubview(buttonRestore)
    
//    navigationItem.rightBarButtonItem = restoreButton
    
//    NotificationCenter.default.addObserver(self, selector: #selector(ModesViewConroller.handlePurchaseNotification(_:)),
//                                           name: .IAPHelperPurchaseNotification,
//                                           object: nil)
    
//    print(view.bounds.size)
//    let scene = GameSceneMainMaze(size: view.bounds.size)
//    let skView = view as! SKView
//    skView.showsFPS = true
//    skView.showsNodeCount = true
//    skView.ignoresSiblingOrder = true
//    scene.scaleMode = .resizeFill
//    skView.presentScene(scene)
    
    // Do any additional setup after loading the view.
    // received info
    if  let receivedEnergySourceLab = EnergySourceLab {
      mode = receivedEnergySourceLab
      print(mode)
    }

    
   /* if scene.isSolved()==1 {
      let scene=GameSceneMainMaze(size: view.bounds.size)
      let transition = SKTransition.moveIn(with: .right, duration: 1)
      skView.presentScene(scene, transition: transition)
    }*/
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    reload()
  }
  
  @objc func reload() {
    products = []
    
//    tableView.reloadData()
 
    RazeFaceProducts.store.requestProducts{ [weak self] success, products in
      guard let self = self else { return }
      if success {
        self.products = products!
        
//        DispatchQueue.main.async {
//            self.tableView.reloadData()
//        }
        
//        self.tableView.reloadData()
      }
//      DispatchQueue.main.async {
//        self.refreshControl?.endRefreshing()
//      }
//      self.refreshControl?.endRefreshing()
    }
  
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
  
  
//  @objc func modesButtonAction(sender: UIButton!) {
//     print("Button tapped")
////          let vc=dashboardViewController()
////          let vc=ModesViewConroller();
//    let vc=ModesViewConroller();
//        vc.modalPresentationStyle = .fullScreen
//        self.present(vc, animated:true, completion: nil)
//  }
  
  @objc func dashboardButtonAction(sender: UIButton!) {
     print("Button tapped")
//          let vc=dashboardViewController()
//          let vc=ModesViewConroller();
    let vc=DashboardViewController();
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated:true, completion: nil)
  }
  
    
  @objc func accountButtonAction(sender: UIButton!) {
     print("Button tapped")
//          let vc=dashboardViewController()
//          let vc=ModesViewConroller();
    let vc=AccountViewController();
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated:true, completion: nil)
  }
  
//  @objc func surveyButtonAction(sender: UIButton!) {
//     print("Button tapped")
////          let vc=dashboardViewController()
////          let vc=ModesViewConroller();
//    let vc=SurveyViewController();
//        vc.modalPresentationStyle = .fullScreen
//        self.present(vc, animated:true, completion: nil)
//  }
  
  @objc func continuousButtonAction(sender: UIButton!) {
     print("Button tapped")
     saveSwiping(swipingMethod: Int16(1))
    sender.backgroundColor = .systemGray2
    discreteSwiping.backgroundColor = .systemGray5
    
  }
  
  @objc func discreteButtonAction(sender: UIButton!) {
     print("Button tapped")
    saveSwiping(swipingMethod: Int16(2))
    sender.backgroundColor = .systemGray2
    continuousSwiping.backgroundColor = .systemGray5
  }
  
  @objc func fluidButtonAction(sender: UIButton!) {
     print("Button tapped")
    saveBg(bgFlag: Int16(3))
    let vc=BackgroundViewController();
    vc.modalPresentationStyle = .fullScreen
    self.present(vc, animated:true, completion: nil)
  }
  
  @objc func artificialIntelligenceButtonAction(sender: UIButton!) {
     print("Button tapped")
    saveBg(bgFlag: Int16(4))
    let vc=BackgroundViewController();
    vc.modalPresentationStyle = .fullScreen
    self.present(vc, animated:true, completion: nil)
  }
  
  @objc func blankActionButton(sender: UIButton!) {
     print("Button tapped")
    saveBg(bgFlag: Int16(0))
    let vc=BackgroundViewController();
    vc.modalPresentationStyle = .fullScreen
    self.present(vc, animated:true, completion: nil)
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
  

  func saveBg(bgFlag: Int16) {
    guard let appDelegate =
      UIApplication.shared.delegate as? AppDelegate else {
      return
    }
    let managedContext =
      appDelegate.persistentContainer.viewContext
    let entity1 =
      NSEntityDescription.entity(forEntityName: "Background",
                                 in: managedContext)!
    let backgroundFlag = NSManagedObject(entity: entity1,
                                 insertInto: managedContext)
    backgroundFlag.setValue(bgFlag, forKeyPath: "bgFlag")
    do {
      try managedContext.save()
      background.append(backgroundFlag)
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
    }
  }
  
  func loadSwiping() {
  guard let appDelegate =
      UIApplication.shared.delegate as? AppDelegate else {
        return
    }
    let managedContext =
      appDelegate.persistentContainer.viewContext
    let fetchRequest1 =
      NSFetchRequest<NSManagedObject>(entityName: "SwipingMethod")
    do {
      swipingObjects = try managedContext.fetch(fetchRequest1)
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
  }
  

  func saveSwiping(swipingMethod: Int16) {
    guard let appDelegate =
      UIApplication.shared.delegate as? AppDelegate else {
      return
    }
    let managedContext =
      appDelegate.persistentContainer.viewContext
    let entity1 =
      NSEntityDescription.entity(forEntityName: "SwipingMethod",
                                 in: managedContext)!
    let swipingMethodFlag = NSManagedObject(entity: entity1,
                                 insertInto: managedContext)
    swipingMethodFlag.setValue(swipingMethod, forKeyPath: "swipingMethod")
    do {
      try managedContext.save()
      swipingObjects.append(swipingMethodFlag)
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
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
  
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
//  @objc func restoreButtonAction(sender: UIButton!) {
//     print("Button tapped")
////          let vc=dashboardViewController()
////          let vc=ModesViewConroller();
//    RazeFaceProducts.store.restorePurchases()
////    let vc=MasterViewController();
////        vc.modalPresentationStyle = .fullScreen
////        self.present(vc, animated:true, completion: nil)
//
//  }
  
  @objc func buyButtonTapped(_ sender: AnyObject) {
    print("Buy Button tapped")
    if IAPHelper.canMakePayments() {
      //      RazeFaceProducts.store.buyProduct(SKProduct: fluidFlow) }
    }
  }
  
  
  @objc func restoreTapped(_ sender: AnyObject) {
    RazeFaceProducts.store.restorePurchases()
  }

  @objc func handlePurchaseNotification(_ notification: Notification) {
    guard
      let productID = notification.object as? String,
      let index = products.index(where: { product -> Bool in
        product.productIdentifier == productID
      })
    else { return }
   
//    let button = UIButton()
//    button.frame = CGRect(x: self.view.frame.size.width-125, y: 200, width: 100, height: 35)
//    button.backgroundColor = UIColor.blue
//    button.setTitle("Bought", for: .normal)
//    button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
//    self.view.addSubview(button)
//
//    tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
  }
}
  
  
  
//
//@IBAction func EnergySourceBut(_ sender: UIButton) {
//
//if sender.isSelected {
//   sender.isSelected = false
//} else {
//        self.performSegue(withIdentifier: "segueID", sender: self)
//}
//}
//
//
//
//override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//if segue.identifier == "segueID" {
//if let vc = segue.destinationViewController as? dashboardViewController {
//   vc.EnergySourceLab = EnSoString
//}
//}
//
  
