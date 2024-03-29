% Code for estimating CG of the airplane and to plot CG travel for various
% loading scenarios. All the units are in FPS unless mentioned otherwise.
% Formulas and approx assumption from commercial airplane design principles(CADP)
% UNLESS mentioned otherwise.

clear;
clc;
close all;
load('Aircraft.mat');

%% Calculating cg of each component (from nose in ft)
Aircraft = fuselage_cg(Aircraft);
Aircraft = vertical_tail_cg(Aircraft);
Aircraft = wing_cg(Aircraft);
Aircraft = horizontal_tail_cg(Aircraft);
Aircraft = propulsion_cg(Aircraft);
Aircraft = NLG_cg(Aircraft);
Aircraft = MLG_cg(Aircraft);
Aircraft = fixed_equip_cg(Aircraft);
Aircraft = crew_cg(Aircraft);

Aircraft.cg.fuel = Aircraft.Fuselage.length - 119.1125;

%% Calculating cg of empty weight of plane (from nose in ft)
Aircraft.cg.empty_weight = Aircraft.cg.fuselage*Aircraft.Weight.fuselage ...
                    +  Aircraft.cg.vtail*Aircraft.Weight.vtail ...
                    +  Aircraft.cg.wing*Aircraft.Weight.wing ...
                    +  Aircraft.cg.htail*Aircraft.Weight.htail ...
                    +  Aircraft.cg.propulsion*Aircraft.Weight.pg_ng ...
                    +  Aircraft.cg.nlg*Aircraft.Weight.nlg ...
                    +  Aircraft.cg.mlg*Aircraft.Weight.mlg ...
                    +  Aircraft.cg.fixed_equip*Aircraft.Weight.fixed_equip_weight;

Aircraft.cg.empty_weight = Aircraft.cg.empty_weight/Aircraft.Weight.empty_Weight;

%% Calculating cg of Operating Empty Weight of plane (from nose in ft)
Aircraft.Weight.op_empty_weight = Aircraft.Weight.empty_Weight + Aircraft.Weight.crew + 0.01*Aircraft.Weight.fuel_Weight;

Aircraft.cg.op_empty_weight = Aircraft.cg.empty_weight * Aircraft.Weight.empty_Weight ...
                    +  Aircraft.cg.fuel * 0.01 * Aircraft.Weight.fuel_Weight ...    % Fuel CG is Wing CG
                    +  Aircraft.cg.crew * Aircraft.Weight.crew;

Aircraft.cg.op_empty_weight = Aircraft.cg.op_empty_weight/Aircraft.Weight.op_empty_weight;

%% Calculating cg of Operating Empty Weight + Window passengers + Baggage (from nose in ft)
Aircraft.cg.op_wind = Aircraft.cg.op_empty_weight * Aircraft.Weight.op_empty_weight ...
                            + 84 * (Aircraft.Weight.baggage + Aircraft.Weight.person) ...   % 84 Window passengers
                        * (Aircraft.Fuselage.length_nc + 0.53*Aircraft.Fuselage.length_cabin);

Aircraft.cg.op_wind = Aircraft.cg.op_wind/( Aircraft.Weight.op_empty_weight +  ...
                        84 * (Aircraft.Weight.baggage + Aircraft.Weight.person) );
                    
%% Calculating cg of Operating Empty Weight + Window passengers + Middle Row + Baggage (from nose in ft)
Aircraft.cg.op_wind_mid = Aircraft.cg.op_wind*(Aircraft.Weight.op_empty_weight + 84 * (Aircraft.Weight.baggage + Aircraft.Weight.person)) ...
                            +  147 * (Aircraft.Weight.baggage + Aircraft.Weight.person) ...   % 147 Middle passengers
                        * (Aircraft.Fuselage.length_nc + 0.53*Aircraft.Fuselage.length_cabin);

Aircraft.cg.op_wind_mid = Aircraft.cg.op_wind_mid/( Aircraft.Weight.op_empty_weight +  ...
                        231 * (Aircraft.Weight.baggage + Aircraft.Weight.person) );                    

