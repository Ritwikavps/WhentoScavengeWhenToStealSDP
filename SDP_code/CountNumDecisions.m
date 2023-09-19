function [Counts_H,Counts_Scav,Counts_Klep] = CountNumDecisions(DecisionMatrix)

%function to get  the num of hunting, scavenging, and stealing 'decisions'
%in the decision matrix

DecisionMatrix = DecisionMatrix(:); %collapse decisionmatric into a vector

Counts_H = numel(DecisionMatrix(DecisionMatrix == 1)); %count the number of hunting 'decisions' (i.e, occurences of 1)
Counts_Scav = numel(DecisionMatrix(DecisionMatrix == 2)); %count the number of scavenging 'decisions' (i.e, occurences of 2)
Counts_Klep = numel(DecisionMatrix(DecisionMatrix == 3)); %count the number of stealing 'decisions' (i.e, occurences of 2)