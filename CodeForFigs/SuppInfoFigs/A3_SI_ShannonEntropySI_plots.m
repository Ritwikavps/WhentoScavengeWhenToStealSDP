clear all
clc

%Ritwika VPS
%UCMerced: script to plot: SI fig S21
%updated Apr 7, 2022 (while at UCLA Dpmt of Comm)

%go to folder
BasePath = '/Users/ritwikavps/Desktop/GoogleDriveFiles/research/justin projects/SDP_useful codes/Copy_of_allometric sdp/code/updated_code_log_sc_mass_Oct2019/CodeForGitHub/';
cd(BasePath)

%Get mass relations
Mp = unique(round(10.^(1:0.05:2.7)));%predator mass; we are simulating on log scale, up to 500 kg
Mc = Mp; %Competitor mass; same range and increments as Mp
Mr = unique(round(10.^(1:0.03:3.5)));%Prey mass, also on log scale increments

aa = dir('StrategyCountsExpfitnessOct2022_*.mat');
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

%Strategy fraction avg as a function of (Mr/Mp) and (Mc/Mp); see user-defined fn mass_ratio_counts for details
for i = 1:numel(aa)
    [Uniq_hCts_{i},Uniq_ScavCts_{i},Uniq_KlepCts{i},u_pc,u_vc] = mass_ratio_counts(CountsCell{i}.Hcount_Cell,CountsCell{i}.Scavcount_Cell,...
                    CountsCell{i}.Klepcount_Cell,Mr,Mc,Mp);
end

Uniq_hCts_mean = cellsum(Uniq_hCts_)/numel(aa);
Uniq_ScavCts_mean = cellsum(Uniq_ScavCts_)/numel(aa);
Uniq_KlepCts_mean = cellsum(Uniq_KlepCts)/numel(aa);

%get Shannon's entropy
%for strategy proportion as a function of Mr and Mp: first take log 
LogFracH_rp_mean = log(FracH_rp_mean);
LogFracScav_rp_mean = log(FracScav_rp_mean);
LogFracKlep_rp_mean = log(FracKlep_rp_mean);
%aset log of 0 to 0. This is because entropy is computed as - prob_i *
%log(prob_i). So, the multiplying by 0 will render these values zero
LogFracH_rp_mean(FracH_rp_mean == 0) = 0;
LogFracScav_rp_mean(FracScav_rp_mean == 0) = 0;
LogFracKlep_rp_mean(FracKlep_rp_mean == 0) = 0;
%find p_i*log(p_i), where p_i is probabiltry (or proportion, in this case)
%of srategy
SE_Hunt_rp = LogFracH_rp_mean.*FracH_rp_mean;
SE_Scav_rp = LogFracScav_rp_mean.*FracScav_rp_mean;
SE_Klep_rp = LogFracKlep_rp_mean.*FracKlep_rp_mean;

SE_PropStrat_rp = -(SE_Hunt_rp + SE_Scav_rp + SE_Klep_rp);

%siimlarly for proportion as a function of mass ratios
LogFracH_MassRatioMean = log(Uniq_hCts_mean);
LogFracScav_MassRatioMean = log(Uniq_ScavCts_mean);
LogFracKlep_MassRatioMean = log(Uniq_KlepCts_mean);
%set log of proportions that were 0 to 0
LogFracH_MassRatioMean(Uniq_hCts_mean == 0) = 0;
LogFracScav_MassRatioMean(Uniq_ScavCts_mean == 0) = 0;
LogFracKlep_MassRatioMean(Uniq_KlepCts_mean == 0) = 0;
%find p_i*log(p_i)
SE_Hunt_ratio = LogFracH_MassRatioMean.*Uniq_hCts_mean;
SE_Scav_ratio = LogFracScav_MassRatioMean.*Uniq_ScavCts_mean;
SE_Klep_ratio = LogFracKlep_MassRatioMean.*Uniq_KlepCts_mean;

SE_PropStrat_ratio = -(SE_Hunt_ratio + SE_Scav_ratio + SE_Klep_ratio);


%Plotting
figure;
hold all
subplot(1,2,1)
h = surf(Mr,Mp,SE_PropStrat_rp);
set(h, 'EdgeColor', 'none');
axis tight
view(2)
colorbar
caxis([min(SE_PropStrat_rp(:)) max(SE_PropStrat_rp(:))]);
xlabel('Prey mass,     (kg)')
ylabel('Predator mass,      (kg)')
title('A')

subplot(1,2,2)
h = surf(u_pc,u_vc,SE_PropStrat_ratio);
set(h, 'EdgeColor', 'none');
axis tight
view(2)
colorbar
caxis([min(SE_PropStrat_ratio(:)) max(SE_PropStrat_ratio(:))]);
xlabel('$M_r$/$M_p$','Interpreter','latex')
ylabel('$M_c$/$M_p$','Interpreter','latex')
title('B')

%%
%functions needed
function [sumans] = cellsum(inp_array)
    
    sumans = zeros(size(inp_array{1}));
    for i = 1:numel(inp_array)
        sumans = sumans + inp_array{i} ;    
    end

end