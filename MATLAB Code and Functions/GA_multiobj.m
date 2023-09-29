tic;
nvars = 3;
options = optimoptions('gamultiobj','ConstraintTolerance',1e-6,'PlotFcn',"gaplotpareto",'PopulationSize',500,'Generations',100,'CrossoverFraction',0.8,'MutationFcn',@mutationadaptfeasible,'ParetoFraction',0.35);
rng default;
[norm_x,fval,~,gaoutput] = gamultiobj(Func_Multiobj_Ensemble,nvars,[],[],[],[],[0 0 0],[1 1 1],options);



% x = zeros(3,1);
% x(1) = norm_x(1)*250 + 250;
% x(2) = norm_x(2)*0.15 + 0.05;
% x(3) = norm_x(3)*9 + 1;
% toc;


%     funEvals=0;
%     bestFitness=inf;
%     [x,fval,exitflag,output,population,scores]  = ga(@FitnessFcn,...);
%       fval=bestFitness;
%    function val = FitnessFcn(x)
%         ...
%         bestFitness=min(bestFitness,val);
%         funEvals=funEvals+1; %increment counter
%         if funEvals>=MaxFunEvals
%             val=-inf;
%         end
%    end
