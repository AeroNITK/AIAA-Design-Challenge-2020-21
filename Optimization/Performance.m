%  Performance Calculations
%  ------------------------------------------------------------------------
%  Input : Aircraft structure datatpye.
%  Output : Aircraft sturcture datatype with appended Perfomance Parameters.
%  All units are in FPS System.
%  ------------------------------------------------------------------------

function Aircraft = Performance(Aircraft)
    
    Aircraft.Performance.range1 = 100;  % in nautical miles
    Aircraft.Performance.range2 = 100;  % in nautical miles
    Aircraft.Performance.range3 = 900;  % in nautical miles
    Aircraft.Performance.altitude_cruise1 = 10000;    % Cruising Altitude in ft  
    Aircraft.Performance.altitude_cruise2 = 18000;    % Cruising Altitude in ft
    
    Aircraft.Performance.takeoff_runway_length = 4000;  % in ft
    Aircraft.Performance.landing_runway_length = 4000;  % in ft
    Aircraft.Performance.M_cruise = 0.67;    % Cruising Mach Number
    
    Aircraft.Performance.loiter2 = 4;   % loiter time in hours
    
    %%% Vn Diagram Values
    Aircraft.Vndiagram.n_limt = 4.5;
    Aircraft.Vndiagram.n_ult = 1.5*Aircraft.Vndiagram.n_limt;
    
    Aircraft.Performance.CL_max_TO=1.3;
    Aircraft.Performance.CL_max_L=2.2;
    

end