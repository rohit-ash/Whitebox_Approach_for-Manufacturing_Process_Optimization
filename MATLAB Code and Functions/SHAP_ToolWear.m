%Data loading and shuffling
input = OverallipNormalizedToolWear;

rng(220,"twister"); %Reproducibility of shuffling
input = input(randperm(size(input,1)),:) ; %Shuffling the data set 

rng("default") % For reproducibility of the data partitions
cvp1 = cvpartition(size(input,1),"Holdout",3/27);
testTbl = input(test(cvp1),:);
trainTbl = input(training(cvp1),:);

%Loading Model
load Ensemble_ToolWear_hyperparam_optimized.mat ;

%XAI - SHAP - Beeswarm Plot
X_train = trainTbl(:,["NormalizedCuttingSpeed","NormalizedFeedRate","NormalizedCuttingTime"]);
r = size(trainTbl,1); 
c = 3;
shap=zeros(r,c);
for i=1:r
    % Set 'UseParallel' to true to parallelize inside the shapley function.
    % For this small example running inside MATLAB answers, we will set
    % 'UseParallel' to false.
    explainer=shapley(Model,'QueryPoint',X_train(i,:),'UseParallel',false);
    % Store the shapley values in a matrix referenced by (query-point-index, predictor-index)
    shap(i,:)=explainer.ShapleyValues{:,2};  
end

t = tiledlayout(1,2);

% Tile 1
nexttile
[sortedMeanAbsShapValues,sortedPredictorIndices]=sort(mean(abs(shap)));
% Loop over the predictors, plot a row of points for each predictor using
% the scatter function with "density" jitter.
% The multiple calls to scatter are needed so that the jitter is normalized
% per-row, rather than globally over all the rows.
for p=1:c
   scatter(shap(:,sortedPredictorIndices(p)), ... % x-value of each point is the shapley value
           p*ones(r,1), ... % y-value of each point is an integer corresponding to a predictor (to be jittered below)
           [], ... % Marker size for each data point, taking the default here
           normalize(table2array(X_train(:,sortedPredictorIndices(p))),'range',[1 256]), ... % Colors based on feature values
           'filled', ... % Fills the circles representing data points
           'YJitter','density', ... % YJitter according to the density of the points in this row
           'YJitterWidth',0.3)
   if (p==1) 
       hold on; 
   end
end
xlabel(['Shapley Value (impact on model output)',newline,'\bf (a)'], 'FontSize', 16,'FontName','Times') 
colormap("cool"); % This colormap is like the one used in many Shapley summary plots
cb= colorbar('Ticks', [1 256], 'TickLabels', {'Low', 'High'});
cb.Label.String = "Scaled Feature Value";
cb.Label.FontSize = 18;
cb.Label.Rotation = 270;
cb.Label.FontName = 'Times';
set(gca, 'YGrid', 'on');
set(gcf,'color','w');
xline(0, 'LineWidth', 1);
row1 = {'Normalized' 'Normalized' 'Normalized'};
row2 = {'Feed' 'Cutting' 'Cutting'};
row3 = {'Rate' 'Time' 'Speed'};
labelArray = [row1; row2; row3]; 
labelArray = strjust(pad(labelArray),'center'); % 'left'(default)|'right'|'center
tickLabels = strtrim(sprintf('%s\\newline%s\\newline%s\n', labelArray{:}));
ax = gca(); 
ax.YTick = 1:3; 
ax.YTickLabel = tickLabels; 
ax.FontName = 'Times';
ax.FontSize = 16; 
hold off;

% Feature Importance Graph - SHAP
% Tile 2
nexttile
y = sortedMeanAbsShapValues;
b = barh(y,0.5,'red');
%yticklabels(convertCharsToStrings(X_train.Properties.VariableNames(sortedPredictorIndices)));
xlabel(['Mean(|SHAP Value|)',newline,'\bf (b)'], 'FontSize', 16,'FontName','Times');
xlim([0 0.21]);
set(gcf,'color','w');
text(b.YEndPoints +0.004,b.XEndPoints,string(round(b.YData,3)),'VerticalAlignment','middle','FontSize',14,'FontName','Times'); 
row1 = {'Normalized' 'Normalized' 'Normalized'};
row2 = {'Feed' 'Cutting' 'Cutting'};
row3 = {'Rate' 'Time' 'Speed'};
labelArray = [row1; row2; row3]; 
labelArray = strjust(pad(labelArray),'center'); % 'left'(default)|'right'|'center
tickLabels = strtrim(sprintf('%s\\newline%s\\newline%s\n', labelArray{:}));
ax = gca(); 
ax.YTick = 1:3; 
ax.YTickLabel = tickLabels; 
ax.FontName = 'Times';
ax.FontSize = 16; 

t.TileSpacing = 'tight';
t.Padding = 'compact';