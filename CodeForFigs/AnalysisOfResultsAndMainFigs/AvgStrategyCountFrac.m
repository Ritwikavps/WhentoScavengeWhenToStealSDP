function [FracH_rp,FracScav_rp,FracKlep_rp,FracH_cp,FracScav_cp,FracKlep_cp,FracH_rc,FracScav_rc,FracKlep_rc,...
    FracH_r,FracScav_r,FracKlep_r,FracH_p,FracScav_p,FracKlep_p,FracH_c,FracScav_c,FracKlep_c] = ...
    AvgStrategyCountFrac(Hcount_Cell,Scavcount_Cell,Klepcount_Cell,Mr,Mp)

%computes average strategy counts as a function of predator (p), prey (r), 
%and competitor (c) masses indivdually (summed over other two mass axes), 
%and how average strategy co-varies as a function of two out of three mass
%combos at time (summed over third mass axis). For details, see supplementary information
%Note that each measure is calculated by summing over results from 15
%trials

%outputs: 
    %FracH_rp,FracScav_rp,FracKlep_rp: fraction of hunting (H), scaveging (Scav) and
        %kleptoparsitsim (Klep) respectively, as a function of prey (X axis) and
        %predator mass (Y axis); similar ourputs as a function of competitor and predator
        %mass; and prey and competitor mass
    %FracH_r,FracScav_r,FracKlep_r: Fraction of H, Scav, and Klep as a
        %function prey mass (r); similar fracs for competitor mass; and
        %predator mass

%inputs: 
    %Hcount_Cell,Scavcount_Cell,Klepcount_Cell: cell array with strategy
        %counts for H, Scav and Klep. Cell array is indexed
        %by competitor mass (i.e., numel(Hcount_Cell) = numel(Mc)). Each array
        %in the cell array is indexed by (Predator mass, Prey mass). Thus, the
        %(i,j)th value is the kth array in Hcount_cell is the total number of
        %hunting decisions for ith predator mass jth prey mass, and kth
        %competitor mass. 
    %Mr, Mp: prey and predator mass vectors. This is only used for
        %indexing, and since the competitior vector is the same numel as Mp (and values), I
        %didn't want a redundant input

%initilailse arrays to store fractions-we want the sum to be the same size array as
%each individual matrix.
%Here, FracH is the matrix to store the sum of total number fo each decision, summed over competitor axis 
FracH = zeros(size(Hcount_Cell{1}));
FracScav = zeros(size(Hcount_Cell{1}));
FracKlep= zeros(size(Hcount_Cell{1}));

%sum over the competitor axis
for i = 1:numel(Hcount_Cell)
    FracH = FracH + Hcount_Cell{i};
    FracScav = FracScav + Scavcount_Cell{i};
    FracKlep= FracKlep+ Klepcount_Cell{i};
end

%Compute average fraction of each decision as a function of Mr and Mp:
%take average (divide by the number of arrays summed) and compute fraction
FracH_rp = FracH/numel(Hcount_Cell)/580; %580 is the size of each decision matrix, will need to change if that changes
FracScav_rp = FracScav/numel(Hcount_Cell)/580;
FracKlep_rp = FracKlep/numel(Hcount_Cell)/580;

%fractions as function of Mc
for i = 1:numel(Hcount_Cell)
    FracH_c(i) = sum(sum(Hcount_Cell{i})); %sums each count array (for each competitor mass--sums over Mp and Mr) across Mr and Mp axes
    FracScav_c(i) = sum(sum(Scavcount_Cell{i}));
    FracKlep_c(i) = sum(sum(Klepcount_Cell{i}));   
end

%normalising by dividing by the total
FracSum = FracH_c + FracScav_c + FracKlep_c;
FracH_c = FracH_c./FracSum;
FracScav_c = FracScav_c./FracSum;
FracKlep_c = FracKlep_c./FracSum;

%-----------------------------------------
%Fraction of strategy as a function of Mc and Mp; and as fraction of Mr
%alone

