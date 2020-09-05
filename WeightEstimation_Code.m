%CODE FOR WEIGHT ESTIMATION(W_TO, W_E AND W_F)

%Variables from RFP
Crew=2;
Payload=3000;

W_crew=200*Crew;

Jet.W_TOguess=21000;
Prop.W_TOguess=21000;   %From reference aircrafts in lbs
Prop.Vcr=323;%mph
Jet.Vcr=581;%mph

%L/D MAX FROM NICOLAI
AR=6.5; %Aspect ratio from ref
e=0.7; %From Nicolai AppG
K=1/(3.14*AR*e);
Cdo=0.018; %assumed from nicolai
LDmax=1/(2*sqrt(Cdo*K));
LDcruise=0.866*LDmax;
LDloiter=LDmax;
%fuel-fraction method


%------------Turbojet-------------------------------

%Design Mission
D_W_PL=Payload;
D_W_TPL=D_W_PL+W_crew;
%phase 1 warm-up
Jet.D_W1=0.99;
%phase 2 taxi
Jet.D_W2=0.99;
%phase 3 takeoff
Jet.D_W3=0.99;
%phase 4 climb
Jet.D_W4=0.985; %Raymers
%phase 5 cruise
Jet.D_Cj=0.7;
Jet.D_Cp=0.6;
Jet.D_Np=0.82;
%turboprop
%Rcr=100*1.1508; %n mi to stat mi
%W5=exp(-(Rcr*Cj)/(375*Np*LDcruise));
%turbojet
Jet.D_Rcr=100;
Jet.D_W5=exp(-(Jet.D_Rcr*Jet.D_Cj)/(Jet.Vcr*LDcruise));
%phase 6 descent
Jet.D_W6=0.99;
%phase 7 loiter
Jet.D_Cj=0.7;
Jet.D_Cp=0.6;
Jet.D_Np=0.77;
Jet.D_Eltr=4; %RFP
%turboprop
%W7=exp(-(Eltr*Cj*Vcr)/(375*Np*LDloiter));
%turbojet
Jet.D_W7=exp(-(Jet.D_Eltr*Jet.D_Cj)/LDloiter);
%phase 8 climb
Jet.D_W8=0.985;
%phase 9 cruise
Jet.D_Cj=0.7;
Jet.D_Cp=0.6;
Jet.D_Np=0.82;
%turboprop
%Rcr=100*1.1508; %n mi to stat mi
%W9=exp(-(Rcr*Cj)/(375*Np*LDcruise));
%turbojet
Jet.D_Rcr=100;
Jet.D_W9=exp(-(Jet.D_Rcr*Jet.D_Cj)/(Jet.Vcr*LDcruise));
%phase 10 descent/landing
Jet.D_W10=0.99;
%phase 11 taxi
Jet.D_W11=0.995;
%reserve fuel
Jet.D_W12=0.99;
Jet.D_Ecr2=0.75;
Jet.D_W13=exp(-(Jet.D_Ecr2*Jet.D_Cj)/LDloiter);
%Fuel Fraction calculation
Jet.D_Mff=Jet.D_W1*Jet.D_W2*Jet.D_W3*Jet.D_W4*Jet.D_W5*Jet.D_W6*Jet.D_W7*Jet.D_W8*Jet.D_W9*Jet.D_W10*Jet.D_W11*Jet.D_W12*Jet.D_W13;
%Jet.D_Wf=1*(1-Jet.D_Mff)*W_TOguess;


%Ferry Mission
F_W_PL=0.6*Payload;
F_W_TPL=F_W_PL+W_crew;
%phase 1 warm-up
Jet.F_W1=0.99;
%phase 2 taxi
Jet.F_W2=0.99;
%phase 3 takeoff
Jet.F_W3=0.99;
%phase 4 climb
Jet.F_W4=0.985; %Raymers
%phase 5 cruise
Jet.F_Cj=0.7;
Jet.F_Cp=0.6;
Jet.F_Np=0.82;
%turboprop
%Rcr=100*1.1508 %n mi to stat mi
%W5=exp(-(Rcr*Cj)/(375*Np*LDcruise));
%turbojet
Jet.F_Rcr=900;
Jet.F_W5=exp(-(Jet.F_Rcr*Jet.F_Cj)/(Jet.Vcr*LDcruise));
%phase 6 descent
Jet.F_W6=0.99;
%phase 11 taxi
Jet.F_W7=0.995;
%reserve fuel
Jet.F_W8=0.99;
Jet.F_Ecr2=0.75;
Jet.F_W9=exp(-(Jet.F_Ecr2*Jet.F_Cj)/LDloiter);

Jet.F_Mff=Jet.F_W1*Jet.F_W2*Jet.F_W3*Jet.F_W4*Jet.F_W5*Jet.F_W6*Jet.F_W7*Jet.F_W8*Jet.F_W9;
%Jet.F_Wf=1*(1-Jet.F_Mff)*Jet.W_TOguess;

if Jet.D_Mff<=Jet.F_Mff
    Jet.Mff=Jet.D_Mff;
    W_TPL=D_W_TPL;
else 
    Jet.Mff=Jet.F_Mff;
    W_TPL=F_W_TPL;
end
condition=true;
Jet.W_TO=Jet.W_TOguess;
while condition
    Jet.Wf=1*(1-Jet.Mff)*Jet.W_TO;
    %{
    Roskam
    A=0.5091
    B=0.9505
    We=10^((log10(W_TOguess)-A)/B)
    %}
    %Nicolai
    Jet.We=3.8626*(Jet.W_TO^0.7979);
    %convergence 
    error=0.01;
    Jet.W_TOcalc=Jet.We+W_TPL+Jet.Wf;
    diff=abs((Jet.W_TOcalc-Jet.W_TO)/Jet.W_TO)*100;
    if diff<error
        condition=false;
    else
            Jet.W_TO=Jet.W_TOcalc;   
    end
