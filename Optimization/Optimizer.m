% Code for finding optimum values of T/W, and W/S which gives minimum weight
% with all constraints satisfied.
clear
clc
close all

global Aircraft
Aircraft = struct();

d2r = pi/180;

LB = [0.2,25,0.11,0.7,34000,0.2,7,3000];  % Lower Bound
UB = [0.6,35,0.15,0.85,40000,0.3,10,4100]; % Upper Bound


A = [];
B = [];
Aeq = [];
Beq = [];
%x0 = nonzeros(8);
x0 = [0.25,30,0.15,0.8,36000,0.25,9,3500];

options = optimoptions('fmincon','Algorithm','sqp','Display','iter-detailed',...
    'FunctionTolerance',1e-6,'OptimalityTolerance',1e-6,'ConstraintTolerance',1e-6,....
    'StepTolerance',1e-20,'MaxFunctionEvaluations',600);
 
[X,~,exitflag,output] = fmincon(@(x) Obj_Func(x), x0, A, B, Aeq, Beq, LB, UB, @(x) Nonlincon(x),options);

%gs = GlobalSearch;

%problem = createOptimProblem('fmincon','x0',x0,...
 %   'objective',@(x) Obj_Func(x),'lb',LB,'ub',UB,'nonlcon',@(x) Nonlincon(x),'options',options);
%[X,output] = run(gs,problem)
                
hold off;

