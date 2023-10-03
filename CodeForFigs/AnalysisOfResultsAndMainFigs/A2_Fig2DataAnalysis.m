clear all 
clc

%code for Fig 2 in paper: mean proportion of stratregy as a function of
%predator energetic statr and time

BasePath = '/Users/ritwikavps/Desktop/GoogleDriveFiles/research/justin projects/SDP_useful codes/Copy_of_allometric sdp/code/updated_code_log_sc_mass_Oct2019/';

FilesPath = strcat(BasePath,'CodeForGitHub');
cd(FilesPath)
%dir relevant mat files
aa = dir('FitDecExpfitness*Oct2022_*.mat');

%get mass ranges
Mp = unique(round(10.^(1:0.05:2.7)));%predator mass; we are simulating on log scale, up to 500 kg
Mc = Mp; %Competitor mass; same range and increments as Mp
%We use larger increments for carnivores cuz fewer heavy carnivores than herbivores
Mr = unique(round(10.^(1:0.03:3.5)));%Prey mass, also on log scale increments

%computing mean prop of strategy across all decision matrices, as a
%function of predator state
for i = 1:numel(aa)
    decfit_cell{i} = load(aa(i).name);
    [FracHunt{i},FracScav{i},FracSteal{i}] = decmat_avg(decfit_cell{i}.Decision_Cell);
    %[hdec_logic{i},ssdec_logic{i},asdec_logic{i}] = decmat_logic_forstats(decfit_cell{i}.Decision_Cell);
end
    
%normalise for all trials
DecCts_H_mean = cellsum(FracHunt)/numel(aa);
DecCts_Scav_mean = cellsum(FracScav)/numel(aa);
DecCts_St_mean = cellsum(FracSteal)/numel(aa);

%Time  = 1:29 
%X = 0.05 to 1 (0 x is dead)

xval = 0.05:0.05:1; %get relevant energetic states and time; in SDP, we use 0 to 1, but there is no decision for x = 0, because thatis the critical level
T = 1:29; %(last time does not have decision; in SDP, we use 1 to 30 days)

%fins SEI
SEI = zeros(size(DecCts_H_mean));
for i = 1:numel(DecCts_St_mean)
    SEI(i) = -((DecCts_St_mean(i)*log(DecCts_St_mean(i))) + (DecCts_Scav_mean(i)*log(DecCts_Scav_mean(i))) +...
    (DecCts_H_mean(i)*log(DecCts_H_mean(i))));
end
SEI = SEI/log(3);

%find min and max values for color scale for the surf plots for hunt and scav
Mx_Hunt = max(max(log10(DecCts_H_mean)));
Mx_Scav = max(max(log10(DecCts_Scav_mean)));
HuntScavMax = max([Mx_Hunt Mx_Scav])
Mn_Hunt = min(min(log10(DecCts_H_mean)));
Mn_Scav = min(min(log10(DecCts_Scav_mean)));
HuntScavMin = min([Mn_Hunt Mn_Scav])

Fig2RVPS_SDPpaper2022(DecCts_H_mean,DecCts_Scav_mean,DecCts_St_mean,SEI,HuntScavMin,HuntScavMax)

%save('avg_dec_mat_15trials.mat','DecCts_H_mean','DecCts_Scav_mean','DecCts_St_mean')

%%
%functions needed: sums up the constiytutent arrays in the cell array
function [sumans] = cellsum(inp_array) 
    sumans = zeros(size(inp_array{1}));
    for i = 1:numel(inp_array)
        sumans = sumans + inp_array{i} ;    
    end
end


