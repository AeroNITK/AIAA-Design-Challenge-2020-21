%CODE FOR WEIGHT ESTIMATION(W_TO, W_E AND W_F)

%Variables from RFP
Crew=2;
Payload=3000;

W_crew=200*Crew;
W_PL=Payload;
W_TPL=W_PL+W_crew;

W_TOguess=21000;
W_TOguessProp=21000;   %From reference aircrafts in lbs
Vcr=350;%mph

%L/D MAX FROM NICOLAI
AR=6.5; %Aspect ratio from ref
e=0.7; %From Nicolai AppG
K=1/(3.14*AR*e);
Cdo=0.018; %assumed from nicolai
LDmax=1/(2*sqrt(Cdo*K));
LDcruise=0.866*LDmax;
LDloiter=LDmax;
%fuel-fraction method
condition=true;
%1 for design and 2 for ferry
state=1;
if state==2
    Payload=Payload*0.6;
end
%Turbojet
while condition
    if state==1
        %phase 1 warm-up
        W1=0.99;
        %phase 2 taxi
        W2=0.99;
        %phase 3 takeoff
        W3=0.99;
        %phase 4 climb
        W4=0.985; %Raymers
        %phase 5 cruise
        Cj=0.7;
        Cp=0.6;
        Np=0.82;
        %turboprop
        %Rcr=100*1.1508; %n mi to stat mi
        %W5=exp(-(Rcr*Cj)/(375*Np*LDcruise));
        %turbojet
        Rcr=100;
        W5=exp(-(Rcr*Cj)/(Vcr*LDcruise));
        %phase 6 descent
        W6=0.99;
        %phase 7 loiter
        Cj=0.7;
        Cp=0.6;
        Np=0.77;
        Eltr=4; %RFP
        %turboprop
        %W7=exp(-(Eltr*Cj*Vcr)/(375*Np*LDloiter));
        %turbojet
        W7=exp(-(Eltr*Cj)/LDloiter);
        %phase 8 climb
        W8=0.985;
        %phase 9 cruise
        Cj=0.7;
        Cp=0.6;
        Np=0.82;
        %turboprop
        %Rcr=100*1.1508; %n mi to stat mi
        %W9=exp(-(Rcr*Cj)/(375*Np*LDcruise));
        %turbojet
        Rcr=100;
        W9=exp(-(Rcr*Cj)/(Vcr*LDcruise));
        %phase 10 descent/landing
        W10=0.99;
        %phase 11 taxi
        W11=0.995;
        %reserve fuel
        W12=0.99;
        Ecr2=0.75;
        W13=exp(-(Ecr2*Cj)/LDloiter);


        Mff=W1*W2*W3*W4*W5*W6*W7*W8*W9*W10*W11*W12*W13;
        Wf=1*(1-Mff)*W_TOguess;
    end
    if state==2
        W_PL=Payload;
        W_TPL=W_PL+W_crew;
        %phase 1 warm-up
        W1=0.99;
        %phase 2 taxi
        W2=0.99;
        %phase 3 takeoff
        W3=0.99;
        %phase 4 climb
        W4=0.985; %Raymers
        %phase 5 cruise
        Cj=0.7;
        Cp=0.6;
        Np=0.82;
        %turboprop
        %Rcr=100*1.1508 %n mi to stat mi
        %W5=exp(-(Rcr*Cj)/(375*Np*LDcruise));
        %turbojet
        Rcr=900;
        W5=exp(-(Rcr*Cj)/(Vcr*LDcruise));
        %phase 6 descent
        W6=0.99;
        %phase 11 taxi
        W11=0.995;
        %reserve fuel
        W12=0.99;
        Ecr2=0.75;
        W13=exp(-(Ecr2*Cj)/LDloiter);

        Mff=W1*W2*W3*W4*W5*W6*W11*W12*W13;
        Wf=1*(1-Mff)*W_TOguess;
    end
    
    %{
    %Roskam
    %turboprop
    %A=0.2705
    %B=0.9830

    %turbojet
    A=0.5091
    B=0.9505

    We=10^((log10(W_TOguess)-A)/B)
    %}
    %Nicolai
    We=0.774*(W_TOguess^0.947);
    %convergence 
    error=0.01;
    W_TOcalc=We+W_TPL+Wf;
    diff=abs((W_TOcalc-W_TOguess)/W_TOguess)*100;
    if diff<error
        condition=false;
    else
            W_TOguess=W_TOcalc;   
    end
