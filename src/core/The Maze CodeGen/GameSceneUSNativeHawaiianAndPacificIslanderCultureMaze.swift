/// Copyright (c) 2018 Razeware LLC
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

import SpriteKit
//import SwiftGraph
import SwiftUI
import Foundation
//import UIKit
import AVKit
import CoreData
import CoreLocation
import Charts


@available(iOS 13.0, *)
class GameSceneUSNativeHawaiianAndPacificIslanderCultureMaze: SKScene, CLLocationManagerDelegate {
  
  var maze: [[Int]]!
  var mazeSwiped: [[Int]]!
  var mazeSprites: [SKSpriteNode]!
  var ball: SKSpriteNode!
  var ballGold: SKEmitterNode!
  var ballPosition: [Int]!
  var mazeBlock: SKSpriteNode!
  var solved=0
//  var numMazeBlocks=0
//  var numMazeBlocksSwiped=0
//  var secondMazeFlag=false
//  var numSwipes = 0.0
  
  var MetricsThisMaze: [NSManagedObject] = []
  var MetricsAll: [NSManagedObject] = []
  var metricsThisMaze: [Double] = []
  let player = SKSpriteNode(imageNamed: "block3")
  var gifTextures: [SKTexture] = [];
  let gifNode = SKSpriteNode(imageNamed: "immersedCircle-unscreen/unscreen-001")
  var background: [NSManagedObject] = []
  var mazeTime: Double = 0
  var numMazeBlocks=0
  var numMazeBlocksSwiped=0
  var numSwipes = 0.0
  var mode = "MetricsUSNativeHawaiianAndPacificIslanderCulture"
  var rM = 0
  var timestamp = 0.0
  var longitude = 0.0
  var latitude = 0.0
  var location = CLLocation()
  var locationManager = CLLocationManager()
  var dataDoubleReal: [Double] = []
  var sizeArray: [Int32] = []
  var MetricsThisDim1D: [Double] = []
  var array = emxArray_real_T()
  var dataOut: [Double] = []
  var numElNodesCorners: [Int] = []
  var initialCenter = CGPoint()
  var numLandedNodesCorners: Int = 1
  var totNumNodesCorners: Int = 0
  var swipingObject: [NSManagedObject] = []
  var swipingMethod = 0
  override func didMove(to view: SKView) {
    numMazeBlocks=0
    numMazeBlocksSwiped=1
    
    //    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
    //
    //    }
    
    var  waitForDouble = SKAction.wait(forDuration: TimeInterval(2.40))
    var tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
    tap.numberOfTapsRequired = 2
    
    //    view.removeGestureRecognizer(tap)
    self.run(waitForDouble, completion: {
      print("Waited 2.4")
      //      view.removeGestureRecognizer(tap)
      view.addGestureRecognizer(tap)
      
    })
    
    self.alpha = 0
    for i in 5...45 {
      gifTextures.append(SKTexture(imageNamed: "immersedCircle-unscreen/unscreenb-\(i)"));
      //      print("immersedCircle-unscreen/unscreen-\(i)")
    }
    
    loadSwiping()
    let swipingMethodFlag=swipingObject[swipingObject.count-1].value(forKey: "swipingMethod")
    let swipingMethod=swipingMethodFlag as! Int
    print("Swiping Method\n")
    print(swipingMethod)
    
    if secondMazeFlag==true {
      gifNode.position = CGPoint(x: frame.midX, y: frame.midY)
      gifNode.size=CGSize(width: 500,height: 680)
      self.addChild(gifNode)
      
      gifNode.run((SKAction.animate(with: gifTextures, timePerFrame: 0.05)));
      let fadeOutGraphic = SKAction.fadeAlpha(to: 0.0, duration: 1.50)
      let fadeInGraphic = SKAction.fadeAlpha(to: 1.0, duration: 0.5)
      
      gifNode.run(fadeInGraphic)
      
      gifNode.run(fadeOutGraphic){
        self.gifNode.removeFromParent()
      }
      //        gifNode.run(SKAction.fadeOut(withDuration: 0.75),completion: {() -> Void in
      //          sample.removeFromParent()
      //        })
      //        NotificationCenter.default.addObserver(self, selector: #selector(GameSceneUSNativeHawaiianAndPacificIslanderCultureMaze.playerItemDidReachEnd), name: AVPlayerItem.didPlayToEndTimeNotification, object: graphicsPlayer.currentItem)
      //        })
    }
    self.run(SKAction.fadeIn(withDuration: 2.375))
    //    backgroundColor = SKColor.white
    
    
    //    if background.count==0{
    //      saveBg(bgFlag: 0)
    //    }
    loadBg()
    let backgroundFlag=background[background.count-1].value(forKey: "bgFlag")
    let backgroundD=backgroundFlag as! Int
    if backgroundD == 0 {
      backgroundColor = .systemBackground
    }
    else if backgroundD == 1{
      let r: Int = Int.random(in: 1..<28)
      print(r)
      let backgroundImage = SKSpriteNode(imageNamed: "Sachuest/Sachuest\(r)")
      backgroundImage.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
      backgroundImage.zPosition = -10
      backgroundImage.size = self.frame.size
      addChild(backgroundImage)
    }
    else if backgroundD == 2 {
      let r: Int = Int.random(in: 1..<28)
      let backgroundImage = SKSpriteNode(imageNamed: "OuterSpace/OuterSpace\(r)")
      backgroundImage.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
      backgroundImage.zPosition = -10
      backgroundImage.size = self.frame.size
      addChild(backgroundImage)
      backgroundColor = .systemBackground
    }
    else if backgroundD == 3 {
      let r: Int = Int.random(in: 1..<8)
      let backgroundImage = SKSpriteNode(imageNamed: "FluidGray/fluidbw\(r)")
      backgroundImage.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
      backgroundImage.zPosition = -10
      backgroundImage.size = self.frame.size
      addChild(backgroundImage)
    }
    else if backgroundD == 4 {
      let r: Int = Int.random(in: 1..<12)
      let backgroundImage = SKSpriteNode(imageNamed: "AI/AI\(r)")
      backgroundImage.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
      backgroundImage.zPosition = -10
      backgroundImage.size = self.frame.size
      addChild(backgroundImage)
    }
    player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
    
    var mazeFileContents=readMazeFileContents();
    var readMaze=readSingleMaze(mazeFileContents: mazeFileContents)
    maze=readMaze.0
    metricsThisMaze=readMaze.3
    var sprites: ([SKSpriteNode],[Int],SKSpriteNode)
    sprites = drawMaze(maze: maze)
    mazeSwiped=maze;
    var nodes = readMaze.4
    var corners = readMaze.5
    var cornerTypes = readMaze.6
    
    //    let scene = SKScene(fileNamed: "circleEmitter")
    //    self.view?.presentScene(scene)
    
    numElNodesCorners = nodes + corners
    totNumNodesCorners = numElNodesCorners.unique().count
    //
    //    for i in 0..<numElNodesCorners{
    //
    //    }
    
    
    
    //    let arr = [1, 1, 2, 3]
    var counts: [Int: Int] = [:]
    var count100 : [Int] = Array(repeating: 0, count: 100)
    //    var count100 : [[Int]] = Array(repeating: Array(repeating: 0, count: 10), count: 10)
    for item in numElNodesCorners {
      counts[item] = (counts[item] ?? 0) + 1
    }
    for count in counts {
      if count.key != 400 {
        count100[count.key-1]=count.value
      }
    }
    var count100count : [Int] = Array(repeating: 0, count: 100)
    var fontH=10
    var straightsCounter=0
    print("Nodes and Corners")
    print(nodes)
    print(corners)
    print("\n")
    print(counts)
    
    for i in 1..<nodes.count+1 {
      for j in 1..<3{
        let nodeText = SKLabelNode(fontNamed: "TimesNewRomanPSMT")
        nodeText.text = String(format: "%d", j+2*(i-1)-straightsCounter)
        nodeText.fontSize = CGFloat(fontH)
        nodeText.fontColor = SKColor.black
        if j==1{
          if count100[nodes[i-1]-1]==1 {
            nodeText.position = mazeSprites[nodes[i-1]-1].position
            nodeText.fontSize=14
            nodeText.position.y = nodeText.position.y - CGFloat(14/2)
          } else if count100[nodes[i-1]-1]==2 && count100count[nodes[i-1]-1]==0 {
            count100count[nodes[i-1]-1]+=1
            nodeText.position = mazeSprites[nodes[i-1]-1].position
          } else if count100[nodes[i-1]-1]==2 && count100count[nodes[i-1]-1]==1 {
            count100count[nodes[i-1]-1]+=1
            nodeText.position = mazeSprites[nodes[i-1]-1].position
            nodeText.position.y = nodeText.position.y - CGFloat(fontH)
          }
          else if count100[nodes[i-1]-1]==3 && count100count[nodes[i-1]-1]==0 {
            count100count[nodes[i-1]-1]+=1
            nodeText.position = mazeSprites[nodes[i-1]-1].position
            nodeText.position.x = nodeText.position.x - CGFloat(fontH/2)
          } else if count100[nodes[i-1]-1]==3 && count100count[nodes[i-1]-1]==1 {
            count100count[nodes[i-1]-1]+=1
            nodeText.position = mazeSprites[nodes[i-1]-1].position
            nodeText.position.x = nodeText.position.x + CGFloat(fontH/2)
          } else if count100[nodes[i-1]-1]==3 && count100count[nodes[i-1]-1]==2 {
            count100count[nodes[i-1]-1]+=1
            nodeText.position = mazeSprites[nodes[i-1]-1].position
            nodeText.position.y = nodeText.position.y - CGFloat(fontH)
            
          } else if count100[nodes[i-1]-1]==4 && count100count[nodes[i-1]-1]==0 {
            count100count[nodes[i-1]-1]+=1
            nodeText.position = mazeSprites[nodes[i-1]-1].position
            nodeText.position.x = nodeText.position.x - CGFloat(fontH/2)
          } else if count100[nodes[i-1]-1]==4 && count100count[nodes[i-1]-1]==1 {
            count100count[nodes[i-1]-1]+=1
            nodeText.position = mazeSprites[nodes[i-1]-1].position
            nodeText.position.x = nodeText.position.x + CGFloat(fontH/2)
          } else if count100[nodes[i-1]-1]==4 && count100count[nodes[i-1]-1]==2 {
            count100count[nodes[i-1]-1]+=1
            nodeText.position = mazeSprites[nodes[i-1]-1].position
            nodeText.position.x = nodeText.position.x - CGFloat(fontH/2)
            nodeText.position.y = nodeText.position.y - CGFloat(fontH)
          } else if count100[nodes[i-1]-1]==4 && count100count[nodes[i-1]-1]==3 {
            count100count[nodes[i-1]-1]+=1
            nodeText.position = mazeSprites[nodes[i-1]-1].position
            nodeText.position.x = nodeText.position.x + CGFloat(fontH/2)
            nodeText.position.y = nodeText.position.y - CGFloat(fontH)
          }
          
        } else if j==2 && i<nodes.count{
          if corners[i-1] != 400{
            if count100[corners[i-1]-1]==1 {
              nodeText.position = mazeSprites[corners[i-1]-1].position
              nodeText.fontSize=14
              nodeText.position.y = nodeText.position.y - CGFloat(14/2)
            } else if count100[corners[i-1]-1]==2 && count100count[corners[i-1]-1]==0 {
              count100count[corners[i-1]-1]+=1
              nodeText.position = mazeSprites[corners[i-1]-1].position
            } else if count100[corners[i-1]-1]==2 && count100count[corners[i-1]-1]==1 {
              count100count[corners[i-1]-1]+=1
              nodeText.position = mazeSprites[corners[i-1]-1].position
              nodeText.position.y = nodeText.position.y - CGFloat(fontH)
            }
            
            else if count100[corners[i-1]-1]==3 && count100count[corners[i-1]-1]==0 {
              count100count[corners[i-1]-1]+=1
              nodeText.position = mazeSprites[corners[i-1]-1].position
              nodeText.position.x = nodeText.position.x - CGFloat(fontH/2)
            } else if count100[corners[i-1]-1]==3 && count100count[corners[i-1]-1]==1 {
              count100count[corners[i-1]-1]+=1
              nodeText.position = mazeSprites[corners[i-1]-1].position
              nodeText.position.x = nodeText.position.x + CGFloat(fontH/2)
            } else if count100[corners[i-1]-1]==3 && count100count[corners[i-1]-1]==2 {
              count100count[corners[i-1]-1]+=1
              nodeText.position = mazeSprites[corners[i-1]-1].position
              nodeText.position.y = nodeText.position.y - CGFloat(fontH)
            }
            
            else if count100[corners[i-1]-1]==4 && count100count[corners[i-1]-1]==0 {
              count100count[corners[i-1]-1]+=1
              nodeText.position = mazeSprites[corners[i-1]-1].position
              nodeText.position.x = nodeText.position.x - CGFloat(fontH/2)
            } else if count100[corners[i-1]-1]==4 && count100count[corners[i-1]-1]==1 {
              count100count[corners[i-1]-1]+=1
              nodeText.position = mazeSprites[corners[i-1]-1].position
              nodeText.position.x = nodeText.position.x + CGFloat(fontH/2)
            } else if count100[corners[i-1]-1]==4 && count100count[corners[i-1]-1]==2 {
              count100count[corners[i-1]-1]+=1
              nodeText.position = mazeSprites[corners[i-1]-1].position
              nodeText.position.x = nodeText.position.x - CGFloat(fontH/2)
              nodeText.position.y = nodeText.position.y - CGFloat(fontH)
            } else if count100[corners[i-1]-1]==4 && count100count[corners[i-1]-1]==3 {
              count100count[corners[i-1]-1]+=1
              nodeText.position = mazeSprites[corners[i-1]-1].position
              nodeText.position.x = nodeText.position.x + CGFloat(fontH/2)
              nodeText.position.y = nodeText.position.y - CGFloat(fontH)
            }
          } else if corners[i-1]==400 {
            straightsCounter+=1
          }
        }
        nodeText.zPosition = 101
        addChild(nodeText)
      }
    }
 print(straightsCounter)
    
    let metric1 = SKLabelNode(fontNamed: "TimesNewRomanPSMT")
    metric1.text = String(format: "Length\n%d", Int(round(metricsThisMaze[0])))
    metric1.fontSize = 16
    metric1.fontColor = SKColor.black
    metric1.position = CGPoint(x: frame.midX-145, y: frame.midY-60)
    metric1.numberOfLines=2
    let background1 = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 105, height: CGFloat(metric1.frame.size.height)), cornerRadius: 6)
    background1.fillColor = .systemGray5
    background1.position = metric1.position
    background1.position.x =  background1.position.x-metric1.frame.size.width/2-10
    addChild(background1)
    addChild(metric1)
    
    var bgIcon1=SKSpriteNode(color: .systemGray5, size: CGSize(width: CGFloat(40), height:CGFloat(metric1.frame.size.height)))
    bgIcon1.position = metric1.position
    bgIcon1.position.x = bgIcon1.position.x+metric1.frame.size.width/2+bgIcon1.frame.size.width/2
    bgIcon1.position.y = bgIcon1.position.y+metric1.frame.size.height/2
    var icon1 = SKSpriteNode(imageNamed: "dimensions")
    icon1.size = bgIcon1.size
    icon1.position = bgIcon1.position
    //    icon1.position.y = icon1.position.y + icon1.position.y/2
    icon1.setScale(0.91)
    //    addChild(bgIcon1)
    addChild(icon1)
    
    let metric2 = SKLabelNode(fontNamed: "TimesNewRomanPSMT")
    metric2.text = String(format: "Cycles\n%d", Int(round(metricsThisMaze[1])))
    metric2.fontSize = 16
    metric2.fontColor = SKColor.black
    metric2.position = CGPoint(x: frame.midX-25, y: frame.midY-60)
    metric2.numberOfLines=0
    let background2 = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 105, height: CGFloat(metric2.frame.size.height)), cornerRadius: 6)
    background2.fillColor = .systemGray5
    background2.position = metric2.position
    background2.position.x =  background2.position.x-metric2.frame.size.width/2-10
    addChild(background2)
    addChild(metric2)
    
    var bgIcon2=SKSpriteNode(color: .systemGray5, size: CGSize(width: CGFloat(40), height:CGFloat(metric2.frame.size.height)))
    bgIcon2.position = metric2.position
    bgIcon2.position.x = bgIcon2.position.x+metric2.frame.size.width/2+bgIcon2.frame.size.width/2
    bgIcon2.position.y = bgIcon2.position.y+metric2.frame.size.height/2
    var icon2 = SKSpriteNode(imageNamed: "recycle")
    icon2.size = bgIcon2.size
    icon2.position = bgIcon2.position
    icon2.setScale(0.85)
    //    addChild(bgIcon2)
    addChild(icon2)
    
    let metric3 = SKLabelNode(fontNamed: "TimesNewRomanPSMT")
    metric3.text = String(format: "Degree\n%f", metricsThisMaze[2])
    metric3.fontSize = 16
    metric3.fontColor = SKColor.black
    metric3.position = CGPoint(x: frame.midX+97, y: frame.midY-60)
    metric3.numberOfLines=0
    let background3 = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 125, height: CGFloat(metric3.frame.size.height)), cornerRadius: 6)
    background3.fillColor = .systemGray5
    background3.position = metric3.position
    background3.position.x =  background3.position.x-metric3.frame.size.width/2-10
    addChild(background3)
    addChild(metric3)
    
    var bgIcon3=SKSpriteNode(color: .systemGray5, size: CGSize(width: CGFloat(40), height:CGFloat(metric3.frame.size.height)))
    bgIcon3.position = metric3.position
    bgIcon3.position.x = bgIcon3.position.x+metric3.frame.size.width/2+bgIcon3.frame.size.width/2
    bgIcon3.position.y = bgIcon3.position.y+metric3.frame.size.height/2
    var icon3 = SKSpriteNode(imageNamed: "network")
    icon3.size = bgIcon3.size
    icon3.setScale(0.80)
    icon3.position = bgIcon3.position
    //    addChild(bgIcon3)
    addChild(icon3)
    
    let metric4 = SKLabelNode(fontNamed: "TimesNewRomanPSMT")
    metric4.text = String(format: "Complextity\n%f", metricsThisMaze[3])
    metric4.fontSize = 16
    metric4.fontColor = SKColor.black
    metric4.position = CGPoint(x: frame.midX-135, y: frame.midY-111)
    metric4.numberOfLines=0
    let background4 = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 135, height: CGFloat(metric4.frame.size.height)), cornerRadius: 6)
    background4.fillColor = .systemGray5
    background4.position = metric4.position
    background4.position.x =  background4.position.x-metric4.frame.size.width/2-10
    addChild(background4)
    addChild(metric4)
    
    var bgIcon4=SKSpriteNode(color: .systemGray5, size: CGSize(width: CGFloat(40), height:CGFloat(metric4.frame.size.height)))
    bgIcon4.position = metric4.position
    bgIcon4.position.x = bgIcon4.position.x+metric4.frame.size.width/2+bgIcon4.frame.size.width/2
    bgIcon4.position.y = bgIcon4.position.y+metric4.frame.size.height/2
    var icon4 = SKSpriteNode(imageNamed: "info")
    icon4.size = icon3.size
    icon4.setScale(0.85)
    icon4.position = bgIcon4.position
    //    addChild(bgIcon4)
    addChild(icon4)
    
    let metric5 = SKLabelNode(fontNamed: "TimesNewRomanPSMT")
    metric5.text = String(format: "Voids\n%d", Int(round(metricsThisMaze[4])))
    metric5.fontSize = 16
    metric5.fontColor = SKColor.black
    metric5.position = CGPoint(x: frame.midX-15, y: frame.midY-111)
    metric5.numberOfLines=0
    let background5 = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 100, height: CGFloat(metric5.frame.size.height)), cornerRadius: 6)
    background5.fillColor = .systemGray5
    background5.position = metric5.position
    background5.position.x =  background5.position.x-metric5.frame.size.width/2-10
    addChild(background5)
    addChild(metric5)
    
    var bgIcon5=SKSpriteNode(color: .systemGray5, size: CGSize(width: CGFloat(40), height:CGFloat(metric5.frame.size.height)))
    bgIcon5.position = metric5.position
    bgIcon5.position.x = bgIcon5.position.x+metric5.frame.size.width/2+bgIcon5.frame.size.width/2
    bgIcon5.position.y = bgIcon5.position.y+metric5.frame.size.height/2
    var icon5 = SKSpriteNode(imageNamed: "new-moon")
    icon5.size = bgIcon5.size
    icon5.setScale(0.725)
    icon5.position = bgIcon5.position
    //    addChild(bgIcon5)
    addChild(icon5)
    
    let metric6 = SKLabelNode(fontNamed: "TimesNewRomanPSMT")
    metric6.text = String(format: "Geodesic\n%f", metricsThisMaze[5])
    metric6.fontSize = 16
    metric6.fontColor = SKColor.black
    metric6.position = CGPoint(x: frame.midX+107, y: frame.midY-111)
    metric6.numberOfLines=0
    let background6 = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 110, height: CGFloat(metric6.frame.size.height)), cornerRadius: 6)
    background6.fillColor = .systemGray5
    background6.position = metric6.position
    background6.position.x =  background6.position.x-metric6.frame.size.width/2-10
    addChild(background6)
    addChild(metric6)
    
    var bgIcon6=SKSpriteNode(color: .systemGray5, size: CGSize(width: CGFloat(40), height:CGFloat(metric6.frame.size.height)))
    bgIcon6.position = metric6.position
    bgIcon6.position.x = bgIcon6.position.x+metric6.frame.size.width/2+bgIcon6.frame.size.width/2
    bgIcon6.position.y = bgIcon6.position.y+metric6.frame.size.height/2
    var icon6 = SKSpriteNode(imageNamed: "route")
    icon6.size = bgIcon6.size
    icon6.position = bgIcon6.position
    icon6.setScale(0.85)
    //    addChild(bgIcon6)
    addChild(icon6)
    
    let connLabel = SKLabelNode(fontNamed: "TimesNewRomanPSMT")
    connLabel.text = "Connectivity"
    connLabel.fontSize = 20
    connLabel.fontColor = SKColor.black
    connLabel.position = CGPoint(x: frame.midX+5, y: frame.midY-145)
    connLabel.numberOfLines=0
    let background7 = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 135, height: CGFloat(connLabel.frame.size.height+5)), cornerRadius: 6)
    background7.fillColor = .systemGray5
    background7.position = connLabel.position
    background7.position.x =  background7.position.x-connLabel.frame.size.width/2-15
    background7.position.y =  background7.position.y - 3
    addChild(background7)
    addChild(connLabel)

    // Ask for Authorisation from the User.
