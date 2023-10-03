function [HuntCts_ForMassRatio,ScavCts_ForMassRatio,KlepCts_ForMassRatio,u_MassRatio_rp,u_MassRatio_cp] =...
                                                                                    mass_ratio_counts(HuntCt_Input,ScavCt_Input,KlepCt_Input,Mr,Mc,Mp)

%function to find mass ratio counts to compute SEI for Fig. S21b. 
%Basically, this function takes in the counts of hunting, scavenging, and
%stealing, for all combos of predator, prey and competitor masses, and
%converts that info to counts of each strategy as a fcuntion of the ratio
%of the competitor mass to the predator mass, and the ratio of the prey
%mass to the predator mass. That is, we get a sense of how strategy varies
%as a function of big the prey and competitor are wrt thje predator

[pp1,rr1] = size(HuntCt_Input{1});
 
%makes cells arrays w/ mass ratios and then pick the unique values. Here,
%we are simply finding all the mass ratios, and rounding them, so we can
%group, for example, 10.2, 10, 9.8, etc to 10. And so on.
for i = 1:numel(HuntCt_Input)
    for pp = 1:pp1
        for rr = 1:rr1
            MassRatio_cp(pp,rr) = round(Mc(i)/Mp(pp),1); %competitor to predator ratio
            MassRatio_rp(pp,rr) = round(Mr(rr)/Mp(pp),1); %Prey to predator ratio
            %Note that ratios less than 1 are rounded to teh first decimal
            %point. So, 0.54 will be 0.5, but ratios greater than 1 are
            %rounded to teh nearest whole number
            
            if MassRatio_cp(pp,rr) > 1
                MassRatio_cp(pp,rr) = round(MassRatio_cp(pp,rr));
            end
            
            if MassRatio_rp(pp,rr) > 1
                MassRatio_rp(pp,rr) = round(MassRatio_rp(pp,rr));
            end  
        end
    end 
    MassRatioCell_cp{i} = MassRatio_cp; %store in cell array
    MassRatioCell_rp{i} = MassRatio_rp;
    
    clear MassRatio_cp MassRatio_rp
end

%Each array in the MassRatioCell_cp/rp cell arrays will have the same
%dimensions as the corresponding hunt, scav, and klep count arrays. So,
%essentially, we can match eacc count to its mass ratio axes, and then
%count the number of hunting, scav, and klep decisions for each mass ratio.

%Convert mass ratio cell arrays to a vector. Pick unique values so we have
%the values of mass ratios that constitute the mass ratio axes
MassRatioMat_cp = cell2mat(MassRatioCell_cp);
MassRatioMat_rp = cell2mat(MassRatioCell_rp);
MassRatioMat_cp = MassRatioMat_cp(:);
MassRatioMat_rp = MassRatioMat_rp(:);
u_MassRatio_cp = unique(MassRatioMat_cp);
u_MassRatio_rp = unique(MassRatioMat_rp);

%Simialrly, convert cell arrays of the counts of each strategy to a vector. This way, we can match them to the mass ratio vectors
% and then count the number of decisions for each unique mass ratio
HuntCts = cell2mat(HuntCt_Input);
HuntCts = HuntCts(:);
ScavCts = cell2mat(ScavCt_Input);
ScavCts = ScavCts(:);
KlepCts = cell2mat(KlepCt_Input);
KlepCts = KlepCts(:);

HuntCts_ForMassRatio = zeros(numel(u_MassRatio_cp),numel(u_MassRatio_rp)); %initialise final output count matrices as a function of mass ratio axes
ScavCts_ForMassRatio = HuntCts_ForMassRatio;
KlepCts_ForMassRatio = HuntCts_ForMassRatio;

for i = 1:numel(u_MassRatio_cp) %go through the mass ratio vectors, match them to the corresponding unique _cp and _rp mass ratio values, and add the corresponding
    %sytrategy counts to the final output matrices
    for j = 1:numel(u_MassRatio_rp)
        for k = 1:numel(MassRatioMat_rp)
            if (MassRatioMat_cp(k) == u_MassRatio_cp(i)) && (MassRatioMat_rp(k) == u_MassRatio_rp(j))
                HuntCts_ForMassRatio(i,j) = HuntCts_ForMassRatio(i,j) + HuntCts(k);
                ScavCts_ForMassRatio(i,j) = ScavCts_ForMassRatio(i,j) + ScavCts(k);
                KlepCts_ForMassRatio(i,j) = KlepCts_ForMassRatio(i,j) + KlepCts(k);
            end  
        end  
    end
end

CtsSum = HuntCts_ForMassRatio + ScavCts_ForMassRatio + KlepCts_ForMassRatio; %get the total number of strartegy counts to normalise the counts

%normalise
HuntCts_ForMassRatio = HuntCts_ForMassRatio./CtsSum;
ScavCts_ForMassRatio = ScavCts_ForMassRatio./CtsSum;
KlepCts_ForMassRatio = KlepCts_ForMassRatio./CtsSum;
