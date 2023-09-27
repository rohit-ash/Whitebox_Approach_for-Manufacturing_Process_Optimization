
input = OverallipNormalizedRoughness ;

rng(224,"twister"); %Reproducibilty of shuffling
input = input(randperm(size(input,1)),:) ; %Shuffling the data set randomly

rng("default") % For reproducibility of the data partitions
cvp1 = cvpartition(size(input,1),"Holdout",3/27);
testTbl = input(test(cvp1),:);
trainTbl = input(training(cvp1),:);

params = hyperparameters("fitrensemble",[input.NormalizedCuttingSpeed input.NormalizedFeedRate input.NormalizedCuttingTime],input.NormalizedRoughness,'Tree');% hyperparameters of the boosted ensemble
params(1).Optimize = false;
params(2).Range = [1 10];
params(4).Range = [1 5];
params(5).Optimize = true;
params(5).Range = [1 10];

rng("default"); %For Reproducibility 
t = templateTree("Reproducible",true,"MinParentSize",3);
Model = fitrensemble(trainTbl,'NormalizedRoughness','Learners',t, ...
    'OptimizeHyperparameters',params,...
    "HyperparameterOptimizationOptions",struct("AcquisitionFunctionName","expected-improvement-plus","KFold",5,"MaxObjectiveEvaluations",100));

predictedY = predict(Model,testTbl(:,["NormalizedCuttingSpeed","NormalizedFeedRate","NormalizedCuttingTime"]));
predictedY1 = predict(Model,input);
predictedY2 = predict(Model,trainTbl(:,["NormalizedCuttingSpeed","NormalizedFeedRate","NormalizedCuttingTime"]));

R = corr(testTbl.NormalizedRoughness, predictedY).^2;
R1 = corr(input.NormalizedRoughness, predictedY1).^2;
R2 = corr(trainTbl.NormalizedRoughness, predictedY2).^2;

%crossVal errors and models

rng("default");
CV_Model = crossval(Model,"kfold",5);
kf_loss = kfoldLoss(CV_Model);
kf_loss_individual = kfoldLoss(CV_Model,"Mode","individual"); 

save('Ensemble_Roughness_hyperparam_optimized.mat','Model');

testMSE = loss(Model,testTbl,"NormalizedRoughness");

% plot(testTbl.NormalizedRoughness,predictedY,"k.");
% hold on;
% grayColor = [.7 .7 .7];
% plot(trainTbl.NormalizedRoughness,trainTbl.NormalizedRoughness,'Color',grayColor);
% xlabel('Actual Values','FontSize',16)
% ylabel('Predicted Values','FontSize',16)
% hold off;
% axis([0 1 -0.2 1]);