//    locationManager.requestAlwaysAuthorization()
//    
//    // For use in foreground
//    locationManager.requestWhenInUseAuthorization()
//    
//    locationManager.delegate = self
//    locationManager.requestWhenInUseAuthorization()
//    locationManager.desiredAccuracy = kCLLocationAccuracyBest
//    locationManager.requestAlwaysAuthorization()
//    locationManager.startUpdatingLocation()
//    
//    if
//      CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
//        CLLocationManager.authorizationStatus() ==  .authorizedAlways
//    {
//      locationManager.startUpdatingLocation()
//    }
    
    
    timestamp = NSDate().timeIntervalSince1970
    //    and For Decoding Unix Epoch time to Date().
    //    let myTimeInterval = TimeInterval(timestamp)
    //    let time = NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval))
    
    load(name: "MetricsUSNativeHawaiianAndPacificIslanderCulture")
    
    var MetricsAllDim1DN = [Any]()
    
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
        MetricsAllDim1DN.append(val.value(forKey: "pcaDim1") as! Double)
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
    print(MetricsAllDim1DN)
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
    
    
    
    
    
    if MetricsThisDim1.count>3 {
      
      dataDoubleReal = MetricsThisDim1 + MetricsThisDim2 + MetricsThisDim3 + MetricsThisDim4 + MetricsThisDim5 + MetricsThisDim6
      
      
      //      var dataDoubleReal: UnsafeMutableBufferPointer
      var dataOut: Array<Double> = []
      //var array: emxArray_real_T
      sizeArray = [Int32(MetricsThisDim1D.count), 6]
      sizeArray.withUnsafeMutableBufferPointer { sizeBP in
        dataDoubleReal.withUnsafeMutableBufferPointer { dataDoubleRealBP in
          array = emxArray_real_T(
            data: dataDoubleRealBP.baseAddress!,
            size: sizeBP.baseAddress!,
            allocatedSize: Int32(6*MetricsThisDim1D.count),
            numDimensions: 2,
            canFreeData: 10
          )
        }}
      let dataInput = UnsafeMutablePointer<emxArray_real_T>.allocate(capacity: 6*MetricsThisDim1.count)
      dataInput.initialize(from: &array, count: 1)
      
      let dataRed = UnsafeMutablePointer<emxArray_real_T>.allocate(capacity: 3*MetricsThisDim1.count)
      dataRed.initialize(from: &array, count: 1)
      
      pcaRed(dataInput, dataRed)
      //          var bufPtr1 = UnsafeBufferPointer(start: dataInput, count: 6*MetricsThisDim1.count)
      //          var newData = Array(bufPtr1)
      var bufPtr2 = UnsafeBufferPointer(start: dataRed, count: 3*MetricsThisDim1.count)
      var newDataRed = Array(bufPtr2)
      //          var bufPtr = UnsafeBufferPointer(start: newData[0].data, count: 6*MetricsThisDim1D.count)
      //      print(Array(bufPtr))
      var bufPtr = UnsafeBufferPointer(start: newDataRed[0].data, count: 3*MetricsThisDim1.count)
                  print(Array(bufPtr))
      dataOut=Array(bufPtr)
      
      dataInput.deallocate()
      dataRed.deallocate()
      
      
      // Loop through Z values, assign to picture.  Generate new pictures from matlab
      
      var dataPlotX: [Double] = []
      var dataPlotY: [Double] = []
      var dataPlotZ: [Double] = []
      for i in 0..<(dataOut.count/3) {
        dataPlotX.append(dataOut[i])
        dataPlotY.append(dataOut[i+(dataOut.count/3)])
        dataPlotZ.append(dataOut[i+(2*dataOut.count/3)])
        //          print(i)
        //          print(i+(dataOut.count/3))
        //          print(i+(2*dataOut.count/3))
      }
      //        print(dataPlotX)
      //        print(dataPlotY)
      //let singleDayCosts = passengersInDay.map { tripCostPerDay  / Double($0) }
      
      if dataPlotX.min()!<0.0{
        dataPlotX=dataPlotX.map{abs(Double($0) + dataPlotX.min()!)}
      }
      else if dataPlotX.min()!>0.0{
        dataPlotX=dataPlotX.map{Double($0) - dataPlotX.min()!}
      }
      if dataPlotY.min()!<0.0{
        dataPlotY=dataPlotY.map{abs( Double($0) + dataPlotY.min()!)}
      }
      else if dataPlotY.min()!>0.0{
        dataPlotY=dataPlotY.map{Double($0) - dataPlotY.min()!}
      }
      if dataPlotZ.min()!<0.0{
        dataPlotZ=dataPlotZ.map{abs( Double($0) + dataPlotY.min()!)}
      }
      else if dataPlotZ.min()!>0.0{
        dataPlotZ=dataPlotZ.map{Double($0) - dataPlotY.min()!}
      }
      
      dataPlotX=dataPlotX.map{Double($0) / dataPlotX.max()! }
      dataPlotY=dataPlotY.map{Double($0) / dataPlotY.max()! }
      dataPlotZ=dataPlotZ.map{Double($0) / dataPlotZ.max()! }
      
      var dataChart: [SKSpriteNode] = []
      print(dataPlotZ)
      for i in 0..<(dataOut.count/3) {
        for j in 1..<51 {
          
          //          print(dataPlotZ[i])
          //          print((Double(j-1)*1.0/50.0))
          if (Double(j-1)*1.0/50.0)<dataPlotZ[i] && dataPlotZ[i]<(Double(j)*1.0/50.0) {
            var newPCAPoint = SKSpriteNode(imageNamed: "pcaPts/pcaPts\(j)")
            newPCAPoint.position = CGPoint(x:  view.frame.width/2-100+dataPlotX[i]*200.0, y:  50+dataPlotY[i]*200.0)
            //        mazeSprites.append(mazeBlock)
            addChild(newPCAPoint)
          }
        }
      }
    }
    //      var dataDouble=[1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0,16.0,17.0,18.0,19.0,20.0]
    //      size = [4, 5]
    //      var array = emxArray_real_T(
    //        data: &dataDouble,
    //        size: &size,
    //        allocatedSize: 20,
    //        numDimensions: 2,
    //        canFreeData: 10
    //      )
    ////          emxArray_real_T.init(data: UnsafeMutablePointer<Double>!, size: UnsafeMutablePointer<Int32>!, allocatedSize: Int32, numDimensions: Int32, canFreeData: boolean_T)
    //
    //      let data = UnsafeMutablePointer<emxArray_real_T>.allocate(capacity: 20)
    //      //    var dataDouble=[1.0,5.0,9.0,13.0,17.0,
    //      //                    2.0,6.0,10.0,14.0,18.0,
    //      //                    3.0,7.0,11.0,15.0,19.0,
    //      //                    4.0,8.0,12.0,16.0,20.0]
    //
    //      data.initialize(from: &array, count: 20)
    //      //    print(data)
    //
    //      let dataRed = UnsafeMutablePointer<emxArray_real_T>.allocate(capacity: 12)
    //      dataRed.initialize(from: &array, count: 12)
    //      //    print(dataRed)
    //      //    data.initialize(from: &dataDouble, count: 20)
    //      //    pcaRed(data,  dataRed)
    //      pcaRed(data, dataRed)
    //      let bufPtr1 = UnsafeBufferPointer(start: data, count: 20)
    //      let newData = Array(bufPtr1)
    //      let bufPtr2 = UnsafeBufferPointer(start: dataRed, count: 12)
    //      let newDataRed = Array(bufPtr2)
    //      var bufPtr = UnsafeBufferPointer(start: newData[0].data, count: 20)
    ////      print(Array(bufPtr))
    //      bufPtr = UnsafeBufferPointer(start: newDataRed[0].data, count: 12)
    //      print(Array(bufPtr))
    //      var dataOut=Array(bufPtr)
    //      //      struct dataPoint {
    //      //          let dim1: Double
    //      //          let dim2: Double
    //      //          let dim3: Double
    //      //      }
    //      //
    //      //      var dataChart: [dataPoint]
    //      //      for i in 0..<(MetricsAllDim1D.count-1)
    //      //      {
    //      //        dataChart.append(dataPoint(dim1: dataOut[i], dim2: dataOut[i+(MetricsAll.count/3)], dim3: dataOut[i+(2*MetricsAll.count/3)]))
    //      //      }
    //
    //
    //      var dataPlotX: [Double] = []
    //      var dataPlotY: [Double] = []
    //      var dataPlotZ: [Double] = []
    //      for i in 0..<(dataOut.count/3) {
    //        dataPlotX.append(dataOut[i])
    //        dataPlotY.append(dataOut[i+(dataOut.count/3)])
    //        dataPlotZ.append(dataOut[i+(2*dataOut.count/3)])
    //        print(i)
    //        print(i+(dataOut.count/3))
    //        print(i+(2*dataOut.count/3))
    //      }
    //      print(dataPlotX)
    //      print(dataPlotY)
    //      //let singleDayCosts = passengersInDay.map { tripCostPerDay  / Double($0) }
    //
    //      if dataPlotX.min()!<0.0{
    //          dataPlotX=dataPlotX.map{abs(dataPlotX.min()!) + Double($0)}
    //      }
    //      else if dataPlotX.min()!>0.0{
    //        dataPlotX=dataPlotX.map{dataPlotX.min()! - Double($0)}
    //      }
    //      if dataPlotY.min()!<0.0{
    //          dataPlotY=dataPlotY.map{abs(dataPlotY.min()!) + Double($0)}
    //      }
    //      else if dataPlotY.min()!>0.0{
    //        dataPlotY=dataPlotY.map{dataPlotY.min()! - Double($0)}
    //      }
    ////      if dataPlotY.min()!<0.0{
    ////          dataPlotZ=dataPlotZ.map{abs(dataPlotZ.min()!) + Double($0)}
    ////      }
    ////      else if dataPlotX.min()!>0.0{
    ////        dataPlotZ=dataPlotZ.map{dataPlotZ.min()! - Double($0)}
    ////      }
    //
    //      print(dataPlotX)
    //      print(dataPlotY)
    ////      print(dataPlotX.max())
    ////      print(dataPlotY.max())
    //      dataPlotX=dataPlotX.map{Double($0) / dataPlotX.max()! }
    //      dataPlotY=dataPlotY.map{Double($0) / dataPlotY.max()! }
    //      dataPlotZ=dataPlotZ.map{Double($0) / dataPlotZ.max()! }
    //
    //      var dataChart: [SKSpriteNode] = []
    //      for i in 0..<(dataOut.count/3) {
    //        let newPCAPoint = SKSpriteNode(imageNamed: "ball")
    //        newPCAPoint.position = CGPoint(x:  100+dataPlotX[i]*200.0, y:  100+dataPlotY[i]*200.0)
    ////        mazeSprites.append(mazeBlock)
    //        addChild(newPCAPoint)
    //      }
    //     print(dataPlotX)
    //    print(dataPlotY)
    
    // Add one for starting point
    numMazeBlocksSwiped=1
    mazeSwiped[ballPosition[0]][ballPosition[1]]=3
    ball=sprites.2
    ballPosition=sprites.1
    mazeSprites=sprites.0
