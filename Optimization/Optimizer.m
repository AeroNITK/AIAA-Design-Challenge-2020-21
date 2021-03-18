% Code for finding optimum values of T/W, and W/S which gives minimum weight
% with all constraints satisfied.
clear
clc
close all

global Aircraft
Aircraft = struct();

d2r = pi/180;

% number of variables: 6
% Design variables order: W/P, Sweep_Quater_Chord, t/c root,
% cruising altitude, A, S.

LB = [4, 0, 0.11, 10000.0, 5, 150.0];  % Lower Bound
UB = [8, 30, 0.16, 35000.0, 7, 350.0]; % Upper Bound

A = [];
B = [];
Aeq = [];
Beq = [];

x0 = [6.11,3.27,0.15,25000,5.08,284]; % Starting Point

options = optimoptions('fmincon','Algorithm','sqp','Display','iter-detailed',...
    'FunctionTolerance',1e-6,'OptimalityTolerance',1e-6,'ConstraintTolerance',1e-6,....
    'StepTolerance',1e-20,'MaxFunctionEvaluations',5000,'MaxIterations',1000);
 
[X,~,exitflag,output] = fmincon(@(x) Obj_Func(x), x0, A, B, Aeq, Beq, LB, UB, @(x) Nonlincon(x),options);

%%%%% Ratios for comparison %%%%%
Aircraft.ratios.Wing_We=Aircraft.Weight.wing/Aircraft.Weight.empty_weight;
Aircraft.ratios.Wing_Wto=Aircraft.Weight.wing/Aircraft.Weight.MTOW;

Aircraft.ratios.Fuselage_We=Aircraft.Weight.fuselage/Aircraft.Weight.empty_weight;
Aircraft.ratios.Fuselage_Wto=Aircraft.Weight.fuselage/Aircraft.Weight.MTOW;

%% Plotting

x1_G = 0:0.4:40; %W/P
x2_G = 20:1:120; %W/S

%% Take-Off
R = 287;
S_TOFL = Aircraft.Performance.takeoff_runway_length; % Take-off field length in feets
CL_max_TO = 2.1;
CL_max_TO_2 = 1.9;
CL_max_TO_3 = 1.7;
CL_max_TO_4 = 1.5;
CL_max_TO_5 = 1.3;

[~,rho,~,~] = ISA(0);

sigma = rho/1.225;  
rho=rho*0.00194032; %converting to slugs
k1=0.0376;
lp=5.75;
k2=lp*(sigma/22.5)^(1/3);
ug=0.05;

syms Y Y2 Y3 Y4 Y5
y=zeros(101,1);
y2=zeros(101,1);
y3=zeros(101,1);
y4=zeros(101,1);
y5=zeros(101,1);
for c=1:101
    eqn1 = (k1*x2_G(c))/(rho*(CL_max_TO*(k2/Y-ug)-0.72*Aircraft.Aero.C_D0_clean))- S_TOFL == 0; %First Constraint
    y(c) = solve(eqn1,Y);
    eqn2 = (k1*x2_G(c))/(rho*(CL_max_TO_2*(k2/Y2-ug)-0.72*Aircraft.Aero.C_D0_clean))- S_TOFL == 0; %First Constraint
    y2(c) = solve(eqn2,Y2);
    eqn3 = (k1*x2_G(c))/(rho*(CL_max_TO_3*(k2/Y3-ug)-0.72*Aircraft.Aero.C_D0_clean))- S_TOFL == 0; %First Constraint
    y3(c) = solve(eqn3,Y3);
    eqn4 = (k1*x2_G(c))/(rho*(CL_max_TO_4*(k2/Y4-ug)-0.72*Aircraft.Aero.C_D0_clean))- S_TOFL == 0; %First Constraint
    y4(c) = solve(eqn4,Y4);
    eqn5 = (k1*x2_G(c))/(rho*(CL_max_TO_5*(k2/Y5-ug)-0.72*Aircraft.Aero.C_D0_clean))- S_TOFL == 0; %First Constraint
    y5(c) = solve(eqn5,Y5);
end

plot(x2_G,y,'LineWidth',1.5);
hold on
plot(x2_G,y2,'LineWidth',1.5);
hold on
plot(x2_G,y3,'LineWidth',1.5);
hold on
plot(x2_G,y4,'LineWidth',1.5);
hold on
plot(x2_G,y5,'LineWidth',1.5);

hold on

%% Landing
S_LFL = Aircraft.Performance.landing_runway_length;
VA = sqrt(S_LFL/0.3);
VS = VA/1.2; % Stall Speed in kts
VS = VS/0.592484; % Stall Speed in ft/s
CL_max_L = 2.6;
CL_max_L_2 = 2.02;
CL_max_L_3 = 1.8;
CL_max_L_4 = 1.6;

[~,rho,~,~] = ISA(0);
rho = rho*0.0623; % Density in lbs/ft^3

