%arrays of correlation i/p and o/p's
R_array = {};
R1_array = {};

for i = 1 : 60
input = OverallipNormalizedRoughness ;
rng(i,"twister"); %Reproducibilty of shuffling
input = input(randperm(size(input,1)),:) ; %Shuffling the data set 

rng("default") % For reproducibility of the data partitions
cvp1 = cvpartition(size(input,1),"Holdout",3/27);
testTbl = input(test(cvp1),:);
trainTbl = input(training(cvp1),:);

% Write code for Model(SVM's, ANN's,Ensembles)


%Prediction Metrics
predictedY = predict(Model,testTbl(:,["NormalizedFmmrev","NormalizedVmmin","NormalizedTmin"]));
predictedY1 = predict(Model,input);
R = corr(testTbl.NormalizedRoughness, predictedY).^2;
R1 = corr(input.NormalizedRoughness, predictedY1).^2;

%filled arrays
R_array = [R_array,R];
R1_array = [R1_array,R1];

end