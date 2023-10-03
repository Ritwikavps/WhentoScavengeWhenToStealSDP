clear all 
clc

%Ritwika VPS; thsi script plots the supplementary figures in supplementary
%section 1

%go to folder
BasePath = '/Users/ritwikavps/Desktop/GoogleDriveFiles/research/justin projects/SDP_useful codes/Copy_of_allometric sdp/code/updated_code_log_sc_mass_Oct2019/CodeForGitHub/';
cd(BasePath)

%Get mass relations
Mp = unique(round(10.^(1:0.05:2.7)));%predator mass; we are simulating on log scale, up to 500 kg
Mc = Mp; %Competitor mass; same range and increments as Mp
Mr = unique(round(10.^(1:0.03:3.5)));%Prey mass, also on log scale increments

load('AllometricRelationshipsOct2022.mat') %load required structure

%call functions that plot figs
AllometricRltnshipsForEncounterProbFigure(Mp,Mr,AllometricStruct) %allometric relationships that go into computing encounter prob
EnergeticCostsFig(Mp,Mr,AllometricStruct) %fig w/ summary of energetic costs
EnergeticGainsFig(Mp,Mr,AllometricStruct) %fig. with summary of energetic gains
HandlingTimeFig(Mp,Mr,AllometricStruct) %fig with handling time and resourcer acquisition time details
MortalityFig(Mp,Mr,Mc,AllometricStruct) %fig with mortality details