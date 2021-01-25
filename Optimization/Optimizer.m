% Code for finding optimum values of T/W, and W/S which gives minimum weight
% with all constraints satisfied.
clear
clc
close all

global Aircraft
Aircraft = struct();

d2r = pi/180;

LB = [4,0,0.11,0.4,18000,0.2,5,150];  % Lower Bound
UB = [8,15,0.2,0.7,40000,0.6,8,400]; % Upper Bound


A = [];
B = [];
Aeq = [];
Beq = [];
%x0 = nonzeros(8);
x0 = [6.11,3.27,0.15,0.42,18000,0.55,5.08,284];

options = optimoptions('fmincon','Algorithm','sqp','Display','iter-detailed',...
    'FunctionTolerance',1e-6,'OptimalityTolerance',1e-6,'ConstraintTolerance',1e-6,....
    'StepTolerance',1e-20,'MaxFunctionEvaluations',1000);
 
%[X,~,exitflag,output] = fmincon(@(x) Obj_Func(x), x0, A, B, Aeq, Beq, LB, UB, @(x) Nonlincon(x),options);

gs = GlobalSearch;

problem = createOptimProblem('fmincon','x0',x0,...
    'objective',@(x) Obj_Func(x),'lb',LB,'ub',UB,'nonlcon',@(x) Nonlincon(x),'options',options);
[X,output] = run(gs,problem)
                
hold off;

