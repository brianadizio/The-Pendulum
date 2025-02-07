oldM=("FluidFlow")
oldB=("block2s2")
oldF=("homotopyFluidFlowMaze_2023-11-26")
oldG=("GameSceneFluidFlowMaze")

newMDemo=("Gravity" "Birds")
newBDemo=("block2s" "block2s")
#newFDemo = ("GameSceneGravityMaze" "GameSceneBirdsMaze")
newGDemo=("GameSceneFluidFlowMaze")
newDateDemo="2023-12-10"

newM=("Gravity" "Birds" "Agricultural" "AnimalGeneExpression" "Architecture" "Astronomy" "BigBang" "Brain" "CancerModel" "Climatological" "DiabetesModels" "FacesAndPortraits" "Food" "Fractal" "Furniture" "HumanGeneExpression" "HumanLifeModels" "Magnetics" "Materials" "NeuralDiseaseModels" "ParticleDynamics" "Plants"  "Political" "HumanProteinFolding" "StoneArt" "TeachingModels" "Textiles" "USAfricanAmericanCulture" "USAsianAmericanCulture" "USCensusEducation" "USCensusEmployment" "USCensusIncomeAndPoverty" "USCensusPublicHealth" "USCensusRaceAndEthnicity" "USCensusSmallBusiness" "USEconomics" "USFinance" "USLatinAmericanCulture" "USNativeAmericanCulture" "USNativeHawaiianAndPacificIslanderCulture" "USWhiteAmericanCulture" "ViralDiseaseModels")

newDate="2023-12-14"

newN=("Gravity" "Birds" "Agricultural" "Animal Gene Expression" "Architecture" "Astronomy" "Big Bang" "Brain" "Cancer Models" "Climatological" "Diabetes Models" "Faces and Portraits" "Food" "Fractals" "Furniture" "Human Gene Expression" "Human Life Models" "Magnetics" "Materials" "Neural Disease Models" "Particle Dynamics" "Plants"  "Political Models" "Human Protein Folding" "Stone Art" "Teaching Models" "Textiles" "African American Culture" "Asian American Culture" "US Education" "US Employment" "US Income and Poverty" "US Public Health" "US Race and Ethnicity" "US Small Business" "US Economics" "US Finance" "Latin American Culture" "Native American Culture" "Native Hawaiian And Pacific Islander American Culture" "White American Culture" "Viral Disease Models")


for ((i=0; i<47; i++)); do

# GameScene.  Originally, you must manually create the first copy of GameSceneMainMaze.swift into GameSceneFluidFlowMaze.swift and then use that as the base file here.

cp "GameSceneFluidFlowMaze.swift" "GameScene${newM[i]}Maze.swift"
find . -name "GameScene${newM[i]}Maze.swift" -print0 | xargs -0 sed -i "" "s/Metrics${oldM[0]}/Metrics${newM[i]}/g"

find . -name "GameScene${newM[i]}Maze.swift" -print0 | xargs -0 sed -i "" "s/block2s2/block2s${i}/g"
find . -name "GameScene${newM[i]}Maze.swift" -print0 | xargs -0 sed -i "" "s/homotopyFluidFlowMazes2023-11-26/homotopy${newM[i]}Mazes${newDate}/g"
find . -name "GameScene${newM[i]}Maze.swift" -print0 | xargs -0 sed -i "" "s/GameSceneFluidFlowMaze/GameScene${newM[i]}Maze/g"

# GameViewController.  Later create a view controller on the storyboard and add these classes to them.  Originally, manually copy GameViewControllerMainMaze.swift into GameViewControllerFluidFlowMaze.swift and then use that as the base file here.

cp "GameViewControllerFluidFlowMaze.swift" "GameViewController${newM[i]}Maze.swift"

find . -name "GameViewController${newM[i]}Maze.swift" -print0 | xargs -0 sed -i "" "s/saveMode(mode: \"MetricsFluidFlow\")/saveMode(mode: \"MetricsFluidFlow\", modeName: \"${newN[i]}\")/g"
find . -name "GameViewController${newM[i]}Maze.swift" -print0 | xargs -0 sed -i "" "s/Metrics${oldM[0]}/Metrics${newM[i]}/g"
find . -name "GameViewController${newM[i]}Maze.swift" -print0 | xargs -0 sed -i "" "s/GameViewControllerFluidFlowMaze/GameViewController${newM[i]}Maze/g"
find . -name "GameViewController${newM[i]}Maze.swift" -print0 | xargs -0 sed -i "" "s/GameSceneFluidFlowMaze/GameScene${newM[i]}Maze/g"




done