%% Calculating cg of Operating Empty Weight + Window passengers + Middle Row + Aisle + Baggage (from nose in ft)
Aircraft.cg.op_wind_mid_ais = Aircraft.cg.op_wind_mid*(Aircraft.Weight.op_empty_weight + 231 * (Aircraft.Weight.baggage + Aircraft.Weight.person)) ...
                            +  169 * (Aircraft.Weight.baggage + Aircraft.Weight.person) ...   % 169 aisle passengers
                        * (Aircraft.Fuselage.length_nc + 0.53*Aircraft.Fuselage.length_cabin);

Aircraft.cg.op_wind_mid_ais = Aircraft.cg.op_wind_mid_ais/( Aircraft.Weight.op_empty_weight +  ...
                        400 * (Aircraft.Weight.baggage + Aircraft.Weight.person) );         
                    
%% Calculating cg of Operating Empty Weight + Fuel Weight of plane (from nose in ft)
Aircraft.cg.op_fuel = Aircraft.cg.op_empty_weight * Aircraft.Weight.op_empty_weight ...
                    + Aircraft.cg.fuel * 0.99 * Aircraft.Weight.fuel_Weight;
                
Aircraft.cg.op_fuel = Aircraft.cg.op_fuel/(Aircraft.Weight.op_empty_weight + 0.99 * Aircraft.Weight.fuel_Weight);                

%% Calculating cg of Operating Empty Weight + Fuel + Passengers + Baggage of plane (Behind the CG) (from nose in ft)
Aircraft.cg.op_fuel_pass_bag = Aircraft.cg.op_fuel * (Aircraft.Weight.op_empty_weight + 0.99 * Aircraft.Weight.fuel_Weight) ...
                        + 190 * Aircraft.Weight.person * (Aircraft.Fuselage.length_nc + 0.625*Aircraft.Fuselage.length_cabin) ...
                        + 190 * Aircraft.Weight.baggage * (Aircraft.Fuselage.length_nc + 0.53*Aircraft.Fuselage.length_cabin);
                
Aircraft.cg.op_fuel_pass_bag = Aircraft.cg.op_fuel_pass_bag/( Aircraft.Weight.op_empty_weight + ...
                          190 * (Aircraft.Weight.baggage + Aircraft.Weight.person) ...
                          + 0.99 * Aircraft.Weight.fuel_Weight);

%% Calculating cg of MTOW of plane (from nose in ft)
Aircraft.cg.MTOW = Aircraft.cg.fuel * 0.99 * Aircraft.Weight.fuel_Weight ...
                 + (Aircraft.Passenger.business +  Aircraft.Passenger.economy) ...
                 * (Aircraft.Weight.baggage + Aircraft.Weight.person) ...
                 * (Aircraft.Fuselage.length_nc + 0.53*Aircraft.Fuselage.length_cabin) ...
                 + Aircraft.cg.op_empty_weight * Aircraft.Weight.op_empty_weight;
             
Aircraft.cg.MTOW = Aircraft.cg.MTOW/Aircraft.Weight.MTOW;             

%% Plotting CG travel
plotting(Aircraft)

% save('Aircraft');

%% Fuselage CG Estimation
%%%Formula taken from Roskam Table 8.1 Pg 114
%DONE
function Aircraft = fuselage_cg(Aircraft)

      Aircraft.cg.fuselage = 0.39*Aircraft.Fuselage.length;  
    
end
%% Vertical Tail CG Estimation
%%%Formula taken from Roskam Table 8.1 Pg 114
%CHECK b/2
function Aircraft = vertical_tail_cg(Aircraft)
     Aircraft.Tail.Vertical.root_chord_pos = 39.26; %TEMP VALUE, From nose (in ft). From cad sketch

    Aircraft.cg.vtail = Aircraft.Tail.Vertical.root_chord_pos + tan(deg2rad(Aircraft.Tail.Vertical.Sweep_LE))*...
        (0.38*Aircraft.Tail.Vertical.b/2) + (Aircraft.Tail.Vertical.chord_tip + ...
        (Aircraft.Tail.Vertical.chord_tip - Aircraft.Tail.Vertical.chord_root)*(0.38-1))*0.42;
   
