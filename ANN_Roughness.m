input  = OverallipNormalizedRoughness;
input = input(randperm(size(input,1)),:); %Shuffling the data set randomly

rng("default") % For reproducibility of the data partitions
cvp1 = cvpartition(size(input,1),"Holdout",3/27);
testTbl = input(test(cvp1),:);
trainTbl = input(training(cvp1),:);

params = hyperparameters("fitrnet",input,"NormalizedRoughness");% hyperparamters of the ANN
params(1).Range = [1 3];%Num of layers
params(3).Optimize = false; %standardization
params(7).Range = [1 20];
params(8).Range = [1 20];
params(9).Range = [1 5];

rng("default") % For reproducibility
Model = fitrnet(trainTbl,"NormalizedRoughness","OptimizeHyperparameters",params, ...
    "HyperparameterOptimizationOptions",struct("AcquisitionFunctionName","expected-improvement-plus","KFold",5, "MaxObjectiveEvaluations",100));

predictedY = predict(Model,input);
predictedYTest = predict(Model,testTbl);

R1 = corr(input.NormalizedRoughness, predictedY).^2;
R = corr(testTbl.NormalizedRoughness, predictedYTest).^2;

% plot(input.NormalizedToolwear,predictedY,".");
% 
% hold on;
% 
% plot(input.NormalizedToolwear,input.NormalizedToolwear);
% 
% hold off;

CVModel = crossval(Model,"kfold",5);

%save('Model_ToolWear.mat','Model');