//    ballGold=explode()
//    addChild(ballGold)
//    ballGold.position=ball.position
    
    // add your pan recognizer to your desired view
    if swipingMethod == 1 {
      let swipeRight = UISwipeGestureRecognizer(target: self,
                                                action: #selector(GameSceneUSNativeHawaiianAndPacificIslanderCultureMaze.swipeRight(sender:)))
      swipeRight.direction = .right
      view.addGestureRecognizer(swipeRight)
      
      let swipeLeft = UISwipeGestureRecognizer(target: self,
                                               action: #selector(GameSceneUSNativeHawaiianAndPacificIslanderCultureMaze.swipeLeft(sender:)))
      swipeLeft.direction = .left
      view.addGestureRecognizer(swipeLeft)
      
      let swipeUp = UISwipeGestureRecognizer(target: self,
                                             action: #selector(GameSceneUSNativeHawaiianAndPacificIslanderCultureMaze.swipeUp(sender:)))
      swipeUp.direction = .up
      view.addGestureRecognizer(swipeUp)
      
      let swipeDown = UISwipeGestureRecognizer(target: self,
                                               action: #selector(GameSceneUSNativeHawaiianAndPacificIslanderCultureMaze.swipeDown(sender:)))
      swipeDown.direction = .down
      view.addGestureRecognizer(swipeDown)
    } else if swipingMethod==2 {
      
      let panRecognizer = UIPanGestureRecognizer(target: self, action:  #selector(panedView))
      view.addGestureRecognizer(panRecognizer)
      
    }
    
    let wait = SKAction.wait(forDuration: 0.01)
    let updateMazeTime = SKAction.run {
      self.mazeTime = self.mazeTime+0.01;
    }
    let repeatTimeAction = SKAction.repeatForever(SKAction.sequence([wait, updateMazeTime]))
    self.run(repeatTimeAction)
    
    run(SKAction.repeatForever(
      SKAction.sequence([
        //        SKAction.run(saveMazeMetrics),
        //        SKAction.run(isSolved),
        //        SKAction.run(getLocation),
        SKAction.wait(forDuration: 0.25)
      ])
    ))
  }
  
  @objc func doubleTapped() {
    print("Doubletappeed");
    secondMazeFlag=true;
    solved=1
    saveMazeMetrics()
    let scene = GameSceneUSNativeHawaiianAndPacificIslanderCultureMaze(size: self.size)
    self.run(SKAction.fadeOut(withDuration: 0.15)){
    self.view?.presentScene(scene)
    }
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
  
  func save(_ pcaDim1: Double,_ pcaDim2: Double,_ pcaDim3: Double,_ pcaDim4: Double,_ pcaDim5: Double,_ pcaDim6: Double,_ pcaDim7: Double,_ pcaDim8: Double,_ pcaDim9: Double,_ datenum1: Double,_ lat1: Double,_ long1: Double,_ rM1: Int,_ mode1: String,_ dim1: Double,_ dim2: Double,_ dim3: Double,_ dim4: Double,_ dim5: Double,_ dim6: Double,_ dim7: Double,_ dim8: Double,_ dim9: Double,_ datenum2: Double,_ lat2: Double,_ long2: Double,_ rM2: Int) {
    guard let appDelegate =
      UIApplication.shared.delegate as? AppDelegate else {
      return
    }
    let managedContext =
      appDelegate.persistentContainer.viewContext
    let entity1 =
      NSEntityDescription.entity(forEntityName: "MetricsAll",
                                 in: managedContext)!
    let entity2 =
        NSEntityDescription.entity(forEntityName: "MetricsUSNativeHawaiianAndPacificIslanderCulture",
                                   in: managedContext)!
    let metricsAll = NSManagedObject(entity: entity1,
                                 insertInto: managedContext)
    let MetricsUSNativeHawaiianAndPacificIslanderCulture = NSManagedObject(entity: entity2,
                                   insertInto: managedContext)
    metricsAll.setValue(pcaDim1, forKeyPath: "pcaDim1")
    metricsAll.setValue(pcaDim2, forKeyPath: "pcaDim2")
    metricsAll.setValue(pcaDim3, forKeyPath: "pcaDim3")
    metricsAll.setValue(pcaDim4, forKeyPath: "pcaDim4")
    metricsAll.setValue(pcaDim5, forKeyPath: "pcaDim5")
    metricsAll.setValue(pcaDim6, forKeyPath: "pcaDim6")
    metricsAll.setValue(pcaDim7, forKeyPath: "pcaDim7")
    metricsAll.setValue(pcaDim8, forKeyPath: "pcaDim8")
    metricsAll.setValue(pcaDim9, forKeyPath: "pcaDim9")
    metricsAll.setValue(datenum1, forKeyPath: "datenum")
    metricsAll.setValue(lat1, forKeyPath: "latitude")
    metricsAll.setValue(long1, forKeyPath: "longitude")
    metricsAll.setValue(rM1, forKeyPath: "rM")
    metricsAll.setValue(mode1, forKeyPath: "mode")
    MetricsUSNativeHawaiianAndPacificIslanderCulture.setValue(dim1, forKeyPath: "dim1")
    MetricsUSNativeHawaiianAndPacificIslanderCulture.setValue(dim2, forKeyPath: "dim2")
    MetricsUSNativeHawaiianAndPacificIslanderCulture.setValue(dim3, forKeyPath: "dim3")
    MetricsUSNativeHawaiianAndPacificIslanderCulture.setValue(dim4, forKeyPath: "dim4")
    MetricsUSNativeHawaiianAndPacificIslanderCulture.setValue(dim5, forKeyPath: "dim5")
    MetricsUSNativeHawaiianAndPacificIslanderCulture.setValue(dim6, forKeyPath: "dim6")
    MetricsUSNativeHawaiianAndPacificIslanderCulture.setValue(dim7, forKeyPath: "dim7")
    MetricsUSNativeHawaiianAndPacificIslanderCulture.setValue(dim8, forKeyPath: "dim8")
    MetricsUSNativeHawaiianAndPacificIslanderCulture.setValue(dim9, forKeyPath: "dim9")
    MetricsUSNativeHawaiianAndPacificIslanderCulture.setValue(datenum2, forKeyPath: "datenum")
    MetricsUSNativeHawaiianAndPacificIslanderCulture.setValue(lat2, forKeyPath: "latitude")
    MetricsUSNativeHawaiianAndPacificIslanderCulture.setValue(long2, forKeyPath: "longitude")
    MetricsUSNativeHawaiianAndPacificIslanderCulture.setValue(rM2, forKeyPath: "rM")
    
    do {
      try managedContext.save()
//      MetricsThisMaze.append(MetricsUSNativeHawaiianAndPacificIslanderCulture)
      MetricsAll.append(metricsAll)
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
      swipingObject = try managedContext.fetch(fetchRequest1)
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
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
  
  func saveMazeMetrics() {
    //      Save It, Print It, To See If It's Saving and Loading For Each Maze
    save(metricsThisMaze[0],metricsThisMaze[1],metricsThisMaze[2],metricsThisMaze[3],metricsThisMaze[4],metricsThisMaze[5],mazeTime,Double(numMazeBlocksSwiped)/Double(numMazeBlocks),Double(numSwipes),Double(timestamp),latitude,longitude,rM,mode,
               metricsThisMaze[0],metricsThisMaze[1],metricsThisMaze[2],metricsThisMaze[3],metricsThisMaze[4],metricsThisMaze[5],mazeTime,Double(numMazeBlocksSwiped)/Double(numMazeBlocks),Double(numSwipes),Double(timestamp),latitude,longitude,rM)
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

      guard let location = locations.last, location.horizontalAccuracy >= 0 else {
          return

      }
  }
  
// / func getLocation() {
//    if solved==1 {
//      var currentLocation: CLLocation!
//      currentLocation = locManager.location
//      locManager.stopUpdatingLocation()
//
//      longitude = currentLocation.coordinate.longitude
//      latitude = currentLocation.coordinate.latitude
//      locationManager(locManager, didUpdateLocations: CLLocationManagerDelegate)
//    }
//  }
  
//  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//      userLocation = locations.last
//  }
  
  @objc func swipeRightPan(panDistPer: Double) {
    // Handle the swipe
    //print("Swiped right")
    numSwipes=numSwipes+1.0
    var ballChange: Int = 0
    var islandPointFlag=0
    var cBF: Double = 0
    var trailingIndices: [Int] = [sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1])]
    for i in 1...maze.count{
      if ballPosition[1]+i<maze.count {
        if mazeSwiped[ballPosition[0]][ballPosition[1]+i] == 0 {
          islandPointFlag=1
        }
        if mazeSwiped[ballPosition[0]][ballPosition[1]+i] == 1 && islandPointFlag==0 {
          //mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1]+i)].color = .green
          //mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1]+i)].colorBlendFactor = 0.5
//          mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1]+i)].texture = SKTexture(imageNamed: "block2s39");
          trailingIndices.append(sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1]+i))

          ballChange=i
          numMazeBlocksSwiped+=1
          mazeSwiped[ballPosition[0]][ballPosition[1]+i]=3
        }
        if mazeSwiped[ballPosition[0]][ballPosition[1]+i] == 3 && islandPointFlag==0 {
          ballChange=i
          trailingIndices.append(sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1]+i))
        }
      }
    }
    var ballPositionOld=ballPosition[0]+ballChange
    ballPosition[1]=ind2sub(size: maze.count, ind: trailingIndices.unique()[Int(round(Double(ballChange)*panDistPer))]).1
//    print(Int(round(Double(ballChange)*panDistPer)))
    let actualDuration = CGFloat(0.05)*CGFloat(ballChange)*CGFloat(panDistPer)
    var actionMove = SKAction.move(to: CGPoint(x: mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1])].position.x, y: mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1])].position.y), duration: TimeInterval(actualDuration))
