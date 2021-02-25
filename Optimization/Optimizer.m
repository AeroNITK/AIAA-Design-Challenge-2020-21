% Code for finding optimum values of T/W, and W/S which gives minimum weight
% with all constraints satisfied.
clear
clc
close all

global Aircraft
Aircraft = struct();

d2r = pi/180;

LB = [4,0,0.11,0.45,18000.0,0.2,5,150.0];  % Lower Bound
UB = [8,5,0.16,0.45,30000.0,0.6,6,375.0]; % Upper Bound


A = [];
B = [];
Aeq = [];
Beq = [];
%x0 = nonzeros(8);
x0 = [6.11,3.27,0.15,0.42,18000,0.55,5.08,284];

options = optimoptions('fmincon','Algorithm','sqp','Display','iter-detailed',...
    'FunctionTolerance',1e-6,'OptimalityTolerance',1e-6,'ConstraintTolerance',1e-6,....
    'StepTolerance',1e-20,'MaxFunctionEvaluations',1000,'MaxIterations',1000);
 
[X,~,exitflag,output] = fmincon(@(x) Obj_Func(x), x0, A, B, Aeq, Beq, LB, UB, @(x) Nonlincon(x),options);

%{
gs = GlobalSearch;

problem = createOptimProblem('fmincon','x0',x0,...
    'objective',@(x) Obj_Func(x),'lb',LB,'ub',UB,'nonlcon',@(x) Nonlincon(x),'options',options);
[X,output] = run(gs,problem);

%}

Aircraft.ratios.Wing_We=Aircraft.Weight.wing/Aircraft.Weight.empty_weight;
Aircraft.ratios.Wing_Wto=Aircraft.Weight.wing/Aircraft.Weight.MTOW;

Aircraft.ratios.Fuselage_We=Aircraft.Weight.fuselage/Aircraft.Weight.empty_weight;
Aircraft.ratios.Fuselage_Wto=Aircraft.Weight.fuselage/Aircraft.Weight.MTOW;





%%Plotting
%{
x1 = 0:0.4:40; %W/P
x2 = 20:1:120; %W/S



%%% Take-Off
R = 287;
S_TOFL = Aircraft.Performance.takeoff_runway_length; % Take-off field length in feets
CL_max_TO = 2.1;
[~,rho,~,~] = ISA(0);

sigma = rho/1.225;  
rho=rho*0.00194032; %converting to slugs
k1=0.0376;
lp=5.75;
k2=lp*(sigma/22.5)^(1/3);
ug=0.05;

syms Y
y=zeros(101,1);
for c=1:101
    eqn1 = (k1*x2(c))/(rho*(CL_max_TO*(k2/Y-ug)-0.72*Aircraft.Aero.C_D0_clean))- S_TOFL == 0; %First Constraint
    y(c) = solve(eqn1,Y);
end

plot(x2,y,'LineWidth',1.5);

hold on

%%% Landing
S_LFL = Aircraft.Performance.landing_runway_length;
VA = sqrt(S_LFL/0.3);
VS = VA/1.2; % Stall Speed in kts
VS = VS/0.592484; % Stall Speed in ft/s
CL_max_L = 2.2;
[~,rho,~,~] = ISA(0);
rho = rho*0.0623; % Density in lbs/ft^3

syms X1
x = zeros(101,1);
for c=1:101
    eqn2 = X1/Aircraft.Weight.Landing_Takeoff - (VS^2)*CL_max_L*rho/(2*32.2) ==0; % Second Constraint
    x(c) = solve(eqn2,X1);
end

y = x1;
plot(x,y,'LineWidth',1.5);

hold on;

%%% Climb Requirement
CGR = 0.025;
Thrust_Factor = 0.85; %CHECK VALUE
%Speed_Factor = 1.2; 
%Corrected_CL = CL_max_TO/Speed_Factor^2; %CHECK CALCULATION OF THIS 
CD_o = Aircraft.Aero.C_D0_clean + Aircraft.Aero.delta_C_D0_takeoff;
%L_by_D = Corrected_CL/(CD_o + Corrected_CL^2/(pi*Aircraft.Wing.Aspect_Ratio*Aircraft.Aero.e_takeoff_flaps));

L_by_D=1.3/(CD_o+1.3^2/(pi*Aircraft.Wing.Aspect_Ratio*Aircraft.Aero.e_takeoff_flaps));
CGRP=(CGR+L_by_D^(-1))/(1.3^0.5); %CHECK
N_p=0.82;

syms Y

y=zeros(101,1);
for c=1:101
    eqn3 = 18.97*N_p/(CGRP*x2(c)^0.5) - Y/Thrust_Factor == 0; % Climb Requirement
    y(c) = solve(eqn3,Y);
end


plot(x2,y,'LineWidth',1.5);

hold on;


%%% Cruising Altitude & Speed
M = Aircraft.Performance.M_cruise;
Cruising_Altitude = Aircraft.Performance.altitude_cruise1; %in feets
[P,rho,T,a] = ISA(Cruising_Altitude*0.3048);
sigma = rho/1.225;
V = M*a/0.3048;
Ip=1.96; 
Z=(Ip^3)*sigma/0.7;

y=x2/Z;
plot(x2,y,'LineWidth',1.5);

 %%%Ceiling 
ClimbRate_Cruise=300;
ClimbRate_Service=100;
RCP_Cruise=ClimbRate_Cruise/33000;
RCP_Service=ClimbRate_Service/33000;
Np=0.82;
Cruising_Altitude = Aircraft.Performance.altitude_cruise1; %in feets
[P,rho,T,a] = ISA(Cruising_Altitude*0.3048);
sigma = rho/1.225;
ClbyCd=1.345*((Aircraft.Wing.Aspect_Ratio*Aircraft.Aero.e_takeoff_flaps)^0.75)/(CD_o^0.25);
syms Y
y=zeros(101,1);
for c=1:101
    eqn4 = -((Np/Y)-((x2(c))^0.5)/(19*ClbyCd*(sigma^0.5))-RCP_Cruise);
    y(c) = solve(eqn4,Y);
end
plot(x2,y,'LineWidth',1.5);

[P,rho,T,a] = ISA(30000*0.3048);
sigma = rho/1.225;
syms Y
y=zeros(101,1);
for c=1:101
    eqn5 = -((Np/Y)-((x2(c))^0.5)/(19*ClbyCd*(sigma^0.5))-RCP_Service);
    y(c) = solve(eqn5,Y);
end
plot(x2,y,'LineWidth',1.5);
    
    
hold off

hold on
plot(Aircraft.Weight.MTOW/X(8),X(1),'ro')

title('Constraint Diagram');
ylabel('W/P');
xlabel('W/S (lbs/ft^2)');
legend ('Takeoff','Landing','Climb','Cruising Speed and Altitude','Cruise Ceiling','Service Ceiling','Location','northwest');
%}          

%TEMP CHANGES

%Avionics 800 -> 600
%Surface controls

