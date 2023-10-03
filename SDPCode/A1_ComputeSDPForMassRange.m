%Ritwika VPS
%UC Merced
%SDP main code

%This script runs the SDP for 15 trials with the specified predator, prey,
%and competitor mass combinations and saves the relevant decision and
%fitness matrices; encounter probabilities for hunting, scavenging, and
%stealing; as well as decisoon counts, for each trial. All figures in the
%paper are based on averages over these 15 trials. 

clear all
clc

Mp = unique(round(10.^(1:0.05:2.7)));%predator mass; we are simulating on log scale, up to 500 kg
Mc = Mp; %Competitor mass; same range and increments as Mp
%We use larger increments for carnivores cuz fewer heavy carnivores than herbivores
Mr = unique(round(10.^(1:0.03:3.5)));%Prey mass, also on log scale increments

%generatw allometric quantities
AllometricStruct = GenerateAllomtericQuantities(Mp,Mr,Mc);
%structure with fields: 
    %FmJ_p: predator fat mass, i Joules (energy units
    %Bmr12hr_p: predator BMR for 12 hr, J/s; FmrJperSec_p: predator FMR, J/s; MmrJperSec_p: predator MMR, J/s
    %MuPerSec_p: baseline mortality, per sec
    %StmGm_p: predator stomach size, grams
    %ConsumedMassGm_r: prey mass consumed by hunter and kleptoparasite; ConsumedMassGmSc_r: prey mass consumed by scaveneger
    %ThandleSec_pr: handling time of prey for predator (pursue, subdue and consume)
    %LinkProb_cr: probabilty of food web b/n pred and prey; LinkProb_pr: prob of food web link b/n competitor and prey
    %RhoPerm2_r: population density of prey in num/m^2; RhoPerm2_c: population density of prey in num/m^2;

save('AllometricRelationshipsOct2022.mat','AllometricStruct')

ActiveTime = 12; %predator and competitor's active time windows in hours

trialnum = 50000; %for deriving probability distributions

%time vector (for SDP)
ti = 1; tf = 30; dt = 1;
tvec = ti:dt:tf;

FitnessFuncType = 'exponential'; %terminal fitnss function functional form

%lengths of predator, prey and competitor mass vectors
lp = length(Mp); lr = length(Mr); lc = length(Mc);
    
for trial = 1:15 

    %initialise cell arrays to store probability distributions
    KlepEncNum = cell(lp,lr,lc);
    KlepEncProb = cell(lp,lr,lc);
    HuntEncNum = cell(lp,lr,lc);
    HuntEncProb = cell(lp,lr,lc);
    ScavEncNum = cell(lp,lr,lc);
    ScavEncProb = cell(lp,lr,lc);
    
    %initialise cell arrays to store decision and fitness matrices for all
    %Mc-Mp-Mr combos
    Decision_Cell = cell(lp,lr,lc);
    Fitness_Cell = cell(lp,lr,lc);
    
    %simiarly, initialise cell arrays to store counts of different
    %strategies
    Hcount_Cell = cell(1,lc);
    Scavcount_Cell = cell(1,lc);
    Klepcount_Cell = cell(1,lc);
        
    parfor cc = 1:lc

        cc
        
        HuntCount = zeros(lp,lr);
        ScavCount = zeros(lp,lr);
        KlepCount = zeros(lp,lr);
        
        for pp = 1:lp %loops over consumer mass
            for rr = 1:lr %loop over prey mass
            
                %genearting encounter probabilities for different behaviours. Here, we are counting the number of h, ss and as decisions for each
                %parameter value to build a distribution. So for each loop, we count the number of each decision and add those occurences and store the
                %total number, for that parameter value. Essentially what proportion of decison matrix is what decision. For more info see
                %relevant functions
                [KlepEncNum{pp,rr,cc},KlepEncProb{pp,rr,cc}] = ComputeEncounterProb_Klep(trialnum,Mp(pp),Mr(rr),Mc(cc),ActiveTime,ActiveTime,...
                                                                                         AllometricStruct.LinkProb_cr(cc,rr)); %see rleevant user def function
                [HuntEncNum{pp,rr,cc},HuntEncProb{pp,rr,cc}] = ComputeEncounterProb_Hunting(Mp(pp),Mr(rr),trialnum,ActiveTime,AllometricStruct.LinkProb_pr(pp,rr));
                                                                                                                               %see rleevant user def function
                [ScavEncNum{pp,rr,cc},ScavEncProb{pp,rr,cc}] = ComputeEncounterProb_Scav(trialnum,Mp(pp),Mr(rr),Mc(cc),ActiveTime,...
                                                                                        ActiveTime,AllometricStruct.LinkProb_cr(cc,rr)); %see rleevant user def function
            
                %do SDP
                [Fitness_Cell{pp,rr,cc},Decision_Cell{pp,rr,cc},HuntCount(pp,rr),ScavCount(pp,rr),KlepCount(pp,rr)] =...
                    SDPfunction(Mp,Mr,Mc,tvec,AllometricStruct,pp,rr,cc,KlepEncNum{pp,rr,cc},...
                    KlepEncProb{pp,rr,cc},HuntEncNum{pp,rr,cc},HuntEncProb{pp,rr,cc},ScavEncNum{pp,rr,cc},ScavEncProb{pp,rr,cc},FitnessFuncType);
                                    %see rleevant user def function
            
            end   
        end

        Hcount_Cell{cc} = HuntCount;
        Scavcount_Cell{cc} = ScavCount;
        Klepcount_Cell{cc} = KlepCount;
    
    end
      
    %loops to make name
    fitsavename = sprintf('FitDecExpfitnessOct2022_%i.mat',trial);
    countssavename = sprintf('StrategyCountsExpfitnessOct2022_%i.mat',trial);
    probsavename = sprintf('SdpEncProbExpfitnessOct2022_%i.mat',trial);
    
    save(fitsavename,'Decision_Cell','Fitness_Cell')
    save(countssavename,'Hcount_Cell','Scavcount_Cell','Klepcount_Cell')
    save(probsavename,'KlepEncNum','KlepEncProb','HuntEncNum','HuntEncProb','ScavEncNum','ScavEncProb')

end
