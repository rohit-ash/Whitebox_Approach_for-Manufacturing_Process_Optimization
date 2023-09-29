tic;  % CPU time measure
global INF
INF = 1.0e4;
fobj = Func_Multiobj_Ensemble;% Objective function
d=3;  % No. of Variables
Var_min=zeros(1,d);  % Lower variable Boundaries
Var_max=ones(1,d);   % Upper variable Boundaries
nobj=3; % Number of objectives
ncon=0;  % Number of constraints
nreal=d;  % Number of real variables
nbin=0;   % Number of binary variables
%% Common parameters of  BO similar to  other optimization algorithms
N=500; % No. of bonobos in the population, i.e. population size
max_it=100;  % Maximum number of iterations
%% Algorithm-specific Parameters for BO (user should set suitable values of the parameters for their problem)
p_xgm_initial=0.08; % Initial probability for extra-group mating (generally 1/d for higher dimensions)
scsb=1.01; %Sharing cofficient for alpha bonobo (Generally 1-2)
scab=1.95;  % Sharing coefficient for selected bonobo(Generally 1-2)
rcpp=0.01; %Rate of change in  phase probability (Generally 1e-3 to 1e-2)
tsgs_factor_max=0.0001;% Max. value of temporary sub-group size factor
%% There is no need to change anything below this %%
%% Initialization
ncolumn = nobj+ncon+nreal+nbin+1+1+1; % cons_viol+rank+crowd_dist
pop = zeros(N,ncolumn);
for i=1:N
    pop(i,(nobj+1):(nobj+d))=unifrnd(Var_min,Var_max,[1 d]);
    pop(i,1:nobj) = [fobj( pop(i,(nobj+1):(nobj+d)))]';%before last ),' was present
end
pop = Rank_and_Crowding_Distance_Calculation(pop, nobj, ncon, nreal, nbin);
%% Initialization of other parameters
npc=0; % Negative phase count
ppc=0; % Positive phase count
p_xgm=p_xgm_initial; % Probability for extra-group mating
tsgs_factor_initial=0.5*tsgs_factor_max; % Initial value for temporary sub-group size factor
tsgs_factor=tsgs_factor_initial; % Temporary sub-group size factor
p_p=0.0; % Phase probability
it=1;
nem=zeros(max_it+1,1);
tempdv=zeros(max_it+1,1);
temp_g=[];
for i=1:N
    if(pop(i,(ncolumn-1))==1)
        temp_g=[temp_g i];
    end
