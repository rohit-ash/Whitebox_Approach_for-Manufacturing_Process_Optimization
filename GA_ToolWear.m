nvars = 3;
options = optimoptions('ga','ConstraintTolerance',1e-6,'PlotFcn', @gaplotbestf,'PopulationSize',100,'Generations',100,'EliteCount',2,'CrossoverFraction',0.8,'MutationFcn',@mutationadaptfeasible);
[x,fval] = ga(ToolWear_func,nvars,[],[],[],[],[0 0 0],[1 1 1],[],options);