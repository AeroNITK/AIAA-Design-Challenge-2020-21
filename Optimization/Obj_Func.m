function value = Obj_Func(x)
        
    global Aircraft
    
    Aircraft.Performance.WbyP = x(1);
    Aircraft.Wing.Sweep_qc = x(2);
    Aircraft.Wing.t_c_root = x(3);
    Aircraft.Performance.cruise_altitude = x(4);
    Aircraft.Wing.Aspect_Ratio = x(5);
    Aircraft.Wing.S = x(6);
    
    Aircraft = Performance(Aircraft);
    
    Aircraft.Weight.MTOW = 15000;  % Initial Guess
    error = 1; % Dummy value to start the while loop
    
    while error > 0.005
    
        error = Aircraft.Weight.MTOW;
        Aircraft = Sizing(Aircraft);
        Aircraft.Performance.WbyS = Aircraft.Weight.MTOW/Aircraft.Wing.S;
        Aircraft = Aero(Aircraft);
        Aircraft = Crew_Payload_Weight(Aircraft);
        Aircraft = Fuel_Weight(Aircraft);
        Aircraft = empty_weight(Aircraft);
        Aircraft.Weight.MTOW = Aircraft.Weight.crew + Aircraft.Weight.payload + Aircraft.Weight.fuel_Weight...
                               + Aircraft.Weight.empty_weight;

        error = abs(error - Aircraft.Weight.MTOW);
    end
    
    value = Aircraft.Weight.MTOW;
end
