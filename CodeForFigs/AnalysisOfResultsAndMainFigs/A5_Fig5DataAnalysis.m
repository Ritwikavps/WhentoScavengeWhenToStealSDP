%Ritwika VPS
%May 2022
%script to analyse data for Fig 5 in SDP paper

clear all
clc

%go to folder
BasePath = '/Users/ritwikavps/Desktop/GoogleDriveFiles/research/justin projects/SDP_useful codes/Copy_of_allometric sdp/code/updated_code_log_sc_mass_Oct2019/';
FilesPath = strcat(BasePath,'CodeForGitHub');
cd(FilesPath)
%Get mass vectors
Mp = unique(round(10.^(1:0.05:2.7)));%predator mass; we are simulating on log scale, up to 500 kg
Mc = Mp; %Competitor mass; same range and increments as Mp
Mr = unique(round(10.^(1:0.03:3.5)));%Prey mass, also on log scale increments

aa = dir('StrategyCountsExpfitnessOct2022_*.mat');

%Average Frac of strategy Counts: go through mat files and find average fraction
for i = 1:numel(aa)  
    CountsCell{i} = load(aa(i).name);
    [FracH_rp{i},FracScav_rp{i},~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~] = AvgStrategyCountFrac(CountsCell{i}.Hcount_Cell,...
                                                                CountsCell{i}.Scavcount_Cell,CountsCell{i}.Klepcount_Cell,Mr,Mc);  
    %we only need the fraction of scavenging and hunting as a function of
    %predator mass (+ hyena kleptoparasitsim fraction)
end

%Ave frac of hunting as function of prey (Mr, X axis) and predator (Mp, Y axis) mass
FracH_rp_mean = cellsum(FracH_rp)/numel(aa);
FracScav_rp_mean = cellsum(FracScav_rp)/numel(aa);

%predator masses
WildDogMass = 30; CheetahMass = 50; LeopardMass = 60; HyenaMass = 60; LionMass = 150; TigerMass = 181;
DataPredMass = [WildDogMass; CheetahMass; LeopardMass; HyenaMass; LionMass; TigerMass]; %vector of masses

%hayward data: cd into folder
cd(strcat(BasePath,'CodeForGitHub/ObsDataFromLit/HaywardPreyPrefData'));
%read tables
WDdata = readtable('1WildDogPreyprefDatatableHayward.xlsx','Sheet','WildDogData');
Cdata = readtable('2CheetahPreyprefDatatableHayward.xlsx','Sheet','CheetahData');
Ledata = readtable('3LeopardPreyprefDatatableHayward.xlsx','Sheet','LeopardData');
Hdata = readtable('4SpottedHyenaPreyprefDatatableHayward.xlsx','Sheet','HyenaData');
Lidata = readtable('5LionPreyprefDatatableHayward.xlsx','Sheet','LionData');
Tdata = readtable('6TigerPreyprefDatatableHayward.xlsx','Sheet','TigerData');

%Prob. exclusive scavenging
cd ../
ExclusiveScavData = readtable('exclusivescavengingprobabilities.csv'); %get probs computed from data
ExScav_Mr = ExclusiveScavData.preymass;
ExScavLion = ExclusiveScavData.lionprob;
ExScavHyena = ExclusiveScavData.hyenaprob;


%we are going to the do the computation of the thresholds etc by hand
%instead of using a loop, since there are only 6 of them: first discard
%kill percentages that are less than 5 %
BM_InputCell{1} = WDdata.BodyMasskg(WDdata.PercentofKills/100 >= 0.05);
BM_InputCell{2} = Cdata.BodyMasskg(Cdata.PercentofKills/100 >= 0.05);
BM_InputCell{3} = Ledata.BodyMasskg(Ledata.PercentofKills/100 >= 0.05);
BM_InputCell{4} = Hdata.BodyMasskg(Hdata.PercentofKills/100 >= 0.05);
BM_InputCell{5} = Lidata.BodyMasskg(Lidata.PercentofKills/100 >= 0.05);
BM_InputCell{6} = Tdata.BodyMasskg(Tdata.PercentofKills/100 >= 0.05);

for i = 1:numel(BM_InputCell)
                                                            %i
    %use user-defined function
    [uniqBM_Data{i,1},CumPropKillsData{i,1},DataThresh(i,1),ModelThresh(i,1)] =...
        GetData10percAndCumCurves(BM_InputCell{i},FracH_rp_mean,DataPredMass(i),Mp,Mr);
end

%get inputs for plotting function
for i = 1:numel(DataPredMass)
    [~,ClosestIndices] = min(abs(Mp-DataPredMass(i))); 
    FracH_pred{i} = FracH_rp_mean(ClosestIndices(1),:);
    FracScav_pred{i} = FracScav_rp_mean(ClosestIndices(1),:);
end

