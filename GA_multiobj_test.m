fitnessfcn = @(x)[sin(x),cos(x)];
options = optimoptions('gamultiobj','ConstraintTolerance',1e-6,'PlotFcn',"gaplotpareto",'PopulationSize',500,'Generations',200,'CrossoverFraction',0.8,'MutationFcn',@mutationadaptfeasible,'ParetoFraction',0.9);
rng default;
[x,fval,~,gaoutput] = gamultiobj(fitnessfcn,1,[],[],[],[],0,2*pi,options);
