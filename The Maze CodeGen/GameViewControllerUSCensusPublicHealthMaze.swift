

import UIKit
import SpriteKit
import AVKit
import CoreData
import SwiftUI

@available(iOS 13.0, *)
class GameViewControllerUSCensusPublicHealthMaze: UIViewController {
   
  var currentMode: [NSManagedObject] = []
  
  override func loadView() {
    self.view = SKView(frame: UIScreen.main.bounds)
//        self.view = UIView(frame: UIScreen.main.bounds)
    //  }
  }
  let EnSoString = "MetricsUSCensusPublicHealth"
  var InitMetrics: [NSManagedObject] = []
  
  override func viewDidAppear(_ animated: Bool) {
    saveMode(mode: "MetricsUSCensusPublicHealth", modeName: "US Public Health")
    loadInitMetrics()
    var InitMetricsFlag=InitMetrics[InitMetrics.count-1].value(forKey: "initMetricsFlag")
    var InitMetricsFlagD=InitMetricsFlag as! Int
    print(InitMetricsFlagD)
    if InitMetricsFlagD==1{
      saveInitMetrics(InitMetricsInput: 2)
      let vc=InstructionsViewController();
          vc.modalPresentationStyle = .fullScreen
          vc.modalTransitionStyle = .crossDissolve
          self.present(vc, animated:true, completion: nil)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    var temp = view.bounds.size
    print(view.bounds.size)
    print("InVC")
    //    print(view)

      let scene = GameSceneUSCensusPublicHealthMaze(size: temp)
      let skView = view as! SKView
      //    scene.size = skView.bounds.size
      skView.showsFPS = true
      skView.showsNodeCount = true
      skView.ignoresSiblingOrder = true
      scene.scaleMode = .resizeFill
      skView.presentScene(scene)
    
      
      let modesButton = UIButton()
      modesButton.frame = CGRect(x: self.view.frame.size.width-134, y: 85, width: 100, height: 35)
      modesButton.backgroundColor = UIColor.systemGray5
      modesButton.setTitle("Modes", for: .normal)
      modesButton.setTitleColor(.black, for: .normal)
      modesButton.layer.cornerRadius=6
      modesButton.titleLabel?.font =  UIFont(name: "TimesNewRomanPSMT" , size: 20)
      modesButton.addTarget(self, action: #selector(modesButtonAction), for: .touchUpInside)
      self.view.addSubview(modesButton)
      
      let dashBoardbutton = UIButton()
      dashBoardbutton.frame = CGRect(x: 30, y: 85, width: 100, height: 35)
      dashBoardbutton.backgroundColor = UIColor.systemGray5
      dashBoardbutton.setTitle("Dashboard", for: .normal)
      dashBoardbutton.setTitleColor(.black, for: .normal)
      dashBoardbutton.layer.cornerRadius=6
      dashBoardbutton.titleLabel?.font =  UIFont(name: "TimesNewRomanPSMT" , size: 20)
      dashBoardbutton.addTarget(self, action: #selector(dashboardButtonAction), for: .touchUpInside)
      self.view.addSubview(dashBoardbutton)
      
      let backgroundButton = UIButton()
      backgroundButton.frame = CGRect(x: 145, y: 85, width: 38, height: 35)
      backgroundButton.backgroundColor = UIColor.systemGray5
      backgroundButton.setImage(UIImage(named: "bg"), for: .normal)
      backgroundButton.setTitleColor(.black, for: .normal)
      backgroundButton.layer.cornerRadius=6
      backgroundButton.titleLabel?.font =  UIFont(name: "TimesNewRomanPSMT" , size: 20)
      backgroundButton.addTarget(self, action: #selector(backgroundButtonAction), for: .touchUpInside)
      self.view.addSubview(backgroundButton)
      
    let swipingButton = UIButton()
    swipingButton.frame = CGRect(x: 195, y: 85, width: 38, height: 35)
    swipingButton.backgroundColor = UIColor.systemGray5
    swipingButton.setImage(UIImage(named: "swipe"), for: .normal)
    swipingButton.setTitleColor(.black, for: .normal)
    swipingButton.layer.cornerRadius=6
    swipingButton.titleLabel?.font =  UIFont(name: "TimesNewRomanPSMT" , size: 20)
    swipingButton.addTarget(self, action: #selector(swipingButtonAction), for: .touchUpInside)
    self.view.addSubview(swipingButton)
    
    
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
       let scene=GameSceneUSCensusPublicHealthMaze(size: view.bounds.size)
       let transition = SKTransition.moveIn(with: .right, duration: 1)
       skView.presentScene(scene, transition: transition)
       }*/
    
  }
  
  @objc func modesButtonAction(sender: UIButton!) {
     print("Button tapped")
    let vc=ModesViewConroller();
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated:true, completion: nil)
  }
  
  @objc func backgroundButtonAction(sender: UIButton!) {
     print("Button tapped")
    let vc=BackgroundViewController();
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated:true, completion: nil)
  }
  
  @objc func swipingButtonAction(sender: UIButton!) {
     print("Button tapped")
    let vc=SwipingMethodViewController();
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated:true, completion: nil)
  }
  
  
  @IBAction func dashboardButtonAction(sender: UIButton!) {
//    if sender.isSelected {
//       sender.isSelected = false
//    } else {
//            self.performSegue(withIdentifier: "segueID", sender: self)
//    }
    let vc=DashboardViewController();
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated:true, completion: nil)
    
  }
    