end
%% Wing CG Estimation
%%%Formula taken from Roskam Table 8.1 Pg 114
function Aircraft = wing_cg(Aircraft)

    Aircraft.Wing.root_chord_pos = 79.734;    %TEMP VALUE, From nose (in ft). From cad sketch
    
    Aircraft.cg.wing = Aircraft.wing.root_chord_pos + tan(deg2rad(Aircraft.wing.Sweep_LE))*...
        (0.38*Aircraft.wing.b/2) + (Aircraft.wing.chord_tip + ...
        (Aircraft.wing.chord_tip - Aircraft.wing.chord_root)*(0.38-1))*0.42;
    


end
%% Horizontal Tail CG Estimation
%%%Formula taken from Roskam Table 8.1 Pg 114
function Aircraft = horizontal_tail_cg(Aircraft)

    Aircraft.Tail.Horizontal.root_chord_pos = 39.26; %TEMP VALUE, From nose (in ft). From cad sketch

    Aircraft.cg.htail = Aircraft.Tail.Horizontal.root_chord_pos + tan(deg2rad(Aircraft.Tail.Horizontal.Sweep_LE))*...
        (0.38*Aircraft.Tail.Horizontal.b/2) + (Aircraft.Tail.Horizontal.chord_tip + ...
        (Aircraft.Tail.Horizontal.chord_tip - Aircraft.Tail.Horizontal.chord_root)*(0.38-1))*0.42;
    


end
%% Propulsion CG Estimation
%ON HOLD
function Aircraft = propulsion_cg(Aircraft)

    Aircraft.cg.propulsion = Aircraft.Fuselage.length - 133.126;%- 150.715;%- 143.225;  
    % 140.109 is from cad sketch.

end
%% Nose landing CG Estimation
%ON HOLD
function Aircraft = NLG_cg(Aircraft)

    Aircraft.cg.nlg = 0.08*Aircraft.Fuselage.length;  % Based on load distribution
    
end
%% Main landing CG Estimation
%ON HOLD
function Aircraft = MLG_cg(Aircraft)

    Aircraft.cg.mlg = 0.51797*Aircraft.Fuselage.length;  % For retracting landing gear into the wing.
    
end
%% Fixed Equipment CG Estimation
function Aircraft = fixed_equip_cg(Aircraft)

    Aircraft.cg.fixed_equip = ( 1.5*Aircraft.Fuselage.length_nc + Aircraft.Fuselage.length_cabin ...
                            + Aircraft.Fuselage.length_tc/2 )/2;  
    % Systems are distributed in such a way that hals of the weight is at
    % the center of the nose cone and remaining half at tail cone center.
    
end
%% Crew CG Estimation
function Aircraft = crew_cg(Aircraft)

    Aircraft.cg.crew = .
    