end
Weight.W_TO_JET=Jet.W_TO;
Weight.We_JET=Jet.We;
Weight.Wf_JET=Jet.Wf;
Weight.W_PL_JET=W_TPL;

% ---------------------------Jet END------------------------

%Turboprop

%Design Mission
D_W_PL=Payload;
D_W_TPL=D_W_PL+W_crew;
%phase 1 warm-up
Prop.D_W1=0.99;
%phase 2 taxi
Prop.D_W2=0.99;
%phase 3 takeoff
Prop.D_W3=0.99;
%phase 4 climb
Prop.D_W4=0.985; %Raymers
%phase 5 cruise
Prop.D_Cj=0.7;
Prop.D_Cp=0.6;
Prop.D_Np=0.82;
%turboprop
Prop.D_Rcr=100*1.1508; %n mi to stat mi
Prop.D_W5=exp(-(Prop.D_Rcr*Prop.D_Cj)/(375*Prop.D_Np*LDcruise));
%phase 6 descent
Prop.D_W6=0.99;
%phase 7 loiter
Prop.D_Cj=0.7;
Prop.D_Cp=0.6;
Prop.D_Np=0.77;
Prop.D_Eltr=4; %RFP
Prop.D_W7=exp(-(Prop.D_Eltr*Prop.D_Cj*Prop.Vcr)/(375*Prop.D_Np*LDloiter));
%phase 8 climb
Prop.D_W8=0.985;
%phase 9 cruise
Prop.D_Cj=0.7;
Prop.D_Cp=0.6;
Prop.D_Np=0.82;
%turboprop
Prop.D_Rcr=100*1.1508; %n mi to stat mi
Prop.D_W9=exp(-(Prop.D_Rcr*Prop.D_Cj)/(375*Prop.D_Np*LDcruise));
%phase 10 descent/landing
Prop.D_W10=0.99;
%phase 11 taxi
Prop.D_W11=0.995;
%reserve fuel
Prop.D_W12=0.99;
Prop.D_Ecr2=0.75;
Prop.D_W13=exp(-(Prop.D_Ecr2*Prop.D_Cj*Prop.Vcr)/(375*Prop.D_Np*LDloiter));
%Fuel Fraction
Prop.D_Mff=Prop.D_W1*Prop.D_W2*Prop.D_W3*Prop.D_W4*Prop.D_W5*Prop.D_W6*Prop.D_W7*Prop.D_W8*Prop.D_W9*Prop.D_W10*Prop.D_W11*Prop.D_W12*Prop.D_W13;


%Ferry Mission
F_W_PL=0.6*Payload;
F_W_TPL=F_W_PL+W_crew;
%phase 1 warm-up
Prop.F_W1=0.99;
%phase 2 taxi
Prop.F_W2=0.99;
%phase 3 takeoff
Prop.F_W3=0.99;
%phase 4 climb
Prop.F_W4=0.985; %Raymers
%phase 5 cruise
Prop.F_Cj=0.7;
Prop.F_Cp=0.6;
Prop.F_Np=0.82;
%turboprop
Prop.F_Rcr=100*1.1508; %n mi to stat mi
Prop.F_W5=exp(-(Prop.F_Rcr*Prop.F_Cj)/(375*Prop.F_Np*LDcruise));
%phase 6 descent
Prop.F_W6=0.99;
%phase 11 taxi
Prop.F_W11=0.995;
%reserve fuel
Prop.F_W12=0.99;
Prop.F_Ecr2=0.75;
Prop.F_W13=exp(-(Prop.F_Ecr2*Prop.F_Cj*Prop.Vcr)/(375*Prop.F_Np*LDloiter));
%Fuel Fraction Calculation
Prop.F_Mff=Prop.F_W1*Prop.F_W2*Prop.F_W3*Prop.F_W4*Prop.F_W5*Prop.F_W6*Prop.F_W11*Prop.F_W12*Prop.F_W13;
%Wf=1*(1-Mff)*W_TOguessProp;

if Prop.D_Mff<=Prop.F_Mff
    Prop.Mff=Prop.D_Mff;
    W_TPL=D_W_TPL;
else 
    Prop.Mff=Prop.F_Mff;
    W_TPL=F_W_TPL;
end  

condition=true;
Prop.W_TO=Prop.W_TOguess;
while condition
    
    Prop.Wf=1*(1-Prop.Mff)*Prop.W_TO;
    
    %Roskam
    %turboprop
    A=-1.4041;
    B=1.4660;

    %turbojet
    %A=0.5091
    %B=0.9505

    Prop.We=10^((log10(Prop.W_TO)-A)/B);
    
    %Nicolai
    %We=0.774*(W_TOguessProp^0.947);
    %convergence 
    error=0.01;
    Prop.W_TOcalc=Prop.We+W_TPL+Prop.Wf;
    diff=abs((Prop.W_TOcalc-Prop.W_TO)/Prop.W_TO)*100;
    if diff<error
        condition=false;
    else
            Prop.W_TO=Prop.W_TOcalc;   
    end
end
Weight.W_TOPROP=Prop.W_TO;
Weight.WePROP=Prop.We;
Weight.WfPROP=Prop.Wf;
Weight.W_PLPROP=W_TPL;
save('WeightEstimation.mat','-struct','Weight');


    