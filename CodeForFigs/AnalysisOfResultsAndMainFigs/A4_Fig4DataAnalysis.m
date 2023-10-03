clear all
clc

%Ritwika VPS
%UCMerced: script to plot: Fig 4 in main paper (hyena and lion: obs vs. model results
%hunting and scavenging proportions)
%updated May 7, 2022 (while at UCLA Dpmt of Comm)

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
    [~,~,~,~,~,~,~,~,~,~,~,~,FracH_p{i},FracScav_p{i},FracKlep_p{i},~,~,~] = AvgStrategyCountFrac(CountsCell{i}.Hcount_Cell,...
                                                                CountsCell{i}.Scavcount_Cell,CountsCell{i}.Klepcount_Cell,Mr,Mc);  
    %we only need the fraction of scavenging and hunting as a function of
    %predator mass (+ hyena kleptoparasitsim fraction)
end

%Ave frac of strategy as function of single mass axes (eg. Mp)
FracH_p_mean = cellsum(FracH_p)/numel(aa);
FracScav_p_mean = cellsum(FracScav_p)/numel(aa);
FracKlep_p_mean = cellsum(FracKlep_p)/numel(aa);

%get values for lion and hyena (source: ????????)
LionMass = 150;
HyenaMass = 60;

%find indices closest to these masses
[~,LionInd] = min(abs(Mp-LionMass));
[~,HyenaInd] = min(abs(Mp-HyenaMass));

%Get hunting and scavenging fraction for both (+hyena klep fraction)
HyenaHuntFrac = FracH_p_mean(HyenaInd);
HyenaScavFrac = FracScav_p_mean(HyenaInd);
HyenaKlepFrac = FracKlep_p_mean(HyenaInd);

LionHuntFrac = FracH_p_mean(LionInd);
LionScavFrac = FracScav_p_mean(LionInd);

%find min and max values for lion and hyena hunting and scavenging (for
%error bars)
for i = 1:numel(FracKlep_p)
    LionHuntVec(i) = FracH_p{i}(LionInd);
    LionScavVec(i) = FracScav_p{i}(LionInd);

    HyenaHuntVec(i) = FracH_p{i}(HyenaInd);
    HyenaScavVec(i) = FracScav_p{i}(HyenaInd);
end

%display averages from model
fprintf('From the model, for lion, mean hunting proportion = %.4f \n and mean scavenging proportion = %.4f \n',LionHuntFrac,LionScavFrac)
fprintf('From the model, for spotted hyena, mean hunting proportion = %.4f, \n  mean scavenging proportion = %.4f, \n and mean kleptoparasitsim proportion = %.4f \n',...
    HyenaHuntFrac,HyenaScavFrac,HyenaKlepFrac)

%get min and max values (1st value is min, second is max)
LionHuntMinMax = [min(LionHuntVec) max(LionHuntVec)];
LionScavMinMax = [min(LionScavVec) max(LionScavVec)];
HyenaHuntMinMax = [min(HyenaHuntVec) max(HyenaHuntVec)];
HyenaScavMinMax = [min(HyenaScavVec) max(HyenaScavVec)];

%load relevant obs data spreadsheet
TableLocation = strcat(BasePath,'CodeForGitHub/ObsDataFromLit/');
TablePointer = strcat(TableLocation,'Perieraetal2013LionHyena_ResultsMar2022.xlsx');
aa = readtable(TablePointer,'Sheet','Sheet1');
%relevant var names: DataPercent (double), Predator (string cell array, Lion or SpottedHyena),
%StrategyType (string cell array, h or sc); all double: Data, Model, ModelMin, ModelMax; 
%DataMin (double or NaN), DataMax (double or NaN)

%create inputs for plotting function
LionHData = aa.Data(strcmp(aa.Predator,'Lion') & strcmp(aa.StrategyType,'h'));
LionHDataMin = str2double(aa.DataMin(strcmp(aa.Predator,'Lion') & strcmp(aa.StrategyType,'h')));
LionHDataMax = str2double(aa.DataMax(strcmp(aa.Predator,'Lion') & strcmp(aa.StrategyType,'h')));
LionHModel = LionHuntFrac*ones(size(LionHData));
LionHModelMin = LionHuntMinMax(1)*ones(size(LionHData));
LionHModelMax = LionHuntMinMax(2)*ones(size(LionHData));
HyenaHData = aa.Data(strcmp(aa.Predator,'SpottedHyena') & strcmp(aa.StrategyType,'h'));
HyenaHDataMin = str2double(aa.DataMin(strcmp(aa.Predator,'SpottedHyena') & strcmp(aa.StrategyType,'h')));
HyenaHDataMax = str2double(aa.DataMax(strcmp(aa.Predator,'SpottedHyena') & strcmp(aa.StrategyType,'h')));
HyenaHModel = HyenaHuntFrac*ones(size(HyenaHData));
HyenaHModelMin = HyenaHuntMinMax(1)*ones(size(HyenaHData));
HyenaHModelMax = HyenaHuntMinMax(2)*ones(size(HyenaHData));
LionScavData = aa.Data(strcmp(aa.Predator,'Lion') & strcmp(aa.StrategyType,'sc'));
LionScavDataMin = str2double(aa.DataMin(strcmp(aa.Predator,'Lion') & strcmp(aa.StrategyType,'sc')));
LionScavDataMax = str2double(aa.DataMax(strcmp(aa.Predator,'Lion') & strcmp(aa.StrategyType,'sc')));
LionScavModel = LionScavFrac*ones(size(LionScavData));
LionScavModelMin = LionScavMinMax(1)*ones(size(LionScavData));
LionScavModelMax = LionScavMinMax(2)*ones(size(LionScavData));
HyenaScavData = aa.Data(strcmp(aa.Predator,'SpottedHyena') & strcmp(aa.StrategyType,'sc'));
HyenaScavDataMin = str2double(aa.DataMin(strcmp(aa.Predator,'SpottedHyena') & strcmp(aa.StrategyType,'sc')));
HyenaScavDataMax = str2double(aa.DataMax(strcmp(aa.Predator,'SpottedHyena') & strcmp(aa.StrategyType,'sc')));
HyenaScavModel = HyenaScavFrac*ones(size(HyenaScavData));
HyenaScavModelMin = HyenaScavMinMax(1)*ones(size(HyenaScavData));
HyenaScavModelMax = HyenaScavMinMax(2)*ones(size(HyenaScavData));

%call function to plot
Fig4RVPS_SDPpaper2022(LionHData,LionHModel,LionHModelMin,LionHModelMax,LionHDataMin,LionHDataMax,...
    HyenaHData,HyenaHModel,HyenaHModelMin,HyenaHModelMax,HyenaHDataMin,HyenaHDataMax,...
    LionScavData,LionScavModel,LionScavModelMin,LionScavModelMax,LionScavDataMin,LionScavDataMax,...
    HyenaScavData,HyenaScavModel,HyenaScavModelMin,HyenaScavModelMax,HyenaScavDataMin,HyenaScavDataMax)


%%
%functions needed
function [sumans] = cellsum(inp_array) %this function just sums all arrays in a cell array. I am sure there are more efficient ways to do this,
%but this works, and I don't want to change this everywhere. There 
    
    sumans = zeros(size(inp_array{1}));
    for i = 1:numel(inp_array)
        sumans = sumans + inp_array{i} ;    
    end

end