//    let wait = SKAction.wait(forDuration: CGFloat(0.05)*CGFloat(ballChange)*CGFloat(panDistPer))
//    var endExplosion = SKAction.run {
//      var tempEx = self.explode()
//      tempEx.particlePosition = CGPoint(x: self.mazeSprites[self.sub2ind(size: self.maze.count,xInd: self.ballPosition[0],yInd: self.ballPosition[1])].position.x, y: self.mazeSprites[self.sub2ind(size: self.maze.count,xInd: self.ballPosition[0],yInd: self.ballPosition[1])].position.y)
//      var fadeOut = SKAction.fadeAlpha(to: 0.0, duration: CGFloat(1))
//      tempEx.run(fadeOut){
//        tempEx.removeFromParent()
//      }
//    }
//    let explodeSequence=SKAction.sequence([wait, endExplosion])
//        self.run(explodeSequence)
//    print(ball.position)
//    print(ballGold.position)
    ball.run(SKAction.sequence([actionMove]))
//    ballGold.run(SKAction.sequence([actionMove]))
    for i in 0...Int(round(panDistPer*Double(ballChange))){
      let wait = SKAction.wait(forDuration: CGFloat(0.05*Double(i)))
      var drawTrailing = SKAction.run {
          self.mazeSprites[trailingIndices.unique()[i]].texture = SKTexture(imageNamed: "block2s39");
          if i<Int(round(panDistPer*Double(ballChange))) {
              var  trailingG = SKSpriteNode(imageNamed: "ballsBg")
              trailingG.position=self.mazeSprites[trailingIndices.unique()[i]].position
              trailingG.zPosition=200
              
              cBF = (0.5*Double(self.numMazeBlocksSwiped)/Double(self.numMazeBlocks))+0.5*(Double(self.numLandedNodesCorners)/Double(self.totNumNodesCorners))
              var gray = SKAction.colorize(with: UIColor.white, colorBlendFactor: cBF, duration: 0.0)
              var fadeOut = SKAction.fadeAlpha(to: 0.0, duration: CGFloat(0.25*panDistPer*Double(ballChange))/1.5)
              self.addChild(trailingG)
              trailingG.run(gray)
              trailingG.run(fadeOut){
                  trailingG.removeFromParent()
              }
          }
        //        let scale = SKAction.scale(to: (1.0-actualDuration*CGFloat(i/(ballChange))), duration: 0.0)
      }
      var landedNodesCorners=trailingIndices.unique()
      if self.numElNodesCorners.contains(landedNodesCorners[i]) {
        print("Add 1, Hit Node or Corner")
        self.numLandedNodesCorners+=1
        self.numElNodesCorners=self.numElNodesCorners.filter(){$0 != landedNodesCorners[i]}
      }
      let sequence = SKAction.sequence([wait, drawTrailing])
      self.run(sequence)
//      if i==Int(round(panDistPer*Double(ballChange))) {
//        var tempEx = explode()
//        tempEx.particlePosition = mazeSprites[trailingIndices.unique()[i]].position
//        var fadeOut = SKAction.fadeAlpha(to: 0.0, duration: CGFloat(1))
//        self.addChild(tempEx)
//        tempEx.run(fadeOut){
//          tempEx.removeFromParent()
//        }
//      }
    }
    print(cBF)
    if numMazeBlocks==numMazeBlocksSwiped {
        solved=1
    }
    
  }
  
  @objc func swipeLeftPan(panDistPer: Double) {
    // Handle the swipe
    //print("Swiped left")
    numSwipes=numSwipes+1.0
    var ballChange: Int = 0
    var islandPointFlag=0;
    var cBF: Double = 0
    var trailingIndices: [Int] = [sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1])]
    for i in 1...maze.count{
      if ballPosition[1]-i>(-1) {
        if mazeSwiped[ballPosition[0]][ballPosition[1]-i] == 0{
          islandPointFlag=1
        }
        if mazeSwiped[ballPosition[0]][ballPosition[1]-i] == 1 && islandPointFlag==0{
         // mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1]-i)].color = .green
          //mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1]-i)].colorBlendFactor = 0.5
          trailingIndices.append(sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1]-i))
//          mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1]-i)].texture = SKTexture(imageNamed: "block2s39");
          ballChange=i
          numMazeBlocksSwiped+=1
          mazeSwiped[ballPosition[0]][ballPosition[1]-i] = 3
        }
        if mazeSwiped[ballPosition[0]][ballPosition[1]-i] == 3 && islandPointFlag==0 {
          ballChange=i
          trailingIndices.append(sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1]-i))
        }
      }
      
    }
    var ballPositionOld=ballPosition[0]+ballChange
    ballPosition[1]=ind2sub(size: maze.count, ind: trailingIndices.unique()[Int(round(Double(ballChange)*panDistPer))]).1
    let actualDuration = CGFloat(0.05)*CGFloat(ballChange)*CGFloat(panDistPer)
    var actionMove = SKAction.move(to: CGPoint(x: mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1])].position.x, y: mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1])].position.y), duration: TimeInterval(actualDuration))
