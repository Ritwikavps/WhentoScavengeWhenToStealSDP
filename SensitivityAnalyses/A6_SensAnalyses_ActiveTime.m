%Ritwika VPS
%UC Merced
%SDP sensitivity analyses -- linear terminal fitness function 

%June 2023: This is a modification of the baseline script used to run the sensitivity analyses. Here, we test the effect of varying active time to rest time splits for 
% teh focal predator on our results. We do this by scaling the fraction of active time using an ActiveTimeScaleFactor. So, ActiveTimeScaleFactor = 0.5 would scale the 
% baseline active time of 12 hours to 6 hours (= 12*0.5).  Everything else remains the same: linkining probablity per Rohr with parameters as cited in our paper, 
% exponential fitness function, and
%other standard parametrisations in the model, inclding the assumption that stealing only occurs when all of prey fat and muscle mass is availble to be stolen. 
%We use a larger log increment in the mass range so we don't have to use as much computational time, and we also use 5 trials instead of 15.
%See below for more details:

clear all
clc

Mp = unique(round(10.^(1:0.1:2.7)));%predator mass; we are simulating on log scale, up to 500 kg
Mc = Mp; %Competitor mass; same range and increments as Mp
%We use larger increments for carnivores cuz fewer heavy carnivores than herbivores
Mr = unique(round(10.^(1:0.09:3.5)));%Prey mass, also on log scale increments

ActiveTime = 12; %predator and competitor's active time windows in hours

trialnum = 50000; %for deriving probability distributions

%time vector (for SDP)
ti = 1; tf = 30; dt = 1;
tvec = ti:dt:tf;

FitnessFuncType = 'exponential';

%lengths of predator, prey and competitor mass vectors
lp = length(Mp); lr = length(Mr); lc = length(Mc);

ActiveTimeScaleFactor = 0.5:0.2:1.5; %factor to scale the Rohr linking probabilty parameters by
ActiveTimeScalePerc = ActiveTimeScaleFactor*100; %percentage value of the scaling factor to name files

for i = 1:numel(ActiveTimeScaleFactor) %go through linking prob. scale factors

    %generatw allometric quantities
    AllometricStruct = GenerateAllomtericQuantities_SensAnalysesActiveTime(Mp,Mr,Mc,ActiveTimeScaleFactor(i));
    %structure with fields: 
        %FmJ_p: predator fat mass, i Joules (energy units
        %Bmr12hr_p: predator BMR for 12 hr, J/s; FmrJperSec_p: predator FMR, J/s; MmrJperSec_p: predator MMR, J/s
        %MuPerSec_p: baseline mortality, per sec
        %StmGm_p: predator stomach size, grams
        %ConsumedMassGm_r: prey mass consumed by hunter and kleptoparasite; ConsumedMassGmSc_r: prey mass consumed by scaveneger
        %ThandleSec_pr: handling time of prey for predator (pursue, subdue and consume)
        %LinkProb_cr: probabilty of food web b/n pred and prey; LinkProb_pr: prob of food web link b/n competitor and prey
        %RhoPerm2_r: population density of prey in num/m^2; RhoPerm2_c: population density of prey in num/m^2;
    
    %save('AllometricRelationships_SensAnalysesLinkProbMarch2023.mat','AllometricStruct')
        
    for trial = 1:5 
    
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
                    [KlepEncNum{pp,rr,cc},KlepEncProb{pp,rr,cc}] = ComputeEncounterProb_Klep(trialnum,Mp(pp),Mr(rr),Mc(cc),ActiveTime*ActiveTimeScaleFactor(i),...
                                                                ActiveTime*ActiveTimeScaleFactor(i),AllometricStruct.LinkProb_cr(cc,rr));
                    [HuntEncNum{pp,rr,cc},HuntEncProb{pp,rr,cc}] = ComputeEncounterProb_Hunting(Mp(pp),Mr(rr),trialnum,ActiveTime*ActiveTimeScaleFactor(i),...
                                                                                            AllometricStruct.LinkProb_pr(pp,rr));
                    [ScavEncNum{pp,rr,cc},ScavEncProb{pp,rr,cc}] = ComputeEncounterProb_Scav(trialnum,Mp(pp),Mr(rr),Mc(cc),ActiveTime*ActiveTimeScaleFactor(i),...
                                                                                            ActiveTime*ActiveTimeScaleFactor(i),AllometricStruct.LinkProb_cr(cc,rr));
                
                    %do SDP
                    [Fitness_Cell{pp,rr,cc},Decision_Cell{pp,rr,cc},HuntCount(pp,rr),ScavCount(pp,rr),KlepCount(pp,rr)] =...
                        SDPfunction_SensAnalysisActiveTime(Mp,Mr,Mc,tvec,AllometricStruct,pp,rr,cc,KlepEncNum{pp,rr,cc},...
                        KlepEncProb{pp,rr,cc},HuntEncNum{pp,rr,cc},HuntEncProb{pp,rr,cc},ScavEncNum{pp,rr,cc},ScavEncProb{pp,rr,cc},FitnessFuncType,ActiveTimeScaleFactor(i));
                
                end   
            end
    
            Hcount_Cell{cc} = HuntCount;
            Scavcount_Cell{cc} = ScavCount;
            Klepcount_Cell{cc} = KlepCount;
        
        end

        %loops to make name
        fitsavename = sprintf('FitDecExpfitness_SensActiveTimeJune2023_ScalePerc%i_%i.mat',ActiveTimeScalePerc(i),trial);
        countssavename = sprintf('StrategyCountsExpfitness_SensActiveTimeJune2023_ScalePerc%i_%i.mat',ActiveTimeScalePerc(i),trial);
        probsavename = sprintf('SdpEncProbExpfitness_SensActiveTimeJune2023_ScalePerc%i_%i.mat',ActiveTimeScalePerc(i),trial);
        
        save(fitsavename,'Decision_Cell','Fitness_Cell')
        save(countssavename,'Hcount_Cell','Scavcount_Cell','Klepcount_Cell')
        save(probsavename,'KlepEncNum','KlepEncProb','HuntEncNum','HuntEncProb','ScavEncNum','ScavEncProb')
    end

end


