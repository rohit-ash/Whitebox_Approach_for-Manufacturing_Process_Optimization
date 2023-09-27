fun = Func_Multiobj_Ensemble;
options = optimoptions('paretosearch','UseVectorized',true,'ParetoSetSize',100,...
    'PlotFcn','psplotparetof');
lb = [0 0 0];
ub = [1 1 1];
rng default % For reproducibility
[x,f] = paretosearch(fun,3,[],[],[],[],lb,ub,[],options);