  @objc func playerItemDidReachEnd(notification: NSNotification) {
      if let playerItem = notification.object as? AVPlayerItem {
          let a=2
      }
  }
  
  @IBAction func unwindToA( _ seg: UIStoryboardSegue) {}
  
  
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

  
//@IBAction func EnergySourceBut(_ sender: UIButton) {
//  if sender.isSelected {
//     sender.isSelected = false
//  } else {
//          self.performSegue(withIdentifier: "segueID", sender: self)
//  }
//}

//
//  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    if segue.identifier == "segueID" {
//      if let vc = segue.destination as? DashboardViewController {
//        vc.EnergySourceLab = EnSoString
//      }
//    }
//  }
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     if segue.identifier == "segueID" {
         if let destination = segue.destination as? DashboardViewController {
           destination.EnergySourceLab = "Immersed Circle" // you can pass value to destination view controller
           
             // destination.nomb = arrayNombers[(sender as! UIButton).tag] // Using button Tag
         }
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
  

    func saveMode(mode: String, modeName: String) {
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
      currentModeEntity.setValue(modeName, forKeyPath: "currentModeName")
      do {
        try managedContext.save()
        currentMode.append(currentModeEntity)
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }

  func saveInitMetrics(InitMetricsInput: Int16) {
    guard let appDelegate =
      UIApplication.shared.delegate as? AppDelegate else {
      return
    }
    let managedContext =
      appDelegate.persistentContainer.viewContext
    let entity1 =
      NSEntityDescription.entity(forEntityName: "InitMetrics",
                                 in: managedContext)!
    let initMetricsFlag = NSManagedObject(entity: entity1,
                                 insertInto: managedContext)
    initMetricsFlag.setValue(InitMetricsInput, forKeyPath: "initMetricsFlag")
    do {
      try managedContext.save()
      InitMetrics.append(initMetricsFlag)
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
    }
  }
  
  
  func loadInitMetrics() {
  guard let appDelegate =
      UIApplication.shared.delegate as? AppDelegate else {
        return
    }
    let managedContext =
      appDelegate.persistentContainer.viewContext
    let fetchRequest1 =
      NSFetchRequest<NSManagedObject>(entityName: "InitMetrics")
    do {
      InitMetrics = try managedContext.fetch(fetchRequest1)
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
  }
  
  
}


