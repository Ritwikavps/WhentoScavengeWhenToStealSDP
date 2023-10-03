function [uniqBM,prop,DataThresh,ModelThresh] = GetData10percAndCumCurves(BM,FracH_rp_mean,PredMass,Mp,Mr)

%Ritwika VPS, May 2022
%function to find threshold prey masses per data and model for when hunting
%becomes negligible, for different predators (Wild dog, cheetah, leopard,
%hyena, lion, and tiger). Note that we do not have enough data to compute
%this threshold for wild dog

%inputs:
    %BM: prey body mass from data spreadhseet for gthe given predator
    %FracH_rp_mean: mean proportion of hunting as a function or prey and
        %predator mass, from model
    %PredMass: mass of predator in question
    %Mp, Mr: predator and prey mass vectors from model

%outputs:
    %uniqBM: vector of unique prey masses from data
    %prop: corresponding cumulative proportion of kills vector
    %DataThresh,ModelThresh: threshold prey masses as computed from data
        %and model results

%Basically, what we are doing is computing the ratio of (the number of prey masses greater than or equal to the
%prey mass in question that contribute to non-neglibigle kill percentages) and (the total number of prey masses
%that contribute to non-negligble kill percentages). If we use a sliding scale and loop over the smallest to the
%largest prey mass in teh dataset, this gives a sort of probability distribution which sort of quantifies how much 
%prey masses greater than or equal to the given prey mass contribute to overall hunting (across all datasets). 
%Thus, we are computing the boundaries of hunting.

%get unique body masses (thsi is because there are sometimes data for same prey mass from different sources)
uniqBM = unique(BM); 

%do the looping to compute the cumulative proportion of kills contribution
%from prey masses greater than or equal to prey mass in question
for i = 1:numel(uniqBM)
        BMnew = BM(BM >= uniqBM(i));
        prop(i) = length(BMnew)/length(BM);
end

%Now, we want to see where the 10 percent cutoff of contribution to hunting
%diet by prey mass is

xq = (sort(unique([prop 0.1]))); %add 0.1 to the proportion vector, filter out unique values and sort
data1 = interp1(prop,uniqBM,xq); %interpolate to find prey mass corresponding to 0.1
DataThresh = data1(xq == 0.1);

%now we want to find the corresponding prey mass value for our model
%We start by finding the preator masses used in our sim closest to the
%mass of focal predator
AbsDiffVec = abs(Mp-PredMass); %absolute value of difference between focal predator mass and predator mass vector
MM = min(abs(Mp-PredMass)); %minmim difference
IndVec = 1:numel(AbsDiffVec); %finding indices corresponding to min diff
Indices = IndVec(AbsDiffVec == MM);

%To account for cases when there are two simulation predator masses
%that are equally close to the mass of the target predator, loop
%through indices
%Note that doing this would only work for predator masses where fraction of
%hunting actually goes from 1 to 0, or, at the very least, has values
%on both sides of 0.1. 
TempVec = [];
for i = 1:numel(Indices)

    ModelVec = FracH_rp_mean(Indices(i),:); %Get simulation results corresponding to predator
    %we can really only interpolate to pick out prey mass corresponding to 10% hunting, in the region that is not flat, so from (also note that you can't interpolate when sample
    %points are non unique) .Our results have some predator masses for which the huting fraction as a function of prey mass is not of the form 
    %[1 1 1 1 ..... <decreasing to 0> 0 0 ....... 0]. Specifically, there are some where the initial values are veru close to 1, but not 1, then the value increases to 1, stabilises, 
    %decreases to zero, and then stabilises. There are also predator masses for which this function doesn't fully decrease to zero, but these are for really high predator masses, 
    %which we don't have data for, and more importantly, correspond to bears and polar bears, which violate some assumptions of the model. So we wont worry about those.
    %At any rate, our goal is to identify the region in which the huntingv fraction decreases from 1 to 0, pick out a single 1 and 0 values bracketing this decrease, and interpolate 
    %in this region to find the prey mas corresponding to ~10% hunting fraction. 
    %(Alternatively, we can something simpler by adding a very small number (~10^-6) multiplied by a random number to every element of the hunting fraction so that the
    %interpolating points are unique. But this somehow seems to result in very scrambled interpolation. It might be because interpolation does
    %not work really well when there are a decently large number of unique query points that we are doctoring to become slightly lerger values by adding a very small number?)
  
    LastNonZeroInd = find(ModelVec,1,'last'); %Get index of last non-zero element
    %Check if this is a predator mass for which hunting fraction does not decrease to 0 (i.e, last non-zero element is the last element in the vector)
    if LastNonZeroInd == numel(ModelVec)
        i
        error('Last not 0')
    end

    ModelVec = ModelVec(1:LastNonZeroInd + 1); %Pick out elements up to that last non-zero element, plus the first 0

    %Now, we need to get the start of the decrease from 1 to 0, and then pick out that region plus the last 1. To do this, we first subtract 1
    %from the entire vector. This would make everything except the 1's negative (while the 1's will become 0). If we take the absolute value
    %of this new vector and query for the last 0 in this transformed vector, that will give us the index of the last 1. 
    TransformedModelVec = abs(ModelVec-1); %Note that this works because 1 is the largest possible va;lue for hunting fractions
    FirstOneInd = find(TransformedModelVec==0, 1, 'last'); %Find last zero in the transformed vector (corresponding to the last 1 ion the original vector, ie,
    %the start of the desecnt to 0)

    ModelVec = ModelVec(FirstOneInd:end); %get the part of the hunting fraction rtaht decreases from 1 to 0 ONLY
    MrTemp = Mr(FirstOneInd:LastNonZeroInd+1); %get corresponding prey mass values

    Xq = sort([ModelVec 0.1]); %query vector
    Yq = interp1(ModelVec,MrTemp,Xq);
    TempVec = [TempVec Yq(Xq == 0.1)];
end

%Take mean
ModelThresh = mean(TempVec);
