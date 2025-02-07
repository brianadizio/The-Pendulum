/// Copyright (c) 2017 Razeware LLC
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

//import UIKit
//
//@UIApplicationMain
//class AppDelegate: UIResponder, UIApplicationDelegate {
//  var window: UIWindow?
//  /*
//  // AppDelegate
//
//  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//      if #available(iOS 13.0, *) { } else {
//          self.window = UIWindow(frame: UIScreen.main.bounds)
//          let mainViewController = GameViewControllerMainMaze()
//          let mainNavigationController = UINavigationController(rootViewController: mainViewController)
//          self.window!.rootViewController = mainNavigationController
//          self.window!.makeKeyAndVisible()
//      }
//      return true
//  }*/
//  
//}

//
//  AppDelegate.swift
//  temporaryCoreDataProject
//
//  Created by Brian DiZio on 11/2/23.
//
import Foundation
import UIKit
import CoreData
@available(iOS 13.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  var background: [NSManagedObject] = []
  var InitMetrics: [NSManagedObject] = []
  var swipingObject: [NSManagedObject] = []
  
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
      let sceneConfig: UISceneConfiguration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
      sceneConfig.delegateClass = SceneDelegate.self
      return sceneConfig
  }
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    
    // Override point for customization after application launch.
    //      deleteContext()
    
    //    if let value = ProcessInfo.processInfo.environment["firstInstallFlag"] {
    //      setenv(<#T##__name: UnsafePointer<CChar>!##UnsafePointer<CChar>!#>, <#T##__value: UnsafePointer<CChar>!##UnsafePointer<CChar>!#>, <#T##__overwrite: Int32##Int32#>)
    //    }
    //
    //  UserDefaults.standard.set(1, forKey: "Flag")  //Integer
    //    if  UserDefaults.standard.value(forUndefinedKey: "Flag")
    //          saveInitMetrics(InitMetricsInput: 1)
    //          print("Saved Initial Init Metrics")
    //
    //  }
    
  
    
    var InitMetricsFlag: Any?
    loadInitMetrics()
    if InitMetrics.count==0{
      saveInitMetrics(InitMetricsInput: 1)
      saveInitial()
      saveBg(bgFlag: 0)
      saveSwiping(swipingMethod: 1)
      
    }
    
    
    loadInitMetrics()
    InitMetricsFlag=InitMetrics[InitMetrics.count-1].value(forKey: "initMetricsFlag")
    var InitMetricsFlagD=InitMetricsFlag as! Int
    print(InitMetricsFlagD)
    
    
    return true
  }
  //// MARK: UISceneSession Lifecycle
  //  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
  //    var window: UIWindow?
  //
  //// Called when a new scene session is being created.
  //// Use this method to select a configuration to create the new scene with.
  //return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  //}
  //  @available(iOS 13.0, *)
  //  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
  //// Called when the user discards a scene session.
  //// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
  //// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  //}
  // MARK: - Core Data stack
  lazy var persistentContainer: NSPersistentCloudKitContainer = {
    /*
     The persistent container for the application. This implementation
     creates and returns a container, having loaded the store for the
     application to it. This property is optional since there are legitimate
     error conditions that could cause the creation of the store to fail.
     */
    
    let container = NSPersistentCloudKitContainer(name: "mazeDataModel")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        /*
         Typical reasons for an error here include:
         * The parent directory does not exist, cannot be created, or disallows writing.
         * The persistent store is not accessible, due to permissions or data protection when the device is locked.
         * The device is out of space.
         * The store could not be migrated to the current model version.
         Check the error message to determine what the actual problem was.
         */
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()
  // MARK: - Core Data Saving support
  func saveContext () {
    let context = persistentContainer.viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
  
  func deleteContext () {
    
    let storeContainer =
    persistentContainer.persistentStoreCoordinator
    
    // Delete each existing persistent store
    for store in storeContainer.persistentStores {
      try! storeContainer.destroyPersistentStore(
        at: store.url!,
        ofType: store.type,
        options: nil
      )
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
      swipingObject.append(swipingMethodFlag)
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
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
  
  
  func saveInitial() {
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
    NSEntityDescription.entity(forEntityName: "MetricsImmersedCircle",
                               in: managedContext)!
    let entity3 =
    NSEntityDescription.entity(forEntityName: "MetricsFluidFlow",
                               in: managedContext)!
    let entity4 =
    NSEntityDescription.entity(forEntityName: "MetricsGravity",
                               in: managedContext)!
    let entity5 =
    NSEntityDescription.entity(forEntityName: "MetricsBirds",
                               in: managedContext)!
    let entity6 =
    NSEntityDescription.entity(forEntityName: "MetricsAgricultural",
                               in: managedContext)!
    let entity7 =
    NSEntityDescription.entity(forEntityName: "MetricsAnimalGeneExpression",
                               in: managedContext)!
    let entity8 =
    NSEntityDescription.entity(forEntityName: "MetricsArchitecture",
                               in: managedContext)!
    let entity9 =
    NSEntityDescription.entity(forEntityName: "MetricsAstronomy",
                               in: managedContext)!
    let entity10 =
    NSEntityDescription.entity(forEntityName: "MetricsBigBang",
                               in: managedContext)!
    let entity11 =
    NSEntityDescription.entity(forEntityName: "MetricsBrain",
                               in: managedContext)!
    let entity12 =
    NSEntityDescription.entity(forEntityName: "MetricsCancerModel",
                               in: managedContext)!
    let entity13 =
    NSEntityDescription.entity(forEntityName: "MetricsClimatological",
                               in: managedContext)!
    let entity14 =
    NSEntityDescription.entity(forEntityName: "MetricsDiabetesModels",
                               in: managedContext)!
    let entity15 =
    NSEntityDescription.entity(forEntityName: "MetricsFacesAndPortraits",
                               in: managedContext)!
    let entity16 =
    NSEntityDescription.entity(forEntityName: "MetricsFood",
                               in: managedContext)!
    let entity17 =
    NSEntityDescription.entity(forEntityName: "MetricsFractal",
                               in: managedContext)!
    let entity18 =
    NSEntityDescription.entity(forEntityName: "MetricsFurniture",
                               in: managedContext)!
    let entity19 =
    NSEntityDescription.entity(forEntityName: "MetricsHumanGeneExpression",
                               in: managedContext)!
    let entity20 =
    NSEntityDescription.entity(forEntityName: "MetricsHumanLifeModels",
                               in: managedContext)!
    let entity21 =
    NSEntityDescription.entity(forEntityName: "MetricsMagnetics",
                               in: managedContext)!
    let entity22 =
    NSEntityDescription.entity(forEntityName: "MetricsMaterials",
                               in: managedContext)!
    let entity23 =
    NSEntityDescription.entity(forEntityName: "MetricsNeuralDiseaseModels",
                               in: managedContext)!
    let entity24 =
    NSEntityDescription.entity(forEntityName: "MetricsParticleDynamics",
                               in: managedContext)!
    let entity25 =
    NSEntityDescription.entity(forEntityName: "MetricsPlants",
                               in: managedContext)!
    let entity26 =
    NSEntityDescription.entity(forEntityName: "MetricsPolitical",
                               in: managedContext)!
    let entity27 =
    NSEntityDescription.entity(forEntityName: "MetricsHumanProteinFolding",
                               in: managedContext)!
    let entity28 =
    NSEntityDescription.entity(forEntityName: "MetricsStoneArt",
                               in: managedContext)!
    let entity29 =
    NSEntityDescription.entity(forEntityName: "MetricsTeachingModels",
                               in: managedContext)!
    let entity30 =
    NSEntityDescription.entity(forEntityName: "MetricsTextiles",
                               in: managedContext)!
    let entity31 =
    NSEntityDescription.entity(forEntityName: "MetricsUSAfricanAmericanCulture",
                               in: managedContext)!
    let entity32 =
    NSEntityDescription.entity(forEntityName: "MetricsUSAsianAmericanCulture",
                               in: managedContext)!
    let entity33 =
    NSEntityDescription.entity(forEntityName: "MetricsUSCensusEducation",
                               in: managedContext)!
    let entity34 =
    NSEntityDescription.entity(forEntityName: "MetricsUSCensusEmployment",
                               in: managedContext)!
    let entity35 =
    NSEntityDescription.entity(forEntityName: "MetricsUSCensusIncomeAndPoverty",
                               in: managedContext)!
    let entity36 =
    NSEntityDescription.entity(forEntityName: "MetricsUSCensusPublicHealth",
                               in: managedContext)!
    let entity37 =
    NSEntityDescription.entity(forEntityName: "MetricsUSCensusRaceAndEthnicity",
                               in: managedContext)!
    let entity38 =
    NSEntityDescription.entity(forEntityName: "MetricsUSCensusSmallBusiness",
                               in: managedContext)!
    
    let entity39 =
    NSEntityDescription.entity(forEntityName: "MetricsUSEconomics",
                               in: managedContext)!
    let entity40 =
    NSEntityDescription.entity(forEntityName: "MetricsUSFinance",
                               in: managedContext)!
    let entity41 =
    NSEntityDescription.entity(forEntityName: "MetricsUSLatinAmericanCulture",
                               in: managedContext)!
    let entity42 =
    NSEntityDescription.entity(forEntityName: "MetricsUSNativeAmericanCulture",
                               in: managedContext)!
    let entity43 =
    NSEntityDescription.entity(forEntityName: "MetricsUSNativeHawaiianAndPacificIslanderCulture",
                               in: managedContext)!
    let entity44 =
    NSEntityDescription.entity(forEntityName: "MetricsUSWhiteAmericanCulture",
                               in: managedContext)!
    
    let entity45 =
    NSEntityDescription.entity(forEntityName: "MetricsViralDiseaseModels",
                               in: managedContext)!
    
    let metricsAll = NSManagedObject(entity: entity1,
                                     insertInto: managedContext)
    let metricsImmersedCircle = NSManagedObject(entity: entity2,
                                                insertInto: managedContext)
    let metricsFluidFlow = NSManagedObject(entity: entity3,
                                           insertInto: managedContext)
    let metricsGravity = NSManagedObject(entity: entity4,
                                         insertInto: managedContext)
    let metricsBirds = NSManagedObject(entity: entity5,
                                       insertInto: managedContext)
    let metricsAgricultural = NSManagedObject(entity: entity6,
                                              insertInto: managedContext)
    let metricsAnimalGeneExpression = NSManagedObject(entity: entity7,
                                                      insertInto: managedContext)
    let metricsArchitecture = NSManagedObject(entity: entity8,
                                              insertInto: managedContext)
    let metricsAstronomy = NSManagedObject(entity: entity9,
                                           insertInto: managedContext)
    let metricsBigBang = NSManagedObject(entity: entity10,
                                         insertInto: managedContext)
    
    let metricsBrain = NSManagedObject(entity: entity11,
                                       insertInto: managedContext)
    let MetricsCancerModel = NSManagedObject(entity: entity12,
                                             insertInto: managedContext)
    let metricsClimatological = NSManagedObject(entity: entity13,
                                                insertInto: managedContext)
    let metricsDiabetesModels = NSManagedObject(entity: entity14,
                                                insertInto: managedContext)
    let metricsFacesAndPortraits = NSManagedObject(entity: entity15,
                                                   insertInto: managedContext)
    let metricsFood = NSManagedObject(entity: entity16,
                                      insertInto: managedContext)
    let metricsFractal = NSManagedObject(entity: entity17,
                                         insertInto: managedContext)
    let metricsFurniture = NSManagedObject(entity: entity18,
                                           insertInto: managedContext)
    let metricsHumanGeneExpression = NSManagedObject(entity: entity19,
                                                     insertInto: managedContext)
    let metricsHumanLifeModels = NSManagedObject(entity: entity20,
                                                 insertInto: managedContext)
    let metricsMagnetics = NSManagedObject(entity: entity21,
                                           insertInto: managedContext)
    let metricsMaterials = NSManagedObject(entity: entity22,
                                           insertInto: managedContext)
    let metricsNeuralDiseaseModels = NSManagedObject(entity: entity23,
                                                     insertInto: managedContext)
    let metricsParticleDynamics = NSManagedObject(entity: entity24,
                                                  insertInto: managedContext)
    let metricsPlant = NSManagedObject(entity: entity25,
                                       insertInto: managedContext)
    let metricsPolitical = NSManagedObject(entity: entity27,
                                           insertInto: managedContext)
    let metricsHumanProteinFolding = NSManagedObject(entity: entity26,
                                                     insertInto: managedContext)
    let metricsStoneArt = NSManagedObject(entity: entity28,
                                          insertInto: managedContext)
    let metricsTeachingModels = NSManagedObject(entity: entity29,
                                                insertInto: managedContext)
    let metricsTextiles = NSManagedObject(entity: entity30,
                                          insertInto: managedContext)
    let metricsUSAfricanAmericanCulture = NSManagedObject(entity: entity31,
                                                          insertInto: managedContext)
    let metricsUSAsianAmericanCulture = NSManagedObject(entity: entity32,
                                                        insertInto: managedContext)
    let metricsUSCensusEducation = NSManagedObject(entity: entity33,
                                                   insertInto: managedContext)
    let metricsUSCensusEmployment = NSManagedObject(entity: entity34,
                                                    insertInto: managedContext)
    let metricsUSCensusIncomeAndPoverty = NSManagedObject(entity: entity35,
                                                          insertInto: managedContext)
    let metricsUSCensusPublicHealth = NSManagedObject(entity: entity36,
                                                      insertInto: managedContext)
    let metricsUSCensusRaceAndEthnicity = NSManagedObject(entity: entity37,
                                                          insertInto: managedContext)
    let metricsUSCensusSmallBusiness = NSManagedObject(entity: entity38,
                                                       insertInto: managedContext)
    let metricsUSEconomics = NSManagedObject(entity: entity39,
                                             insertInto: managedContext)
    let metricsUSFinance = NSManagedObject(entity: entity40,
                                           insertInto: managedContext)
    let metricsUSLatinAmericanCulture = NSManagedObject(entity: entity41,
                                                        insertInto: managedContext)
    let metricsUSNativeAmericanCulture = NSManagedObject(entity: entity42,
                                                         insertInto: managedContext)
    let metricsUSNativeHawaiianAndPacificIslanderCulture = NSManagedObject(entity: entity43,
                                                                           insertInto: managedContext)
    let metricsUSWhiteAmericanCulture = NSManagedObject(entity: entity44,
                                                        insertInto: managedContext)
    let metricsViralDiseasesModel = NSManagedObject(entity: entity45,
                                                    insertInto: managedContext)
    
    metricsAll.setValue(0, forKeyPath: "pcaDim1")
    metricsAll.setValue(0, forKeyPath: "pcaDim2")
    metricsAll.setValue(0, forKeyPath: "pcaDim3")
    metricsAll.setValue(0, forKeyPath: "pcaDim4")
    metricsAll.setValue(0, forKeyPath: "pcaDim5")
    metricsAll.setValue(0, forKeyPath: "pcaDim6")
    metricsAll.setValue(0, forKeyPath: "pcaDim7")
    metricsAll.setValue(0, forKeyPath: "pcaDim8")
    metricsAll.setValue(0, forKeyPath: "pcaDim9")
    metricsAll.setValue(0, forKeyPath: "datenum")
    metricsAll.setValue(0, forKeyPath: "latitude")
    metricsAll.setValue(0, forKeyPath: "longitude")
    metricsAll.setValue(0, forKeyPath: "rM")
    metricsAll.setValue("All", forKeyPath: "mode")
    metricsImmersedCircle.setValue(0, forKeyPath: "dim1")
    metricsImmersedCircle.setValue(0, forKeyPath: "dim2")
    metricsImmersedCircle.setValue(0, forKeyPath: "dim3")
    metricsImmersedCircle.setValue(0, forKeyPath: "dim4")
    metricsImmersedCircle.setValue(0, forKeyPath: "dim5")
    metricsImmersedCircle.setValue(0, forKeyPath: "dim6")
    metricsImmersedCircle.setValue(0, forKeyPath: "dim7")
    metricsImmersedCircle.setValue(0, forKeyPath: "dim8")
    metricsImmersedCircle.setValue(0, forKeyPath: "dim9")
    metricsImmersedCircle.setValue(0, forKeyPath: "datenum")
    metricsImmersedCircle.setValue(0, forKeyPath: "latitude")
    metricsImmersedCircle.setValue(0, forKeyPath: "longitude")
    metricsImmersedCircle.setValue(0, forKeyPath: "rM")
    
    metricsFluidFlow.setValue(0, forKeyPath: "dim1")
    metricsFluidFlow.setValue(0, forKeyPath: "dim2")
    metricsFluidFlow.setValue(0, forKeyPath: "dim3")
    metricsFluidFlow.setValue(0, forKeyPath: "dim4")
    metricsFluidFlow.setValue(0, forKeyPath: "dim5")
    metricsFluidFlow.setValue(0, forKeyPath: "dim6")
    metricsFluidFlow.setValue(0, forKeyPath: "dim7")
    metricsFluidFlow.setValue(0, forKeyPath: "dim8")
    metricsFluidFlow.setValue(0, forKeyPath: "dim9")
    metricsFluidFlow.setValue(0, forKeyPath: "datenum")
    metricsFluidFlow.setValue(0, forKeyPath: "latitude")
    metricsFluidFlow.setValue(0, forKeyPath: "longitude")
    metricsFluidFlow.setValue(0, forKeyPath: "rM")
    
    metricsGravity.setValue(0, forKeyPath: "dim1")
    metricsGravity.setValue(0, forKeyPath: "dim2")
    metricsGravity.setValue(0, forKeyPath: "dim3")
    metricsGravity.setValue(0, forKeyPath: "dim4")
    metricsGravity.setValue(0, forKeyPath: "dim5")
    metricsGravity.setValue(0, forKeyPath: "dim6")
    metricsGravity.setValue(0, forKeyPath: "dim7")
    metricsGravity.setValue(0, forKeyPath: "dim8")
    metricsGravity.setValue(0, forKeyPath: "dim9")
    metricsGravity.setValue(0, forKeyPath: "datenum")
    metricsGravity.setValue(0, forKeyPath: "latitude")
    metricsGravity.setValue(0, forKeyPath: "longitude")
    metricsGravity.setValue(0, forKeyPath: "rM")
    
    metricsBirds.setValue(0, forKeyPath: "dim1")
    metricsBirds.setValue(0, forKeyPath: "dim2")
    metricsBirds.setValue(0, forKeyPath: "dim3")
    metricsBirds.setValue(0, forKeyPath: "dim4")
    metricsBirds.setValue(0, forKeyPath: "dim5")
    metricsBirds.setValue(0, forKeyPath: "dim6")
    metricsBirds.setValue(0, forKeyPath: "dim7")
    metricsBirds.setValue(0, forKeyPath: "dim8")
    metricsBirds.setValue(0, forKeyPath: "dim9")
    metricsBirds.setValue(0, forKeyPath: "datenum")
    metricsBirds.setValue(0, forKeyPath: "latitude")
    metricsBirds.setValue(0, forKeyPath: "longitude")
    metricsBirds.setValue(0, forKeyPath: "rM")
    
    metricsAgricultural.setValue(0, forKeyPath: "dim1")
    metricsAgricultural.setValue(0, forKeyPath: "dim2")
    metricsAgricultural.setValue(0, forKeyPath: "dim3")
    metricsAgricultural.setValue(0, forKeyPath: "dim4")
    metricsAgricultural.setValue(0, forKeyPath: "dim5")
    metricsAgricultural.setValue(0, forKeyPath: "dim6")
    metricsAgricultural.setValue(0, forKeyPath: "dim7")
    metricsAgricultural.setValue(0, forKeyPath: "dim8")
    metricsAgricultural.setValue(0, forKeyPath: "dim9")
    metricsAgricultural.setValue(0, forKeyPath: "datenum")
    metricsAgricultural.setValue(0, forKeyPath: "latitude")
    metricsAgricultural.setValue(0, forKeyPath: "longitude")
    metricsAgricultural.setValue(0, forKeyPath: "rM")
    
    metricsAnimalGeneExpression.setValue(0, forKeyPath: "dim1")
    metricsAnimalGeneExpression.setValue(0, forKeyPath: "dim2")
    metricsAnimalGeneExpression.setValue(0, forKeyPath: "dim3")
    metricsAnimalGeneExpression.setValue(0, forKeyPath: "dim4")
    metricsAnimalGeneExpression.setValue(0, forKeyPath: "dim5")
    metricsAnimalGeneExpression.setValue(0, forKeyPath: "dim6")
    metricsAnimalGeneExpression.setValue(0, forKeyPath: "dim7")
    metricsAnimalGeneExpression.setValue(0, forKeyPath: "dim8")
    metricsAnimalGeneExpression.setValue(0, forKeyPath: "dim9")
    metricsAnimalGeneExpression.setValue(0, forKeyPath: "datenum")
    metricsAnimalGeneExpression.setValue(0, forKeyPath: "latitude")
    metricsAnimalGeneExpression.setValue(0, forKeyPath: "longitude")
    metricsAnimalGeneExpression.setValue(0, forKeyPath: "rM")
    
    metricsArchitecture.setValue(0, forKeyPath: "dim1")
    metricsArchitecture.setValue(0, forKeyPath: "dim2")
    metricsArchitecture.setValue(0, forKeyPath: "dim3")
    metricsArchitecture.setValue(0, forKeyPath: "dim4")
    metricsArchitecture.setValue(0, forKeyPath: "dim5")
    metricsArchitecture.setValue(0, forKeyPath: "dim6")
    metricsArchitecture.setValue(0, forKeyPath: "dim7")
    metricsArchitecture.setValue(0, forKeyPath: "dim8")
    metricsArchitecture.setValue(0, forKeyPath: "dim9")
    metricsArchitecture.setValue(0, forKeyPath: "datenum")
    metricsArchitecture.setValue(0, forKeyPath: "latitude")
    metricsArchitecture.setValue(0, forKeyPath: "longitude")
    metricsArchitecture.setValue(0, forKeyPath: "rM")
    
    metricsAstronomy.setValue(0, forKeyPath: "dim1")
    metricsAstronomy.setValue(0, forKeyPath: "dim2")
    metricsAstronomy.setValue(0, forKeyPath: "dim3")
    metricsAstronomy.setValue(0, forKeyPath: "dim4")
    metricsAstronomy.setValue(0, forKeyPath: "dim5")
    metricsAstronomy.setValue(0, forKeyPath: "dim6")
    metricsAstronomy.setValue(0, forKeyPath: "dim7")
    metricsAstronomy.setValue(0, forKeyPath: "dim8")
    metricsAstronomy.setValue(0, forKeyPath: "dim9")
    metricsAstronomy.setValue(0, forKeyPath: "datenum")
    metricsAstronomy.setValue(0, forKeyPath: "latitude")
    metricsAstronomy.setValue(0, forKeyPath: "longitude")
    metricsAstronomy.setValue(0, forKeyPath: "rM")
    
    metricsBigBang.setValue(0, forKeyPath: "dim1")
    metricsBigBang.setValue(0, forKeyPath: "dim2")
    metricsBigBang.setValue(0, forKeyPath: "dim3")
    metricsBigBang.setValue(0, forKeyPath: "dim4")
    metricsBigBang.setValue(0, forKeyPath: "dim5")
    metricsBigBang.setValue(0, forKeyPath: "dim6")
    metricsBigBang.setValue(0, forKeyPath: "dim7")
    metricsBigBang.setValue(0, forKeyPath: "dim8")
    metricsBigBang.setValue(0, forKeyPath: "dim9")
    metricsBigBang.setValue(0, forKeyPath: "datenum")
    metricsBigBang.setValue(0, forKeyPath: "latitude")
    metricsBigBang.setValue(0, forKeyPath: "longitude")
    metricsBigBang.setValue(0, forKeyPath: "rM")
    
    metricsBrain.setValue(0, forKeyPath: "dim1")
    metricsBrain.setValue(0, forKeyPath: "dim2")
    metricsBrain.setValue(0, forKeyPath: "dim3")
    metricsBrain.setValue(0, forKeyPath: "dim4")
    metricsBrain.setValue(0, forKeyPath: "dim5")
    metricsBrain.setValue(0, forKeyPath: "dim6")
    metricsBrain.setValue(0, forKeyPath: "dim7")
    metricsBrain.setValue(0, forKeyPath: "dim8")
    metricsBrain.setValue(0, forKeyPath: "dim9")
    metricsBrain.setValue(0, forKeyPath: "datenum")
    metricsBrain.setValue(0, forKeyPath: "latitude")
    metricsBrain.setValue(0, forKeyPath: "longitude")
    metricsBrain.setValue(0, forKeyPath: "rM")
    
    MetricsCancerModel.setValue(0, forKeyPath: "dim1")
    MetricsCancerModel.setValue(0, forKeyPath: "dim2")
    MetricsCancerModel.setValue(0, forKeyPath: "dim3")
    MetricsCancerModel.setValue(0, forKeyPath: "dim4")
    MetricsCancerModel.setValue(0, forKeyPath: "dim5")
    MetricsCancerModel.setValue(0, forKeyPath: "dim6")
    MetricsCancerModel.setValue(0, forKeyPath: "dim7")
    MetricsCancerModel.setValue(0, forKeyPath: "dim8")
    MetricsCancerModel.setValue(0, forKeyPath: "dim9")
    MetricsCancerModel.setValue(0, forKeyPath: "datenum")
    MetricsCancerModel.setValue(0, forKeyPath: "latitude")
    MetricsCancerModel.setValue(0, forKeyPath: "longitude")
    MetricsCancerModel.setValue(0, forKeyPath: "rM")
    
    metricsClimatological.setValue(0, forKeyPath: "dim1")
    metricsClimatological.setValue(0, forKeyPath: "dim2")
    metricsClimatological.setValue(0, forKeyPath: "dim3")
    metricsClimatological.setValue(0, forKeyPath: "dim4")
    metricsClimatological.setValue(0, forKeyPath: "dim5")
    metricsClimatological.setValue(0, forKeyPath: "dim6")
    metricsClimatological.setValue(0, forKeyPath: "dim7")
    metricsClimatological.setValue(0, forKeyPath: "dim8")
    metricsClimatological.setValue(0, forKeyPath: "dim9")
    metricsClimatological.setValue(0, forKeyPath: "datenum")
    metricsClimatological.setValue(0, forKeyPath: "latitude")
    metricsClimatological.setValue(0, forKeyPath: "longitude")
    metricsClimatological.setValue(0, forKeyPath: "rM")
    
    metricsDiabetesModels.setValue(0, forKeyPath: "dim1")
    metricsDiabetesModels.setValue(0, forKeyPath: "dim2")
    metricsDiabetesModels.setValue(0, forKeyPath: "dim3")
    metricsDiabetesModels.setValue(0, forKeyPath: "dim4")
    metricsDiabetesModels.setValue(0, forKeyPath: "dim5")
    metricsDiabetesModels.setValue(0, forKeyPath: "dim6")
    metricsDiabetesModels.setValue(0, forKeyPath: "dim7")
    metricsDiabetesModels.setValue(0, forKeyPath: "dim8")
    metricsDiabetesModels.setValue(0, forKeyPath: "dim9")
    metricsDiabetesModels.setValue(0, forKeyPath: "datenum")
    metricsDiabetesModels.setValue(0, forKeyPath: "latitude")
    metricsDiabetesModels.setValue(0, forKeyPath: "longitude")
    metricsDiabetesModels.setValue(0, forKeyPath: "rM")
    
    metricsFacesAndPortraits.setValue(0, forKeyPath: "dim1")
    metricsFacesAndPortraits.setValue(0, forKeyPath: "dim2")
    metricsFacesAndPortraits.setValue(0, forKeyPath: "dim3")
    metricsFacesAndPortraits.setValue(0, forKeyPath: "dim4")
    metricsFacesAndPortraits.setValue(0, forKeyPath: "dim5")
    metricsFacesAndPortraits.setValue(0, forKeyPath: "dim6")
    metricsFacesAndPortraits.setValue(0, forKeyPath: "dim7")
    metricsFacesAndPortraits.setValue(0, forKeyPath: "dim8")
    metricsFacesAndPortraits.setValue(0, forKeyPath: "dim9")
    metricsFacesAndPortraits.setValue(0, forKeyPath: "datenum")
    metricsFacesAndPortraits.setValue(0, forKeyPath: "latitude")
    metricsFacesAndPortraits.setValue(0, forKeyPath: "longitude")
    metricsFacesAndPortraits.setValue(0, forKeyPath: "rM")
    
    metricsFood.setValue(0, forKeyPath: "dim1")
    metricsFood.setValue(0, forKeyPath: "dim2")
    metricsFood.setValue(0, forKeyPath: "dim3")
    metricsFood.setValue(0, forKeyPath: "dim4")
    metricsFood.setValue(0, forKeyPath: "dim5")
    metricsFood.setValue(0, forKeyPath: "dim6")
    metricsFood.setValue(0, forKeyPath: "dim7")
    metricsFood.setValue(0, forKeyPath: "dim8")
    metricsFood.setValue(0, forKeyPath: "dim9")
    metricsFood.setValue(0, forKeyPath: "datenum")
    metricsFood.setValue(0, forKeyPath: "latitude")
    metricsFood.setValue(0, forKeyPath: "longitude")
    metricsFood.setValue(0, forKeyPath: "rM")
    
    metricsFractal.setValue(0, forKeyPath: "dim1")
    metricsFractal.setValue(0, forKeyPath: "dim2")
    metricsFractal.setValue(0, forKeyPath: "dim3")
    metricsFractal.setValue(0, forKeyPath: "dim4")
    metricsFractal.setValue(0, forKeyPath: "dim5")
    metricsFractal.setValue(0, forKeyPath: "dim6")
    metricsFractal.setValue(0, forKeyPath: "dim7")
    metricsFractal.setValue(0, forKeyPath: "dim8")
    metricsFractal.setValue(0, forKeyPath: "dim9")
    metricsFractal.setValue(0, forKeyPath: "datenum")
    metricsFractal.setValue(0, forKeyPath: "latitude")
    metricsFractal.setValue(0, forKeyPath: "longitude")
    metricsFractal.setValue(0, forKeyPath: "rM")
    
    metricsFurniture.setValue(0, forKeyPath: "dim1")
    metricsFurniture.setValue(0, forKeyPath: "dim2")
    metricsFurniture.setValue(0, forKeyPath: "dim3")
    metricsFurniture.setValue(0, forKeyPath: "dim4")
    metricsFurniture.setValue(0, forKeyPath: "dim5")
    metricsFurniture.setValue(0, forKeyPath: "dim6")
    metricsFurniture.setValue(0, forKeyPath: "dim7")
    metricsFurniture.setValue(0, forKeyPath: "dim8")
    metricsFurniture.setValue(0, forKeyPath: "dim9")
    metricsFurniture.setValue(0, forKeyPath: "datenum")
    metricsFurniture.setValue(0, forKeyPath: "latitude")
    metricsFurniture.setValue(0, forKeyPath: "longitude")
    metricsFurniture.setValue(0, forKeyPath: "rM")
    
    metricsHumanGeneExpression.setValue(0, forKeyPath: "dim1")
    metricsHumanGeneExpression.setValue(0, forKeyPath: "dim2")
    metricsHumanGeneExpression.setValue(0, forKeyPath: "dim3")
    metricsHumanGeneExpression.setValue(0, forKeyPath: "dim4")
    metricsHumanGeneExpression.setValue(0, forKeyPath: "dim5")
    metricsHumanGeneExpression.setValue(0, forKeyPath: "dim6")
    metricsHumanGeneExpression.setValue(0, forKeyPath: "dim7")
    metricsHumanGeneExpression.setValue(0, forKeyPath: "dim8")
    metricsHumanGeneExpression.setValue(0, forKeyPath: "dim9")
    metricsHumanGeneExpression.setValue(0, forKeyPath: "datenum")
    metricsHumanGeneExpression.setValue(0, forKeyPath: "latitude")
    metricsHumanGeneExpression.setValue(0, forKeyPath: "longitude")
    metricsHumanGeneExpression.setValue(0, forKeyPath: "rM")
    
    metricsHumanLifeModels.setValue(0, forKeyPath: "dim1")
    metricsHumanLifeModels.setValue(0, forKeyPath: "dim2")
    metricsHumanLifeModels.setValue(0, forKeyPath: "dim3")
    metricsHumanLifeModels.setValue(0, forKeyPath: "dim4")
    metricsHumanLifeModels.setValue(0, forKeyPath: "dim5")
    metricsHumanLifeModels.setValue(0, forKeyPath: "dim6")
    metricsHumanLifeModels.setValue(0, forKeyPath: "dim7")
    metricsHumanLifeModels.setValue(0, forKeyPath: "dim8")
    metricsHumanLifeModels.setValue(0, forKeyPath: "dim9")
    metricsHumanLifeModels.setValue(0, forKeyPath: "datenum")
    metricsHumanLifeModels.setValue(0, forKeyPath: "latitude")
    metricsHumanLifeModels.setValue(0, forKeyPath: "longitude")
    metricsHumanLifeModels.setValue(0, forKeyPath: "rM")
    
    metricsMagnetics.setValue(0, forKeyPath: "dim1")
    metricsMagnetics.setValue(0, forKeyPath: "dim2")
    metricsMagnetics.setValue(0, forKeyPath: "dim3")
    metricsMagnetics.setValue(0, forKeyPath: "dim4")
    metricsMagnetics.setValue(0, forKeyPath: "dim5")
    metricsMagnetics.setValue(0, forKeyPath: "dim6")
    metricsMagnetics.setValue(0, forKeyPath: "dim7")
    metricsMagnetics.setValue(0, forKeyPath: "dim8")
    metricsMagnetics.setValue(0, forKeyPath: "dim9")
    metricsMagnetics.setValue(0, forKeyPath: "datenum")
    metricsMagnetics.setValue(0, forKeyPath: "latitude")
    metricsMagnetics.setValue(0, forKeyPath: "longitude")
    metricsMagnetics.setValue(0, forKeyPath: "rM")
    
    metricsMaterials.setValue(0, forKeyPath: "dim1")
    metricsMaterials.setValue(0, forKeyPath: "dim2")
    metricsMaterials.setValue(0, forKeyPath: "dim3")
    metricsMaterials.setValue(0, forKeyPath: "dim4")
    metricsMaterials.setValue(0, forKeyPath: "dim5")
    metricsMaterials.setValue(0, forKeyPath: "dim6")
    metricsMaterials.setValue(0, forKeyPath: "dim7")
    metricsMaterials.setValue(0, forKeyPath: "dim8")
    metricsMaterials.setValue(0, forKeyPath: "dim9")
    metricsMaterials.setValue(0, forKeyPath: "datenum")
    metricsMaterials.setValue(0, forKeyPath: "latitude")
    metricsMaterials.setValue(0, forKeyPath: "longitude")
    metricsMaterials.setValue(0, forKeyPath: "rM")
    
    metricsNeuralDiseaseModels.setValue(0, forKeyPath: "dim1")
    metricsNeuralDiseaseModels.setValue(0, forKeyPath: "dim2")
    metricsNeuralDiseaseModels.setValue(0, forKeyPath: "dim3")
    metricsNeuralDiseaseModels.setValue(0, forKeyPath: "dim4")
    metricsNeuralDiseaseModels.setValue(0, forKeyPath: "dim5")
    metricsNeuralDiseaseModels.setValue(0, forKeyPath: "dim6")
    metricsNeuralDiseaseModels.setValue(0, forKeyPath: "dim7")
    metricsNeuralDiseaseModels.setValue(0, forKeyPath: "dim8")
    metricsNeuralDiseaseModels.setValue(0, forKeyPath: "dim9")
    metricsNeuralDiseaseModels.setValue(0, forKeyPath: "datenum")
    metricsNeuralDiseaseModels.setValue(0, forKeyPath: "latitude")
    metricsNeuralDiseaseModels.setValue(0, forKeyPath: "longitude")
    metricsNeuralDiseaseModels.setValue(0, forKeyPath: "rM")
    
    metricsParticleDynamics.setValue(0, forKeyPath: "dim1")
    metricsParticleDynamics.setValue(0, forKeyPath: "dim2")
    metricsParticleDynamics.setValue(0, forKeyPath: "dim3")
    metricsParticleDynamics.setValue(0, forKeyPath: "dim4")
    metricsParticleDynamics.setValue(0, forKeyPath: "dim5")
    metricsParticleDynamics.setValue(0, forKeyPath: "dim6")
    metricsParticleDynamics.setValue(0, forKeyPath: "dim7")
    metricsParticleDynamics.setValue(0, forKeyPath: "dim8")
    metricsParticleDynamics.setValue(0, forKeyPath: "dim9")
    metricsParticleDynamics.setValue(0, forKeyPath: "datenum")
    metricsParticleDynamics.setValue(0, forKeyPath: "latitude")
    metricsParticleDynamics.setValue(0, forKeyPath: "longitude")
    metricsParticleDynamics.setValue(0, forKeyPath: "rM")
    
    metricsPlant.setValue(0, forKeyPath: "dim1")
    metricsPlant.setValue(0, forKeyPath: "dim2")
    metricsPlant.setValue(0, forKeyPath: "dim3")
    metricsPlant.setValue(0, forKeyPath: "dim4")
    metricsPlant.setValue(0, forKeyPath: "dim5")
    metricsPlant.setValue(0, forKeyPath: "dim6")
    metricsPlant.setValue(0, forKeyPath: "dim7")
    metricsPlant.setValue(0, forKeyPath: "dim8")
    metricsPlant.setValue(0, forKeyPath: "dim9")
    metricsPlant.setValue(0, forKeyPath: "datenum")
    metricsPlant.setValue(0, forKeyPath: "latitude")
    metricsPlant.setValue(0, forKeyPath: "longitude")
    metricsPlant.setValue(0, forKeyPath: "rM")
    
    metricsPolitical.setValue(0, forKeyPath: "dim1")
    metricsPolitical.setValue(0, forKeyPath: "dim2")
    metricsPolitical.setValue(0, forKeyPath: "dim3")
    metricsPolitical.setValue(0, forKeyPath: "dim4")
    metricsPolitical.setValue(0, forKeyPath: "dim5")
    metricsPolitical.setValue(0, forKeyPath: "dim6")
    metricsPolitical.setValue(0, forKeyPath: "dim7")
    metricsPolitical.setValue(0, forKeyPath: "dim8")
    metricsPolitical.setValue(0, forKeyPath: "dim9")
    metricsPolitical.setValue(0, forKeyPath: "datenum")
    metricsPolitical.setValue(0, forKeyPath: "latitude")
    metricsPolitical.setValue(0, forKeyPath: "longitude")
    metricsPolitical.setValue(0, forKeyPath: "rM")
    
    metricsHumanProteinFolding.setValue(0, forKeyPath: "dim1")
    metricsHumanProteinFolding.setValue(0, forKeyPath: "dim2")
    metricsHumanProteinFolding.setValue(0, forKeyPath: "dim3")
    metricsHumanProteinFolding.setValue(0, forKeyPath: "dim4")
    metricsHumanProteinFolding.setValue(0, forKeyPath: "dim5")
    metricsHumanProteinFolding.setValue(0, forKeyPath: "dim6")
    metricsHumanProteinFolding.setValue(0, forKeyPath: "dim7")
    metricsHumanProteinFolding.setValue(0, forKeyPath: "dim8")
    metricsHumanProteinFolding.setValue(0, forKeyPath: "dim9")
    metricsHumanProteinFolding.setValue(0, forKeyPath: "datenum")
    metricsHumanProteinFolding.setValue(0, forKeyPath: "latitude")
    metricsHumanProteinFolding.setValue(0, forKeyPath: "longitude")
    metricsHumanProteinFolding.setValue(0, forKeyPath: "rM")
    
    metricsStoneArt.setValue(0, forKeyPath: "dim1")
    metricsStoneArt.setValue(0, forKeyPath: "dim2")
    metricsStoneArt.setValue(0, forKeyPath: "dim3")
    metricsStoneArt.setValue(0, forKeyPath: "dim4")
    metricsStoneArt.setValue(0, forKeyPath: "dim5")
    metricsStoneArt.setValue(0, forKeyPath: "dim6")
    metricsStoneArt.setValue(0, forKeyPath: "dim7")
    metricsStoneArt.setValue(0, forKeyPath: "dim8")
    metricsStoneArt.setValue(0, forKeyPath: "dim9")
    metricsStoneArt.setValue(0, forKeyPath: "datenum")
    metricsStoneArt.setValue(0, forKeyPath: "latitude")
    metricsStoneArt.setValue(0, forKeyPath: "longitude")
    metricsStoneArt.setValue(0, forKeyPath: "rM")
    
    metricsTeachingModels.setValue(0, forKeyPath: "dim1")
    metricsTeachingModels.setValue(0, forKeyPath: "dim2")
    metricsTeachingModels.setValue(0, forKeyPath: "dim3")
    metricsTeachingModels.setValue(0, forKeyPath: "dim4")
    metricsTeachingModels.setValue(0, forKeyPath: "dim5")
    metricsTeachingModels.setValue(0, forKeyPath: "dim6")
    metricsTeachingModels.setValue(0, forKeyPath: "dim7")
    metricsTeachingModels.setValue(0, forKeyPath: "dim8")
    metricsTeachingModels.setValue(0, forKeyPath: "dim9")
    metricsTeachingModels.setValue(0, forKeyPath: "datenum")
    metricsTeachingModels.setValue(0, forKeyPath: "latitude")
    metricsTeachingModels.setValue(0, forKeyPath: "longitude")
    metricsTeachingModels.setValue(0, forKeyPath: "rM")
    
    metricsTextiles.setValue(0, forKeyPath: "dim1")
    metricsTextiles.setValue(0, forKeyPath: "dim2")
    metricsTextiles.setValue(0, forKeyPath: "dim3")
    metricsTextiles.setValue(0, forKeyPath: "dim4")
    metricsTextiles.setValue(0, forKeyPath: "dim5")
    metricsTextiles.setValue(0, forKeyPath: "dim6")
    metricsTextiles.setValue(0, forKeyPath: "dim7")
    metricsTextiles.setValue(0, forKeyPath: "dim8")
    metricsTextiles.setValue(0, forKeyPath: "dim9")
    metricsTextiles.setValue(0, forKeyPath: "datenum")
    metricsTextiles.setValue(0, forKeyPath: "latitude")
    metricsTextiles.setValue(0, forKeyPath: "longitude")
    metricsTextiles.setValue(0, forKeyPath: "rM")
    
    metricsUSAfricanAmericanCulture.setValue(0, forKeyPath: "dim1")
    metricsUSAfricanAmericanCulture.setValue(0, forKeyPath: "dim2")
    metricsUSAfricanAmericanCulture.setValue(0, forKeyPath: "dim3")
    metricsUSAfricanAmericanCulture.setValue(0, forKeyPath: "dim4")
    metricsUSAfricanAmericanCulture.setValue(0, forKeyPath: "dim5")
    metricsUSAfricanAmericanCulture.setValue(0, forKeyPath: "dim6")
    metricsUSAfricanAmericanCulture.setValue(0, forKeyPath: "dim7")
    metricsUSAfricanAmericanCulture.setValue(0, forKeyPath: "dim8")
    metricsUSAfricanAmericanCulture.setValue(0, forKeyPath: "dim9")
    metricsUSAfricanAmericanCulture.setValue(0, forKeyPath: "datenum")
    metricsUSAfricanAmericanCulture.setValue(0, forKeyPath: "latitude")
    metricsUSAfricanAmericanCulture.setValue(0, forKeyPath: "longitude")
    metricsUSAfricanAmericanCulture.setValue(0, forKeyPath: "rM")
    
    metricsUSAsianAmericanCulture.setValue(0, forKeyPath: "dim1")
    metricsUSAsianAmericanCulture.setValue(0, forKeyPath: "dim2")
    metricsUSAsianAmericanCulture.setValue(0, forKeyPath: "dim3")
    metricsUSAsianAmericanCulture.setValue(0, forKeyPath: "dim4")
    metricsUSAsianAmericanCulture.setValue(0, forKeyPath: "dim5")
    metricsUSAsianAmericanCulture.setValue(0, forKeyPath: "dim6")
    metricsUSAsianAmericanCulture.setValue(0, forKeyPath: "dim7")
    metricsUSAsianAmericanCulture.setValue(0, forKeyPath: "dim8")
    metricsUSAsianAmericanCulture.setValue(0, forKeyPath: "dim9")
    metricsUSAsianAmericanCulture.setValue(0, forKeyPath: "datenum")
    metricsUSAsianAmericanCulture.setValue(0, forKeyPath: "latitude")
    metricsUSAsianAmericanCulture.setValue(0, forKeyPath: "longitude")
    metricsUSAsianAmericanCulture.setValue(0, forKeyPath: "rM")
    
    metricsUSCensusEducation.setValue(0, forKeyPath: "dim1")
    metricsUSCensusEducation.setValue(0, forKeyPath: "dim2")
    metricsUSCensusEducation.setValue(0, forKeyPath: "dim3")
    metricsUSCensusEducation.setValue(0, forKeyPath: "dim4")
    metricsUSCensusEducation.setValue(0, forKeyPath: "dim5")
    metricsUSCensusEducation.setValue(0, forKeyPath: "dim6")
    metricsUSCensusEducation.setValue(0, forKeyPath: "dim7")
    metricsUSCensusEducation.setValue(0, forKeyPath: "dim8")
    metricsUSCensusEducation.setValue(0, forKeyPath: "dim9")
    metricsUSCensusEducation.setValue(0, forKeyPath: "datenum")
    metricsUSCensusEducation.setValue(0, forKeyPath: "latitude")
    metricsUSCensusEducation.setValue(0, forKeyPath: "longitude")
    metricsUSCensusEducation.setValue(0, forKeyPath: "rM")
    
    metricsUSCensusEmployment.setValue(0, forKeyPath: "dim1")
    metricsUSCensusEmployment.setValue(0, forKeyPath: "dim2")
    metricsUSCensusEmployment.setValue(0, forKeyPath: "dim3")
    metricsUSCensusEmployment.setValue(0, forKeyPath: "dim4")
    metricsUSCensusEmployment.setValue(0, forKeyPath: "dim5")
    metricsUSCensusEmployment.setValue(0, forKeyPath: "dim6")
    metricsUSCensusEmployment.setValue(0, forKeyPath: "dim7")
    metricsUSCensusEmployment.setValue(0, forKeyPath: "dim8")
    metricsUSCensusEmployment.setValue(0, forKeyPath: "dim9")
    metricsUSCensusEmployment.setValue(0, forKeyPath: "datenum")
    metricsUSCensusEmployment.setValue(0, forKeyPath: "latitude")
    metricsUSCensusEmployment.setValue(0, forKeyPath: "longitude")
    metricsUSCensusEmployment.setValue(0, forKeyPath: "rM")
    
    metricsUSCensusIncomeAndPoverty.setValue(0, forKeyPath: "dim1")
    metricsUSCensusIncomeAndPoverty.setValue(0, forKeyPath: "dim2")
    metricsUSCensusIncomeAndPoverty.setValue(0, forKeyPath: "dim3")
    metricsUSCensusIncomeAndPoverty.setValue(0, forKeyPath: "dim4")
    metricsUSCensusIncomeAndPoverty.setValue(0, forKeyPath: "dim5")
    metricsUSCensusIncomeAndPoverty.setValue(0, forKeyPath: "dim6")
    metricsUSCensusIncomeAndPoverty.setValue(0, forKeyPath: "dim7")
    metricsUSCensusIncomeAndPoverty.setValue(0, forKeyPath: "dim8")
    metricsUSCensusIncomeAndPoverty.setValue(0, forKeyPath: "dim9")
    metricsUSCensusIncomeAndPoverty.setValue(0, forKeyPath: "datenum")
    metricsUSCensusIncomeAndPoverty.setValue(0, forKeyPath: "latitude")
    metricsUSCensusIncomeAndPoverty.setValue(0, forKeyPath: "longitude")
    metricsUSCensusIncomeAndPoverty.setValue(0, forKeyPath: "rM")
    
    metricsUSCensusPublicHealth.setValue(0, forKeyPath: "dim1")
    metricsUSCensusPublicHealth.setValue(0, forKeyPath: "dim2")
    metricsUSCensusPublicHealth.setValue(0, forKeyPath: "dim3")
    metricsUSCensusPublicHealth.setValue(0, forKeyPath: "dim4")
    metricsUSCensusPublicHealth.setValue(0, forKeyPath: "dim5")
    metricsUSCensusPublicHealth.setValue(0, forKeyPath: "dim6")
    metricsUSCensusPublicHealth.setValue(0, forKeyPath: "dim7")
    metricsUSCensusPublicHealth.setValue(0, forKeyPath: "dim8")
    metricsUSCensusPublicHealth.setValue(0, forKeyPath: "dim9")
    metricsUSCensusPublicHealth.setValue(0, forKeyPath: "datenum")
    metricsUSCensusPublicHealth.setValue(0, forKeyPath: "latitude")
    metricsUSCensusPublicHealth.setValue(0, forKeyPath: "longitude")
    metricsUSCensusPublicHealth.setValue(0, forKeyPath: "rM")
    
    metricsUSCensusRaceAndEthnicity.setValue(0, forKeyPath: "dim1")
    metricsUSCensusRaceAndEthnicity.setValue(0, forKeyPath: "dim2")
    metricsUSCensusRaceAndEthnicity.setValue(0, forKeyPath: "dim3")
    metricsUSCensusRaceAndEthnicity.setValue(0, forKeyPath: "dim4")
    metricsUSCensusRaceAndEthnicity.setValue(0, forKeyPath: "dim5")
    metricsUSCensusRaceAndEthnicity.setValue(0, forKeyPath: "dim6")
    metricsUSCensusRaceAndEthnicity.setValue(0, forKeyPath: "dim7")
    metricsUSCensusRaceAndEthnicity.setValue(0, forKeyPath: "dim8")
    metricsUSCensusRaceAndEthnicity.setValue(0, forKeyPath: "dim9")
    metricsUSCensusRaceAndEthnicity.setValue(0, forKeyPath: "datenum")
    metricsUSCensusRaceAndEthnicity.setValue(0, forKeyPath: "latitude")
    metricsUSCensusRaceAndEthnicity.setValue(0, forKeyPath: "longitude")
    metricsUSCensusRaceAndEthnicity.setValue(0, forKeyPath: "rM")
    
    metricsUSCensusSmallBusiness.setValue(0, forKeyPath: "dim1")
    metricsUSCensusSmallBusiness.setValue(0, forKeyPath: "dim2")
    metricsUSCensusSmallBusiness.setValue(0, forKeyPath: "dim3")
    metricsUSCensusSmallBusiness.setValue(0, forKeyPath: "dim4")
    metricsUSCensusSmallBusiness.setValue(0, forKeyPath: "dim5")
    metricsUSCensusSmallBusiness.setValue(0, forKeyPath: "dim6")
    metricsUSCensusSmallBusiness.setValue(0, forKeyPath: "dim7")
    metricsUSCensusSmallBusiness.setValue(0, forKeyPath: "dim8")
    metricsUSCensusSmallBusiness.setValue(0, forKeyPath: "dim9")
    metricsUSCensusSmallBusiness.setValue(0, forKeyPath: "datenum")
    metricsUSCensusSmallBusiness.setValue(0, forKeyPath: "latitude")
    metricsUSCensusSmallBusiness.setValue(0, forKeyPath: "longitude")
    metricsUSCensusSmallBusiness.setValue(0, forKeyPath: "rM")
    
    metricsUSEconomics.setValue(0, forKeyPath: "dim1")
    metricsUSEconomics.setValue(0, forKeyPath: "dim2")
    metricsUSEconomics.setValue(0, forKeyPath: "dim3")
    metricsUSEconomics.setValue(0, forKeyPath: "dim4")
    metricsUSEconomics.setValue(0, forKeyPath: "dim5")
    metricsUSEconomics.setValue(0, forKeyPath: "dim6")
    metricsUSEconomics.setValue(0, forKeyPath: "dim7")
    metricsUSEconomics.setValue(0, forKeyPath: "dim8")
    metricsUSEconomics.setValue(0, forKeyPath: "dim9")
    metricsUSEconomics.setValue(0, forKeyPath: "datenum")
    metricsUSEconomics.setValue(0, forKeyPath: "latitude")
    metricsUSEconomics.setValue(0, forKeyPath: "longitude")
    metricsUSEconomics.setValue(0, forKeyPath: "rM")
    
    metricsUSFinance.setValue(0, forKeyPath: "dim1")
    metricsUSFinance.setValue(0, forKeyPath: "dim2")
    metricsUSFinance.setValue(0, forKeyPath: "dim3")
    metricsUSFinance.setValue(0, forKeyPath: "dim4")
    metricsUSFinance.setValue(0, forKeyPath: "dim5")
    metricsUSFinance.setValue(0, forKeyPath: "dim6")
    metricsUSFinance.setValue(0, forKeyPath: "dim7")
    metricsUSFinance.setValue(0, forKeyPath: "dim8")
    metricsUSFinance.setValue(0, forKeyPath: "dim9")
    metricsUSFinance.setValue(0, forKeyPath: "datenum")
    metricsUSFinance.setValue(0, forKeyPath: "latitude")
    metricsUSFinance.setValue(0, forKeyPath: "longitude")
    metricsUSFinance.setValue(0, forKeyPath: "rM")
    
    metricsUSLatinAmericanCulture.setValue(0, forKeyPath: "dim1")
    metricsUSLatinAmericanCulture.setValue(0, forKeyPath: "dim2")
    metricsUSLatinAmericanCulture.setValue(0, forKeyPath: "dim3")
    metricsUSLatinAmericanCulture.setValue(0, forKeyPath: "dim4")
    metricsUSLatinAmericanCulture.setValue(0, forKeyPath: "dim5")
    metricsUSLatinAmericanCulture.setValue(0, forKeyPath: "dim6")
    metricsUSLatinAmericanCulture.setValue(0, forKeyPath: "dim7")
    metricsUSLatinAmericanCulture.setValue(0, forKeyPath: "dim8")
    metricsUSLatinAmericanCulture.setValue(0, forKeyPath: "dim9")
    metricsUSLatinAmericanCulture.setValue(0, forKeyPath: "datenum")
    metricsUSLatinAmericanCulture.setValue(0, forKeyPath: "latitude")
    metricsUSLatinAmericanCulture.setValue(0, forKeyPath: "longitude")
    metricsUSLatinAmericanCulture.setValue(0, forKeyPath: "rM")
    
    metricsUSNativeAmericanCulture.setValue(0, forKeyPath: "dim1")
    metricsUSNativeAmericanCulture.setValue(0, forKeyPath: "dim2")
    metricsUSNativeAmericanCulture.setValue(0, forKeyPath: "dim3")
    metricsUSNativeAmericanCulture.setValue(0, forKeyPath: "dim4")
    metricsUSNativeAmericanCulture.setValue(0, forKeyPath: "dim5")
    metricsUSNativeAmericanCulture.setValue(0, forKeyPath: "dim6")
    metricsUSNativeAmericanCulture.setValue(0, forKeyPath: "dim7")
    metricsUSNativeAmericanCulture.setValue(0, forKeyPath: "dim8")
    metricsUSNativeAmericanCulture.setValue(0, forKeyPath: "dim9")
    metricsUSNativeAmericanCulture.setValue(0, forKeyPath: "datenum")
    metricsUSNativeAmericanCulture.setValue(0, forKeyPath: "latitude")
    metricsUSNativeAmericanCulture.setValue(0, forKeyPath: "longitude")
    metricsUSNativeAmericanCulture.setValue(0, forKeyPath: "rM")
    
    metricsUSNativeHawaiianAndPacificIslanderCulture.setValue(0, forKeyPath: "dim1")
    metricsUSNativeHawaiianAndPacificIslanderCulture.setValue(0, forKeyPath: "dim2")
    metricsUSNativeHawaiianAndPacificIslanderCulture.setValue(0, forKeyPath: "dim3")
    metricsUSNativeHawaiianAndPacificIslanderCulture.setValue(0, forKeyPath: "dim4")
    metricsUSNativeHawaiianAndPacificIslanderCulture.setValue(0, forKeyPath: "dim5")
    metricsUSNativeHawaiianAndPacificIslanderCulture.setValue(0, forKeyPath: "dim6")
    metricsUSNativeHawaiianAndPacificIslanderCulture.setValue(0, forKeyPath: "dim7")
    metricsUSNativeHawaiianAndPacificIslanderCulture.setValue(0, forKeyPath: "dim8")
    metricsUSNativeHawaiianAndPacificIslanderCulture.setValue(0, forKeyPath: "dim9")
    metricsUSNativeHawaiianAndPacificIslanderCulture.setValue(0, forKeyPath: "datenum")
    metricsUSNativeHawaiianAndPacificIslanderCulture.setValue(0, forKeyPath: "latitude")
    metricsUSNativeHawaiianAndPacificIslanderCulture.setValue(0, forKeyPath: "longitude")
    metricsUSNativeHawaiianAndPacificIslanderCulture.setValue(0, forKeyPath: "rM")
    
    
    metricsUSWhiteAmericanCulture.setValue(0, forKeyPath: "dim1")
    metricsUSWhiteAmericanCulture.setValue(0, forKeyPath: "dim2")
    metricsUSWhiteAmericanCulture.setValue(0, forKeyPath: "dim3")
    metricsUSWhiteAmericanCulture.setValue(0, forKeyPath: "dim4")
    metricsUSWhiteAmericanCulture.setValue(0, forKeyPath: "dim5")
    metricsUSWhiteAmericanCulture.setValue(0, forKeyPath: "dim6")
    metricsUSWhiteAmericanCulture.setValue(0, forKeyPath: "dim7")
    metricsUSWhiteAmericanCulture.setValue(0, forKeyPath: "dim8")
    metricsUSWhiteAmericanCulture.setValue(0, forKeyPath: "dim9")
    metricsUSWhiteAmericanCulture.setValue(0, forKeyPath: "datenum")
    metricsUSWhiteAmericanCulture.setValue(0, forKeyPath: "latitude")
    metricsUSWhiteAmericanCulture.setValue(0, forKeyPath: "longitude")
    metricsUSWhiteAmericanCulture.setValue(0, forKeyPath: "rM")
    
    metricsViralDiseasesModel.setValue(0, forKeyPath: "dim1")
    metricsViralDiseasesModel.setValue(0, forKeyPath: "dim2")
    metricsViralDiseasesModel.setValue(0, forKeyPath: "dim3")
    metricsViralDiseasesModel.setValue(0, forKeyPath: "dim4")
    metricsViralDiseasesModel.setValue(0, forKeyPath: "dim5")
    metricsViralDiseasesModel.setValue(0, forKeyPath: "dim6")
    metricsViralDiseasesModel.setValue(0, forKeyPath: "dim7")
    metricsViralDiseasesModel.setValue(0, forKeyPath: "dim8")
    metricsViralDiseasesModel.setValue(0, forKeyPath: "dim9")
    metricsViralDiseasesModel.setValue(0, forKeyPath: "datenum")
    metricsViralDiseasesModel.setValue(0, forKeyPath: "latitude")
    metricsViralDiseasesModel.setValue(0, forKeyPath: "longitude")
    metricsViralDiseasesModel.setValue(0, forKeyPath: "rM")
    
    
    
    do {
      try managedContext.save()
      //MetricsAll.append(metricsAll)
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
