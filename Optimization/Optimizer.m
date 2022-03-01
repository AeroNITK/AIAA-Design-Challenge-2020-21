% Code for finding optimum values of T/W, and W/S which gives minimum weight
% with all constraints satisfied.
clear
clc
close all

global Aircraft
Aircraft = struct();

d2r = pi/180;

% number of variables: 6
% Design variables order: T/W, Sweep_Quater_Chord, t/c root,
% cruising altitude, A, S.

LB = [0.158 , 23, 0.11, 20000,8.98,0.195,800,0.7];  % Lower Bound
UB = [0.266, 42, 0.14, 35000, 10.85,0.345,3500,0.85]; % Upper Bound
%LB = [0.158 , 1.9, 0.11, 10000,8.98, 85.95,0];  % Lower Bound
%UB = [0.266, 3.5, 0.15, 30000, 10.85,200,19]; % Upper Bound

A = [];
B = [];
Aeq = [];
Beq = [];

x0 = [0.19,27,0.13,27000,9.91,0.21,2210,0.75]; % Starting Point

options = optimoptions('fmincon','Algorithm','sqp','Display','iter-detailed',...
    'FunctionTolerance',1e-6,'OptimalityTolerance',1e-6,'ConstraintTolerance',1e-6,....
    'StepTolerance',1e-20,'MaxFunctionEvaluations',500,'MaxIterations',1000);
% x=Obj_Func(x0);
% disp(x);
[X,~,exitflag,output]= fmincon(@(x) Obj_Func(x), x0, A, B, Aeq, Beq, LB, UB, @(x) Nonlincon(x),options);
%disp(x);
%%%%% Ratios for comparison %%%%%
Aircraft.ratios.Wing_We=Aircraft.Weight.wing/Aircraft.Weight.empty_weight;
Aircraft.ratios.Wing_Wto=Aircraft.Weight.wing/Aircraft.Weight.MTOW;

Aircraft.ratios.Fuselage_We=Aircraft.Weight.fuselage/Aircraft.Weight.empty_weight;
Aircraft.ratios.Fuselage_Wto=Aircraft.Weight.fuselage/Aircraft.Weight.MTOW;


 %%Plotting
x1 = 0.15:0.005:0.27; % T/W
x2 = 44:1.1:130;    % Wing loading

figure(2);

R = 287;
S_TOFL = Aircraft.Performance.takeoff_runway_length; % Take-off field length in feets
CL_max_TO = 1.9;
[P,rho,T,~] = ISA(0);
sigma = (P/(R*(T+15)))/rho;
y = x2./(sigma*CL_max_TO*S_TOFL/37.5); %T/W Calculated
plot(x2,y,'LineWidth',1.5);

hold on

S_LFL = Aircraft.Performance.landing_runway_length;
VA = sqrt(S_LFL/0.3);
VS = VA/1.3; % Stall Speed in kts
VS = VS/0.592484; % Stall Speed in ft/s
CL_max_L = 2.3;
rho = 0.0726; % Density in lbs/ft^3

x = (VS^2)*CL_max_L*rho/(2*32.2*Aircraft.Weight.Landing_Takeoff)*ones(1,101);
y = x1;
%plot(x,y,'LineWidth',1.5);
%{
AR = Aircraft.Wing.Aspect_Ratio;
e = Aircraft.Aero.e_takeoff_flaps;
CGR = 0.024;
Thrust_Factor = 0.966;
Speed_Factor = 1.2;
CL_max = 1.9;
Corrected_CL = CL_max/Speed_Factor^2;
CD_o = Aircraft.Aero.C_D0_clean + Aircraft.Aero.C_D0_takeoff;
K = (pi*AR*e)^-1;
L_by_D = Corrected_CL/( CD_o + K*Corrected_CL^2 );

x = x2;
y = 2*(L_by_D^(-1) + CGR)*Thrust_Factor;

plot(x,y,'LineWidth',1.5);

Cruising_Altitude = Aircraft.Performance.cruise_altitude; %in feets
[P,rho,T,a] = ISA(Cruising_Altitude*0.3048);
rho = rho*0.0623;
V = Aircraft.Performance.M_cruise*a/0.3048;
q = 0.5*rho*V^2;
q = q/32;
alpha = (P*288.15)/(T*101325);
beta = 0.96;

y = ones(1,101);

for i = 1:101

    y(i) = ( (beta*x2(i) )/(pi*Aircraft.Wing.Aspect_Ratio*Aircraft.Aero.e_clean*q) ...
            + ( (Aircraft.Aero.C_D0_clean + 0.003)*q)/( beta*x2(i) ) )/(alpha/beta);
    
end

plot(x,y,'LineWidth',1.5);

plot(Aircraft.Performance.WbyS,Aircraft.Performance.TbyW,'-p','MarkerFaceColor','red',...
    'MarkerSize',15);

hold off

title('Constraint Diagram');
ylabel('T/W');
xlabel('W/S (lbs/ft^2)');
legend ('Takeoff','Landing','Climb','Cruising Speed and Altitude','Final Point','Location','northwest');
%}