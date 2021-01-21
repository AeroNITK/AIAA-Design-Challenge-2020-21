%  Aircraft Empty Weight Calculator
%  ------------------------------------------------------------------------
%  Input : Aircraft structure datatpye.
%  Output : Aircraft sturcture datatype with updated Empty Weight.
%  All the equations are taken from Commercial Airplane
%  Design Principles. Chapter No. 8. 
%  All units are in FPS System.
%  ------------------------------------------------------------------------

function [Aircraft] = Empty_Weight(Aircraft)

    d2r = pi/180;
    %in2ft = 1/12;

    Aircraft.Weight.wing = Wing_Weight(Aircraft);
    Aircraft.Weight.fuselage = Fuselage_Weight(Aircraft);
    Aircraft = Landing_Gear_Weight(Aircraft);
    Aircraft = Tail_Weight(Aircraft);
    Aircraft.Weight.pg_ng = Propulsion_Nacelle_Group_Weight(Aircraft);
    Aircraft.Weight.fcg = Flight_Controls_group_Weight(Aircraft);
    %Aircraft.Weight.apug = Auxiliary_Power_Unit_group_Weight(Aircraft);
    Aircraft.Weight.ig = Instrument_group_Weight(Aircraft);
    %Aircraft.Weight.hpg = Hydra_Pneu_group_Weight(Aircraft);
    Aircraft.Weight.eg = Electrical_group_Weight(Aircraft);
    Aircraft.Weight.av = Avionics_group_Weight(Aircraft);
    Aircraft.Weight.ef = Equip_Furnish_group_Weight(Aircraft);
    Aircraft.Weight.aci = AC_Anti_Icing_group_Weight(Aircraft);
    Aircraft.Weight.weap = Weapons_Group_Weight(Aircraft);
    
    
    Aircraft.Weight.empty_Weight = Aircraft.Weight.wing + Aircraft.Weight.fuselage + Aircraft.Weight.LG + Aircraft.Weight.tail ...
                                + Aircraft.Weight.pg_ng + Aircraft.Weight.fcg + Aircraft.Weight.ig ...
                                + Aircraft.Weight.eg + Aircraft.Weight.av + Aircraft.Weight.ef + Aircraft.Weight.aci ...
                                + Aircraft.Weight.weap;
                            
    Aircraft.Weight.fixed_equip_weight = Aircraft.Weight.fcg + Aircraft.Weight.ig...
                                + Aircraft.Weight.eg + Aircraft.Weight.av + Aircraft.Weight.ef...
                                + Aircraft.Weight.aci + Aircraft.Weight.weap;                                                 
%%  Function for calculating Wing Weight
%%% Formula taken from Roskam 5
%%% Equation number 5.9; Pg. No. 70 ( pdf pg No. 86) 
    function W_wg = Wing_Weight(Aircraft)
    
        Kw = 1;
        W_ff = 0.85;    % Wing Fudge Factor 0.85-0.89 (From Raymer)    
        
        %WORK PENDING
        %wether to use flight design gross weight instaed of Wto
        % does (t/c)m mean mean of root and tip
        W_wg=3.08*(((Kw*Aircraft.Vndiagram.n_ult*Aircraft.Weight.MTOW)/...
            (Aircraft.Wing.t_c_root+Aircraft.Wing.t_c_tip)/2)*((tan(d2r*Aircraft.Wing.Sweep_le)-...
            2*(1-Aircraft.Wing.taper_ratio)/Aircraft.Wing.Aspect_Ratio*(1+Aircraft.Wing.taper_ratio))^2+...
            1)*10^-6)^0.593*(Aircraft.Wing.Aspect_Ratio*(1+Aircraft.Wing.taper_ratio))^0.89*...
            (Aircraft.Wing.S)^0.741;
        
        W_wg = W_ff * W_wg;
    end
%%  Function for calculating Fuselage Weight
%%% Formula taken from Roskam 5
%%% Equation number 5.26; Pg. No. 76 (pdf Pg. No. 77)
    function W_fus = Fuselage_Weight(Aircraft)
        
        %WORK PENDING
        %CHECK qd design dive dynamic pressure
    
        Kinl = 1;
        F_ff = 0.90;    % Fuselage Fudge Factor 0.90-0.95(From Raymer)
        Aircraft.qd=218.292;
        

        W_fus=10.43*((Kinl)^1.42)*((Aircraft.qd/100)^0.283)*((Aircraft.Weight.MTOW/1000)^0.95)...
            *((Aircraft.Fuselage.length/Aircraft.Fuselage.height)^0.71);
        
        W_fus = W_fus * F_ff;
      
    end
