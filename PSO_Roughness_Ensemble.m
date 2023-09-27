nvars = 3;
options = optimoptions('particleswarm','SwarmSize',100,'FunctionTolerance',1e-6,'PlotFcn','pswplotbestf');
[norm_x,fval,exitflag,output] = particleswarm(Roughness_Ensemble_func,nvars,[0 0 0],[1 1 1],options);

x = zeros(3,1);
x(1) = norm_x(1)*250 + 250;
x(2) = norm_x(2)*0.15 + 0.05;
x(3) = norm_x(3)*9 + 1;