end
rep=pop(temp_g,:);
nem(it)=size(rep,1);
ss=minmax(rep(:,1:nobj)');
tempdv(it)=mean(std(rep(:,1:nobj))./(ss(:,2)-ss(:,1))');
%% Main Loop of BO
while(it<=max_it)
    newbonobo=zeros(N,ncolumn);
    tsgs_max=max(2,ceil(N*tsgs_factor));  % Maximum size of the temporary sub-group
    sz=size(rep,1);
    for i=1:N
        if (sz==1)
            alphabonobo=rep;
        elseif (sz==2)
            alphabonobo=rep(randi(2),:);
        else
            alphabonobo=SelectAlphaBonobo(rep,ncolumn);
        end
        B = 1:N;
        B(i)=[];
        %% Determining the actual size of the temporary sub-group
        tsg=randi([2 tsgs_max]);
        %% Selection of pth Bonobo using fission-fusion social strategy
        q=randsample(B,tsg);
        temp1=pop(q,:);
        m=min(temp1(:,(ncolumn-1)));
        k=find(temp1(:,(ncolumn-1))==m);
        if (size(k,1)>1)
            q1=temp1(k,end);
            [~,k2]=max(q1);
            mo=k(k2);
        else
            mo=k;
        end
        p=q(mo);
        %% Creation of newbonobo
        if(rand<=p_p)
            r1=rand(1,d); %% Promiscuous or restrictive mating strategy
            newbonobo(i,(nobj+1):(nobj+d))=pop(i,(nobj+1):(nobj+d))+scab*r1.*(alphabonobo((nobj+1):(nobj+d))-pop(i,(nobj+1):(nobj+d)))+scsb*(1-r1).*(pop(i,(nobj+1):(nobj+d))-pop(p,(nobj+1):(nobj+d)));
        else
            for j=1:d
                if(rand<=p_xgm)
                    rand_var=rand; %% Extra group mating strategy
                    if(alphabonobo(1,nobj+j)>=pop(i,nobj+j))
                        if(rand<=0.5)
                            beta1=exp(((rand_var)^2)+rand_var-(2/rand_var));
                            newbonobo(i,j+nobj)=pop(i,j+nobj)+beta1*(Var_max(j)-pop(i,j+nobj));
                        else
                            beta2=exp((-((rand_var)^2))+(2*rand_var)-(2/rand_var));
                            newbonobo(i,j+nobj)=pop(i,j+nobj)-beta2*(pop(i,j+nobj)-Var_min(j));
                        end
                    else
                        if(rand<=0.5)
                            beta1=exp(((rand_var)^2)+(rand_var)-2/rand_var);
                            newbonobo(i,j+nobj)=pop(i,j+nobj)-beta1*(pop(i,j+nobj)-Var_min(j));
                        else
                            beta2=exp((-((rand_var)^2))+(2*rand_var)-2/rand_var);
                            newbonobo(i,j+nobj)=pop(i,j+nobj)+beta2*(Var_max(j)-pop(i,j+nobj));
                        end
                    end
                else
                    if((rand<=0.5)) %% Consortship mating strategy
                        newbonobo(i,j+nobj)=pop(i,j+nobj)+(exp(-rand))*(pop(i,j+nobj)-pop(p,j+nobj));
                    else
                        newbonobo(i,j+nobj)=pop(p,j+nobj);
                    end
                end
            end
        end
        %% Clipping
        for j=1:d
            if(newbonobo(i,j+nobj)>Var_max(j))
                newbonobo(i,j+nobj)=Var_max(j);
            end
            if(newbonobo(i,j+nobj)<Var_min(j))
                newbonobo(i,j+nobj)=Var_min(j);
            end
        end
        newbonobo(i,1:nobj)= [fobj(newbonobo(i,(nobj+1):(nobj+d)))]'; % New cost evaluation,before last ),' was present
    end
    mixedpop=[pop; newbonobo];
    mixedpop = Rank_and_Crowding_Distance_Calculation(mixedpop, nobj, ncon, nreal, nbin);
    pop = NondominatedSort_and_filling(mixedpop, nobj, ncon, nreal, nbin);
    temp_g=[];
    for i=1:N
        if(pop(i,(ncolumn-1))==1)
            temp_g=[temp_g i];
        end
    end
    rep=pop(temp_g,:);
    temp_rep2=rep(:,1:nobj);
    [~,kl]=unique(temp_rep2,'rows');
    rep=rep(kl,:);
    clear newbonobo mixedpop temp1 temp_g temp_rep2
    nem(it+1)=size(rep,1);
    if(nem(it+1)>1)
        ss=minmax(rep(:,1:nobj)');
        tempdv(it+1)=mean(std(rep(:,1:nobj))./(ss(:,2)-ss(:,1))');
        if(nem(it+1)>=nem(it)&& tempdv(it+1)>tempdv(it))
            pp=1;
        else
            pp=0;
        end
    else
        pp=0;
    end
    %% Parameters updation
    if(pp==1)
        npc=0; %% Positive phase
        ppc=ppc+1;
        cp=min(0.5,(ppc*rcpp));
        p_xgm=p_xgm_initial;
        p_p=0.5+cp;
        tsgs_factor=min(tsgs_factor_max,(tsgs_factor_initial+ppc*(rcpp^2)));
    else
        npc=npc+1; %% Negative phase
        ppc=0;
        cp=-(min(0.5,(npc*rcpp)));
        p_xgm=min(0.5,p_xgm_initial+npc*(rcpp^2));
        tsgs_factor=max(0,(tsgs_factor_initial-npc*(rcpp^2)));
        p_p=0.5+cp;
    end
    % Show Iteration Information
    disp(['Iteration = ' num2str(it)]);
    it=it+1;
end
% Plot of the results
PlotObjectiveFunction(pop,rep,nobj);
toc;