//    let waitExplode = SKAction.wait(forDuration: CGFloat(0.05)*CGFloat(ballChange)*CGFloat(panDistPer))
//    var endExplosion = SKAction.run {
//      var tempEx = self.explode()
//      tempEx.particlePosition = CGPoint(x: self.mazeSprites[self.sub2ind(size: self.maze.count,xInd: self.ballPosition[0],yInd: self.ballPosition[1])].position.x, y: self.mazeSprites[self.sub2ind(size: self.maze.count,xInd: self.ballPosition[0],yInd: self.ballPosition[1])].position.y)
//      var fadeOut = SKAction.fadeAlpha(to: 0.0, duration: CGFloat(1))
//      tempEx.run(fadeOut){
//        tempEx.removeFromParent()
//      }
//    }
//    let explodeSequence=SKAction.sequence([waitExplode, endExplosion])
//        self.run(explodeSequence)
    ball.run(SKAction.sequence([actionMove]))
//    ballGold.run(SKAction.sequence([actionMove]))
    for i in 0...Int(round(panDistPer*Double(ballChange))){
      let wait = SKAction.wait(forDuration: CGFloat(0.05*Double(i)))
      print(trailingIndices.unique()[i])
      var drawTrailing = SKAction.run {
          self.mazeSprites[trailingIndices.unique()[i]].texture = SKTexture(imageNamed: "block2s39");
          if i<Int(round(panDistPer*Double(ballChange))) {
              var  trailingG = SKSpriteNode(imageNamed: "ballsBg")
              trailingG.position=self.mazeSprites[trailingIndices.unique()[i]].position
              trailingG.zPosition=200
              
              cBF = (0.5*Double(self.numMazeBlocksSwiped)/Double(self.numMazeBlocks))+0.5*(Double(self.numLandedNodesCorners)/Double(self.totNumNodesCorners))
              var gray = SKAction.colorize(with: UIColor.white, colorBlendFactor: cBF, duration: 0.0)
              var fadeOut = SKAction.fadeAlpha(to: 0.0, duration: CGFloat(0.25*panDistPer*Double(ballChange))/1.5)
              self.addChild(trailingG)
              trailingG.run(gray)
              trailingG.run(fadeOut){
                  trailingG.removeFromParent()
              }
          }
        //        let scale = SKAction.scale(to: (1.0-actualDuration*CGFloat(i/(ballChange))), duration: 0.0)
        }
      var landedNodesCorners=trailingIndices.unique()
      if self.numElNodesCorners.contains(landedNodesCorners[i]) {
        print("Add 1, Hit Node or Corner")
        numLandedNodesCorners+=1
        self.numElNodesCorners=self.numElNodesCorners.filter(){$0 != landedNodesCorners[i]}
      }
      let sequence = SKAction.sequence([wait, drawTrailing])
      self.run(sequence)
//      if i==Int(round(panDistPer*Double(ballChange))) {
//      var tempEx = explode()
//        tempEx.position = mazeSprites[trailingIndices.unique()[i]].position
//        var fadeOut = SKAction.fadeAlpha(to: 0.0, duration: CGFloat(1))
//          self.addChild(tempEx)
//          tempEx.run(fadeOut){
//            tempEx.removeFromParent()
//          }
//      }
      }
    if numMazeBlocks==numMazeBlocksSwiped {
        solved=1
    }
    
  }
  
  @objc func swipeUpPan(panDistPer: Double) {
    // Handle the swipe
    //print("Swiped up")
    numSwipes=numSwipes+1.0
    var ballChange: Int = 0
    var islandPointFlag=0;
    var cBF: Double = 0
    var trailingIndices: [Int] = [sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1])]
    for i in 1...maze.count{
      if ballPosition[0]-i>(-1) {
        if mazeSwiped[ballPosition[0]-i][ballPosition[1]] == 0 {
          islandPointFlag=1
        }
          if mazeSwiped[ballPosition[0]-i][ballPosition[1]] == 1 && islandPointFlag==0 {
//          mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0]-i,yInd: ballPosition[1])].color = .green
//          mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0]-i,yInd: ballPosition[1])].colorBlendFactor = 0.5
//            mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0]-i,yInd: ballPosition[1])].texture = SKTexture(imageNamed: "block2s39");
          ballChange=i
            trailingIndices.append(sub2ind(size: maze.count,xInd: ballPosition[0]-i,yInd: ballPosition[1]))
          numMazeBlocksSwiped+=1
            mazeSwiped[ballPosition[0]-i][ballPosition[1]] = 3
        }
        if mazeSwiped[ballPosition[0]-i][ballPosition[1]] == 3 && islandPointFlag==0 {
          ballChange=i
          trailingIndices.append(sub2ind(size: maze.count,xInd: ballPosition[0]-i,yInd: ballPosition[1]))
        }
      }
    }
    var ballPositionOld=ballPosition[0]+ballChange
    ballPosition[0]=ind2sub(size: maze.count, ind: trailingIndices.unique()[Int(round(Double(ballChange)*panDistPer))]).0
    let actualDuration = CGFloat(0.05)*CGFloat(ballChange)*CGFloat(panDistPer)
    var actionMove = SKAction.move(to: CGPoint(x: mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1])].position.x, y: mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1])].position.y), duration: TimeInterval(actualDuration))
    let actionMoveDone = SKAction.removeFromParent()
    let waitExplode = SKAction.wait(forDuration: 5.0)
//    var endExplosion = SKAction.run {
//      var tempEx = self.explode()
//      tempEx.particlePosition = CGPoint(x: self.mazeSprites[self.sub2ind(size: self.maze.count,xInd: self.ballPosition[0],yInd: self.ballPosition[1])].position.x, y: self.mazeSprites[self.sub2ind(size: self.maze.count,xInd: self.ballPosition[0],yInd: self.ballPosition[1])].position.y)
//      var fadeOut = SKAction.fadeAlpha(to: 0.0, duration: CGFloat(1))
//      tempEx.run(fadeOut){
//        tempEx.removeFromParent()
//      }
//    }
//    let explodeSequence=SKAction.sequence([waitExplode, endExplosion])
//    self.run(explodeSequence)
    
    ball.run(SKAction.sequence([actionMove]))
//    ballGold.run(SKAction.sequence([actionMove]))
    print(ballChange)
    print(trailingIndices)
    for i in 0...Int(round(panDistPer*Double(ballChange))){
      let wait = SKAction.wait(forDuration: CGFloat(0.05*Double(i)))
      print(trailingIndices.unique()[i])
      var drawTrailing = SKAction.run {
          self.mazeSprites[trailingIndices.unique()[i]].texture = SKTexture(imageNamed: "block2s39");
          if i<Int(round(panDistPer*Double(ballChange))) {
              var  trailingG = SKSpriteNode(imageNamed: "ballsBg")
              trailingG.position=self.mazeSprites[trailingIndices.unique()[i]].position
              trailingG.zPosition=200
              
              cBF = (0.5*Double(self.numMazeBlocksSwiped)/Double(self.numMazeBlocks))+0.5*(Double(self.numLandedNodesCorners)/Double(self.totNumNodesCorners))
              var gray = SKAction.colorize(with: UIColor.white, colorBlendFactor: cBF, duration: 0.0)
              var fadeOut = SKAction.fadeAlpha(to: 0.0, duration: CGFloat(0.25*panDistPer*Double(ballChange))/1.5)
              self.addChild(trailingG)
              trailingG.run(gray)
              trailingG.run(fadeOut){
                  trailingG.removeFromParent()
              }
          }
        //        let scale = SKAction.scale(to: (1.0-actualDuration*CGFloat(i/(ballChange))), duration: 0.0)
        }
      var landedNodesCorners=trailingIndices.unique()
      if self.numElNodesCorners.contains(landedNodesCorners[i]) {
        print("Add 1, Hit Node or Corner")
        numLandedNodesCorners+=1
        self.numElNodesCorners=self.numElNodesCorners.filter(){$0 != landedNodesCorners[i]}
      }
      let sequence = SKAction.sequence([wait, drawTrailing])
      self.run(sequence)
//      if i==Int(round(panDistPer*Double(ballChange))) {
//      var tempEx = explode()
//        tempEx.position = mazeSprites[trailingIndices.unique()[i]].position
//        
//        tempEx.zPosition=200
//        var fadeOut = SKAction.fadeAlpha(to: 0.0, duration: CGFloat(1))
//          self.addChild(tempEx)
//          tempEx.run(fadeOut){
//            tempEx.removeFromParent()
//          }
//      }
      }
    if numMazeBlocks==numMazeBlocksSwiped {
        solved=1
    }
  }
    
  
  @objc func swipeRight(sender: UISwipeGestureRecognizer) {
    // Handle the swipe
    //print("Swiped right")
    var panDistPer = 1.0
    numSwipes=numSwipes+1.0
    var ballChange: Int = 0
    var islandPointFlag=0
    var cBF: Double = 0
    var trailingIndices: [Int] = [sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1])]
    for i in 1...maze.count{
      if ballPosition[1]+i<maze.count {
        if mazeSwiped[ballPosition[0]][ballPosition[1]+i] == 0 {
          islandPointFlag=1
        }
        if mazeSwiped[ballPosition[0]][ballPosition[1]+i] == 1 && islandPointFlag==0 {
          //mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1]+i)].color = .green
          //mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1]+i)].colorBlendFactor = 0.5
//          mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1]+i)].texture = SKTexture(imageNamed: "block2s39");
          trailingIndices.append(sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1]+i))

          ballChange=i
          numMazeBlocksSwiped+=1
          mazeSwiped[ballPosition[0]][ballPosition[1]+i]=3
        }
        if mazeSwiped[ballPosition[0]][ballPosition[1]+i] == 3 && islandPointFlag==0 {
          ballChange=i
          trailingIndices.append(sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1]+i))
        }
      }
    }
    var ballPositionOld=ballPosition[0]+ballChange
    ballPosition[1]=ind2sub(size: maze.count, ind: trailingIndices.unique()[Int(round(Double(ballChange)*panDistPer))]).1
