function test = Power_Ensemble_func()
     load Ensemble_Power_hyperparam_optimized.mat ;
     test = @(x)(predict(Model,x)*2.11 + 0.69);
end
