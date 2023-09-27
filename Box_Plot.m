load kf_loss_indiv_roughness.mat;
load kf_loss_indiv_Toolwear.mat;
load kf_loss_individual_Power.mat;
boxplot([kf_loss_individual, kf_loss_individual_ToolWear,kf_loss_individual_Power],'Labels',{'Roughness','Tool Wear','Power'})