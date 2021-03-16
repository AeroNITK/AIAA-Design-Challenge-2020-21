 %  Aircraft Empty Weight Calculator
%  ------------------------------------------------------------------------
%  Input : Aircraft structure datatpye.
%  Output : Aircraft sturcture datatype with updated Empty Weight.
%  Equations are taken from Roskam part 5, Nicolai and Raymer. 
%  All units are in FPS System.
%  ------------------------------------------------------------------------

function [Aircraft] = empty_weight(Aircraft)

    d2r = pi/180;

    Aircraft.Weight.wing = Wing_Weight(Aircraft);
    Aircraft.Weight.fuselage = Fuselage_Weight(Aircraft);
    Aircraft = Landing_Gear_Weight(Aircraft);
    Aircraft = Tail_Weight(Aircraft);
    Aircraft = Propulsion_Weight(Aircraft);
    Aircraft.Weight.fcg = Flight_Controls_group_Weight(Aircraft);
    Aircraft.Weight.ig = Instrument_group_Weight(Aircraft);
    Aircraft.Weight.eg = Electrical_group_Weight(Aircraft); 
    
    %%%% System
    Aircraft.Weight.av = Avionics_group_Weight(Aircraft); 
    Aircraft.Weight.ef = Equip_Furnish_group_Weight(Aircraft);
    Aircraft.Weight.aci = AC_Anti_Icing_group_Weight(Aircraft);
    Aircraft.Weight.weap = Weapons_Group_Weight(Aircraft);
    
    
    Aircraft.Weight.empty_weight = Aircraft.Weight.wing + Aircraft.Weight.fuselage + Aircraft.Weight.LG + Aircraft.Weight.tail ...
                                + Aircraft.Weight.pg  + Aircraft.Weight.fcg + Aircraft.Weight.ig ...
                                + Aircraft.Weight.av + Aircraft.Weight.ef + Aircraft.Weight.aci ...
                                + Aircraft.Weight.weap + Aircraft.Weight.eg;
                           
    Aircraft.Weight.fixed_equip_weight = Aircraft.Weight.fcg + Aircraft.Weight.ig...
                                + Aircraft.Weight.av + Aircraft.Weight.ef...
                                + Aircraft.Weight.aci + Aircraft.Weight.weap + Aircraft.Weight.eg;                                                 
%%  Function for calculating Wing Weight
%%% Formula taken from Nicolai
%%% Equation number 20.1a
    function W_wg = Wing_Weight(Aircraft)
    
        Kw = 1;
        W_ff = 0.85;    % Wing Fudge Factor 0.85-0.89 (From Raymer)    
        
        W_wg = 3.08*(((Kw*Aircraft.Vndiagram.n_ult*Aircraft.Weight.Design_Gross_Weight)/...
            (Aircraft.Wing.t_c_root))*((tan(d2r*(Aircraft.Wing.Sweep_LE))-...
            2*(1-Aircraft.Wing.taper_ratio)/Aircraft.Wing.Aspect_Ratio*...
            (1+Aircraft.Wing.taper_ratio))^2+...
            1)*10^-6)^0.593*(Aircraft.Wing.Aspect_Ratio*(1+Aircraft.Wing.taper_ratio))^0.89*...
            (Aircraft.Wing.S)^0.741;
        
        W_wg = W_ff * W_wg;
    end
%%  Function for calculating Fuselage Weight
%%% Formula taken from Nicolai
%%% Equation number 20.4
    function W_fus = Fuselage_Weight(Aircraft)
        Kinl = 1;
        F_ff = 0.90;    % Fuselage Fudge Factor 0.90-0.95(From Raymer)
        
        Design_dive_speed = 1.25*(Aircraft.Performance.M_cruise*666.74)*sqrt(1);
        Aircraft.qd = 0.5*(Design_dive_speed*1.688)^2*0.00238; %Rho at sea level in slugs/ft^3

        W_fus=10.43*((Kinl)^1.42)*((Aircraft.qd/100)^0.283)*((Aircraft.Weight.MTOW/1000)^0.95)...
            *((Aircraft.Fuselage.length/Aircraft.Fuselage.height)^0.71);
        
        W_fus = W_fus * F_ff;
    end
