function test = Roughness_Ensemble_func()
     load Ensemble_Roughness_hyperparam_optimized.mat ;
     test = @(x)(predict(Model,x)*3.47 + 0.33);
end
