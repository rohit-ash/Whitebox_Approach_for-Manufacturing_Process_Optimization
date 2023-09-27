nvars = 3;
options = optimoptions('gamultiobj','ConstraintTolerance',100,'PlotFcn',"gaplotpareto",'PopulationSize',100,'Generations',300,'CrossoverFraction',0.8,'MutationFcn',@mutationadaptfeasible);
rng default;
[norm_x,fval] = gamultiobj(Func_Multiobj_Ensemble_TW_Pow,nvars,[],[],[],[],[0 0 0],[1 1 1],[],options);

x = zeros(3,1);
x(1) = norm_x(1)*250 + 250;
x(2) = norm_x(2)*0.15 + 0.05;
x(3) = norm_x(3)*9 + 1;
