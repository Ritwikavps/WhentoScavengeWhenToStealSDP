clear all
clc

%Ritwika VPS
%Code to analyse and plot sensitivity analyses data

BasePath = '/Users/ritwikavps/Desktop/GoogleDriveFiles/research/justin projects/SDP_useful codes/Copy_of_allometric sdp/code/updated_code_log_sc_mass_Oct2019/CodeForGitHub/ResultsMatMarch2022/SensAnalyses/';

BaselinePath = strcat(BasePath,'Baseline/'); %get path for baseline matrices (same SDP comps as the full model, but on a more sparse mass range for Mp, Mr, and Mc + 5 trials instead of 15 to average over)
cd(BaselinePath)
BaselineMats = dir('FitDecExpfitness_SensBaseline*.mat'); %get baseline decision matrices. This is what we will comapre all sensitivity analyses against
GetSensAnalysesFig3Plot(BaselinePath,'StrategyCountsExpfitness_SensBaseline*.mat') %plot version of Fig 3 from main text for base line strategy counts

%hunt success body mass ratio
[MeanDiffFrac_HuntSuccessBodyMassRatio] = GetMeanFracAlteredStates_NoParamSweep(BasePath,'HuntSuccessBodyMassRatio','FitDecExpfitness_SensHuntSuccessBodyMassRatioJ*.mat',BaselineMats,'StrategyCountsExpfitness_SensHuntSuccessBodyMassRatio*.mat');

%link probability with body mas ratio inverted
[MeanDiffFrac_LinkProbInvBodyMassRatio] = GetMeanFracAlteredStates_NoParamSweep(BasePath,'LinkProbInvBodyMassRatio','FitDecExpfitness_SensLinkProbInvBodyMassRatio*.mat',BaselineMats,'StrategyCountsExpfitness_SensLinkProbInvBodyMassRatio*.mat');

%linear fiitness func
[MeanDiffFrac_LinFitness] = GetMeanFracAlteredStates_NoParamSweep(BasePath,'LinFitnessFunc','FitDecExpfitness_SensLinearTerminalFitness*.mat',BaselineMats,'StrategyCountsExpfitness_SensLinearTerminalFitness*.mat');

%link prob
LinkProbScaleFactorPerc = [50 70 90 110 130 150];
[MeanDiffFrac_LinkProb] = GetMeanFracAlteredStates_ParamSweep(BasePath,'LinkProbParamScale','FitDecExpfitness_SensLinkProbMarch2023_ScalePerc',BaselineMats,LinkProbScaleFactorPerc);

%Active time
ActiveTimeScaleFactorPerc = [50 70 90 110 130 150];
[MeanDiffFrac_ActiveTime] = GetMeanFracAlteredStates_ParamSweep(BasePath,'ActiveTime','FitDecExpfitness_SensActiveTimeJune2023_ScalePerc',BaselineMats,ActiveTimeScaleFactorPerc);

%functions used:
%-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function [MeanDiffFrac] = GetMeanFracAlteredStates_NoParamSweep(BasePath,FolderName,DirMatsString,BaselineMats,DirMatStringForPlots)

%this function deals with sensitivity analyses that aren't parameter
%sweeps. So, anything that is testing a single different condition, such as
%linear terminal fitness function vs. the default exponbential terminal
%fitness function (baseline); or the hunting success probability being a
%simple body mass ratio, etc. 

%This computes the mean proportion of altered states for the test condition
%wrt to the baseline condition, and this mean is obtained by averaging over
%the 5 trials. 

%inputs: BasePath: common part of the path variable
        %FolderName: the name of the spcific folder in which the relevant results matrices are
        %DirMatsString: The string to pick out (using dir) decision matrices to compute mean proportion of altered states
        %BaselineMats: decision matrices from baseline computation
        %DirMatStringForPlots: the string to pick out (using dir) strategy count matrices to plot a versiion of Fig 3 in main text

    DesiredPath = strcat(BasePath,FolderName,'/'); %get path of the .mat files
    cd(DesiredPath)
    DesiredMats = dir(DirMatsString); %get fitness and decision matrix .mat files

    if numel(BaselineMats) ~= numel(DesiredMats) %check if both baseline mats and the current mat files have the same number of unique elements (ie, same number of trials done)
        error('Num. mats for baseline and test case %s not same',FolderName)
    end
    
    for i = 1:numel(BaselineMats) 
        Bb = load(BaselineMats(i).name); %get baseline mat and test mat, one by one
        Mm = load(DesiredMats(i).name);
    
        [SumOfDiff_Mat,DenomMat] = cellfun(@GetSensResults, Bb.Decision_Cell, Mm.Decision_Cell); %apply GetSensResults to every element of the cell array pair in the arguyments (see GetSensResults below)
        DiffFracVec(i,1) = sum(SumOfDiff_Mat(:))/sum(DenomMat(:)); %The total fraction of altered states for one trial is the sum of the differences across the whole trial divided by the total number of decisions in the whole trial
    end
    
    MeanDiffFrac = mean(DiffFracVec);  %get mean frac of altered states for all trials

    GetSensAnalysesFig3Plot(DesiredPath,DirMatStringForPlots) %plot version of Fig 3
end

%--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function [MeanDiffFrac] = GetMeanFracAlteredStates_ParamSweep(BasePath,FolderName,DirMatsString,BaselineMats,ParamVector)

%this function deals with sensitivity analyses that are parameter
%sweeps. So, anything that is testing a range of parameters for a single different condition, such as
%how results change when the Rohr coefficients are csaled by some factor

%This computes the mean proportion of altered states for the test condition
%wrt to the baseline condition, and this mean is obtained by averaging over
%the 5 trials, for each unique parameter value

%inputs: BasePath: common part of the path variable
        %FolderName: the name of the spcific folder in which the relevant results matrices are
        %DirMatsString: The string to pick out (using dir) decision matrices to compute mean proportion of altered states
        %BaselineMats: decision matrices from baseline computation
        %ParamVector: the vector of parameters we are sweeping

    DesiredPath = strcat(BasePath,FolderName,'/'); %get path of the .mat files
    cd(DesiredPath)

    for i = 1:numel(ParamVector) %go through the parameter vector
        DesiredMats = dir(strcat(DirMatsString,num2str(ParamVector(i)),'*.mat')); %get mat files for that parameter value
    
        DiffFracVec = zeros(numel(DesiredMats),1); %initialise vector to store mean frac of altered states for each param value
    
        for j = 1:numel(DesiredMats) 
            Bb = load(BaselineMats(j).name); %get baseline mat and test mat, one by one, for the given param value
            Mm = load(DesiredMats(j).name);
     
            [SumOfDiff_Mat,DenomMat] = cellfun(@GetSensResults, Bb.Decision_Cell, Mm.Decision_Cell); %apply GetSensResults to every element of the cell array pair in the arguyments (see GetSensResults below)
            DiffFracVec(j) = sum(SumOfDiff_Mat(:))/sum(DenomMat(:)); %The total fraction of altered states for one trial is the sum of the differences across the whole trial divided by the total number of decisions in the whole trial
        end
    
        MeanDiffFrac(i) = mean(DiffFracVec); %get mean fraqc of altered states for that param value
    end  
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
