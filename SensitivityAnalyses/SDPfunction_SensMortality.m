function [DecisionMatrix] =...
    SDPfunction_SensMortality(Mp,Mr,Mc,tvec,AllometricStruct,pp,rr,cc,KlepEncNumVec,KlepEncProbVec,HuntEncNumVec,HuntEncProbVec,ScavEncNumVec,ScavEncProbVec,...
                            FitnessFuncType,HuntMortScaleFactor,StealMortScaleFactor)

%function that does SDP computation, modified so that we account for scaling the increased 
% mortality assoacted with hunting and strealing. 
%Note the use of the HuntMortScaleFactor and StealMortScaleFactor variables 
% in the computation of associated mortalities

%inputs: predator, prey and competitor mass vectors: Mp, Mr, Mc
        %tvec: predator energetic content vector, and time vector (for SDP)
        %AllometricStruct: structure with fields: 
                %FmJ_p: predator fat mass, i Joules (energy units
                %Bmr12hr_p: predator BMR for 12 hr, J/s; FmrJperSec_p: predator FMR, J/s; MmrJperSec_p: predator MMR, J/s
                %MuPerSec_p: baseline mortality, per sec
                %StmGm_p: predator stomach size, grams
                %ConsumedMassGm_r: prey mass consumed by hunter and kleptoparasite; ConsumedMassGmSc_r: prey mass consumed by scaveneger
                %ThandleSec_pr: handling time of prey for predator (pursue, subdue and consume)
                %LinkProb_cr: probabilty of food web b/n pred and prey; LinkProb_pr: prob of food web link b/n competitor and prey
        %pp, rr, cc: indices of predator, prey, and competitor mass of
                %interest
        %KlepEncNumVec: vector of number of successful
            %kleptoparasitic encounter, from 0 to max possible number
            %(similarly for hunting and scavenging)
        %KlepEncProbVec: probabiltty vector with probabilties for i
            %kleptoparasitsic encounters (corresponding to KlepEncProbVec);
            %s(imilarly for hunting and scavenging)
        %FitnessFuncType: type of terminal fitness function; string
        %('exponential' or 'linear')

%outputs: FitnessMatrix,DecisionMatrix: computed fitness and decision
                %matrices
        %HuntCount, ScavCount, KlepCount: number of instances of hunting,
                %scavenging and kleptoparasitsim in the decision matrix


%generate predator eneregtic content vector
xmin = 0; %starvation threshold
xmax = AllometricStruct.FmJ_p(pp); %max fat mass for consumer
xn = 20; %n+1 is the number of x entries you have
dx = (xmax-xmin)/xn;
x = xmin:dx:xmax;

%initialise fitness and decision cell arrays (a little redundant, since
%these will be converted to arrays at the end, but this is an older script
%I pretti-fied, and this is how it was set up back then)
DecCell = cell(1,length(tvec)-1); %no decision for final time, hence the tvec-1 length
FitnessCell = cell(1,length(tvec));

%initialise arrays to store energy updates for each x value for all
%possible number of encounters, for different behaviours
x_h = zeros(length(x),length(HuntEncNumVec));
x_scav = zeros(length(x),length(ScavEncNumVec));
x_klep = zeros(length(x),length(KlepEncNumVec));

F = FitnessFunction(x/xmax,FitnessFuncType); %terminal fitness function %fitness defined relative to maximum possible energetic state
FitnessCell{1,length(tvec)} = F; %fitness matrix to be filled; terminal fitness is filled in

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%update choices for hunter
for i = 1:numel(HuntEncNumVec)
    %fat energy - bmr for 12 hr - fmr  for time spent foraging - mmr for
    %actual huntiing time (20 percent of handling time) + gain; each i corresponds to n = 0, 1, 2 etc
    %succesful prey encounters; adding prey consumable mass for hunting as gain
    x_h(:,i) = x - AllometricStruct.Bmr12hr_p(pp) - ...
        (12*60*60 - 0.2*AllometricStruct.ThandleSec_pr(pp,rr)*HuntEncNumVec(i))*AllometricStruct.FmrJperSec_p(pp) -...
        0.2*AllometricStruct.ThandleSec_pr(pp,rr)*HuntEncNumVec(i)*AllometricStruct.MmrJperSec_p(pp) +...
        20000*0.1*min(AllometricStruct.ConsumedMassGm_r(rr)*HuntEncNumVec(i),AllometricStruct.StmGm_p(pp)); %only 10% of energy accumuilated 
end

%set max and min bounds
x_h(x_h > xmax) = xmax;
x_h(x_h < xmin) = xmin;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%update choices for scavenger
for i = 1:numel(ScavEncNumVec)
    x_scav(:,i) = x - AllometricStruct.Bmr12hr_p(pp) - 12*60*60*AllometricStruct.FmrJperSec_p(pp) + ...
        20000*0.1*min(AllometricStruct.ConsumedMassGmSc_r(rr)*ScavEncNumVec(i),AllometricStruct.StmGm_p(pp));
end

%set max and min bounds
x_scav(x_scav > xmax) = xmax;
x_scav(x_scav < xmin) = xmin;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%update choices for kleptoparasite
for i = 1:length(KlepEncNumVec)
    x_klep(:,i) = x - AllometricStruct.Bmr12hr_p(pp) - 12*60*60*AllometricStruct.FmrJperSec_p(pp) +...
        20000*0.1*min(AllometricStruct.ConsumedMassGm_r(rr)*KlepEncNumVec(i),AllometricStruct.StmGm_p(pp));
end

%set max and min bounds
x_klep(x_klep > xmax) = xmax;
x_klep(x_klep < xmin) = xmin;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%both x_h and x_klep have the same size, since the max possible encounters
%is dictated by the consumable mass for the behaviour, which is the same
%for hunting and stealing
[r_h,c_h] = size(x_h);  %row and column number of hunting update array (same for stealing update array)
[r_scav,c_scav] = size(x_scav); %row and column number of scavenging update array 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute fitness and decision matrices, looped over time
for t_in = length(tvec)-1:-1:1 %start at terminal time - 1 because no decisions at terminal time
    
    fx_h = zeros(size(x_h)); %corresponding computed fitnesses for updated values of each x for each number of encounters, for each behaviour
    fx_scav = zeros(size(x_scav));
    fx_klep = zeros(size(x_klep));
    MaxFitVec = zeros(size(x)); %max fitness value for each x 9used to find corresponding decisions)
    DecOpt = zeros(1,length(x) - 1); %'optimal' decision
    
    %fitness for x_h, x_klep, x_scav if they are the same values as values
    %in x (i.e., no need for interpolation)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %for hunting and kleptoparasitsm
    for i  = 1:r_h
       for j = 1:c_h
           for k  = 1:numel(x)
               if x_h(i,j) == x(k)
                    fx_h(i,j) = F(k); %this F will be recast as the T-1 time's computed max fitness and so on and so forth
               end
               if x_klep(i,j) == x(k)
                     fx_klep(i,j) = F(k);
               end
            end
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %for scaveneging
    for i  = 1:r_scav
       for j = 1:c_scav
           for k  = 1:length(x)
               if x_scav(i,j) == x(k)
                    fx_scav(i,j) = F(k);
               end
            end
        end
    end
    
    %interpolation, for updated x values that don't match values in x
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %for hunting and kleptoprasitsim
    for i  = 1:r_h
        for j = 1:c_h
           for k  = 1:length(x)-1
              if (x_h(i,j) > x(k)) && (x_h(i,j) < x(k+1))
                  fx_h(i,j) = ((1-((x_h(i,j)-x(k))/dx))*F(k))+((x_h(i,j)-x(k))/dx)*F(k+1);
              end
              if (x_klep(i,j) > x(k)) && (x_klep(i,j) < x(k+1))
                  fx_klep(i,j) = ((1-((x_klep(i,j)-x(k))/dx))*F(k))+((x_klep(i,j)-x(k))/dx)*F(k+1);
              end
           end
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %for scaveneging
    for i  = 1:r_scav
        for j = 1:c_scav
           for k  = 1:length(x)-1
              if (x_scav(i,j) > x(k)) && (x_scav(i,j) < x(k+1))
                  fx_scav(i,j) = ((1-((x_scav(i,j)-x(k))/dx))*F(k))+((x_scav(i,j)-x(k))/dx)*F(k+1);
              end
           end
        end
    end
       
    %weight with encounter proibabiities and non-mortality probability to
    %find fitness for each decision for each x(t)
    %scavenging 
    FitScavWeighted = fx_scav*transpose(ScavEncProbVec)*(1-(AllometricStruct.MuPerSec_p(pp)*60*60*24));
    
    %hunting mortality; %n encounters have n*updated mortality associated with it
    mu_h = (24*60*60 + 0.2*AllometricStruct.ThandleSec_pr(pp,rr)*HuntEncNumVec*((1 + (HuntMortScaleFactor*Mr(rr)/Mp(pp))) - 1))*AllometricStruct.MuPerSec_p(pp); 
    FitHuntWeighted = fx_h*transpose((HuntEncProbVec).*(1-mu_h));
    
    %kleptoparasitsim mortality
    mu_k = (24*60*60 + 0.1*AllometricStruct.ThandleSec_pr(pp,rr)*KlepEncNumVec*((1 + (StealMortScaleFactor*2*Mc(cc)/Mp(pp))) - 1))*AllometricStruct.MuPerSec_p(pp);
    FitKlepWeighted = fx_klep*transpose((KlepEncProbVec).*(1-mu_k));
    
    %set first fitness element to zero because zero fitness for x = 0
    FitHuntWeighted(1) = 0; FitScavWeighted(1) = 0; FitKlepWeighted(1) = 0;
    
    %choose maxi value of computed fitness values
    for i = 2:numel(FitHuntWeighted)
        [MaxFitVec(i),DecOpt(i-1)] = max([FitHuntWeighted(i),FitScavWeighted(i),FitKlepWeighted(i)]);
    end
    
    F = MaxFitVec; %recast F as new max fit vec, for teh next iteration
    FitnessCell{1,t_in} = MaxFitVec;
    DecCell{1,t_in} = DecOpt;

end

DecisionMatrix = cell2mat(transpose(DecCell)); %we need to count how many of each decisions occur
%FitnessMatrix = cell2mat(transpose(FitnessCell));

%[HuntCount,ScavCount,KlepCount] = CountNumDecisions(DecisionMatrix);
         

    
