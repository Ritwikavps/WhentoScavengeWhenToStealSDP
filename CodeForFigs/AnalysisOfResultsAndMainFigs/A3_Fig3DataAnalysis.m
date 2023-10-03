clear all
clc

%Ritwika VPS
%UCMerced: script to plot:
%updated Apr 7, 2022 (while at UCLA Dpmt of Comm)

BasePath = '/Users/ritwikavps/Desktop/GoogleDriveFiles/research/justin projects/SDP_useful codes/Copy_of_allometric sdp/code/updated_code_log_sc_mass_Oct2019/';

FilesPath = strcat(BasePath,'CodeForGitHub');
cd(FilesPath)

%Get mass relations
Mp = unique(round(10.^(1:0.05:2.7)));%predator mass; we are simulating on log scale, up to 500 kg
Mc = Mp; %Competitor mass; same range and increments as Mp
Mr = unique(round(10.^(1:0.03:3.5)));%Prey mass, also on log scale increments

aa = dir('StrategyCountsExpfitnessOct2022_*.mat'); %dir relevant mat files
colorlog = 0;

%Average Frac of strategy Counts

%go through mat files and find average fraction
for i = 1:numel(aa)  
    CountsCell{i} = load(aa(i).name);
    
    [FracH_rp{i},FracScav_rp{i},FracKlep_rp{i},~,~,~,~,~,~,FracH_r{i},FracScav_r{i},FracKlep_r{i},FracH_p{i},FracScav_p{i},FracKlep_p{i},...
    FracH_c{i},FracScav_c{i},FracKlep_c{i}] =...
                               AvgStrategyCountFrac(CountsCell{i}.Hcount_Cell,CountsCell{i}.Scavcount_Cell,...
                               CountsCell{i}.Klepcount_Cell,Mr,Mc);   
end

%avg fraction of strategy as function of two mass axes (eg. Mr and Mp)
FracH_rp_mean = cellsum(FracH_rp)/numel(aa);
FracScav_rp_mean = cellsum(FracScav_rp)/numel(aa);
FracKlep_rp_mean = cellsum(FracKlep_rp)/numel(aa);

%Ave frac of strategy as function of single mass axes (eg. Mp)
FracH_r_mean = cellsum(FracH_r)/numel(aa);
FracScav_r_mean = cellsum(FracScav_r)/numel(aa);
FracKlep_r_mean = cellsum(FracKlep_r)/numel(aa);
FracH_p_mean = cellsum(FracH_p)/numel(aa);
FracScav_p_mean = cellsum(FracScav_p)/numel(aa);
FracKlep_p_mean = cellsum(FracKlep_p)/numel(aa);
FracH_c_mean = cellsum(FracH_c)/numel(aa);
FracScav_c_mean = cellsum(FracScav_c)/numel(aa);
FracKlep_c_mean = cellsum(FracKlep_c)/numel(aa);

Fig3RVPS_SDPpaper2022(BasePath, Mp, Mr, Mc, FracH_p_mean, FracScav_p_mean, FracKlep_p_mean, FracH_r_mean, FracScav_r_mean, FracKlep_r_mean,...
    FracH_c_mean, FracScav_c_mean, FracKlep_c_mean, FracH_rp_mean, FracScav_rp_mean, FracKlep_rp_mean)

%functions needed: sums up the constiytutent arrays in the cell array
function [sumans] = cellsum(inp_array)
    sumans = zeros(size(inp_array{1}));
    for i = 1:numel(inp_array)
        sumans = sumans + inp_array{i} ;    
    end
end