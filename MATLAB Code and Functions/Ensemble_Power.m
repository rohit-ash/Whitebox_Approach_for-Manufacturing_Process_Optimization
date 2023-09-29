%Upload OverallipNormalized_Power.xlsx before running code
input = OverallipNormalizedPower;
rng(214,"twister"); %Reproducibility of shuffling
input = input(randperm(size(input,1)),:) ; %Shuffling the data set 

rng("default") % For reproducibility of the data partitions
cvp1 = cvpartition(size(input,1),"Holdout",3/27);
testTbl = input(test(cvp1),:);
trainTbl = input(training(cvp1),:);

% Write code for Model(SVM's, ANN's,Ensembles)
params = hyperparameters("fitrensemble",[input.NormalizedCuttingSpeed input.NormalizedFeedRate input.NormalizedCuttingTime],input.NormalizedPower,'Tree');% hyperparameters of the boosted ensemble
params(1).Optimize = false;
params(2).Range = [1 10];
params(4).Range = [1 5];
params(5).Optimize = true;
params(5).Range = [1 10];

rng("default"); %For Reproducibility - 8philox
t = templateTree("Reproducible",true,"MinParentSize",3);
Model = fitrensemble(trainTbl,'NormalizedPower','Learners',t, ...
    'OptimizeHyperparameters',params,...
    "HyperparameterOptimizationOptions",struct("AcquisitionFunctionName","expected-improvement-plus","KFold",5,"MaxObjectiveEvaluations",100));
%"Verbose",0,"ShowPlots",false

%Prediction Metrics
predictedY = predict(Model,testTbl(:,["NormalizedCuttingSpeed","NormalizedFeedRate","NormalizedCuttingTime"]));
predictedY1 = predict(Model,input);%Overall
predictedY2 = predict(Model,trainTbl(:,["NormalizedCuttingSpeed","NormalizedFeedRate","NormalizedCuttingTime"]));

R = corr(testTbl.NormalizedPower, predictedY).^2;%Test
R1 = corr(input.NormalizedPower, predictedY1).^2;%Overall
R2 = corr(trainTbl.NormalizedPower, predictedY2).^2;%Train
%crossVal errors and models

rng("default");
CV_Model = crossval(Model,"kfold",5);
kf_loss = kfoldLoss(CV_Model);
kf_loss_individual_Power = kfoldLoss(CV_Model,"Mode","individual"); 

save('Ensemble_Power_hyperparam_optimized.mat','Model');

plot(input.NormalizedPower,predictedY1,".");
xlabel('Actual Values');
ylabel('Predicted Values');
hold on;
grayColor = [.7 .7 .7];
plot(trainTbl.NormalizedPower,trainTbl.NormalizedPower,'Color',grayColor);
xlabel('Actual Values','FontSize',16)
ylabel('Predicted Values','FontSize',16)
hold off;
axis([0 1 -0.2 1]);

