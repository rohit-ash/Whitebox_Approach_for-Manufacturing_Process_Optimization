load paretosearch.mat;
load pareto_GA.mat;

plot3(f(:,1),f(:,2),f(:,3),'o');
hold on;
plot3(fval(:,1),fval(:,2),fval(:,3),'*');
hold off;

