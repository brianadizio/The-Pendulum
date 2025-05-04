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
/// THE SOFTWARE.EDIT

import Foundation

public struct RazeFaceProducts {
  
  //public static let fluidFlowMaze = "app.goldenenterprises.TheMaze.fluidFlowMaze"
  //1
  public static let agriculturalMazes = "app.goldenenterprises.TheMaze.agriculturalMazes"
  //2
  public static let animalGeneExpressionMazes = "app.goldenenterprises.TheMaze.animalGeneExpressionMazes"
  //3
  public static let architectureMazes = "app.goldenenterprises.TheMaze.architectureMazes"
  //4
  public static let astronomyMazes = "app.goldenenterprises.TheMaze.astronomyMazes"
  //5
  public static let bigBangMazes = "app.goldenenterprises.TheMaze.bigBangMazes"
  //6
  public static let brainMazes = "app.goldenenterprises.TheMaze.brainMazes"
  //7
  public static let cancerModelMazes = "app.goldenenterprises.TheMaze.cancerModelMazes"
  //8
  public static let climatologicalMazes = "app.goldenenterprises.TheMaze.climatologicalMazes"
  //9
  public static let diabtetesModelsMazes = "app.goldenenterprises.TheMaze.diabetesModelsMazes"
  //10
  public static let facesAndPortraitsMazes = "app.goldenenterprises.TheMaze.facesAndPortraitsMazes"
  //11
  public static let foodMazes = "app.goldenenterprises.TheMaze.foodMazes"
  //12
  public static let fractalMazes = "app.goldenenterprises.TheMaze.fractalMazes"
  //13
  public static let furnitureMazes = "app.goldenenterprises.TheMaze.furnitureMazes"
  //14
  public static let humanGeneExpressionMazes = "app.goldenenterprises.TheMaze.humanGeneExpressionMazes"
  //15
  public static let humanLifeModelsMazes = "app.goldenenterprises.TheMaze.humanLifeModelsMazes"
  //16
  public static let magneticsMazes = "app.goldenenterprises.TheMaze.magneticsMazes"
  //17
  public static let materialsMazes = "app.goldenenterprises.TheMaze.materialsMazes"
  //18
  public static let neuralDiseasesModelsMazes = "app.goldenenterprises.TheMaze.neuralDiseasesModelsMazes"
  //19
  public static let particleDynamicsMazes = "app.goldenenterprises.TheMaze.particleDynamicsMazes"
  //20
  public static let plantsMazes = "app.goldenenterprises.TheMaze.plantsMazes"
  //21
  public static let politicalMazes = "app.goldenenterprises.TheMaze.politicalMazes"
  //22
  public static let proteinFoldingMazes = "app.goldenenterprises.TheMaze.proteinFoldingMazes"
  //23
  public static let stoneArtMazes = "app.goldenenterprises.TheMaze.stoneArtMazes"
  //24
  public static let teachingModelsMazes = "app.goldenenterprises.TheMaze.teachingModelsMazes"
  //25
  public static let textilesMazes = "app.goldenenterprises.TheMaze.textilesMazes"
  //26
  public static let uSAfricanAmericanCulture = "app.goldenenterprises.TheMaze.uSAfricanAmericanCulture"
  //27
  public static let uSAsianAmericanCulture = "app.goldenenterprises.TheMaze.uSAsianAmericanCulture"
  //28
  public static let uSEconomicsMazes = "app.goldenenterprises.TheMaze.uSEconomicsMazes"
  //29
  public static let uSEducationMazes = "app.goldenenterprises.TheMaze.uSEducationMazes"
  //30
  public static let uSFinancialMazes = "app.goldenenterprises.TheMaze.uSFinancialMazes"
  //31
  public static let uSEmploymentMazes = "app.goldenenterprises.TheMaze.uSEmploymentMazes"
  //32
  public static let uSIncomeAndPovertyMazes = "app.goldenenterprises.TheMaze.uSIncomeAndPovertyMazes"
  //33
  public static let uSLatinAmericanCultureMazes = "app.goldenenterprises.TheMaze.uSLatinAmericanCultureMazes"
  //34
  public static let uSNativeAmericanCultureMazes = "app.goldenenterprises.TheMaze.uSNativeAmericanCultureMazes"
  //35
  public static let uSNativeHawaiianAndPacificIslanderAmericanCultureMazes = "app.goldenenterprises.TheMaze.uSNativeHawaiianAndPacificIslanderAmericanCultureMazes"
  //36
  public static let uSPublicHealthMazes = "app.goldenenterprises.TheMaze.usPublicHealthMazes"
  //37
  public static let uSRaceAndEthnicityMazes = "app.goldenenterprises.TheMaze.uSRaceAndEthnicityMazes"
  //38
  public static let uSSmallBusinessMazes = "app.goldenenterprises.TheMaze.uSSmallBusinessMazes"
  //39
  public static let uSWhiteAmericanCulture = "app.goldenenterprises.TheMaze.uSWhiteAmericanCulture"
  //40
  public static let viralDiseasesModelsMazes = "app.goldenenterprises.TheMaze.viralDiseasesModelsMazes"
  
  private static let productIdentifiers: Set<ProductIdentifier> = [RazeFaceProducts.agriculturalMazes, RazeFaceProducts.animalGeneExpressionMazes, RazeFaceProducts.architectureMazes, RazeFaceProducts.astronomyMazes, RazeFaceProducts.bigBangMazes, RazeFaceProducts.brainMazes, RazeFaceProducts.cancerModelMazes, RazeFaceProducts.climatologicalMazes, RazeFaceProducts.diabtetesModelsMazes, RazeFaceProducts.facesAndPortraitsMazes, RazeFaceProducts.foodMazes, RazeFaceProducts.fractalMazes, RazeFaceProducts.furnitureMazes, RazeFaceProducts.humanGeneExpressionMazes, RazeFaceProducts.humanLifeModelsMazes, RazeFaceProducts.humanLifeModelsMazes, RazeFaceProducts.magneticsMazes, RazeFaceProducts.materialsMazes, RazeFaceProducts.neuralDiseasesModelsMazes, RazeFaceProducts.particleDynamicsMazes, RazeFaceProducts.plantsMazes, RazeFaceProducts.politicalMazes, RazeFaceProducts.proteinFoldingMazes, RazeFaceProducts.stoneArtMazes, RazeFaceProducts.teachingModelsMazes, RazeFaceProducts.textilesMazes, RazeFaceProducts.uSAfricanAmericanCulture, RazeFaceProducts.uSAsianAmericanCulture, RazeFaceProducts.uSEconomicsMazes, RazeFaceProducts.uSFinancialMazes, RazeFaceProducts.uSEducationMazes, RazeFaceProducts.uSEmploymentMazes, RazeFaceProducts.uSIncomeAndPovertyMazes, RazeFaceProducts.uSLatinAmericanCultureMazes, RazeFaceProducts.uSNativeAmericanCultureMazes, RazeFaceProducts.uSNativeHawaiianAndPacificIslanderAmericanCultureMazes, RazeFaceProducts.uSPublicHealthMazes, RazeFaceProducts.uSRaceAndEthnicityMazes, RazeFaceProducts.uSSmallBusinessMazes, RazeFaceProducts.uSWhiteAmericanCulture, RazeFaceProducts.viralDiseasesModelsMazes]

  public static let store = IAPHelper(productIds: RazeFaceProducts.productIdentifiers)
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
  return productIdentifier.components(separatedBy: ".").last
}