%first, recast such that instead of the cell array being along Mc axis, is
%along Mr axis
for i = 1:numel(Mr)
    for j = 1:numel(Hcount_Cell) %loop through
        TempH = Hcount_Cell{j};
        TempScav = Scavcount_Cell{j};
        TempKlep = Klepcount_Cell{j};
        NewHmat(:,j) = TempH(:,i); %pick out column corresponding to each prey mass and stack
        NewScavmat(:,j) = TempScav(:,i);
        NewKlepmat(:,j) = TempKlep(:,i);
    end
    Hcount_r{i} = NewHmat; %store
    Scavcount_r{i} = NewScavmat;
    Klepcount_r{i} = NewKlepmat;
    clear NewHmat NewScavmat NewKlepmat
end

%initialise
FracH = zeros(size(Hcount_r{1}));
FracScav = zeros(size(Hcount_r{1}));
FracKlep= FracScav;

%sum up
for i = 1:numel(Hcount_r)
    FracH = FracH + Hcount_r{i};
    FracScav = FracScav + Scavcount_r{i};
    FracKlep = FracKlep + Klepcount_r{i};
end

%average and normalise
FracH_cp = FracH/numel(Hcount_r)/580;
FracScav_cp = FracScav/numel(Hcount_r)/580;
FracKlep_cp = FracKlep/numel(Hcount_r)/580;

%get fraction as function of prey mass alone
for i = 1:numel(Hcount_r)
    FracH_r(i) = sum(sum(Hcount_r{i}));
    FracScav_r(i) = sum(sum(Scavcount_r{i}));
    FracKlep_r(i) = sum(sum(Klepcount_r{i}));
end

%normalising
FracSum = FracH_r + FracScav_r + FracKlep_r;
FracH_r = FracH_r./FracSum;
FracScav_r = FracScav_r./FracSum;
FracKlep_r = FracKlep_r./FracSum;

%-----------------------
%Fraction of strategy as a function of Mr and Mc; and as fraction of Mc
%alone; 

%first, recast such that instead of the cell array being along Mc axis, is
%along Mp axis
for i = 1:numel(Mp)
    for j = 1:numel(Hcount_Cell) %loop through
        TempH = Hcount_Cell{j};
        TempScav = Scavcount_Cell{j};
        TempKlep = Klepcount_Cell{j};
        NewHmat(j,:) = TempH(i,:); %pick out rowcorresponding to each predator mass and stack
        NewScavmat(j,:) = TempScav(i,:);
        NewKlepmat(j,:) = TempKlep(i,:);
    end
    Hcount_p{i} = NewHmat;
    Scavcount_p{i} = NewScavmat;
    Klepcount_p{i} = NewKlepmat;
    clear NewHmat NewScavmat NewKlepmat
end

%initialise
FracH = zeros(size(Hcount_p{1}));
FracScav = zeros(size(Hcount_p{1}));
FracKlep= FracScav;

%sum up
for i = 1:numel(Hcount_p)
    FracH = FracH + Hcount_p{i};
    FracScav = FracScav + Scavcount_p{i};
    FracKlep= FracKlep+ Klepcount_p{i};
end

%average and normalise
FracH_rc = FracH/numel(Hcount_p)/580;
FracScav_rc = FracScav/numel(Hcount_p)/580;
FracKlep_rc = FracKlep/numel(Hcount_p)/580;

%get fraction as function of predator mass alone
for i = 1:numel(Hcount_p)
    FracH_p(i) = sum(sum(Hcount_p{i}));
    FracScav_p(i) = sum(sum(Scavcount_p{i}));
    FracKlep_p(i) = sum(sum(Klepcount_p{i}));
end

%normalising
FracSum = FracH_p + FracScav_p + FracKlep_p;
FracH_p = FracH_p./FracSum;
FracScav_p = FracScav_p./FracSum;
FracKlep_p = FracKlep_p./FracSum;