%%  Function for calculating Landing Gear Weight
%%% Formula taken from Roskam
%%% Equation number 5.42 ( attck aircraft section redirects to this); Pg.
%%% No. 82 (PDF Pg. No. 98)
    function Aircraft = Landing_Gear_Weight(Aircraft)
        
        %DONE
    
        LG_ff = 0.95;    % Landing Gear Fudge Factor 0.95-1.00 (From Raymer)
       
        Ag_mlg=33.0;
        Bg_mlg=0.04;
        Cg_mlg=0.021;
        Dg_mlg=0.0;
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
%         W_lg = 0.00891*Aircraft.Weight.MTOW^1.12;
        
%         W_lg = W_lg * LG_ff;
      
    end
%%  Function for calculating Tail Weight
%%% Formula taken from Commercial Airplane Design Principles
%%% Equation number 8.13 & 8.14; Pg. No. 312 & 313
    function Aircraft = Tail_Weight(Aircraft)
        

        
        T_ff = 0.85;    % Tail Fudge Factor (From Raymer)
        
        
        
        %check wether to use flight design gross weight
        
        Aircraft.Tail.gamma_h = (Aircraft.Weight.MTOW*Aircraft.Vndiagram.n_ult)^0.813*...
            (Aircraft.Tail.Horizontal.S)^0.584*...
            (Aircraft.Tail.Horizontal.b/(Aircraft.Tail.Horizontal.t_c*Aircraft.Tail.Horizontal.chord_root))^0.033*...
            (Aircraft.Wing.mac/Aircraft.Tail.Horizontal.arm)^0.28;
        
       W_h = 0.0034*Aircraft.Tail.gamma_h^0.915;
        
        %CHECK M_0 and Rudder Area
        Aircraft.Tail.gamma_v = (Aircraft.Weight.MTOW*Aircraft.Vndiagram.n_ult)^0.363*...
            (Aircraft.Tail.Vertical.S)^1.089*(Aircraft.M_0)^0.601*(Aircraft.Tail.Vertical.arm)^-0.726*...
            (1+Aircraft.Tail.Vertical.Rudder_S/Aircraft.Tail.Vertical.S)^0.217*...
            (Aircraft.Tail.Horizontal.Aspect_Ratio)^0.337*(1+Aircraft.Tail.Vertical.taper_ratio)^0.363*...
            (cos(d2r*Aircraft.Tail.Horizontal.Sweep_qc))^-0.484;
        
        W_v = 0.19*Aircraft.Tail.gamma_v^1.014;
        
        W_t = W_h + W_v;
        
        Aircraft.Weight.tail = W_t * T_ff;
        
        Aircraft.Weight.vtail = W_v * T_ff;
        Aircraft.Weight.htail = W_h * T_ff;
        
       
        
    end
%%  Function for calculating Propulsion Group + Nacelle Weight
%%% It includes Engine Weight + it's associated components like
%%% Engine Controls+.
%%% Formula taken from Nicolai since no formula for turboprop attack in
%%% Roskam
%%% Equation number 20.24,20.29, 20.31, 20.32   Pg. No. 558
    function W_pg_ng = Propulsion_Nacelle_Group_Weight(Aircraft)
        
        %WORK PENDING
        %ENGINE WEIGHT
        W_Engine = 515; %lbs
        
        N_ff = 0.90;% Nacelle Fudge Factor 0.9-0.95(From Raymer);
        
        %not including fuel systems here
        %need to add variable values We(engine wt), Np, d_p, HP)
       
        W_engineControls=56.84*((Aircraft.Fuselage.Length+Aircraft.Wing.b)*...
            Aircraft.Propulsion.no_of_engines*10^-2)^0.514;
        W_StartingSystems=12.05*(Aircraft.Propulsion.no_of_engines*W_e*10^-3)^1.458;
        
        Kp=31.92;  %24 if HP>1500 and 31.92 if HP<1500
        W_Propellor=Kp*Np*(Nbl)^0.391*(d_p*HP*10^-3)^0.782;
        
        W_PropellorControls=0.322*(Nbl)^0.589*(Np*d_p*HP*10^-3)^1.178;
        
        %Fuel System
        fuel_density= 52.4; %JP4 CHECK
        fuel_inGallons= (Aircraft.Weight.fuel_Weight*7.48)/fuel_density; %7.48 is ft^3 to Gallon
        
        W_self_Sealing_Bladder=41.6*(fuel_inGallons*10^-2)^0.818;
        W_Fuel_System_Bladder_Cell_Backing_and_Supports=7.91*(fuel_inGallons*10^-2)^0.854;
        W_In_Flight_Refuel_System=13.64*(fuel_inGallons*10^-2)^0.392;
        W_Dump_and_Drain_System=7.38*(fuel_inGallons*10^-2)^0.458;
        W_CG_Control_System=28.38*(fuel_inGallons*10^-2)^0.442;
        
        Aircraft.Weight.FuelSystem=W_self_Sealing_Bladder + W_Fuel_System_Bladder_Cell_Backing_and_Supports +...
            W_In_Flight_Refuel_System + W_Dump_and_Drain_System + W_CG_Control_System;
   
        W_pg_ng= W_engine*Aircraft.Propulsion.no_of_engines + N_ff*W_Nacelle + W_engineControls + W_StartingSystems + ...
            W_Propellor + W_PropellorControls + Aircraft.Weight.FuelSystem;
        
      
    end