%add-on plotting for supplementary figure to show best fit exponent for Mr*
%scaling
for i = 1:numel(Mp) 
    ModelVec = FracH_rp_mean(i,:);  %Get simulation results corresponding to predator

    %we can really only interpolate to pick out prey mass corresponding to 10% hunting, in the region that is not flat, so from (also note that you can't interpolate when sample
    %points are non unique) .Our results have some predator masses for which the huting fraction as a function of prey mass is not of the form 
    %[1 1 1 1 ..... <decreasing to 0> 0 0 ....... 0]. Specifically, there are some where the initial values are veru close to 1, but not 1, then the value increases to 1, stabilises, 
    %decreases to zero, and then stabilises. There are also predator masses for which this function doesn't fully decrease to zero, but these are for really high predator masses, 
    %which we don't have data for, and more importantly, correspond to bears and polar bears, which violate some assumptions of the model. So we wont worry about those.
    %At any rate, our goal is to identify the region in which the huntingv fraction decreases from 1 to 0, pick out a single 1 and 0 values bracketing this decrease, and interpolate 
    %in this region to find the prey mas corresponding to ~10% hunting fraction. 
    
    LastNonZeroInd = find(ModelVec,1,'last'); %Get index of last non-zero element

    %Check if this is a predator mass for which hunting fraction does not decrease to 0 (i.e, last non-zero element is the last element in the vector)
    if LastNonZeroInd ~= numel(ModelVec)

        ModelVec = ModelVec(1:LastNonZeroInd + 1); %Pick out elements up to that last non-zero element, plus the first 0
                                    
        %Now, we need to get the start of the decrease from 1 to 0, and then pick out that region plus the last 1. To do this, we first subtract 1
        %from the entire vector. This would make everything except the 1's negative (while the 1's will become 0). If we take the absolute value
        %of this new vector and query for the last 0 in this transformed vector, that will give us the index of the last 1. 
        TransformedModelVec = abs(ModelVec-1); %Note that this works because 1 is the largest possible va;lue for hunting fractions
        FirstOneInd = find(TransformedModelVec==0, 1, 'last'); %Find last zero in the transformed vector (corresponding to the last 1 ion the original vector, ie,
        %the start of the desecnt to 0)
    
        ModelVec = ModelVec(FirstOneInd:end); %get the part of the hunting fraction rtaht decreases from 1 to 0 ONLY
        ModelVec = ModelVec + (rand(size(ModelVec))*(10^-10));
        MrTemp = Mr(FirstOneInd:LastNonZeroInd+1); %get corresponding prey mass values
    
        Xq = sort([ModelVec 0.1]); %query vector
        Yq = interp1(ModelVec,MrTemp,Xq);
        ThreshMr(i) = Yq(Xq == 0.1);
    end
end

%Find the best fit re-scaline exponent for the threshold prey mass
%transition (Fig S22)
[fitobject, gof] = fit(transpose(Mp(1:numel(ThreshMr))),ThreshMr','x.^b');
ThreshMrBestFit = fitobject.b;
ThreshMrR2 = gof.rsquare;
fprintf('\n The best fit for Mr* ~ Mp^b is b = %.4f and R2 for fit is %.4f \n',ThreshMrBestFit,ThreshMrR2)
figure1 = figure('Color',[1 1 1]);
hold all
plot(Mp(1:numel(ThreshMr)),ThreshMr,'MarkerSize',15,'Marker','.','LineStyle','none')
plot(Mp(1:numel(ThreshMr)),Mp(1:numel(ThreshMr)).^ThreshMrBestFit,'--','LineWidth',1.5)
xlabel('Predator mass,    (kg)','FontSize',33,'FontName','Helvetica Neue')
ylabel('$M_r^*$','Interpreter','latex','FontSize',33,'FontName','Helvetica Neue')

%plotting function
Fig5RVPS_SDPpaper2022(FracH_pred{1},WDdata.BodyMasskg,WDdata.PercentofKills/100,WDdata.JacobsIndex,...
    FracH_pred{2},Cdata.BodyMasskg,Cdata.PercentofKills/100,Cdata.JacobsIndex,...
    FracH_pred{3},Ledata.BodyMasskg,Ledata.PercentofKills/100,Ledata.JacobsIndex,...
    FracH_pred{4},Hdata.BodyMasskg,Hdata.PercentofKills/100,Hdata.JacobsIndex,...
    FracScav_pred{4},...
    FracH_pred{5},Lidata.BodyMasskg,Lidata.PercentofKills/100,Lidata.JacobsIndex,...
    FracScav_pred{5},...
    FracH_pred{6},Tdata.BodyMasskg,Tdata.PercentofKills/100,Tdata.JacobsIndex,...
    Mp,Mr,FracH_rp_mean,DataThresh,ModelThresh,...
    uniqBM_Data{1},CumPropKillsData{1},uniqBM_Data{2},CumPropKillsData{2},uniqBM_Data{3},CumPropKillsData{3},...
    uniqBM_Data{4},CumPropKillsData{4},uniqBM_Data{5},CumPropKillsData{5},uniqBM_Data{6},CumPropKillsData{6},...
    WildDogMass,CheetahMass,LeopardMass,HyenaMass,LionMass,TigerMass,...
    ThreshMrBestFit,...
    ExScav_Mr,ExScavLion,ExScavHyena)

%Getting Scabv half-sat masses from model! 
% mass_H = Mr;
% mass_H = mass_H(45:end);
% perc_H = FracScav_pred{4} + (0.0000001*rand(size(FracScav_pred{4})));
% perc_H = perc_H(45:end);
% perc_Hq = sort([perc_H max(perc_H)*.5]);
% halfsat_H = max(perc_H)*.5;
% mass_int_H = interp1(perc_H,mass_H,perc_Hq);
% [~,indH] = min(abs(perc_Hq - halfsat_H));
% perc_Hq(indH)
% mass_int_H(indH)
% 
% 
% mass_L = Mr;
% mass_L = mass_L(66:end);
% perc_L = FracScav_pred{5} + (0.0000001*rand(size(FracScav_pred{5})));
% perc_L = perc_L(66:end);
% perc_Lq = sort([perc_L max(perc_L)*.5]);
% halfsat_L = max(perc_L)*.5;
% mass_int_L = interp1(perc_L,mass_L,perc_Lq);
% [~,indL] = min(abs(perc_Lq - halfsat_L));
% perc_Lq(indL)
% mass_int_L(indL)

%%
%functions needed
function [sumans] = cellsum(inp_array)
    
    sumans = zeros(size(inp_array{1}));
    for i = 1:numel(inp_array)
        sumans = sumans + inp_array{i} ;    
    end

end
