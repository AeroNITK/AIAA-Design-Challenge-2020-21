%  Aircraft Fuel Weight Calculator for a given mission
%  ------------------------------------------------------------------------
%  Input : Aircraft structure datatpye.
%  Output : Aircraft sturcture datatype with updated Fuel Weight.
%  All units are in FPS System.
%  ------------------------------------------------------------------------
%  Mission Description:
%  Complete mission is divided into various segments. Mission Weight
%  Fraction for each segment is calculated. All the Weight weight fractions
%  are mutliplied to get ratio of weight of the airplane at the end of the
%  mission to start of the mission.
%  Segment No.		Name			
%  1                Engine Start & Warm Up			
%  2                Taxi to Runway			
%  3                Take Off			
%  4                Climb to cruise altitude			
%  5                Cruise to full range			
%  6                Descent			
%  7                Loiter for four hours 			
%  8                Climb			
%  9                Cruise 			
%  10               Descent 			
%  11               Taxi					
%  ------------------------------------------------------------------------

function [Aircraft] = Fuel_Weight(Aircraft)
    
    Cj_cruise = 0.7;   % Specific Fuel Consumption (in lbs/lbs/hr)
    Cj_loiter = 0.7;   % Specific Fuel Consumption (in lbs/lbs/hr)
    Cp_cruise = 0.6;   % (in lbs/hp/hr)
    Cp_loiter = 0.6;   % (in lbs/hp/hr)
    Np_cruise = 0.82;
    Np_loiter = 0.77;
    
    RC=1500;            %ft/min
    ClimbSpeed=140;     %KIA
    R1 = (Aircraft.Performance.altitude_cruise1*ClimbSpeed)/(RC*60); %Distance travelled during climb
    R2 = ((Aircraft.Performance.altitude_cruise1-3000)*ClimbSpeed)/(RC*60); %Distance travelled during climb from 3000ft
    
    V = 323;    % Cruising Speed in mph
    
    %DESIGN MISSION
    
    W1byW_TO = 0.99;    % Mission Segement Weight Fraction for Engine Start & Warm Up     
    W2byW1 = 0.99;      % Mission Segement Weight Fraction for Taxi to Runway
    W3byW2 = 0.99;     % Mission Segement Weight Fraction for Take Off
    W4byW3 = 0.985;      % Mission Segement Weight Fraction for Climb to cruise altitude (Raymer)
    
    % Mission Segement Weight Fraction for Cruise segment 1
    
    range = (Aircraft.Performance.range1-R1)*1.1508;  % nm to stat mi
    
    W5byW4 = exp(-(range*Cp_cruise)/(375*Np_cruise*Aircraft.Aero.LbyD_max_cruise));
    
    W6byW5=0.99; %descent
    
    % Mission Segement Weight Fraction for Loiter segment 
    
    loiter1 = 4;  % Four hours from RFP
    
    W7byW6 = exp(-(loiter1*Cp_loiter*V)/(375*Np_loiter*Aircraft.Aero.LbyD_max_loiter));
    
    W8byW7 = 0.985;  % Mission Segement Weight Fraction for Climb 
    
    % Mission Segement Weight Fraction for Cruise segment 2
    
    range = (Aircraft.Performance.range2-R2)*1.1508; %n mi to stat mi
    W9byW8 = exp(-(range*Cp_cruise)/(375*Np_cruise*Aircraft.Aero.LbyD_max_cruise));  % Mission Segement Weight Fraction for Cruise 2
    
    
    W10byW9 = 0.99; % Mission Segement Weight Fraction for Descent
    
    W11byW10 = 0.995;   % Mission Segement Weight Fraction for  Taxi (Raymer)
    
    W12byW11=0.99;
    
    %reserve fuel
    Ecr2=0.75;
    W13byW12 = exp(-(Ecr2*Cp_loiter*V)/(375*Np_loiter*Aircraft.Aero.LbyD_max_loiter));
    
    W13byW_TO = W1byW_TO*W2byW1*W3byW2*W4byW3*W5byW4*W6byW5*W7byW6*W8byW7*W9byW8*W10byW9*W11byW10*W12byW11*W13byW12; 
           
    %Aircraft.Weight.Landing_Takeoff = W1byW_TO*W2byW1*W3byW2*W4byW3*W5byW4*W6byW5...
               %*W7byW6;
           
    Aircraft.Weight.WfbyW_TO = 1.06*(1 - W13byW_TO);    % Fuel to MTOW ratio
    Aircraft.Weight.Landing_Takeoff = W1byW_TO*W2byW1*W3byW2*W4byW3*W5byW4*W6byW5*W7byW6*W8byW7*W9byW8*W10byW9;
    Aircraft.Weight.Design_Gross_Weight_Fraction=W1byW_TO*W2byW1*W3byW2*W4byW3*W5byW4*W6byW5;
    Aircraft.Weight.Design_Gross_Weight=Aircraft.Weight.MTOW*Aircraft.Weight.Design_Gross_Weight_Fraction;

    
    
    %FERRY MISSION
    W1=0.99; %Warmup
    W2=0.99; %Taxi
    W3=0.99; %Takeoff
    W4=0.985; %Climb
    
    %Cruise
    R3 = (Aircraft.Performance.altitude_cruise2*ClimbSpeed)/(RC*60); %Distance travelled during climb
    range=(Aircraft.Performance.range3-R3)*1.1508;
    W5=exp(-(range*Cp_cruise)/(375*Np_cruise*Aircraft.Aero.LbyD_max_cruise));
    
    W6=0.99; %descent
    W7=0.995; %taxi
    W8=0.99; %reserve fuel
    %reserve fuel
    Ecr2=0.75;
    W9 = exp(-(Ecr2*Cp_loiter*V)/(375*Np_loiter*Aircraft.Aero.LbyD_max_loiter));
    
    %FuelFraction
    W9byW_TO = W1*W2*W3*W4*W5*W6*W7*W8*W9; 
    
    
    if W9byW_TO<W13byW_TO
        Aircraft.Weight.WfbyW_TO = 1.06*(1 - W9byW_TO);    % Fuel to MTOW ratio
        Aircraft.Weight.Landing_Takeoff = W1*W2*W3*W4*W5*W6;
    end
    
    
    Aircraft.Weight.fuel_Weight = Aircraft.Weight.WfbyW_TO * Aircraft.Weight.MTOW;  % Fuel Weight
    
end