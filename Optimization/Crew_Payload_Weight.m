%  Aircraft Payload & Crew Weight Calculation
%  ------------------------------------------------------------------------
%  Input : Aircraft structure datatpye.
%  Output : Aircraft sturcture datatype with appended payload data.
%  All units are in FPS System.

function Aircraft = Crew_Payload_Weight(Aircraft)

    %%% Crew
    Aircraft.Crew = 2;
    Aircraft.Weight.person = 200;
    
    %%% Armaments
    Aircraft.Weight.armaments = 3000;
    Aircraft.Weight.bullet = 0.357;
    Aircraft.weigth.ammunutions = Aircraft.Weight.bullet * 300 * 2.20462; %2.20462 is Kg to Lbs
    
    %%% Calculating weight of total payload and crew
    Aircraft.Weight.payload = Aircraft.Weight.armaments + Aircraft.weigth.ammunutions;
                    
    Aircraft.Weight.crew =  Aircraft.Weight.person * Aircraft.Crew;                

end