syms X1 X2 X3 X4
x1 = zeros(101,1);
x2 = zeros(101,1);
x3 = zeros(101,1);
x4 = zeros(101,1);
for c=1:101
    eqn1 = X1/Aircraft.Weight.Landing_Takeoff - (VS^2)*CL_max_L*rho/(2*32.2) ==0; % Second Constraint
    x1(c) = solve(eqn1,X1);
    eqn2 = X2/Aircraft.Weight.Landing_Takeoff - (VS^2)*CL_max_L_2*rho/(2*32.2) ==0; % Second Constraint
    x2(c) = solve(eqn2,X2);
    eqn3 = X3/Aircraft.Weight.Landing_Takeoff - (VS^2)*CL_max_L_3*rho/(2*32.2) ==0; % Second Constraint
    x3(c) = solve(eqn3,X3);
    eqn4 = X4/Aircraft.Weight.Landing_Takeoff - (VS^2)*CL_max_L_4*rho/(2*32.2) ==0; % Second Constraint
    x4(c) = solve(eqn4,X4);
end

y = x1_G;
plot(x1,y,'LineWidth',1.5);
hold on;
y = x1_G;
plot(x2,y,'LineWidth',1.5);
hold on;
y = x1_G;
plot(x3,y,'LineWidth',1.5);
hold on;
y = x1_G;
plot(x4,y,'LineWidth',1.5);
hold on;

%% Climb Requirement
CGR = 0.025;
Thrust_Factor = 0.85; %CHECK VALUE
%Speed_Factor = 1.2; 
%Corrected_CL = CL_max_TO/Speed_Factor^2; %CHECK CALCULATION OF THIS 
CD_o = Aircraft.Aero.C_D0_takeoff;
%L_by_D = Corrected_CL/(CD_o + Corrected_CL^2/(pi*Aircraft.Wing.Aspect_Ratio*Aircraft.Aero.e_takeoff_flaps));

L_by_D=1.3/(CD_o+1.3^2/(pi*Aircraft.Wing.Aspect_Ratio*Aircraft.Aero.e_takeoff_flaps));
CGRP=(CGR+L_by_D^(-1))/(1.3^0.5); %CHECK
N_p=0.82;

syms Y

y=zeros(101,1);
for c=1:101
    eqn3 = 18.97*N_p/(CGRP*x2_G(c)^0.5) - Y/Thrust_Factor == 0; % Climb Requirement
    y(c) = solve(eqn3,Y);
end

plot(x2_G,y,'LineWidth',1.5);

hold on;

%% Cruising Altitude & Speed
M = Aircraft.Performance.M_cruise;
Cruising_Altitude = Aircraft.Performance.cruise_altitude; %in feets
[P,rho,T,a] = ISA(Cruising_Altitude*0.3048);
sigma = rho/1.225;
V = M*a/0.3048;
Ip=1.96; 
Z=(Ip^3)*sigma/0.7;

y=x2_G/Z;
plot(x2_G,y,'LineWidth',1.5);

%% Ceiling 
ClimbRate_Cruise=300;
ClimbRate_Service=100;
RCP_Cruise=ClimbRate_Cruise/33000;
RCP_Service=ClimbRate_Service/33000;
Np=0.82;
Cruising_Altitude = Aircraft.Performance.cruise_altitude; %in feets
[P,rho,T,a] = ISA(Cruising_Altitude*0.3048);
sigma = rho/1.225;
ClbyCd=1.345*((Aircraft.Wing.Aspect_Ratio*Aircraft.Aero.e_takeoff_flaps)^0.75)/(CD_o^0.25);
syms Y
y=zeros(101,1);
for c=1:101
    eqn4 = -((Np/Y)-((x2_G(c))^0.5)/(19*ClbyCd*(sigma^0.5))-RCP_Cruise);
    y(c) = solve(eqn4,Y);
end
plot(x2_G,y,'LineWidth',1.5);

[P,rho,T,a] = ISA(30000*0.3048);
sigma = rho/1.225;
syms Y
y=zeros(101,1);
for c=1:101
    eqn5 = -((Np/Y)-((x2_G(c))^0.5)/(19*ClbyCd*(sigma^0.5))-RCP_Service);
    y(c) = solve(eqn5,Y);
end
plot(x2_G,y,'LineWidth',1.5);
    
    
hold off

hold on
plot(Aircraft.Weight.MTOW/X(6),X(1),'ro')

title('Constraint Diagram');
ylabel('W/P');
xlabel('W/S (lbs/ft^2)');
%legend ('Takeoff','Landing','Climb','Cruising Speed and Altitude','Cruise Ceiling','Service Ceiling','Location','northwest');
legend ('Takeoff_2.1','Takeoff_1.9','Takeoff_1.7','Takeoff_1.5','Takeoff_1.3','Landing_2.2','Landing_2.0','Landing_1.8','Landing_1.6','Climb','Cruising Speed and Altitude','Cruise Ceiling','Service Ceiling','Final Point','Location','northwest');         
%}