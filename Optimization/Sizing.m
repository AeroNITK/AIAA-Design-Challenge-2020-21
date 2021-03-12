%  Aircraft Sizing based on independent variables
%  ------------------------------------------------------------------------
%  Input : Aircraft structure datatpye.
%  Output : Aircraft sturcture datatype with appended Dimensions of Wing,
%  Tail, Fuselage, Propulsion.
%  All units are in FPS System.
%  ------------------------------------------------------------------------

function Aircraft = Sizing(Aircraft)
    
    d2r = pi/180;
    
    Aircraft = Wing_Sizing(Aircraft);
    
    Aircraft = Fuselage_Sizing(Aircraft);
    
    Aircraft = Tail_Sizing(Aircraft);
    
    Aircraft = Prop_Sizing(Aircraft);
    
    %% Wing Sizing
    function Aircraft = Wing_Sizing(Aircraft)

        Aircraft.Wing.b = sqrt(Aircraft.Wing.Aspect_Ratio*Aircraft.Wing.S);
        
        Aircraft.Wing.taper_ratio = 0.491 * exp(-0.04 * Aircraft.Wing.Sweep_qc); 
        % From Raymer Fig 4.24 Pg: 84 ; Function obtained from curve fitting
        % Input is in degrees only.

        Aircraft.Wing.Sweep_LE = atan( tan(Aircraft.Wing.Sweep_qc*d2r) + ...
                                (1 - Aircraft.Wing.taper_ratio)/(Aircraft.Wing.Aspect_Ratio*(1 + Aircraft.Wing.taper_ratio)) )/d2r;
                            
        Aircraft.Wing.Sweep_hc = atan( tan(Aircraft.Wing.Sweep_qc*d2r) - ...
                                (1 - Aircraft.Wing.taper_ratio)/(Aircraft.Wing.Aspect_Ratio*(1 + Aircraft.Wing.taper_ratio)) )/d2r;
        
        Aircraft.Wing.chord_root = (2*Aircraft.Wing.S)/(Aircraft.Wing.b*(1 + Aircraft.Wing.taper_ratio));
        
        Aircraft.Wing.chord_tip = Aircraft.Wing.chord_root*Aircraft.Wing.taper_ratio;
        
        Aircraft.Wing.Dihedral = 5; % Based on average taken from Raymer (Pg. No. 89)
        
        Aircraft.Wing.incidence = 0;
   
        Aircraft.Wing.mac = 2*Aircraft.Wing.chord_root*(1 + Aircraft.Wing.taper_ratio ...
                            + Aircraft.Wing.taper_ratio^2)/(3*(1 + Aircraft.Wing.taper_ratio));
        Aircraft.Wing.Y = (Aircraft.Wing.b/6)*(1 + 2*Aircraft.Wing.taper_ratio) ...
                            /(1 + Aircraft.Wing.taper_ratio);
    end
    %% Tail Sizing
    function Aircraft = Tail_Sizing(Aircraft)
        % ------------------------------------------------------------------------------------------------------------------------
        %%% Horizontal Tail
        % ------------------------------------------------------------------------------------------------------------------------
        Aircraft.Tail.Horizontal.Coeff = 0.75;    % Horizontal Tail Volume Coefficient from Raymer avg of fighter and trainer Pg: 160
        Aircraft.Tail.Horizontal.arm = 0.49 * Aircraft.Fuselage.length;    % Horizontal Tail Moment Arm (in ft)from raymer Pg: 160
        Aircraft.Tail.Horizontal.Aspect_Ratio = 3.5;   % Avg data from Raymer  
        Aircraft.Tail.Horizontal.taper_ratio = 0.3;   % Avg data from Raymer
        Aircraft.Tail.Horizontal.dihedral = 0;    % Avg data from Roskam (in deg)
        Aircraft.Tail.Horizontal.Sweep_qc = 5 + Aircraft.Wing.Sweep_qc;   % Based on the guidelines of Raymer; Pg: 111 (in deg)

        Aircraft.Tail.Horizontal.S = (Aircraft.Tail.Horizontal.Coeff*Aircraft.Wing.S...
                                    *Aircraft.Wing.mac)/(Aircraft.Tail.Horizontal.arm);

        Aircraft.Tail.Horizontal.b = sqrt(Aircraft.Tail.Horizontal.Aspect_Ratio...
                                    *Aircraft.Tail.Horizontal.S);

        Aircraft.Tail.Horizontal.chord_root = 2*Aircraft.Tail.Horizontal.S/(Aircraft.Tail.Horizontal.b ...
                                *(1 + Aircraft.Tail.Horizontal.taper_ratio));

        Aircraft.Tail.Horizontal.chord_tip = Aircraft.Tail.Horizontal.taper_ratio * Aircraft.Tail.Horizontal.chord_root;

        Aircraft.Tail.Horizontal.Sweep_LE = atan(tan(Aircraft.Tail.Horizontal.Sweep_qc*d2r) - (Aircraft.Tail.Horizontal.chord_root...
                            *(Aircraft.Tail.Horizontal.taper_ratio - 1))/2/Aircraft.Tail.Horizontal.b)/d2r;

        Aircraft.Tail.Horizontal.Sweep_hc = atan( tan(Aircraft.Tail.Horizontal.Sweep_qc*d2r) - ...
                                            (1 - Aircraft.Tail.Horizontal.taper_ratio)...
                                            /(Aircraft.Tail.Horizontal.Aspect_Ratio*(1 + Aircraft.Tail.Horizontal.taper_ratio)) )/d2r;

        Aircraft.Tail.Horizontal.mac = 2*Aircraft.Tail.Horizontal.chord_root*(1 + Aircraft.Tail.Horizontal.taper_ratio ...
                            + Aircraft.Tail.Horizontal.taper_ratio^2)/(3*(1 + Aircraft.Tail.Horizontal.taper_ratio));

        Aircraft.Tail.Horizontal.Y = (Aircraft.Tail.Horizontal.b/6)*(1 + 2*Aircraft.Tail.Horizontal.taper_ratio) ...
                            /(1 + Aircraft.Tail.Horizontal.taper_ratio);

        Aircraft.Tail.Horizontal.t_c = 0.12;    % NACA 0012
        % ------------------------------------------------------------------------------------------------------------------------
        %%% Vertical Tail
        % ------------------------------------------------------------------------------------------------------------------------
        Aircraft.Tail.Vertical.Coeff = 0.06;    % Vertical Tail Volume Coefficient - Avg data from CADP
        Aircraft.Tail.Vertical.arm = 0.52 * Aircraft.Fuselage.length;    % Vertical Tail Moment Arm (in ft)
        Aircraft.Tail.Vertical.Aspect_Ratio = 1.87;   % Avg data from CADP   
        Aircraft.Tail.Vertical.taper_ratio = 0.31;   % Avg data from CADP
        Aircraft.Tail.Vertical.dihedral = 90;    % Avg data from Roskam (in deg)
        Aircraft.Tail.Vertical.Sweep_qc = 35;   % Based on the guidelines of Raymer; Pg: 111 (in deg)

        Aircraft.Tail.Vertical.S = (Aircraft.Tail.Vertical.Coeff*Aircraft.Wing.S...
                                    *Aircraft.Wing.b)/(Aircraft.Tail.Vertical.arm);

        Aircraft.Tail.Vertical.b = sqrt(Aircraft.Tail.Vertical.Aspect_Ratio...
                                    *(Aircraft.Tail.Vertical.S/2));

        Aircraft.Tail.Vertical.chord_root = 2*(Aircraft.Tail.Vertical.S/2)/(Aircraft.Tail.Vertical.b ...
                                *(1 + Aircraft.Tail.Vertical.taper_ratio));

        Aircraft.Tail.Vertical.chord_tip = Aircraft.Tail.Vertical.taper_ratio * Aircraft.Tail.Vertical.chord_root;

        Aircraft.Tail.Vertical.Sweep_LE = atan(tan(Aircraft.Tail.Vertical.Sweep_qc*d2r) - (Aircraft.Tail.Vertical.chord_root...
                            *(Aircraft.Tail.Vertical.taper_ratio - 1))/4/Aircraft.Tail.Vertical.b)/d2r;

        Aircraft.Tail.Vertical.Sweep_hc = atan( tan(Aircraft.Tail.Vertical.Sweep_qc*d2r) - ...
                                            (1 - Aircraft.Tail.Vertical.taper_ratio)...
                                            /(2*Aircraft.Tail.Vertical.Aspect_Ratio*(1 + Aircraft.Tail.Vertical.taper_ratio)) )/d2r;

        Aircraft.Tail.Vertical.mac = 2*Aircraft.Tail.Vertical.chord_root*(1 + Aircraft.Tail.Vertical.taper_ratio ...
                            + Aircraft.Tail.Vertical.taper_ratio^2)/(3*(1 + Aircraft.Tail.Vertical.taper_ratio));

        Aircraft.Tail.Vertical.Y = (Aircraft.Tail.Vertical.b/3)*(1 + 2*Aircraft.Tail.Vertical.taper_ratio) ...
                            /(1 + Aircraft.Tail.Vertical.taper_ratio);

        Aircraft.Tail.Vertical.t_c = 0.12;    % NACA 0015
    end
    %% Fuselage Sizing
    function Aircraft = Fuselage_Sizing(Aircraft)
        Aircraft.Fuselage.height = 77/12;   % From CAD Model : Maximum fuselage height
        Aircraft.Fuselage.length = 0.37 * Aircraft.Weight.MTOW^0.51; % From Raymer Table: 6.3 Pg: 157
    end
    %% Propulsion Sizing
    function Aircraft = Prop_Sizing(Aircraft)
        Aircraft.Propulsion.power = Aircraft.Weight.MTOW/Aircraft.Performance.WbyP;
        Aircraft.Propulsion.no_of_engines = 2;
        Aircraft.Propulsion.power_per_engine = Aircraft.Propulsion.power/Aircraft.Propulsion.no_of_engines;
    end
end