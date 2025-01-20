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
class GameSceneBirdsMaze: SKScene, CLLocationManagerDelegate {
  
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
  var secondMazeFlag=false
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
  var mode = "MetricsBirds"
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
    
  }
  
}
