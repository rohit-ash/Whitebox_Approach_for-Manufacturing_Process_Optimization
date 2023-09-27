function multi_val = Func_Multiobj_Ensemble_TW_Pow()
     Roughness = load('Ensemble_Roughness_hyperparam_optimized.mat');
     ToolWear = load('Ensemble_ToolWear_hyperparam_optimized.mat');
     %Power = load('Ensemble_Power_hyperparam_optimized.mat');
     multi_val = @(x)[(Roughness.Model.predict(transpose(x'))*3.47 + 0.33),(ToolWear.Model.predict(transpose(x'))*0.52 + 0.03)];
end
%(Power.Model.predict(transpose(x'))*2.11 + 0.69)