%%  Function for calculating Landing Gear Weight
%%% Formula taken from Roskam
%%% Equation number 5.42 
    function Aircraft = Landing_Gear_Weight(Aircraft)
    
        LG_ff = 0.95;    % Landing Gear Fudge Factor 0.95-1.00 (From Raymer)
       
        Ag_mlg=33.0;
        Bg_mlg=0.04;
        Cg_mlg=0.021;
        Dg_mlg=0.0;
        K_gr=1; %K_gr=1 for low wing
        W_mlg=K_gr*(Ag_mlg+Bg_mlg*(Aircraft.Weight.MTOW^0.75)+...
            Cg_mlg*(Aircraft.Weight.MTOW)+Dg_mlg*Aircraft.Weight.MTOW^(3/2));
        W_mlg=W_mlg*LG_ff;
        Aircraft.Weight.mlg=W_mlg;
        
        Ag_nlg=12.0;
        Bg_nlg=0.06;
        Cg_nlg=0.0;
        Dg_nlg=0.0;
        W_nlg=K_gr*(Ag_nlg+Bg_nlg*(Aircraft.Weight.MTOW^0.75)+...
            Cg_nlg*(Aircraft.Weight.MTOW+Dg_nlg*Aircraft.Weight.MTOW^(3/2)));
        W_nlg=W_nlg*LG_ff;
        Aircraft.Weight.nlg=W_nlg;
        
        Aircraft.Weight.LG = Aircraft.Weight.mlg + Aircraft.Weight.nlg;
      
    end
%%  Function for calculating Tail Weight
%%% Formula taken from Nicolai
%%% Equation number 20.3a and 20.3b
    function Aircraft = Tail_Weight(Aircraft)
        T_ff = 0.85;    % Tail Fudge Factor (From Raymer)
        
        Aircraft.Tail.gamma_h = (Aircraft.Weight.Design_Gross_Weight*Aircraft.Vndiagram.n_ult)^0.813*...
            (Aircraft.Tail.Horizontal.S)^0.584*...
            (Aircraft.Tail.Horizontal.b/(Aircraft.Tail.Horizontal.t_c*Aircraft.Tail.Horizontal.chord_root))^0.033*...
            (Aircraft.Wing.mac/Aircraft.Tail.Horizontal.arm)^0.28;
        
       W_h = 0.0034*Aircraft.Tail.gamma_h^0.915;
       
       M_0=0.67; 

        Aircraft.Tail.gamma_v = (Aircraft.Weight.Design_Gross_Weight*Aircraft.Vndiagram.n_ult)^0.363*...
            (Aircraft.Tail.Vertical.S)^1.089*(M_0)^0.601*(Aircraft.Tail.Vertical.arm)^-0.726*...
            (1+0.3)^0.217*...
            (Aircraft.Tail.Horizontal.Aspect_Ratio)^0.337*(1+Aircraft.Tail.Vertical.taper_ratio)^0.363*...
            (cos(d2r*Aircraft.Tail.Horizontal.Sweep_qc))^-0.484;
        
        W_v = 0.19*Aircraft.Tail.gamma_v^1.014;
        
        W_t = W_h + W_v;
        
        Aircraft.Weight.tail = W_t * T_ff;
        
        Aircraft.Weight.vtail = W_v * T_ff;
        Aircraft.Weight.htail = W_h * T_ff;
        
       
        
    end
%%  Function for calculating Propulsion Group
%%% It includes Engine Weight + it's associated components like
%%% Engine Controls and Propellor controls.
%%% Formula taken from Nicolai
%%% Equation number 20.24,20.29, 20.31, 20.32   Pg. No. 558
    function Aircraft = Propulsion_Weight(Aircraft)
        
        W_Engine = (Aircraft.Propulsion.power_per_engine - 110.7) / 2.331; % From regression of Engines available in our power range
        Aircraft.Weight.Engine.W_Engine = W_Engine;
        
        N_ff = 0.90; % Nacelle Fudge Factor 0.9-0.95(From Raymer);
        
        Aircraft.Weight.Engine.W_engineControls = 56.84*((Aircraft.Fuselage.length+Aircraft.Wing.b)*...
            Aircraft.Propulsion.no_of_engines*10^-2)^0.514;
        Aircraft.Weight.Engine.W_StartingSystems = 12.05*(Aircraft.Propulsion.no_of_engines*W_Engine*10^-3)^1.458;
        
        Kp = 31.92;  %24 if HP>1500 and 31.92 if HP<1500
        Np = Aircraft.Propulsion.no_of_engines; %No. Of propellers per aircraft
        Nbl = 5; %No. of blades per propellor 
        d_p = 115.2/12; %Blade Dia (in ft) taken from Harzell data
  
        Aircraft.Weight.Engine.W_Propellor = 516; % Propellor weight by scaling Hartzell Data
        
        Aircraft.Weight.Engine.W_PropellorControls = Np*0.322*(Nbl)^0.589*(d_p*Aircraft.Propulsion.power*10^-3)^1.178;
        
        % Fuel System
        fuel_density = 52.4; %JP8
        fuel_inGallons = (Aircraft.Weight.fuel_Weight * 7.48)/fuel_density; %7.48 is ft^3 to Gallon
        
        Aircraft.Weight.Engine.W_self_Sealing_Bladder = 41.6*(fuel_inGallons*10^-2)^0.818;
        Aircraft.Weight.Engine.W_Fuel_System_Bladder_Cell_Backing_and_Supports = 7.91*(fuel_inGallons*10^-2)^0.854;
        Aircraft.Weight.Engine.W_In_Flight_Refuel_System = 13.64*(fuel_inGallons*10^-2)^0.392;
        Aircraft.Weight.Engine.W_Dump_and_Drain_System = 7.38*(fuel_inGallons*10^-2)^0.458;
        Aircraft.Weight.Engine.W_CG_Control_System = 28.38*(fuel_inGallons*10^-2)^0.442;
        
        Aircraft.Weight.FuelSystem = Aircraft.Weight.Engine.W_self_Sealing_Bladder + Aircraft.Weight.Engine.W_Fuel_System_Bladder_Cell_Backing_and_Supports +...
            Aircraft.Weight.Engine.W_In_Flight_Refuel_System + Aircraft.Weight.Engine.W_Dump_and_Drain_System + Aircraft.Weight.Engine.W_CG_Control_System;
        
        Aircraft.Weight.pg= (W_Engine*Aircraft.Propulsion.no_of_engines + Aircraft.Weight.Engine.W_engineControls + Aircraft.Weight.Engine.W_StartingSystems + ...
            Aircraft.Weight.Engine.W_Propellor + Aircraft.Weight.Engine.W_PropellorControls + Aircraft.Weight.FuelSystem);
    end
