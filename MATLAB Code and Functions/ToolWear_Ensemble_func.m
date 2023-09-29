function test = ToolWear_Ensemble_func()
     load Ensemble_ToolWear_hyperparam_optimized.mat ;
     test = @(x)(predict(Model,x)*0.52 + 0.03);
end
