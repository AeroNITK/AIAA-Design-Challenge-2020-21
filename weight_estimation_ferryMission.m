%CODE FOR WEIGHT ESTIMATION(W_TO, W_E AND W_F)

%Variables from RFP
Crew=2;
Payload=3500*0.6;

W_crew=200*Crew;
W_PL=Payload;
W_TPL=W_PL+W_crew;

W_TOguess=13000; %From reference aircrafts in lbs
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
while condition
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
    %W5=W4*exp(-(Rcr*Cj)/(375*Np*LDcruise))
    %turbojet
    Rcr=900;
    W5=exp(-(Rcr*Cj)/(Vcr*LDcruise));
    %phase 6 descent
    W6=0.99;
    
    %phase 11 taxi
    W11=0.995;
    %reserve fuel
    W12=0.99;
    Rcr2=0.75;
    W13=exp(-(Rcr2*Cj)/(Vcr*LDcruise));


    Mff=W1*W2*W3*W4*W5*W6*W11*W12*W13;
    Wf=1*(1-Mff)*W_TOguess;
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
    Wer=W_TOguess-(Wf+W_TPL);
    diff=abs(We-Wer)/We*100;
    if diff<error
        condition=false;
    else if We-Wer>0
            W_TOguess=1+W_TOguess;
    else
            W_TOguess=W_TOguess-1;
    end            
    end
end
 W_TOguess
 diff
