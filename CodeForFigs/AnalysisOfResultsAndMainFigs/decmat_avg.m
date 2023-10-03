function [HuntingMatsum,ScavMatum,StealMatum] = decmat_avg(decisionmatrix_all)

%This function takes the cell array containing the decision matrices for
%one trial of the SDP, converts that info into the fraction of hunting,
%scavenging, and stealing decisions as a function of predator state

%initialise cell to store
HuntingCell = cell(1,numel(decisionmatrix_all));
ScavCell = cell(1,numel(decisionmatrix_all));
StealCell = cell(1,numel(decisionmatrix_all));

%have matrices for keeping track of h, ss, and as decisions. If h = yes,
%then put a 1 in its place in the respetive tracking matrix. This way, when
%we sum it all up, we get the number of times that a particular decision
%was made
for i = 1:numel(decisionmatrix_all) %go through every decision matrix
    %for each decision matrix, separate the info about whether the decision
    %is hunting, scavenging or stealing. So, we are separating the decision
    %maatrix into a hunting matrix (yes or no), scav matrix, and a stealing
    %matrix. Store this info in the respective cell arrays
    TempMat = decisionmatrix_all{i};
    HuntMat_Temp = zeros(size(TempMat));
    HuntMat_Temp(TempMat == 1) = 1;
    ScavMat_Temp = zeros(size(TempMat));
    ScavMat_Temp(TempMat == 2) = 1;
    StealMat_Temp = zeros(size(TempMat));
    StealMat_Temp(TempMat == 3) = 1;
    HuntingCell{i} = HuntMat_Temp;
    ScavCell{i} = ScavMat_Temp;
    StealCell{i} = StealMat_Temp;
end

%sum over the huntiing matrices, thereby getting the total number of
%hunting, scav and stealing decisions for each predator state (energetic
%store and time) for all combo of predator, prey and competitor mass
HuntingMatsum = sum(cat(3,HuntingCell{:}),3);
ScavMatum = sum(cat(3,ScavCell{:}),3);
StealMatum = sum(cat(3,StealCell{:}),3);

%Get fraction of each decision as a function of predator state by dividing by  the number of total decisoon matrices
HuntingMatsum = HuntingMatsum/numel(decisionmatrix_all);
ScavMatum = ScavMatum/numel(decisionmatrix_all);
StealMatum = StealMatum/numel(decisionmatrix_all);