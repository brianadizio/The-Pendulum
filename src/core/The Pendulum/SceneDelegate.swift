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
import Singular
import AppTrackingTransparency
import AdSupport
import Foundation
import UIKit
import SpriteKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  // ...
  
  var window: UIWindow?
     let viewController = GameViewControllerMainMaze()
  

  /*
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
          guard let _ = (scene as? UIWindowScene) else { return }
          if let windowScene = scene as? UIWindowScene {
              self.window = UIWindow(windowScene: windowScene)
              let mainNavigationController = UINavigationController(rootViewController: viewController)
              self.window!.rootViewController = mainNavigationController
              self.window!.makeKeyAndVisible()
          }
      }*/
  
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
      
      if let config = self.getConfig() {
        config.userActivity = userActivity
        Singular.start(config)
      }
      
      NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
      
      var IDFA = String()
      if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
        IDFA = ASIdentifierManager.shared().advertisingIdentifier.uuidString
      }
      print(IDFA)
      /// 1. Capture the scene
      guard let windowScene = (scene as? UIWindowScene) else { return }
      
      /// 2. Create a new UIWindow using the windowScene constructor which takes in a window scene.
      let window = UIWindow(windowScene: windowScene)
      
      /// 3. Create a view hierarchy programmatically
      let viewController = GameViewControllerMainMaze()
      let navigation = UINavigationController(rootViewController: viewController)
      
      /// 4. Set the root view controller of the window with your view controller
      window.rootViewController = navigation
      
      /// 5. Set the window and call makeKeyAndVisible()
      self.window = window
      window.makeKeyAndVisible()
      
//        if let userActivity = connectionOptions.userActivities.first, let config = self.getConfig() {
//            // Starts a new session when the user opens the app using a Singular Link while it was in the background
//            config.userActivity = userActivity
//          Singular.start(config)
//        }

    }
  
  
  @objc func didBecomeActiveNotification() {
      // Request user consent to use the Advertising Identifier (idfa)
      if #available(iOS 14, *) {
          ATTrackingManager.requestTrackingAuthorization { status in
          }
      }
  }
  
    
  func getConfig() -> SingularConfig? {
      // Create the config object with the SDK Key and SDK Secret
      guard let config = SingularConfig(apiKey:"goldenenterprises_2c52889f", andSecret:"df4df5c7bc8cbefe57a359f39950915a") else {
          return nil
      }
      
      // Set a 300 sec delay before initialization to wait for the user's ATT response
      config.waitForTrackingAuthorizationWithTimeoutInterval = 300;

      // Enable SKAdNetwork in Managed Mode
      config.skAdNetworkEnabled = true

      // Get the current conversion value tracked by the Singular SDK.
      config.conversionValuesUpdatedCallback = { conversionValue, coarse, lock in
          // Here you have access to the latest conversion value
      };
      
      Singular.setCustomUserId("custom_user_id")
      
      return config
  }
  
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        // Starts a new session when the user opens the app using a Singular Link while it was in the background
        if let config = getConfig() {
            config.userActivity = userActivity
            Singular.start(config)
        }
    }
    
}
