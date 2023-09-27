input = OverallipNormalizedRoughness ;

rng("default"); %Reproducibilty of shuffling - 3,18,20,25,34,46,47,48,53 twister, 15,28,61,105,111,161,205,211 twister-good enuf,best - 79,104,129,154,179,204,229 twister - best possible - 224
input = input(randperm(size(input,1)),:) ; %Shuffling the data set randomly

rng("default") % For reproducibility of the data partitions
cvp1 = cvpartition(size(input,1),"Holdout",3/27);
testTbl = input(test(cvp1),:);
trainTbl = input(training(cvp1),:);

params = hyperparameters("fitrensemble",[input.NormalizedVmmin input.NormalizedFmmrev input.NormalizedTmin],input.NormalizedRoughness,'Tree');% hyperparameters of the boosted ensemble
params(1).Optimize = false;
params(2).Range = [1 10];
params(4).Range = [1 5];
params(5).Optimize = true;
params(5).Range = [1 10];

rng("default"); %For Reproducibility - 8philox
t = templateTree("Reproducible",true,"MinParentSize",3);
Model = fitrensemble(input,'NormalizedRoughness','Learners',t, ...
    'OptimizeHyperparameters',params,...
    "HyperparameterOptimizationOptions",struct("AcquisitionFunctionName","expected-improvement-plus","KFold",27,"MaxObjectiveEvaluations",100));
%"Verbose",0,"ShowPlots",false

predictedY = predict(Model,testTbl(:,["NormalizedFmmrev","NormalizedVmmin","NormalizedTmin"]));
predictedY1 = predict(Model,input);

%R = corr(testTbl.NormalizedRoughness, predictedY).^2;
R1 = corr(input.NormalizedRoughness, predictedY1).^2;

%crossVal errors and models