//    print(Int(round(Double(ballChange)*panDistPer)))
    let actualDuration = CGFloat(0.05)*CGFloat(ballChange)*CGFloat(panDistPer)
    var actionMove = SKAction.move(to: CGPoint(x: mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1])].position.x, y: mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1])].position.y), duration: TimeInterval(actualDuration))
    let wait = SKAction.wait(forDuration: CGFloat(0.05)*CGFloat(ballChange)*CGFloat(panDistPer))
//    var endExplosion = SKAction.run {
//      var tempEx = self.explode()
//      tempEx.particlePosition = CGPoint(x: self.mazeSprites[self.sub2ind(size: self.maze.count,xInd: self.ballPosition[0],yInd: self.ballPosition[1])].position.x, y: self.mazeSprites[self.sub2ind(size: self.maze.count,xInd: self.ballPosition[0],yInd: self.ballPosition[1])].position.y)
//      var fadeOut = SKAction.fadeAlpha(to: 0.0, duration: CGFloat(1))
//      tempEx.run(fadeOut){
//        tempEx.removeFromParent()
//      }
//    }
//    let explodeSequence=SKAction.sequence([wait, endExplosion])
//        self.run(explodeSequence)
//    print(ball.position)
//    print(ballGold.position)
    ball.run(SKAction.sequence([actionMove]))
//    ballGold.run(SKAction.sequence([actionMove]))
    for i in 0...Int(round(panDistPer*Double(ballChange))){
      let wait = SKAction.wait(forDuration: CGFloat(0.05*Double(i)))
        var drawTrailing = SKAction.run {
            self.mazeSprites[trailingIndices.unique()[i]].texture = SKTexture(imageNamed: "block2s39");
            if i<Int(round(panDistPer*Double(ballChange))) {
                var  trailingG = SKSpriteNode(imageNamed: "ballsBg")
                trailingG.position=self.mazeSprites[trailingIndices.unique()[i]].position
                trailingG.zPosition=200
                
                cBF = (0.5*Double(self.numMazeBlocksSwiped)/Double(self.numMazeBlocks))+0.5*(Double(self.numLandedNodesCorners)/Double(self.totNumNodesCorners))
                var gray = SKAction.colorize(with: UIColor.white, colorBlendFactor: cBF, duration: 0.0)
                var fadeOut = SKAction.fadeAlpha(to: 0.0, duration: CGFloat(0.25*panDistPer*Double(ballChange))/1.5)
                self.addChild(trailingG)
                trailingG.run(gray)
                trailingG.run(fadeOut){
                trailingG.removeFromParent()
            }
        }
        //        let scale = SKAction.scale(to: (1.0-actualDuration*CGFloat(i/(ballChange))), duration: 0.0)
      }
      var landedNodesCorners=trailingIndices.unique()
      if self.numElNodesCorners.contains(landedNodesCorners[i]) {
        print("Add 1, Hit Node or Corner")
        self.numLandedNodesCorners+=1
        self.numElNodesCorners=self.numElNodesCorners.filter(){$0 != landedNodesCorners[i]}
      }
      let sequence = SKAction.sequence([wait, drawTrailing])
      self.run(sequence)
//      if i==Int(round(panDistPer*Double(ballChange))) {
//        var tempEx = explode()
//        tempEx.particlePosition = mazeSprites[trailingIndices.unique()[i]].position
//        var fadeOut = SKAction.fadeAlpha(to: 0.0, duration: CGFloat(1))
//        self.addChild(tempEx)
//        tempEx.run(fadeOut){
//          tempEx.removeFromParent()
//        }
//      }
    }
    print(cBF)
    if numMazeBlocks==numMazeBlocksSwiped {
        solved=1
    }
    
  }
  @objc func swipeLeft(sender: UISwipeGestureRecognizer) {
    // Handle the swipe
    //print("Swiped left")
    var panDistPer = 1.0
    numSwipes=numSwipes+1.0
    var ballChange: Int = 0
    var islandPointFlag=0;
    var cBF: Double = 0
    var trailingIndices: [Int] = [sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1])]
    for i in 1...maze.count{
      if ballPosition[1]-i>(-1) {
        if mazeSwiped[ballPosition[0]][ballPosition[1]-i] == 0{
          islandPointFlag=1
        }
        if mazeSwiped[ballPosition[0]][ballPosition[1]-i] == 1 && islandPointFlag==0{
         // mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1]-i)].color = .green
          //mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1]-i)].colorBlendFactor = 0.5
          trailingIndices.append(sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1]-i))
//          mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1]-i)].texture = SKTexture(imageNamed: "block2s39");
          ballChange=i
          numMazeBlocksSwiped+=1
          mazeSwiped[ballPosition[0]][ballPosition[1]-i] = 3
        }
        if mazeSwiped[ballPosition[0]][ballPosition[1]-i] == 3 && islandPointFlag==0 {
          ballChange=i
          trailingIndices.append(sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1]-i))
        }
      }
      
    }
    var ballPositionOld=ballPosition[0]+ballChange
    ballPosition[1]=ind2sub(size: maze.count, ind: trailingIndices.unique()[Int(round(Double(ballChange)*panDistPer))]).1
    let actualDuration = CGFloat(0.05)*CGFloat(ballChange)*CGFloat(panDistPer)
    var actionMove = SKAction.move(to: CGPoint(x: mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1])].position.x, y: mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1])].position.y), duration: TimeInterval(actualDuration))
    let waitExplode = SKAction.wait(forDuration: CGFloat(0.05)*CGFloat(ballChange)*CGFloat(panDistPer))
//    var endExplosion = SKAction.run {
//      var tempEx = self.explode()
//      tempEx.particlePosition = CGPoint(x: self.mazeSprites[self.sub2ind(size: self.maze.count,xInd: self.ballPosition[0],yInd: self.ballPosition[1])].position.x, y: self.mazeSprites[self.sub2ind(size: self.maze.count,xInd: self.ballPosition[0],yInd: self.ballPosition[1])].position.y)
//      var fadeOut = SKAction.fadeAlpha(to: 0.0, duration: CGFloat(1))
//      tempEx.run(fadeOut){
//        tempEx.removeFromParent()
//      }
//    }
//    let explodeSequence=SKAction.sequence([waitExplode, endExplosion])
//        self.run(explodeSequence)
    ball.run(SKAction.sequence([actionMove]))
//    ballGold.run(SKAction.sequence([actionMove]))
    for i in 0...Int(round(panDistPer*Double(ballChange))){
      let wait = SKAction.wait(forDuration: CGFloat(0.05*Double(i)))
      print(trailingIndices.unique()[i])
      var drawTrailing = SKAction.run {
          self.mazeSprites[trailingIndices.unique()[i]].texture = SKTexture(imageNamed: "block2s39");
          if i<Int(round(panDistPer*Double(ballChange))) {
              var  trailingG = SKSpriteNode(imageNamed: "ballsBg")
              trailingG.position=self.mazeSprites[trailingIndices.unique()[i]].position
              trailingG.zPosition=200
              
              cBF = (0.5*Double(self.numMazeBlocksSwiped)/Double(self.numMazeBlocks))+0.5*(Double(self.numLandedNodesCorners)/Double(self.totNumNodesCorners))
              var gray = SKAction.colorize(with: UIColor.white, colorBlendFactor: cBF, duration: 0.0)
              var fadeOut = SKAction.fadeAlpha(to: 0.0, duration: CGFloat(0.25*panDistPer*Double(ballChange))/1.5)
              self.addChild(trailingG)
              trailingG.run(gray)
              trailingG.run(fadeOut){
                  trailingG.removeFromParent()
              }
          }
        //        let scale = SKAction.scale(to: (1.0-actualDuration*CGFloat(i/(ballChange))), duration: 0.0)
        }
      var landedNodesCorners=trailingIndices.unique()
      if self.numElNodesCorners.contains(landedNodesCorners[i]) {
        print("Add 1, Hit Node or Corner")
        numLandedNodesCorners+=1
        self.numElNodesCorners=self.numElNodesCorners.filter(){$0 != landedNodesCorners[i]}
      }
      let sequence = SKAction.sequence([wait, drawTrailing])
      self.run(sequence)
//      if i==Int(round(panDistPer*Double(ballChange))) {
//      var tempEx = explode()
//        tempEx.position = mazeSprites[trailingIndices.unique()[i]].position
//        var fadeOut = SKAction.fadeAlpha(to: 0.0, duration: CGFloat(1))
//          self.addChild(tempEx)
//          tempEx.run(fadeOut){
//            tempEx.removeFromParent()
//          }
//      }
      }
    if numMazeBlocks==numMazeBlocksSwiped {
        solved=1
    }
    
  }
  @objc func swipeUp(sender: UISwipeGestureRecognizer) {
    // Handle the swipe
    //print("Swiped up")
    var panDistPer = 1.0
    numSwipes=numSwipes+1.0
    var ballChange: Int = 0
    var islandPointFlag=0;
    var cBF: Double = 0
    var trailingIndices: [Int] = [sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1])]
    for i in 1...maze.count{
      if ballPosition[0]-i>(-1) {
        if mazeSwiped[ballPosition[0]-i][ballPosition[1]] == 0 {
          islandPointFlag=1
        }
          if mazeSwiped[ballPosition[0]-i][ballPosition[1]] == 1 && islandPointFlag==0 {
//          mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0]-i,yInd: ballPosition[1])].color = .green
//          mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0]-i,yInd: ballPosition[1])].colorBlendFactor = 0.5
//            mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0]-i,yInd: ballPosition[1])].texture = SKTexture(imageNamed: "block2s39");
          ballChange=i
            trailingIndices.append(sub2ind(size: maze.count,xInd: ballPosition[0]-i,yInd: ballPosition[1]))
          numMazeBlocksSwiped+=1
            mazeSwiped[ballPosition[0]-i][ballPosition[1]] = 3
        }
        if mazeSwiped[ballPosition[0]-i][ballPosition[1]] == 3 && islandPointFlag==0 {
          ballChange=i
          trailingIndices.append(sub2ind(size: maze.count,xInd: ballPosition[0]-i,yInd: ballPosition[1]))
        }
      }
    }
    var ballPositionOld=ballPosition[0]+ballChange
    ballPosition[0]=ind2sub(size: maze.count, ind: trailingIndices.unique()[Int(round(Double(ballChange)*panDistPer))]).0
    let actualDuration = CGFloat(0.05)*CGFloat(ballChange)*CGFloat(panDistPer)
    var actionMove = SKAction.move(to: CGPoint(x: mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1])].position.x, y: mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1])].position.y), duration: TimeInterval(actualDuration))
    let actionMoveDone = SKAction.removeFromParent()
//    let waitExplode = SKAction.wait(forDuration: 5.0)
//    var endExplosion = SKAction.run {
//      var tempEx = self.explode()
//      tempEx.particlePosition = CGPoint(x: self.mazeSprites[self.sub2ind(size: self.maze.count,xInd: self.ballPosition[0],yInd: self.ballPosition[1])].position.x, y: self.mazeSprites[self.sub2ind(size: self.maze.count,xInd: self.ballPosition[0],yInd: self.ballPosition[1])].position.y)
//      var fadeOut = SKAction.fadeAlpha(to: 0.0, duration: CGFloat(1))
//      tempEx.run(fadeOut){
//        tempEx.removeFromParent()
//      }
//    }
//    let explodeSequence=SKAction.sequence([waitExplode, endExplosion])
//    self.run(explodeSequence)
    
    ball.run(SKAction.sequence([actionMove]))