end
%% Plotting CG Travel
function plotting(Aircraft)

    X_LE_mac = Aircraft.Fuselage.length - 126.266; %- 137.546; %- 129.382;  % Based on cad model.
    Xe = (Aircraft.cg.empty_weight - X_LE_mac)/Aircraft.Wing.mac;
    Xoe = (Aircraft.cg.op_empty_weight - X_LE_mac)/Aircraft.Wing.mac;
    Xoe_wind = (Aircraft.cg.op_wind - X_LE_mac)/Aircraft.Wing.mac;
    Xoe_wind_mid = (Aircraft.cg.op_wind_mid - X_LE_mac)/Aircraft.Wing.mac;
    Xoe_wind_mid_ais = (Aircraft.cg.op_wind_mid_ais - X_LE_mac)/Aircraft.Wing.mac;
    Xoe_fuel = (Aircraft.cg.op_fuel - X_LE_mac)/Aircraft.Wing.mac;
    Xoe_fuel_pass_bag = (Aircraft.cg.op_fuel_pass_bag - X_LE_mac)/Aircraft.Wing.mac; 
    Xmtow = (Aircraft.cg.MTOW - X_LE_mac)/Aircraft.Wing.mac;
    
    plot(Xe,Aircraft.Weight.empty_Weight,'o','MarkerSize',8,'MarkerFaceColor','r');
    
    hold on
    
    plot(Xoe,Aircraft.Weight.op_empty_weight,'h','MarkerSize',8,'MarkerFaceColor','m');  
    
    plot(Xoe_wind, Aircraft.Weight.op_empty_weight + 84 * (Aircraft.Weight.baggage + Aircraft.Weight.person),'s','MarkerSize',8,'MarkerFaceColor','b');
    plot(Xoe_wind_mid, Aircraft.Weight.op_empty_weight + 231 * (Aircraft.Weight.baggage + Aircraft.Weight.person),'^','MarkerSize',8,'MarkerFaceColor','r');
    plot(Xoe_wind_mid_ais, Aircraft.Weight.op_empty_weight + 400 * (Aircraft.Weight.baggage + Aircraft.Weight.person),'>','MarkerSize',8,'MarkerFaceColor','m');
    plot(Xoe_fuel,Aircraft.Weight.op_empty_weight + 0.99 * Aircraft.Weight.fuel_Weight,'d','MarkerSize',8,'MarkerFaceColor','b');
    plot(Xoe_fuel_pass_bag, Aircraft.Weight.op_empty_weight + 190*(Aircraft.Weight.baggage + Aircraft.Weight.person) ...
                            + 0.99 * Aircraft.Weight.fuel_Weight,'p','MarkerSize',8,'MarkerFaceColor','r');
    plot(Xmtow,Aircraft.Weight.MTOW,'<','MarkerSize',8,'MarkerFaceColor','m');
    
    x = [Xe,Xoe];
    y = [Aircraft.Weight.empty_Weight,Aircraft.Weight.op_empty_weight];
    
    plot(x,y,'b--','LineWidth',1.5);
    
    x = [Xoe,Xoe_wind,Xoe_wind_mid,Xoe_wind_mid_ais,Xmtow];
    y = [Aircraft.Weight.op_empty_weight, ...
        Aircraft.Weight.op_empty_weight + 84 * (Aircraft.Weight.baggage + Aircraft.Weight.person), ...
        Aircraft.Weight.op_empty_weight + 231 * (Aircraft.Weight.baggage + Aircraft.Weight.person), ...
        Aircraft.Weight.op_empty_weight + 400 * (Aircraft.Weight.baggage + Aircraft.Weight.person), ...
        Aircraft.Weight.MTOW];
    
    plot(x,y,'r--','LineWidth',1.5);
    
    x = [Xoe,Xoe_fuel,Xoe_fuel_pass_bag,Xmtow];
    y = [Aircraft.Weight.op_empty_weight, ...
        Aircraft.Weight.op_empty_weight + 0.99 * Aircraft.Weight.fuel_Weight, ...
        Aircraft.Weight.op_empty_weight + 190*(Aircraft.Weight.baggage + Aircraft.Weight.person) ...
                            + 0.99 * Aircraft.Weight.fuel_Weight,...
        Aircraft.Weight.MTOW];
    
    plot(x,y,'k--','LineWidth',1.5);
    
        legend('Empty Weight','Opt Empty Weight','Window Passenger + Baggage', ...
            'Middle Passenger + Baggage','Aisle Passenger + Baggage','Fuel', ...
            'Fully Aft loaded','MTOW','Location','southeast','Mandatory Path','Loading Path 1','Loading Path 2');
    
    hold off
    
    title('CG Excursion Diagram')
    xlabel('Percentage of MAC')
    ylabel('Weight (lbs)')
    grid on
%     xlim([0.18 0.3]);
%     text(Xe + 0.001,Aircraft.Weight.empty_Weight,'Empty Weight');
%     text(Xoe + 0.001,Aircraft.Weight.op_empty_weight + 5000,'Opt Empty Weight');
%     text(Xoe_fuel + 0.001,Aircraft.Weight.op_empty_weight + 0.99 * Aircraft.Weight.fuel_Weight,'Opt Empty Weight + Fuel');
%     text(Xmtow + 0.001,Aircraft.Weight.MTOW + 5000,'MTOW');            
    
end

%     Xoe_pass_bag = (Aircraft.cg.op_pass_bag - X_LE_mac)/Aircraft.Wing.mac;


%     text(Xoe_fuel + 0.001,Aircraft.Weight.op_empty_weight + 0.99 * Aircraft.Weight.fuel_Weight,'Opt Empty Weight + Fuel');
%     text(Xoe_pass_bag + 0.001, Aircraft.Weight.op_empty_weight + ...
%                       (Aircraft.Passenger.business +  Aircraft.Passenger.economy) ...
%                     * (Aircraft.Weight.baggage + Aircraft.Weight.person) + 5000, 'Opt Empty Weight + Passenger + Baggage');
