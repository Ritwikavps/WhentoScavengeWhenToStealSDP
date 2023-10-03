clear all
clc

%Ritwika VPS
%This is a modification of the baseline script used to run the sensitivity analyses. Here, we test the effect of scaling the the
% additional mortality associated with hunting and stealing, using
% HuntMortScaleFactor and StealMortScaleFactor, respectively. (See Supp Info for more context/details.)
% Everything else remains the same: a linear fitness function, a 12 hr:12 hr split of activity and rest, 
% linkining probablity per Rohr with parameters as cited in our paper, and other standard parametrisations in the model, inclding the assumption that 
% stealing only occurs when all of prey fat and muscle mass is availble to be stolen. We use a larger log increment in the mass range so we don't 
%h ave to use as much computational time, and we also use 5 trials instead of 15. See below for more details:

BasePath = '/Users/ritwikavps/Desktop/GoogleDriveFiles/research/justin projects/SDP_useful codes/Copy_of_allometric sdp/code/updated_code_log_sc_mass_Oct2019/CodeForGitHub/ResultsMatMarch2022/SensAnalyses/';

BaselinePath = strcat(BasePath,'Baseline/'); %get path for baseline matrices (same SDP comps as the full model, but on a more sparse mass range for Mp, Mr, and Mc + 5 trials instead of 15 to average over)
cd(BaselinePath)
BaselineMats = dir('FitDecExpfitness_SensBaseline*.mat'); %get baseline decision matrices. This is what we will comapre all sensitivity analyses against

%Mortality sensitivity analyses
cd(BaselinePath)
ProbDir = dir('SdpEncProbExpfitness_SensBaseline*.mat');
HuntMortScaleFactor = 0:0.2:10;
StealMortScaleFactor = 0:0.2:10;

MeanDiffFrac = NaN*ones(numel(HuntMortScaleFactor),numel(StealMortScaleFactor));
NumelStealFac = numel(StealMortScaleFactor);

p = parpool(HuntMortScaleFactor);

parfor i = 1:numel(HuntMortScaleFactor)
    i
    for j = 1:NumelStealFac 
        MeanDiffFrac(i,j) = GetMeanFracAlteredStatesMortalitySens(ProbDir,HuntMortScaleFactor(i),StealMortScaleFactor(j),BaselineMats);
    end
end

save('SensMortalityResultsJul2023.mat','MeanDiffFrac');
%surf(StealMortScaleFactor,HuntMortScaleFactor,MeanDiffFrac,'EdgeColor','none');

%functions used:
%--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function [MeanDiffFrac] = GetMeanFracAlteredStatesMortalitySens(ProbDir,HuntMortScaleFactor,StealMortScaleFactor,BaselineMats)

    Mp = unique(round(10.^(1:0.1:2.7)));%predator mass; we are simulating on log scale, up to 500 kg
    Mc = Mp; %Competitor mass; same range and increments as Mp
    %We use larger increments for carnivores cuz fewer heavy carnivores than herbivores
    Mr = unique(round(10.^(1:0.09:3.5)));%Prey mass, also on log scale increments
    
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
    
    %time vector (for SDP)
    ti = 1; tf = 30; dt = 1;
    tvec = ti:dt:tf;
    
    FitnessFuncType = 'exponential';
    
    %lengths of predator, prey and competitor mass vectors
    lp = length(Mp); lr = length(Mr); lc = length(Mc);
        
    for trial = 1:5 

        CurrProb = load(ProbDir(trial).name);

        HuntEncNum = CurrProb.HuntEncNum;
        HuntEncProb = CurrProb.HuntEncProb;
        ScavEncNum = CurrProb.ScavEncNum;
        ScavEncProb = CurrProb.ScavEncProb;
        KlepEncNum = CurrProb.KlepEncNum;
        KlepEncProb = CurrProb.KlepEncProb;
        
        %initialise cell arrays to store decision and fitness matrices for all Mc-Mp-Mr combos
        Decision_Cell = cell(lp,lr,lc);
            
        for cc = 1:lc
            for pp = 1:lp %loops over consumer mass
                for rr = 1:lr %loop over prey mas
                    %do SDP
                    [Decision_Cell{pp,rr,cc}] = SDPfunction_SensMortality(Mp,Mr,Mc,tvec,AllometricStruct,pp,rr,cc,...
                            KlepEncNum{pp,rr,cc},KlepEncProb{pp,rr,cc},HuntEncNum{pp,rr,cc},HuntEncProb{pp,rr,cc},ScavEncNum{pp,rr,cc},ScavEncProb{pp,rr,cc},...
                            FitnessFuncType,HuntMortScaleFactor,StealMortScaleFactor);
                end   
            end
        end
        
        BaseLineStruct = load(BaselineMats(trial).name);
        Bb = BaseLineStruct.Decision_Cell;
        [SumOfDiff,DenomForFraction] = cellfun(@GetSensResults, Decision_Cell, Decision_Cell);
        DiffFracVec(trial) = sum(SumOfDiff(:))/sum(DenomForFraction(:));
    end
    MeanDiffFrac = mean(DiffFracVec);
end

%--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function [SumOfDiff,DenomForFraction] = GetSensResults(BaseLine,Test)
%This function is to get the total number of instances of differences
%between a baseline decision maytrix and a test decision matrix, as well as
%the total number of decisions in the decisio matrix (to compute the
%proportion of altered states0. The idea is to use cellfun to apply this to
%a whole cell array
    DiffInMats = BaseLine-Test; %differnce between decision matrices; The same decisions will have a 0 diff, everything else will be non-zero
    DiffInMats(DiffInMats ~= 0) = 1; %change every element in the difference matrix taht is non-zero to 1
    SumOfDiff = sum(sum(DiffInMats)); %get the sum
    DenomForFraction = numel(DiffInMats); %this is the runnning denominator to do total sum of differences/total possible differences
end