//    ballGold.run(SKAction.sequence([actionMove]))
    print(ballChange)
    print(trailingIndices)
    for i in 0...Int(round(panDistPer*Double(ballChange))){
      let wait = SKAction.wait(forDuration: CGFloat(0.05*Double(i)))
      print(trailingIndices.unique()[i])
      var drawTrailing = SKAction.run {
          self.mazeSprites[trailingIndices.unique()[i]].texture = SKTexture(imageNamed: "block2s39");
          if i<Int(round(panDistPer*Double(ballChange))) {
              var  trailingG = SKSpriteNode(imageNamed: "ballsBg")
              trailingG.position=self.mazeSprites[trailingIndices.unique()[i]].position
              trailingG.zPosition=200
              
              cBF = (0.5*Double(self.numMazeBlocksSwiped)/Double(self.numMazeBlocks))+0.5*(Double(self.numLandedNodesCorners)/Double(self.totNumNodesCorners))
              var gray = SKAction.colorize(with: UIColor.white, colorBlendFactor: cBF, duration: 0.0)
              var fadeOut = SKAction.fadeAlpha(to: 0.0, duration: CGFloat(0.25*panDistPer*Double(ballChange))/1.5)
              self.addChild(trailingG)
              trailingG.run(gray)
              trailingG.run(fadeOut){
                  trailingG.removeFromParent()
              }}

        //        let scale = SKAction.scale(to: (1.0-actualDuration*CGFloat(i/(ballChange))), duration: 0.0)
        }
      var landedNodesCorners=trailingIndices.unique()
      if self.numElNodesCorners.contains(landedNodesCorners[i]) {
        print("Add 1, Hit Node or Corner")
        numLandedNodesCorners+=1
        self.numElNodesCorners=self.numElNodesCorners.filter(){$0 != landedNodesCorners[i]}
      }
      let sequence = SKAction.sequence([wait, drawTrailing])
      self.run(sequence)
//      if i==Int(round(panDistPer*Double(ballChange))) {
//      var tempEx = explode()
//        tempEx.position = mazeSprites[trailingIndices.unique()[i]].position
//        
//        tempEx.zPosition=200
//        var fadeOut = SKAction.fadeAlpha(to: 0.0, duration: CGFloat(1))
//          self.addChild(tempEx)
//          tempEx.run(fadeOut){
//            tempEx.removeFromParent()
//          }
//      }
      }
    if numMazeBlocks==numMazeBlocksSwiped {
        solved=1
    }
  }
  
 @objc func swipeDown(sender: UISwipeGestureRecognizer) {
   var panDistPer = 1.0
   var ballChange: Int = 0
   var islandPointFlag=0;
   numSwipes=numSwipes+1.0
   var cBF: Double = 0
   var trailingIndices: [Int] = [sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1])]
   for i in 1...maze.count{
     if ballPosition[0]+i<maze.count {
       if mazeSwiped[ballPosition[0]+i][ballPosition[1]] == 0 {
         islandPointFlag=1
       }
       if mazeSwiped[ballPosition[0]+i][ballPosition[1]] == 1 && islandPointFlag==0{
         //mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0]+i,yInd: ballPosition[1])].color = .green
//          mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0]+i,yInd: ballPosition[1])].texture = SKTexture(imageNamed: "block2s39");
         ballChange=i
         trailingIndices.append(sub2ind(size: maze.count,xInd: ballPosition[0]+i,yInd: ballPosition[1]))
         numMazeBlocksSwiped+=1
         mazeSwiped[ballPosition[0]+i][ballPosition[1]] = 3
       }
       if mazeSwiped[ballPosition[0]+i][ballPosition[1]] == 3 && islandPointFlag==0 {
         ballChange=i
         trailingIndices.append(sub2ind(size: maze.count,xInd: ballPosition[0]+i,yInd: ballPosition[1]))
       }
     }
   }
   var ballPositionOld=ballPosition[0]+ballChange
   ballPosition[0]=ind2sub(size: maze.count, ind: trailingIndices.unique()[Int(round(Double(ballChange)*panDistPer))]).0
   let actualDuration = CGFloat(0.05)*CGFloat(ballChange)*CGFloat(panDistPer)
   var actionMove = SKAction.move(to: CGPoint(x: mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1])].position.x, y: mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1])].position.y), duration: TimeInterval(actualDuration))
   
   let actionMoveDone = SKAction.removeFromParent()
   let waitExplode = SKAction.wait(forDuration: CGFloat(0.05)*CGFloat(ballChange)*CGFloat(panDistPer))
//   var endExplosion = SKAction.run {
//     var tempEx = self.explode()
//     tempEx.particlePosition = CGPoint(x: self.mazeSprites[self.sub2ind(size: self.maze.count,xInd: self.ballPosition[0],yInd: self.ballPosition[1])].position.x, y: self.mazeSprites[self.sub2ind(size: self.maze.count,xInd: self.ballPosition[0],yInd: self.ballPosition[1])].position.y)
//     var fadeOut = SKAction.fadeAlpha(to: 0.0, duration: CGFloat(1))
//     tempEx.run(fadeOut){
//       tempEx.removeFromParent()
//     }
//   }
//   let explodeSequence=SKAction.sequence([waitExplode, endExplosion])
//       self.run(explodeSequence)
       ball.run(SKAction.sequence([actionMove]))
//    ballGold.run(SKAction.sequence([actionMove]))
   //      print(ballChange)
   //      print(trailingIndices)
   for i in 0...Int(round(panDistPer*Double(ballChange))){
     let wait = SKAction.wait(forDuration: CGFloat(0.05*Double(i)))
     //        print(trailingIndices.unique()[i])
     var drawTrailing = SKAction.run {
         self.mazeSprites[trailingIndices.unique()[i]].texture = SKTexture(imageNamed: "block2s39");
         if i<Int(round(panDistPer*Double(ballChange))) {
             var  trailingG = SKSpriteNode(imageNamed: "ballsBg")
             trailingG.position=self.mazeSprites[trailingIndices.unique()[i]].position
             trailingG.zPosition=200
             
             cBF = (0.5*Double(self.numMazeBlocksSwiped)/Double(self.numMazeBlocks))+0.5*(Double(self.numLandedNodesCorners)/Double(self.totNumNodesCorners))
             var gray = SKAction.colorize(with: UIColor.white, colorBlendFactor: cBF, duration: 0.0)
             var fadeOut = SKAction.fadeAlpha(to: 0.0, duration: CGFloat(0.25*panDistPer*Double(ballChange))/1.5)
             self.addChild(trailingG)
             trailingG.run(gray)
             trailingG.run(fadeOut){
                 trailingG.removeFromParent()
             }
         }
       //        let scale = SKAction.scale(to: (1.0-actualDuration*CGFloat(i/(ballChange))), duration: 0.0)
     }
     var landedNodesCorners=trailingIndices.unique()
     if self.numElNodesCorners.contains(landedNodesCorners[i]) {
       print("Add 1, Hit Node or Corner")
       numLandedNodesCorners+=1
       self.numElNodesCorners=self.numElNodesCorners.filter(){$0 != landedNodesCorners.unique()[i]}
     }
     let sequence = SKAction.sequence([wait, drawTrailing])
     self.run(sequence)
//     if i==Int(round(panDistPer*Double(ballChange))) {
//     var tempEx = explode()
//       tempEx.position = mazeSprites[trailingIndices.unique()[i]].position
//         var fadeOut = SKAction.fadeAlpha(to: 0.0, duration: CGFloat(1))
//         self.addChild(tempEx)
//         tempEx.run(fadeOut){
//           tempEx.removeFromParent()
//         }
//     }
   }
   print(cBF)
   if numMazeBlocks==numMazeBlocksSwiped {
     solved=1
   }
   
 }
  
  func swipeDownPan(panDistPer: Double) {
    var ballChange: Int = 0
    var islandPointFlag=0;
    numSwipes=numSwipes+1.0
    var cBF: Double = 0
    var trailingIndices: [Int] = [sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1])]
    for i in 1...maze.count{
      if ballPosition[0]+i<maze.count {
        if mazeSwiped[ballPosition[0]+i][ballPosition[1]] == 0 {
          islandPointFlag=1
        }
        if mazeSwiped[ballPosition[0]+i][ballPosition[1]] == 1 && islandPointFlag==0{
          //mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0]+i,yInd: ballPosition[1])].color = .green
//          mazeSprites[sub2ind(size: maze.count,xInd: ballPosition[0]+i,yInd: ballPosition[1])].texture = SKTexture(imageNamed: "block2s39");
          ballChange=i
          trailingIndices.append(sub2ind(size: maze.count,xInd: ballPosition[0]+i,yInd: ballPosition[1]))
          numMazeBlocksSwiped+=1
          mazeSwiped[ballPosition[0]+i][ballPosition[1]] = 3
        }
        if mazeSwiped[ballPosition[0]+i][ballPosition[1]] == 3 && islandPointFlag==0 {
          ballChange=i
          trailingIndices.append(sub2ind(size: maze.count,xInd: ballPosition[0]+i,yInd: ballPosition[1]))
        }
      }
    }
    var ballPositionOld=ballPosition[0]+ballChange
    ballPosition[0]=ind2sub(size: self.maze.count, ind: trailingIndices.unique()[Int(round(Double(ballChange)*panDistPer))]).0
    let actualDuration = CGFloat(0.05)*CGFloat(ballChange)*CGFloat(panDistPer)
    var actionMove = SKAction.move(to: CGPoint(x: self.mazeSprites[sub2ind(size: maze.count,xInd: self.ballPosition[0],yInd: self.ballPosition[1])].position.x, y: self.mazeSprites[sub2ind(size: self.maze.count,xInd: ballPosition[0],yInd: self.ballPosition[1])].position.y), duration: TimeInterval(actualDuration))
    
    let actionMoveDone = SKAction.removeFromParent()
    let waitExplode = SKAction.wait(forDuration: CGFloat(0.05)*CGFloat(ballChange)*CGFloat(panDistPer))
//    var endExplosion = SKAction.run {
//      var tempEx = self.explode()
//      tempEx.particlePosition = CGPoint(x: self.mazeSprites[self.sub2ind(size: self.maze.count,xInd: self.ballPosition[0],yInd: self.ballPosition[1])].position.x, y: self.mazeSprites[self.sub2ind(size: self.maze.count,xInd: self.ballPosition[0],yInd: self.ballPosition[1])].position.y)
//      var fadeOut = SKAction.fadeAlpha(to: 0.0, duration: CGFloat(1))
//      tempEx.run(fadeOut){
//        tempEx.removeFromParent()
//      }
//    }
//    let explodeSequence=SKAction.sequence([waitExplode, endExplosion])
//        self.run(explodeSequence)
        ball.run(SKAction.sequence([actionMove]))