end
Weight.W_TO_JET=W_TOguess;
Weight.We_JET=We;
Weight.Wf_JET=Wf;
Weight.W_PL_JET=W_TPL;
%Turboprop
condition=1;
while condition
    if state==1
        %phase 1 warm-up
        W1=0.99;
        %phase 2 taxi
        W2=0.99;
        %phase 3 takeoff
        W3=0.99;
        %phase 4 climb
        W4=0.985; %Raymers
        %phase 5 cruise
        Cj=0.7;
        Cp=0.6;
        Np=0.82;
        %turboprop
        Rcr=100*1.1508; %n mi to stat mi
        W5=exp(-(Rcr*Cj)/(375*Np*LDcruise));
        %phase 6 descent
        W6=0.99;
        %phase 7 loiter
        Cj=0.7;
        Cp=0.6;
        Np=0.77;
        Eltr=4; %RFP
        %turboprop
        W7=exp(-(Eltr*Cj*Vcr)/(375*Np*LDloiter));
        %phase 8 climb
        W8=0.985;
        %phase 9 cruise
        Cj=0.7;
        Cp=0.6;
        Np=0.82;
        %turboprop
        Rcr=100*1.1508; %n mi to stat mi
        W9=exp(-(Rcr*Cj)/(375*Np*LDcruise));
        %phase 10 descent/landing
        W10=0.99;
        %phase 11 taxi
        W11=0.995;
        %reserve fuel
        W12=0.99;
        Ecr2=0.75;
        W13=exp(-(Ecr2*Cj*Vcr)/(375*Np*LDloiter));


        Mff=W1*W2*W3*W4*W5*W6*W7*W8*W9*W10*W11*W12*W13;
        Wf=1*(1-Mff)*W_TOguessProp;
    end
    if state==2
        W_PL=Payload;
        W_TPL=W_PL+W_crew;
        %phase 1 warm-up
        W1=0.99;
        %phase 2 taxi
        W2=0.99;
        %phase 3 takeoff
        W3=0.99;
        %phase 4 climb
        W4=0.985; %Raymers
        %phase 5 cruise
        Cj=0.7;
        Cp=0.6;
        Np=0.82;
        %turboprop
        Rcr=100*1.1508 %n mi to stat mi
        W5=exp(-(Rcr*Cj)/(375*Np*LDcruise));
        %phase 6 descent
        W6=0.99;
        %phase 11 taxi
        W11=0.995;
        %reserve fuel
        W12=0.99;
        Ecr2=0.75;
        W13=exp(-(Ecr2*Cj*Vcr)/(375*Np*LDloiter));

        Mff=W1*W2*W3*W4*W5*W6*W11*W12*W13;
        Wf=1*(1-Mff)*W_TOguessProp;
    end
    
    %{
    %Roskam
    %turboprop
    %A=0.2705
    %B=0.9830

    %turbojet
    A=0.5091
    B=0.9505

    We=10^((log10(W_TOguess)-A)/B)
    %}
    %Nicolai
    We=0.774*(W_TOguessProp^0.947);
    %convergence 
    error=0.01;
    W_TOcalc=We+W_TPL+Wf;
    diff=abs((W_TOcalc-W_TOguessProp)/W_TOguess)*100;
    if diff<error
        condition=false;
    else
            W_TOguessProp=W_TOcalc;   
    end
end
Weight.W_TOPROP=W_TOguessProp;
Weight.WePROP=We;
Weight.WfPROP=Wf;
Weight.W_PLPROP=W_TPL;
save('WeightEstimation.mat','-struct','Weight');
W_TOguess
diff

    