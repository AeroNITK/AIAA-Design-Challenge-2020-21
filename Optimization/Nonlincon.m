function [c,ceq] = Nonlincon(x)
    global Aircraft
    d2r = pi/180;
    
    
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
    
    c(1) =  k1*Aircraft.Performance.WbyS/(rho*(CL_max_TO*(k2/x(1)-ug)-0.72*Aircraft.Aero.C_D0_clean))- S_TOFL; % First Constrain
    
   
    %%% Landing
    S_LFL = Aircraft.Performance.landing_runway_length;
    VA = sqrt(S_LFL/0.3);
    VS = VA/1.2; % Stall Speed in kts
    VS = VS/0.592484; % Stall Speed in ft/s
    CL_max_L = 2.2;
    [~,rho,~,~] = ISA(0);
    rho = rho*0.0623; % Density in lbs/ft^3
    
    c(2) = Aircraft.Performance.WbyS/Aircraft.Weight.Landing_Takeoff - (VS^2)*CL_max_L*rho/(2*32.2); % Second Constrain
    
    
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
    
    c(3) = -(18.97*N_p/(CGRP*Aircraft.Performance.WbyS^0.5) - x(1)/Thrust_Factor); % Climb Requirement
    
    
    
    %%% Cruising Altitude & Speed
    M = Aircraft.Performance.M_cruise;
    Cruising_Altitude = Aircraft.Performance.altitude_cruise1; %in feets
    [P,rho,T,a] = ISA(Cruising_Altitude*0.3048);
    sigma = rho/1.225;
    V = M*a/0.3048;
    Ip=1.96; 
    Z=Ip^3*sigma/0.7;
    c(4) = -(Aircraft.Performance.WbyS/Z  - x(1));
    
    
    
    ceq=[];
end