import UIKit
import SpriteKit
import StoreKit
import AVKit
import CoreData
import SwiftUI
@available(iOS 13.0, *)
class ModesViewConroller: UIViewController {
  
  //override func loadView() {
    //self.view = SKView()
    //self.view = UIView(frame: UIScreen.main.bounds)
  //}
  let EnSoString = "Energy Source"

  var products: [SKProduct] = []
  var background: [NSManagedObject] = []

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
    print(view.bounds.size)
    self.view.backgroundColor = .systemBackground

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
//      scrollView.backgroundColor = UIColor(patternImage: UIImage(imageLiteralResourceName: "Sachuest/Sachuest\(r).jpeg"));
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
      scrollContainer.leadingAnchor.constraint (equalTo: scrollContentGuide.leadingAnchor),
      scrollContainer.trailingAnchor.constraint (equalTo: scrollContentGuide.trailingAnchor),
      scrollContainer.topAnchor.constraint (equalTo: scrollContentGuide.topAnchor),
      scrollContainer.bottomAnchor.constraint (equalTo: scrollContentGuide.bottomAnchor),
    //for dynamic vertical scrolling
      scrollContainer.leadingAnchor.constraint (equalTo: scrollFrameGuide.leadingAnchor),
      scrollContainer.trailingAnchor.constraint(equalTo: scrollFrameGuide.trailingAnchor),
      scrollContainer.heightAnchor.constraint (equalToConstant: 1500)])
   
    scrollView.backgroundColor = .clear

    let immersedCircleButton = UIButton()
    immersedCircleButton.frame = CGRect(x: 37, y: 85, width: 150, height: 35)
    immersedCircleButton.backgroundColor = .systemGray5
    immersedCircleButton.setTitle("Immersed Circle", for: .normal)
    immersedCircleButton.addTarget(self, action: #selector(immersedCircleButtonAction), for: .touchUpInside)
    immersedCircleButton.layer.cornerRadius=6
    immersedCircleButton.setTitleColor(.black, for: .normal)
    immersedCircleButton.titleLabel?.font =  UIFont(name: "TimesNewRomanPSMT" , size: 20)
    scrollView.addSubview(immersedCircleButton)
    
    let birdsButton = UIButton()
    birdsButton.frame = CGRect(x: self.view.frame.size.width-174, y: 85, width: 150, height: 35)
    birdsButton.backgroundColor = .systemGray5
    birdsButton.setTitle("Birds", for: .normal)
    birdsButton.addTarget(self, action: #selector(birdsButtonAction), for: .touchUpInside)
    birdsButton.layer.cornerRadius=6
    birdsButton.setTitleColor(.black, for: .normal)
    birdsButton.titleLabel?.font =  UIFont(name: "TimesNewRomanPSMT" , size: 20)
    scrollView.addSubview(birdsButton)
    
    let gravityButton = UIButton()
    gravityButton.frame = CGRect(x: self.view.frame.size.width-174, y: 145, width: 150, height: 35)
    gravityButton.backgroundColor = .systemGray5
    gravityButton.setTitle("Gravity", for: .normal)
    gravityButton.addTarget(self, action: #selector(gravityButtonAction), for: .touchUpInside)
    gravityButton.layer.cornerRadius=6
    gravityButton.setTitleColor(.black, for: .normal)
    gravityButton.titleLabel?.font =  UIFont(name: "TimesNewRomanPSMT" , size: 20)
    scrollView.addSubview(gravityButton)
    
    let fluidFlowButton = UIButton()
    fluidFlowButton.frame = CGRect(x: 37, y: 145, width: 150, height: 35)
    fluidFlowButton.backgroundColor = .systemGray5
    fluidFlowButton.setTitle("Fluid Flow", for: .normal)
    fluidFlowButton.addTarget(self, action: #selector(fluidFlowButtonAction), for: .touchUpInside)
    fluidFlowButton.layer.cornerRadius=6
    fluidFlowButton.setTitleColor(.black, for: .normal)
    fluidFlowButton.titleLabel?.font =  UIFont(name: "TimesNewRomanPSMT" , size: 20)
    scrollView.addSubview(fluidFlowButton)
    
    
//    let immersedCircleButton = UIButton()
//    immersedCircleButton.frame = CGRect(x: 75, y: 90, width: 100, height: 35)
//    immersedCircleButton.backgroundColor = UIColor.lightGray
//    immersedCircleButton.setTitle("Immersed Circle", for: .normal)
//    immersedCircleButton.addTarget(self, action: #selector(immersedCircleButtonAction), for: .touchUpInside)
//    self.view.addSubview(immersedCircleButton)
//    
//    let birdsButton = UIButton()
//    birdsButton.frame = CGRect(x: self.view.frame.size.width - 125, y: 90, width: 100, height: 35)
//    birdsButton.backgroundColor = UIColor.lightGray
//    birdsButton.setTitle("Birds", for: .normal)
//    birdsButton.addTarget(self, action: #selector(birdsButtonAction), for: .touchUpInside)
//    self.view.addSubview(birdsButton)
//    
//    let gravityButton = UIButton()
//    gravityButton.frame = CGRect(x: 75, y: 200, width: 100, height: 35)
//    gravityButton.backgroundColor = UIColor.lightGray
//    gravityButton.setTitle("Gravity", for: .normal)
//    gravityButton.addTarget(self, action: #selector(gravityButtonAction), for: .touchUpInside)
//    self.view.addSubview(gravityButton)
//    
//    let fluidFlowButton = UIButton()
//    fluidFlowButton.frame = CGRect(x: self.view.frame.size.width - 125, y: 200, width: 100, height: 35)
//    fluidFlowButton.backgroundColor = UIColor.lightGray
//    fluidFlowButton.setTitle("FluidFlow: $.29", for: .normal)
//    fluidFlowButton.addTarget(self, action: #selector(fluidFlowButtonAction), for: .touchUpInside)
//    self.view.addSubview(fluidFlowButton)
    
    NotificationCenter.default.addObserver(self, selector: #selector(ModesViewConroller.handlePurchaseNotification(_:)),
                                           name: .IAPHelperPurchaseNotification,
                                           object: nil)

//    let button = UIButton(type: .system) // let preferred over var here
//    button.frame = CGRectMake(100, 100, 100, 50)
//    button.backgroundColor = UIColor.green
//    button.setTitle("Button", for: [])
//    button.addTarget(self, action: Selector(("Action:")), for: UIControlEvents.touchUpInside)
//    self.view.addSubview(button)
//
//    var label: UILabel = UILabel()
//    label.frame = CGRectMake(50, 50, 200, 21)
//    label.backgroundColor = UIColor.black
//    label.textColor = UIColor.white
//    label.textAlignment = NSTextAlignment.center
//    label.text = "test label"
//    self.view.addSubview(label)
////
    
    //    self.button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        
    
    
   /* if scene.isSolved()==1 {
      let scene=GameSceneMainMaze(size: view.bounds.size)
      let transition = SKTransition.moveIn(with: .right, duration: 1)
      skView.presentScene(scene, transition: transition)
    }*/
    
  }
  
  @objc func immersedCircleButtonAction(sender: UIButton!) {
     print("Button tapped")
//        let vc=dashboardViewController()
          let vc=GameViewControllerMainMaze();
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated:true, completion: nil)
  }
  
  @objc func birdsButtonAction(sender: UIButton!) {
     print("Button tapped")
//        let vc=dashboardViewController()
          let vc=GameViewControllerBirdsMaze();
    print(vc)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated:true, completion: nil)
  }
  
  @objc func gravityButtonAction(sender: UIButton!) {
     print("Button tapped")
//        let vc=dashboardViewController()
          let vc=GameViewControllerGravityMaze();
    print(vc)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated:true, completion: nil)
  }
  
  @objc func fluidFlowButtonAction(sender: UIButton!) {
     print("Button tapped")
//        let vc=dashboardViewController()
          let vc=GameViewControllerFluidFlowMaze();
    print(vc)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated:true, completion: nil)
  }
  
  @objc func buyButtonTapped(_ sender: AnyObject, prodIndex: Int) {
    print("Buy Button tapped")
    if IAPHelper.canMakePayments() {
            RazeFaceProducts.store.buyProduct(self.products[prodIndex])
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
  }
  
//  private var button: UIButton {
////    let button = UIButton()
//    let button = UIButton(type: .system) // let preferred over var here
//    button.frame = CGRectMake(50, 100, 100, 50)
//    button.backgroundColor = UIColor.blue
//    button.setTitle("Button", for: [])
//    button.addTarget(self, action: Selector(("Action:")), for: UIControlEvents.touchUpInside)
//    self.view.addSubview(button)
//    return button
//  }
  
//  private func setupUI(){
//    self.view.addSubview(button)
//    self.button.translatesAutoresizingMaskIntoConstraints=false
////    NSLayoutConstraint.activate([
////      button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor,
////      button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor,
////      button.widthAnchor.constraint(equalToConstant: 200),
////      button.heightAnchor.constraint(equalToConstant: 4)])
//  }
//
  
//    @IBAction func buttonPressed(_ sender: UIButton) {
//    print("BUTTON PRESSED")
//      var changeMaze=1;
//     // let vc = GameSceneMainMaze(fileNamed: "GameSceneMainMaze", securelyWithClasses: nil);
//      //vc.text = "Next level blog photo booth, tousled authentic tote bag kogi"
//
//      //navigationController?.pushViewController(vc, animated: true)
//
//    }
  
  //    let buttonRestore = UIButton()
  //    button.frame = CGRect(x: self.view.frame.size.width-125, y: 200, width: 100, height: 35)
  //    button.backgroundColor = UIColor.blue
  //    button.setTitle("Resture", for: .normal)
  //    button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
  //    self.view.addSubview(buttonRestore)
      
  //    navigationItem.rightBarButtonItem = restoreButton
      
    
  @objc func playerItemDidReachEnd(notification: NSNotification) {

      if let playerItem = notification.object as? AVPlayerItem {
          let a=2
      }
  }
  
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
 
  
  @objc func didTapButton() {
    print("DEBUG PRINT: button pressed")
//    let vc=dashboardViewController()
//    vc.modalPresentationStyle = .fullScreen
//    self.present(vc, animated:true, completion: nil)
//
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
//  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    if segue.identifier == "segueID" {
//      if let vc = segue.destination as? dashboardViewController {
//        vc.EnergySourceLab = EnSoString
//      }
//    }
//  }
}

