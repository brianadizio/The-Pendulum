///// Copyright (c) 2018 Razeware LLC
/////
///// Permission is hereby granted, free of charge, to any person obtaining a copy
///// of this software and associated documentation files (the "Software"), to deal
///// in the Software without restriction, including without limitation the rights
///// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
///// copies of the Software, and to permit persons to whom the Software is
///// furnished to do so, subject to the following conditions:
/////
///// The above copyright notice and this permission notice shall be included in
///// all copies or substantial portions of the Software.
/////
///// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
///// distribute, sublicense, create a derivative work, and/or sell copies of the
///// Software in any work that is designed, intended, or marketed for pedagogical or
///// instructional purposes related to programming, coding, application development,
///// or information technology.  Permission for such use, copying, modification,
///// merger, publication, distribution, sublicensing, creation of derivative works,
///// or sale is expressly withheld.
/////
///// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
///// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
///// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
///// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
///// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
///// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
///// THE SOFTWARE.
//
//import SpriteKit
////import SwiftGraph
//import SwiftUI
//import Foundation
////import UIKit
//import AVKit
//import CoreData
//import CoreLocation
//import Charts
//import Singular
//
//func +(left: CGPoint, right: CGPoint) -> CGPoint {
//  return CGPoint(x: left.x + right.x, y: left.y + right.y)
//}
//
//func -(left: CGPoint, right: CGPoint) -> CGPoint {
//  return CGPoint(x: left.x - right.x, y: left.y - right.y)
//}
//
//func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
//  return CGPoint(x: point.x * scalar, y: point.y * scalar)
//}
//
//func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
//  return CGPoint(x: point.x / scalar, y: point.y / scalar)
//}
//
//#if !(arch(x86_64) || arch(arm64))
//  func sqrt(a: CGFloat) -> CGFloat {
//    return CGFloat(sqrtf(Float(a)))
//  }
//#endif
//
//extension CGPoint {
//  func length() -> CGFloat {
//    return sqrt(x*x + y*y)
//  }
//  
//  func normalized() -> CGPoint {
//    return self / length()
//  }
//}
//
//func loadGraphics() -> (SKVideoNode, AVPlayer){
//  let bundle = Bundle.main
//  var sample: SKVideoNode!
//  var graphicsPlayer: AVPlayer!
//    if let videoURL = bundle.url(forResource: "immersedCircle", withExtension: "mp4") {
//      graphicsPlayer = AVPlayer(url: videoURL)
//      graphicsPlayer.actionAtItemEnd = .none
//      sample = SKVideoNode(avPlayer: graphicsPlayer)
//  }
//  return (sample, graphicsPlayer)
//}
//
//var maze: [[Int]]!
//var mazeSwiped: [[Int]]!
//var mazeSprites: [SKSpriteNode]!
//var ball: SKSpriteNode!
//var ballGold: SKEmitterNode!
//var ballPosition: [Int]!
//var mazeBlock: SKSpriteNode!
//var solved=0
//var numMazeBlocks=0
//var numMazeBlocksSwiped=0
//var secondMazeFlag=false
//var numSwipes = 0.0
////@available(iOS 13.0, *)
//@available(iOS 13.0, *)
//class GameSceneMainMaze: SKScene, CLLocationManagerDelegate {
//  
//  var MetricsThisMaze: [NSManagedObject] = []
//  var MetricsAll: [NSManagedObject] = []
//  var metricsThisMaze: [Double] = []
//  let player = SKSpriteNode(imageNamed: "block3")
//  var gifTextures: [SKTexture] = [];
//  let gifNode = SKSpriteNode(imageNamed: "immersedCircle-unscreen/unscreen-001")
//  var background: [NSManagedObject] = []
//  var mazeTime: Double = 0
//  var numMazeBlocks=0
//  var numMazeBlocksSwiped=0
//  var numSwipes = 0.0
//  var mode = "MetricsImmersedCircle"
//  var rM = 0
//  var timestamp = 0.0
//  var longitude = 0.0
//  var latitude = 0.0
//  var location = CLLocation()
//  var locationManager = CLLocationManager()
//  var dataDoubleReal: [Double] = []
//  var sizeArray: [Int32] = []
//  var MetricsThisDim1D: [Double] = []
//  var array = emxArray_real_T()
//  var dataOut: [Double] = []
//  var numElNodesCorners: [Int] = []
//  var initialCenter = CGPoint()
//  var numLandedNodesCorners: Int = 1
//  var totNumNodesCorners: Int = 0
//  var swipingObject: [NSManagedObject] = []
//  var swipingMethod = 0
//  
////  let pendulumViewModel = PendulumViewModel()
//  
//  override func didMove(to view: SKView) {
//    
//    
//  var numMazeBlocks=0
//  var numMazeBlocksSwiped=1
//    
//    var  waitForDouble = SKAction.wait(forDuration: TimeInterval(2.40))
//    var tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
//    tap.numberOfTapsRequired = 2
//    
//    //    view.removeGestureRecognizer(tap)
//    self.run(waitForDouble, completion: {
//      print("Waited 2.4")
//      //      view.removeGestureRecognizer(tap)
//      view.addGestureRecognizer(tap)
//      
//    })
//    
//    self.alpha = 0
//    for i in 5...45 {
//      gifTextures.append(SKTexture(imageNamed: "immersedCircle-unscreen/unscreenb-\(i)"));
//      //      print("immersedCircle-unscreen/unscreen-\(i)")
//    }
//    
////    loadSwiping()
//    let swipingMethodFlag=swipingObject[swipingObject.count-1].value(forKey: "swipingMethod")
//    let swipingMethod=swipingMethodFlag as! Int
//    print("Swiping Method\n")
//    print(swipingMethod)
//    
//    if secondMazeFlag==true {
//      gifNode.position = CGPoint(x: frame.midX, y: frame.midY)
//      gifNode.size=CGSize(width: 500,height: 680)
//      self.addChild(gifNode)
//      
//      gifNode.run((SKAction.animate(with: gifTextures, timePerFrame: 0.05)));
//      let fadeOutGraphic = SKAction.fadeAlpha(to: 0.0, duration: 1.50)
//      let fadeInGraphic = SKAction.fadeAlpha(to: 1.0, duration: 0.5)
//      
//      gifNode.run(fadeInGraphic)
//      
//      gifNode.run(fadeOutGraphic){
//        self.gifNode.removeFromParent()
//      }
//      //        gifNode.run(SKAction.fadeOut(withDuration: 0.75),completion: {() -> Void in
//      //          sample.removeFromParent()
//      //        })
//      //        NotificationCenter.default.addObserver(self, selector: #selector(GameSceneMainMaze.playerItemDidReachEnd), name: AVPlayerItem.didPlayToEndTimeNotification, object: graphicsPlayer.currentItem)
//      //        })
//    }
//    self.run(SKAction.fadeIn(withDuration: 2.375))
//    //    backgroundColor = SKColor.white
//
//    player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
//    
////    var mazeFileContents=readMazeFileContents();
////    var readMaze=readSingleMaze(mazeFileContents: mazeFileContents)
////    maze=readMaze.0
////    metricsThisMaze=readMaze.3
////    var sprites: ([SKSpriteNode],[Int],SKSpriteNode)
////    sprites = drawMaze(maze: maze)
//    
//    
//    
//    // Input pendulum equations, constants, trial sampling
//    
//    
////    var pendulum=rK4(0.002, <#T##independentVariable: Double##Double#>, <#T##dependentVariables: [Double]##[Double]#>, functions: <#T##[(Double, [Double]) -> Double]#>)
//////
////    simpleEuler(<#T##Double#>, <#T##Double#>, <#T##[Double]#>, functions: <#T##[(Double, [Double]) -> Double]#>)
////    
////    var newValues1=simpleEuler(timeStep,
////                               time,
////                               [theta, angVelocity],
////                               [pendulumTheta(time,[theta, angVelocity]),
////                                pendulumOmega(time, [theta,angVelocity])] )
////    
////    theta2=newValues1[0];
////    angVelocity2=newValues1[1];
////    var newValues2=simpleEuler(timeStep,
////                               time+timeStep*1,
////                               [theta, angVelocity],
////                               [pendulumTheta(time,[theta, angVelocity]),
////                                pendulumOmega(time, [theta,angVelocity])] )
////    
////    var newValues=simpleEuler(0.002, 0, [-pi/100, 0], pendulum())
////    
////  
//    ball = SKSpriteNode(imageNamed: "ballShadedBg")
//    //          ball.scale(to: CGSize(width: ball.size.width*0.115, height: ball.size.height*0.115))
//    //ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
//    //ball.physicsBody?.restitution = 0.4
//    ball.position = CGPoint(x: size.width*0.5, y: size.height*0.5)
//    addChild(ball)
//    ball.zPosition = CGFloat(pow(Double(maze.count),2)+1)
//    mazeSwiped=maze;
//    
////    ball.position=pendulum
//
//    
////    setupPendulum()
////    
////    pendulumViewModel.startSimulation()
////        
////        // Use the pendulum state to update ball position
////        run(SKAction.repeatForever(
////            SKAction.sequence([
////                SKAction.run { [weak self] in
////                    guard let self = self else { return }
////                    let pendulumState = self.pendulumViewModel.currentState
////                    ball.position = CGPoint(
////                        x: size.width*0.5 + CGFloat(100 * sin(pendulumState.theta)),
////                        y: size.height*0.5 - CGFloat(100 * cos(pendulumState.theta))
////                    )
////                },
////                SKAction.wait(forDuration: 1.0/60.0)
////            ])
////        ))
////    
//    
//  }
//  
//
//  
//  
//  @objc func doubleTapped() {
//    print("Doubletappeed");
//    secondMazeFlag=true;
//    solved=1
////    saveMazeMetrics()
//    // Example 1: Standard event, no attributes
//    //    Singular.event(EVENT_SNG_LOGIN)
//    
//    // Example 2: Standard event, with standard attributes
//    //    var dic: [AnyHashable : Any] = [:]
//    //    dic[ATTRIBUTE_SNG_ATTR_CONTENT_TYPE] = "PrivacyController"
//    //    dic[ATTRIBUTE_SNG_ATTR_CONTENT_ID] = "0"
//    //    dic[ATTRIBUTE_SNG_ATTR_CONTENT] = "GDPR and CCPA Opt-Out Options"
//    //    Singular.event(EVENT_SNG_CONTENT_VIEW, withArgs: dic)
//    
//    // Example 3: Custom event, without attributes
//    Singular.event("Installed, Played First Maze")
//    
//    // Example 4: Custom event, with a custom attribute
//    //    var bonusdata: [AnyHashable: Any] = [ "level": 10, "points": 500 ]
//    //    Singular.event("Bonus Points Earned", withArgs: bonusdata)
//    
//    let scene = GameSceneMainMaze(size: self.size)
//    self.run(SKAction.fadeOut(withDuration: 0.15)){
//      self.view?.presentScene(scene)
//    }
//  }
//  
//  func load(name: String) {
//    guard let appDelegate =
//            UIApplication.shared.delegate as? AppDelegate else {
//      return
//    }
//    let managedContext =
//    appDelegate.persistentContainer.viewContext
//    //2
//    let fetchRequest1 =
//    NSFetchRequest<NSManagedObject>(entityName: name)
//    let fetchRequest2 =
//    NSFetchRequest<NSManagedObject>(entityName: "MetricsAll")
//    do {
//      MetricsThisMaze = try managedContext.fetch(fetchRequest1)
//      MetricsAll = try managedContext.fetch(fetchRequest2)
//    } catch let error as NSError {
//      print("Could not fetch. \(error), \(error.userInfo)")
//    }
//  }
//  
////  private func setupPendulum() {
////          let pendulumScene = PendulumScene(size: size)
////          pendulumScene.viewModel = pendulumViewModel
////          pendulumScene.setupControls()
////          
////          // Load test data if available
////          if let fileURL = Bundle.main.url(forResource: "myiptype8", withExtension: "m") {
////              pendulumViewModel.importTestData(from: fileURL.path)
////          }
////          
////          // Link pendulum position to ball position
////          run(SKAction.repeatForever(SKAction.sequence([
////              SKAction.run { [weak self] in
////                  guard let self = self else { return }
////                  let state = self.pendulumViewModel.currentState
////                  
////                  // Convert pendulum angle to position
////                  let x = size.width/2 + CGFloat(sin(state.theta) * 100)
////                  let y = size.height/2 - CGFloat(cos(state.theta) * 100)
////                  
////                  ball.position = CGPoint(x: x, y: y)
////              },
////              SKAction.wait(forDuration: 1.0/60.0)
////          ])))
////      }
////  }
//  
////  func save(_ pcaDim1: Double,_ pcaDim2: Double,_ pcaDim3: Double,_ pcaDim4: Double,_ pcaDim5: Double,_ pcaDim6: Double,_ pcaDim7: Double,_ pcaDim8: Double,_ pcaDim9: Double,_ datenum1: Double,_ lat1: Double,_ long1: Double,_ rM1: Int,_ mode1: String,_ dim1: Double,_ dim2: Double,_ dim3: Double,_ dim4: Double,_ dim5: Double,_ dim6: Double,_ dim7: Double,_ dim8: Double,_ dim9: Double,_ datenum2: Double,_ lat2: Double,_ long2: Double,_ rM2: Int) {
////    guard let appDelegate =
////            UIApplication.shared.delegate as? AppDelegate else {
////      return
////    }
////    let managedContext =
////    appDelegate.persistentContainer.viewContext
////    let entity1 =
////    NSEntityDescription.entity(forEntityName: "MetricsAll",
////                               in: managedContext)!
////    let entity2 =
////    NSEntityDescription.entity(forEntityName: "MetricsImmersedCircle",
////                               in: managedContext)!
////    let metricsAll = NSManagedObject(entity: entity1,
////                                     insertInto: managedContext)
////    let metricsImmersedCircle = NSManagedObject(entity: entity2,
////                                                insertInto: managedContext)
////    metricsAll.setValue(pcaDim1, forKeyPath: "pcaDim1")
////    metricsAll.setValue(pcaDim2, forKeyPath: "pcaDim2")
////    metricsAll.setValue(pcaDim3, forKeyPath: "pcaDim3")
////    metricsAll.setValue(pcaDim4, forKeyPath: "pcaDim4")
////    metricsAll.setValue(pcaDim5, forKeyPath: "pcaDim5")
////    metricsAll.setValue(pcaDim6, forKeyPath: "pcaDim6")
////    metricsAll.setValue(pcaDim7, forKeyPath: "pcaDim7")
////    metricsAll.setValue(pcaDim8, forKeyPath: "pcaDim8")
////    metricsAll.setValue(pcaDim9, forKeyPath: "pcaDim9")
////    metricsAll.setValue(datenum1, forKeyPath: "datenum")
////    metricsAll.setValue(lat1, forKeyPath: "latitude")
////    metricsAll.setValue(long1, forKeyPath: "longitude")
////    metricsAll.setValue(rM1, forKeyPath: "rM")
////    metricsAll.setValue(mode1, forKeyPath: "mode")
////    metricsImmersedCircle.setValue(dim1, forKeyPath: "dim1")
////    metricsImmersedCircle.setValue(dim2, forKeyPath: "dim2")
////    metricsImmersedCircle.setValue(dim3, forKeyPath: "dim3")
////    metricsImmersedCircle.setValue(dim4, forKeyPath: "dim4")
////    metricsImmersedCircle.setValue(dim5, forKeyPath: "dim5")
////    metricsImmersedCircle.setValue(dim6, forKeyPath: "dim6")
////    metricsImmersedCircle.setValue(dim7, forKeyPath: "dim7")
////    metricsImmersedCircle.setValue(dim8, forKeyPath: "dim8")
////    metricsImmersedCircle.setValue(dim9, forKeyPath: "dim9")
////    metricsImmersedCircle.setValue(datenum2, forKeyPath: "datenum")
////    metricsImmersedCircle.setValue(lat2, forKeyPath: "latitude")
////    metricsImmersedCircle.setValue(long2, forKeyPath: "longitude")
////    metricsImmersedCircle.setValue(rM2, forKeyPath: "rM")
////    
////    do {
////      try managedContext.save()
////      //      MetricsThisMaze.append(metricsImmersedCircle)
////      MetricsAll.append(metricsAll)
////    } catch let error as NSError {
////      print("Could not save. \(error), \(error.userInfo)")
////    }
////  }
//  
//  
//  
////  func pendulumOmega(ind: Double, dep: [Double]) -> Double {
////    
////    // omega(i)=omega(i-1)-g/L*h*sin(theta(i-1));
////
////    omegaNew=-g/L*sin(dep[0]);
////    
////   // t(i)=t(i-1)+h;
////    
////    
////  }
////  func pendulumTheta(ind: Double, dep: [Double]) -> Double {
////  
////  // theta(i)=theta(i-1)+h*omega(i-1);
////
////  thetaNew=dep[1];
////  
////  }
//  
//
//  func explode() -> SKEmitterNode {
//    
//    let enode = SKEmitterNode()
//    let image = UIImage(named: "ball")
//    let texture = SKTexture(image: image!)
//    //    enode.particlePosition = CGPoint(x: self.view.frame.width * 0.5, y: self.view.frame.height * 0.5)
//    //    enode.particlePosition = ball.position
//    enode.particleTexture = texture
//    enode.particleColor = .brown
//    //    enode.numParticlesToEmit = 100
//    enode.particleBirthRate = 200
//    
//    enode.particleLifetimeRange = 0
//    enode.particleLifetime = 1
//    
//    enode.emissionAngle = 89.32
//    enode.emissionAngleRange = 360
//    
//    enode.particleSpeed = 500
//    enode.particleSpeedRange = 503
//    
//    enode.xAcceleration = 0
//    enode.yAcceleration = -1000
//    
//    enode.particleAlpha = 1
//    enode.particleAlphaSpeed = -1
//    enode.particleAlphaRange = 0.2
//    
//    enode.particleScale = 0.3
//    enode.particleScaleRange = 0.2
//    enode.particleScaleSpeed = -0.4
//    
//    enode.particleRotation = 0
//    enode.particleRotationRange = 359
//    enode.particleRotationSpeed = 0
//    
//    enode.particleColorBlendFactor = 1
//    
//    enode.particleBlendMode = .add
//    
//    return enode
//  }
//  
//  
//  func sub2ind(size: Int, xInd: Int, yInd: Int) -> Int{
//    let ind = xInd*size+yInd
////    let ind = yInd*size+xInd
//    return ind
//  }
//  
//  func ind2sub(size: Int, ind: Int)  -> (Int, Int){
//    
//    let xInd = ind / size
//    let yInd = (ind % size)
//    return (xInd,yInd)
//    
//  }
////
////extension Sequence where Iterator.Element: Hashable {
////    func unique() -> [Iterator.Element] {
////        var seen: Set<Iterator.Element> = []
//        return filter { seen.insert($0).inserted }
////    }
////}
