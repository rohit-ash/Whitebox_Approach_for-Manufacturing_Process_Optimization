%Dataset loading and shuffling
input = OverallipNormalizedToolWear ;

rng(220,"twister"); %Reproducibilty of shuffling
input = input(randperm(size(input,1)),:) ; %Shuffling the data set randomly

rng("default") % For reproducibility of the data partitions
cvp1 = cvpartition(size(input,1),"Holdout",3/27);
testTbl = input(test(cvp1),:);
trainTbl = input(training(cvp1),:);

%Loading Model
load Ensemble_ToolWear_hyperparam_optimized.mat ;
load ToolWear_Objective_Results.mat ;
load ToolWear_Estimated_Objective_Results.mat ;

predictedY = predict(Model,testTbl(:,["NormalizedCuttingSpeed","NormalizedFeedRate","NormalizedCuttingTime"]));
predictedY1 = predict(Model,input);
predictedY2 = predict(Model,trainTbl(:,["NormalizedCuttingSpeed","NormalizedFeedRate","NormalizedCuttingTime"]));

R = corr(testTbl.NormalizedToolwear, predictedY).^2;
R1 = corr(input.NormalizedToolwear, predictedY1).^2;
R2 = corr(trainTbl.NormalizedToolwear, predictedY2).^2;

grayColor = [.7 .7 .7];

t = tiledlayout(2,2);

% Tile 1
nexttile
plot(trainTbl.NormalizedToolwear,trainTbl.NormalizedToolwear,'Color',grayColor,'LineWidth',2);
hold on;
plot(trainTbl.NormalizedToolwear,predictedY2,"k.",'MarkerSize',12);
xlabel(['Actual Values',newline,'\bf (a)'],'FontSize',11,'FontName', 'Times')
ylabel('Predicted Values','FontSize',11.5,'FontName', 'Times')
hold off;
axis([0 1 -0.2 1]);

% Tile 2
nexttile
plot(trainTbl.NormalizedToolwear,trainTbl.NormalizedToolwear,'Color',grayColor,'LineWidth',2);
hold on;
plot(testTbl.NormalizedToolwear,predictedY,"k.",'MarkerSize',12);
xlabel(['Actual Values',newline,'\bf (b)'],'FontSize',11,'FontName', 'Times')
ylabel('Predicted Values','FontSize',11.5,'FontName', 'Times')
hold off;
axis([0 1 -0.2 1]);

% Tile 3
nexttile
plot(trainTbl.NormalizedToolwear,trainTbl.NormalizedToolwear,'Color',grayColor,'LineWidth',2);
hold on;
plot(input.NormalizedToolwear,predictedY1,"k.",'MarkerSize',12);
xlabel(['Actual Values',newline,'\bf (c)'],'FontSize',11,'FontName', 'Times')
ylabel('Predicted Values','FontSize',11.5,'FontName', 'Times')
hold off;
axis([0 1 -0.2 1]);

% Tile 4
func_eval = 1:100;
nexttile
plot(func_eval,obj_trace,'-o','Color','blue','MarkerSize',2,'DisplayName','Min observed objective')
hold on
plot(func_eval,estim_obj_trace,'-o','Color','green','MarkerSize',2,'DisplayName','Estimated min objective')
xlabel(['Function Evaluations',newline,'\bf (d)'],'FontSize',11,'FontName','Times')
ylabel('Minimum Objective','FontSize',11.5,'FontName', 'Times')
hold off
lgd = legend;
lgd.FontSize = 8;

t.TileSpacing = 'tight';
t.Padding = 'tight';