%%  Function for calculating Flight Controls Group Weight Plus Hyraulics and Pneumatics
%%% It includes actuation systems for ailerons + rudder + elevator
%%% + rudder + Adjustable stabilizor + high lift devices.
%%% Formula taken from Roskam
%%% Equation number 7.10; Pg. No. 100

    %DONE
    
    function W_fcg = Flight_Controls_group_Weight(Aircraft)
        
        Kfcf=138; %with horizontal tail
        W_fcg = Kfcf*(Aircraft.Weight.MTOW/1000)^0.581;
      
    end

%%  Function for calculating Instrument Group Weight
%%% Formula taken from Nicolai
%%% Equation number 20.39, 20.49; Pg. No. 561
    
    %DONE

    function W_ig = Instrument_group_Weight(Aircraft)
        Npil=2;
        W_FlighInstrumentIndicators=Npil*(15+0.032*(Aircraft.Weight.MTOW*10^-3));
        W_EngineInstrumentIndicators=Aircraft.Propulsion.no_of_engines*(4.8+0.006*(Aircraft.Weight.MTOW*10^-3));
        W_ig = W_FlighInstrumentIndicators+W_EngineInstrumentIndicators;
      
    end

%%  Function for calculating Electrical Group Weight
%%% Formula taken from Nicolai
%%% Equation number 20.43; 

%DONE

    function W_eg = Electrical_group_Weight(Aircraft)
        
        W_eg = 426.17*(Aircraft.Weight.FuelSystem*10^-3)^0.510;
      
    end
%%  Function for calculating Avionics Group Weight
%%% Formula taken from Commercial Airplane Design Principles
%%% Equation number 8.33; Pg. No. 328

%NEED TO FIND FORMULA

    function W_av = Avionics_group_Weight(Aircraft)
        
        W_av = 600 + 0.005*Aircraft.Weight.MTOW;
      
    end
%%  Function for calculating Furnishing Group Weight
%%% Formula taken from Nicolai
%%% Equation number 20.47, 20.48;

%DONE

    function W_efg = Equip_Furnish_group_Weight(Aircraft)
        
        Aircraft.N_Crew=2;
        W_Ejection_Seats= 22.89*(N_Crew*Aircraft.qd*10^-2)^0.743;
        W_Misc=106.61*(Aircraft.N_Crew*Aircraft.Weight.MTOW*10^-5)^0.585;
        W_efg = W_Ejection_Seats + W_Misc;
      
    end
%%  Function for calculating AC and Anti-icing group Group Weight
%%% Formula taken from Nicolai
%%% Equation number 20.66;

%DONE

    function W_aci = AC_Anti_Icing_group_Weight(Aircraft)
        
        K_acai= 108.64;
        W_aci = K_acai*((W_av+200*Aircraft.N_Crew)*10^-3)^0.538;
      
    end


%% %%Function for Weapons Weight

%DONE

    function W_weap = Weapons_Group_Weight(Aircraft)
        Aircraft.Weight.ammo_box=60;
        Aircraft.Weight.Gun= 260;
        Number_Of_Guns= 2;
        Aircraft.Weight.Guns= Aircraft.Weight.Gun* Number_Of_Guns;
       
        W_weap = Aircraft.Weight.ammo_box + Aircraft.Weight.Guns;
      
    end


end