%%  Function for calculating Flight Controls Group Weight Plus Hyraulics and Pneumatics
%%% It includes actuation systems for ailerons + rudder + elevator
%%% + rudder + Adjustable stabilizor + high lift devices.
%%% Formula taken from Nicolai
%%% Equation number 20.34

    function W_fcg = Flight_Controls_group_Weight(Aircraft)
        
        Kfcf=138; %with horizontal tail
        W_fcg = Kfcf*(Aircraft.Weight.MTOW/1000)^0.581;
      
    end

%%  Function for calculating Instrument Group Weight
%%% Formula taken from Nicolai
%%% Equation number 20.39, 20.49

    function W_ig = Instrument_group_Weight(Aircraft)
        Npil=2;
        W_FlighInstrumentIndicators=Npil*(15+0.032*(Aircraft.Weight.MTOW*10^-3));
        W_EngineInstrumentIndicators=Aircraft.Propulsion.no_of_engines*(4.8+0.006*(Aircraft.Weight.MTOW*10^-3));
        W_ig = W_FlighInstrumentIndicators+W_EngineInstrumentIndicators;
      
    end

%%  Function for calculating Electrical Group Weight
%%% Formula taken from Nicolai
%%% Equation number 20.43; 


    function W_eg = Electrical_group_Weight(Aircraft)
        
        W_eg = 426.17*(Aircraft.Weight.FuelSystem*10^-3)^0.510;
      
    end
%%  Function for calculating Avionics Group Weight
%%% Formula taken from Raymer
%%% Equation number 15.21


    function W_av = Avionics_group_Weight(Aircraft)
        
        W_uav = 600; 
        W_av = 2.117*W_uav^0.933;
        
      
    end
%%  Function for calculating Furnishing Group Weight
%%% Formula taken from Nicolai
%%% Equation number 20.47, 20.48;

    function W_efg = Equip_Furnish_group_Weight(Aircraft)
        Design_dive_speed = 1.25*(Aircraft.Performance.M_cruise*666.74)*sqrt(1);
        Aircraft.qd = 0.5*(Design_dive_speed*1.688)^2*0.00238; %Rho at sea level in slugs/ft^3
        
        W_Ejection_Seats= 22.89*(Aircraft.Crew*Aircraft.qd*10^-2)^0.743;
        W_Misc=106.61*(Aircraft.Crew*Aircraft.Weight.MTOW*10^-5)^0.585;
        W_efg = W_Ejection_Seats + W_Misc;
      
    end
%%  Function for calculating AC and Anti-icing group Group Weight
%%% Formula taken from Nicolai
%%% Equation number 20.66;

    function W_aci = AC_Anti_Icing_group_Weight(Aircraft)
        
        K_acai= 108.64;
        W_aci = K_acai*((Aircraft.Weight.av+200*Aircraft.Crew)*10^-3)^0.538;
      
    end


%% %%Function for Weapons Weight

    function W_weap = Weapons_Group_Weight(Aircraft)
        Aircraft.Weight.ammo_box=60;
        Aircraft.Weight.Gun= 260;
        Number_Of_Guns= 2;
        Aircraft.Weight.Guns= Aircraft.Weight.Gun* Number_Of_Guns;
       
        W_weap = Aircraft.Weight.ammo_box + Aircraft.Weight.Guns;
      
    end


end