//    ballGold.run(SKAction.sequence([actionMove]))
    //      print(ballChange)
    //      print(trailingIndices)
    for i in 0...Int(round(panDistPer*Double(ballChange))){
      let wait = SKAction.wait(forDuration: CGFloat(0.05*Double(i)))
      //        print(trailingIndices.unique()[i])
      var drawTrailing = SKAction.run {
          self.mazeSprites[trailingIndices.unique()[i]].texture = SKTexture(imageNamed: "block2s39");
          if i<Int(round(panDistPer*Double(ballChange))) {
              var  trailingG = SKSpriteNode(imageNamed: "ballsBg")
              trailingG.position=self.mazeSprites[trailingIndices.unique()[i]].position
              trailingG.zPosition=200

              cBF = (0.5*Double(self.numMazeBlocksSwiped)/Double(self.numMazeBlocks))+0.5*(Double(self.numLandedNodesCorners)/Double(self.totNumNodesCorners))
              var gray = SKAction.colorize(with: UIColor.white, colorBlendFactor: cBF, duration: 0.0)
              var fadeOut = SKAction.fadeAlpha(to: 0.0, duration: CGFloat(0.25*panDistPer*Double(ballChange))/1.5)
              self.addChild(trailingG)
              trailingG.run(gray)
              trailingG.run(fadeOut){
                  trailingG.removeFromParent()
              }
          }        //        let scale = SKAction.scale(to: (1.0-actualDuration*CGFloat(i/(ballChange))), duration: 0.0)
      }
      var landedNodesCorners=trailingIndices.unique()
      if self.numElNodesCorners.contains(landedNodesCorners[i]) {
        print("Add 1, Hit Node or Corner")
        numLandedNodesCorners+=1
        self.numElNodesCorners=self.numElNodesCorners.filter(){$0 != landedNodesCorners.unique()[i]}
      }
      let sequence = SKAction.sequence([wait, drawTrailing])
      self.run(sequence)
//      if i==Int(round(panDistPer*Double(ballChange))) {
//      var tempEx = explode()
//        tempEx.position = mazeSprites[trailingIndices.unique()[i]].position
//          var fadeOut = SKAction.fadeAlpha(to: 0.0, duration: CGFloat(1))
//          self.addChild(tempEx)
//          tempEx.run(fadeOut){
//            tempEx.removeFromParent()
//          }
//      }
    }
    print(cBF)
    if numMazeBlocks==numMazeBlocksSwiped {
      solved=1
    }
    
  }
  
  @objc func panedView(sender:UIPanGestureRecognizer){
    var startLocation = CGPoint()
//    numSwipes+=1.0
    var ballChange: Int = 0
    var islandPointFlag=0;
    var trailingIndices: [Int] = [sub2ind(size: maze.count,xInd: ballPosition[0],yInd: ballPosition[1])]
    var panDistPerX: Double = 1.0
    var panDistPerY: Double = 1.0
    let v = sender.velocity(in: self.view)
    
    let dx = (sender.translation(in: view).x)
    let dy = (sender.translation(in: view).y)
    
    if (sender.state == UIGestureRecognizer.State.began) {
      startLocation = sender.location(in: self.view)
    }
    else if (sender.state == UIGestureRecognizer.State.ended) {
//      let stopLocation = sender.location(in: self.view)
//      var dx = stopLocation.x - startLocation.x
//      var dy = stopLocation.y - startLocation.y

      if abs(dx)<65.0{
        panDistPerX=abs(dx)/65.0}
      else{
        panDistPerX=1.0
      }
      if abs(dy)<(65.0){
        panDistPerY=abs(dy)/(65.0)}
      else{
        panDistPerY=1.0
      }

      print("Transitions")
      print(dx)
      print(dy)
      
      
      if dy>0 && abs(dy)>abs(dx) {
        var downResult = swipeDownPan(panDistPer: panDistPerY)
      } else if dy<0 && abs(dy)>abs(dx) {
        var upResult = swipeUpPan(panDistPer: panDistPerY)
      }   else if dx>0 && abs(dy)<abs(dx) {
        var rightResult = swipeRightPan(panDistPer: panDistPerX)
      } else if dx<0 && abs(dy)<abs(dx) {
        var leftResult = swipeLeftPan(panDistPer: panDistPerX)
      }
                  
      // Swiping farther has to do with velocity.  Swiping close has to do with distance
      if dx > 400 {
        //do what you want to do
      }
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      let touch = touches.first!
      let location = touch.location(in: self.view)
  }
  
  func isSolved() {
    if solved==1{
//      saveMazeMetrics()
      solved=0;
    }
  }
  
  func readMazeFileContents() -> [String.SubSequence] {
    var lines: [String.SubSequence] = ["File Opening Error"]
    if let fileURL = Bundle.main.url(forResource: "homotopyUSNativeHawaiianAndPacificIslanderCultureMazes2023-12-14", withExtension: "txt") {
      if let fileContents = try? String(contentsOf: fileURL) {
          lines = fileContents.split(separator:"\n")
        return lines
      }
    }
    return lines
  }
  
  func readSingleMaze(mazeFileContents: [String.SubSequence]) -> ([[Int]],Int,String,[Double],[Int],[Int],[Int]){
        var numMazes: Int = Int(String(mazeFileContents[0].split(separator:" ").last!))!
    var size: Int = Int(String(mazeFileContents[1].split(separator:" ").last!))!
    var mazeName: String = "File Reading Error"
    rM = Int.random(in: 1..<numMazes+1)
    //print("Maze Number: \(r)");
    var maze = [[Int]](repeating: [Int](repeating: 0, count: size), count: size)
    var metricsThisMaze=[Double]()
    var nodesThisMaze=[Int]()
    var cornersThisMaze=[Int]()
    var cornerTypesThisMaze=[Int]()
    
    for i in 1...size+1+1+3 {
      if i==2{
        metricsThisMaze=mazeFileContents[(size+5)*(rM-1)+i+1].split(separator:" ").map{ String($0)}.map{Double($0)!}
      } else if i==3 {
        nodesThisMaze=mazeFileContents[(size+5)*(rM-1)+i+1].split(separator:" ").map{ String($0)}.map{Int($0)!}
      } else if i==4 {
        cornersThisMaze=mazeFileContents[(size+5)*(rM-1)+i+1].split(separator:" ").map{ String($0)}.map{Int($0)!}
      } else if i==5 {
        cornerTypesThisMaze=mazeFileContents[(size+5)*(rM-1)+i+1].split(separator:" ").map{ String($0)}.map{Int($0)!}
      }
      else if i==1{
//        var index=(size+1)*(rM-1)+i+1
        mazeName=String(mazeFileContents[(size+5)*(rM-1)+i+1].split(separator:" ").last!)
      }
      else {
//        var index2=(size+1)*(rM-1)+i+1
//        print(i)
        var toAppend=mazeFileContents[(size+5)*(rM-1)+i+1].split(separator:" ").map{ String($0)}.map{Int($0)!}
        maze[i-6] = mazeFileContents[(size+5)*(rM-1)+i+1].split(separator:" ").map{ String($0)}.map{Int($0)!}
      }
      //print(maze)
    }
    return (maze,size,mazeName,metricsThisMaze,nodesThisMaze,cornersThisMaze,cornerTypesThisMaze)
}
  
func explode() -> SKEmitterNode {

    let enode = SKEmitterNode()
    let image = UIImage(named: "ball")
    let texture = SKTexture(image: image!)
//    enode.particlePosition = CGPoint(x: self.view.frame.width * 0.5, y: self.view.frame.height * 0.5)
//    enode.particlePosition = ball.position
    enode.particleTexture = texture
    enode.particleColor = .brown
//    enode.numParticlesToEmit = 100
    enode.particleBirthRate = 200
    
    enode.particleLifetimeRange = 0
    enode.particleLifetime = 1
    
    enode.emissionAngle = 89.32
    enode.emissionAngleRange = 360
    
    enode.particleSpeed = 500
    enode.particleSpeedRange = 503
    
    enode.xAcceleration = 0
    enode.yAcceleration = -1000
    
    enode.particleAlpha = 1
    enode.particleAlphaSpeed = -1
    enode.particleAlphaRange = 0.2
    
    enode.particleScale = 0.3
    enode.particleScaleRange = 0.2
    enode.particleScaleSpeed = -0.4
    
    enode.particleRotation = 0
    enode.particleRotationRange = 359
    enode.particleRotationSpeed = 0
    
    enode.particleColorBlendFactor = 1
    
    enode.particleBlendMode = .add
    
    return enode
  }
  
  func drawMaze(maze: [[Int]]) -> ([SKSpriteNode],[Int],SKSpriteNode)
  {
    let ballBlock = SKSpriteNode(imageNamed: "block1s")
    mazeSprites = []
    //var ball: SKSpriteNode = SKSpriteNode()
    //var mazeSprites :[SKSpriteNode] = [SKSpriteNode]()
    //var ballPosition: [Int] = []
    for i in 1...maze.count{
      for j in 1...maze[0].count{
        if maze[i-1][j-1]==0{
          mazeBlock = SKSpriteNode(imageNamed: "block3s")
          mazeBlock.position = CGPoint(x: size.width*0.075+mazeBlock.size.width*CGFloat(j)*1.05, y: 10+size.height*0.5 + mazeBlock.size.width*CGFloat(maze.count-i))
          mazeSprites.append(mazeBlock)
          addChild(mazeBlock)
        }
        else if maze[i-1][j-1]==1 {
          mazeBlock = SKSpriteNode(imageNamed: "block1s")
          mazeBlock.position = CGPoint(x: size.width*0.075+mazeBlock.size.width*CGFloat(j)*1.05, y: 10+size.height*0.5 + mazeBlock.size.width*CGFloat(maze.count-i))
          //mazeBlock.position = CGPoint(x: size.width*0.2+mazeBlock.size.width*CGFloat(i)*1.05, y: size.height*0.3 + mazeBlock.size.width*CGFloat(j))
          mazeSprites.append(mazeBlock)
          addChild(mazeBlock)
          numMazeBlocks+=1
        }
        else if maze[i-1][j-1]==2 {
          mazeBlock = SKSpriteNode(imageNamed: "block2s39")
          mazeBlock.position = CGPoint(x: size.width*0.075+mazeBlock.size.width*CGFloat(j)*1.05, y: 10+size.height*0.5 + mazeBlock.size.width*CGFloat(maze.count-i))
          //mazeBlock.color = .green
          //mazeBlock.colorBlendFactor = 0.5
          mazeSprites.append(mazeBlock)
          addChild(mazeBlock)
          ball = SKSpriteNode(imageNamed: "ballShadedBg")
//          ball.scale(to: CGSize(width: ball.size.width*0.115, height: ball.size.height*0.115))
          //ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
          //ball.physicsBody?.restitution = 0.4
          ball.position = CGPoint(x: size.width*0.075+ballBlock.size.width*CGFloat(j)*1.05, y: 10+size.height*0.5 + ballBlock.size.width*CGFloat(maze.count-i))
          addChild(ball)
          ball.zPosition = CGFloat(pow(Double(maze.count),2)+1)
          ballPosition=[i-1,j-1]
          numMazeBlocks+=1
        }
      }
    }
    
    
    let mazeBg = SKShapeNode()
    mazeBg.path = UIBezierPath(roundedRect: CGRect(x: -128, y: -128, width: 330, height: 314), cornerRadius: 6).cgPath
    mazeBg.position = CGPoint(x: frame.midX-37, y: frame.midY+114)
    mazeBg.fillColor = UIColor.systemGray5
    mazeBg.alpha=0.60
    mazeBg.strokeColor = UIColor.darkGray
    mazeBg.lineWidth = 3
    addChild(mazeBg)
    let connBg = SKShapeNode()
    connBg.path = UIBezierPath(roundedRect: CGRect(x: -128, y: -128, width: 240, height: 240), cornerRadius: 10).cgPath
    connBg.position = CGPoint(x: frame.midX+11, y: frame.midY-270)
    connBg.fillColor = UIColor.systemGray5
    connBg.alpha=0.40
    connBg.strokeColor = UIColor.gray
    connBg.lineWidth = 3
    addChild(connBg)
 
    return (mazeSprites,ballPosition,ball)
  }
  
  func sub2ind(size: Int, xInd: Int, yInd: Int) -> Int{
    let ind = xInd*size+yInd
//    let ind = yInd*size+xInd
    return ind
  }
  
  func ind2sub(size: Int, ind: Int)  -> (Int, Int){
    
    let xInd = ind / size
    let yInd = (ind % size)
    return (xInd,yInd)
    
  }
  
}
