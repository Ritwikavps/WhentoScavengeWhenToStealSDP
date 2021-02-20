clear all
clc

%Ritwika VPS
%UC Merced
%SDP Data screaping
%Feb 2021

%Code to compute scavenging fractions from Puma kills

Pumadata = readtable('PumaScavData.xlsx'); %readtable
NumPumaKills = numel(Pumadata.KillCarcassName); %Total number of Puma Kills

%I am choosing to simply compute the fraction of scavenging by each
%scavenger species (within the mass range we investigated) by dividing
%number of kills with scavenger S present by total number of kills

Scavengers = char(Pumadata.ScavengersPresent); %Convert to string array

counter = 0;

for i = 1:NumPumaKills %Go through number of kills and list out each scavenger species for each kill.
    %We will find unique species from this lise
    
    TempStr = strtrim(strsplit(Scavengers(i,:),',')); %split at commas, trim off trailing and starting spaces
    
    for k = 1:numel(TempStr)
        
        %List out: Counter helps with this
        counter = counter + 1;
        ScavList{counter,1} = TempStr{k};
             
    end
end

%Find unique scavenger species, regardless of case (convert to lower case
%first)
%lower converts everything to lowercase, UniqueScav is the list of unique
%scavenger species, the second output is such that UniqueScav = lower(ScavList)(~)
%and idc is sucth that lower(ScavList) = UniqueScav(idc). That is idc gives the indices of 
%each element of the lowercase ScavList wrt to the unique list. So if we
%count the number of times each index occurs in idc, we get the number of
%times a unique scavenger species was at a kill
[UniqueScav, ~, idc] = unique(lower(ScavList)); 
NumOfKillsPresent = accumarray( idc, ones(size(idc)));

%The way the Excel file is set up, there is an empty character vector as
%the first element. Remove that
UniqueScav = UniqueScav(2:end);
NumOfKillsPresent = NumOfKillsPresent(2:end);
NumOfTotalKills = NumPumaKills*ones(size(NumOfKillsPresent));

%As it turns out, Puma and mountain lion occur as 2 different scavenger
%species but to the best of my knowledge they are the same species. We will
%fix this in the final step (in the table we generate)
T = table(UniqueScav,NumOfKillsPresent,NumOfTotalKills);
writetable(T,'PumaScavDataProcessed.xlsx')

