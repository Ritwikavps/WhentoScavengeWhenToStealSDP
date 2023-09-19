function [NumEncounter,EncounterProb] = ComputeEncounterProb_Klep(TrialNum,Mp,Mr,Mc,ActiveTime_p,ActiveTime_c,ProbSuccess_c)

%function to compute encounter probability for successful kleptoparasitic encounters. Note that all input masses are in kg

%inputs: predator mass (Mp), prey mass (Mr), competitor mass (Mc), Number of independent trials to run to compute encounter probabilty (TrialNum),
        %Upper limit of predator's active time in hours (ActiveTime_p) to terminate each trial if this limit is reached, 
        %Upper limit of competitor's active time in hours (ActiveTime_c) as input for the DrawHuntingEncTimes function, which outputs the start time of 
            %the compeitor's successful prey encounters, based on a single realisation of the search process,
        %Probability that the competitor is able to successfully pursue and subdue prey once encountered (ProbSuccess_c), also as input for the 
            %DrawHuntingEncTimes function

%outputs: -NumEncounter: vector of the form 0:max number of possible successful encounters for the given predator, competitor, and prey combo 
         %-EncounterProb: corresponding vector of the probabiltities of n successful encounters, where n = 0:max num of possible successful encounters

%--------------------------------------------------------------------------------------------------------------------------------------
%Note: This function is written with the assumption that active times for the predator and the competitor are the same. If we choose to vary it allometrically, we will 
% have to account for situations where the predator's active time limit is met before a competitor the predator has encountered successfully captures prey to provide 
% leftovers (and other similar cases, like if competitor's active time limite is less than the predator's, etc.)
%--------------------------------------------------------------------------------------------------------------------------------------

%The algorithm used is as follows:
%- Predator (P) initiates foraging bout, searching for a competitor (C)
    %-One realisation of the competitor's foraging bout for hunting for the prey in question (since we are looking at 'decisions' for the specific predator-prey-competitor
    %triad) id simulated and the times correspoding to the start of each successful competitor-prey encounters are drawn (EncounterTimes_cr)
%-Time of first P-C encounter is drawn from a exponential distribtion. Note taht this would only become a successful encounter if the predator acquires the resource from 
%this encounter. If this time is greater than the predator's activity time limt, we end the bout. In this case, the predator has not had any successful encounters in 
%the bout. Alternatively, if this time is within the activity time for the predator, we use this time relative to the EncounterTimes_cr vector to determine how the P-C
%encounter pans out. The key point here is that once the predator encounters a competitor, the predator needs to wait for a successfull competitor-prey encounter where the 
% competitor captures and subdues the prey, and then successfully steal the captured prey from the competitor before the competitor starts consuming prey. Implicit in this
% is the assumption that stealing is only viable when all prey fat and muscle mass is availble to be stolen:
    %-Case A: C has not successfully encountered prey during its bout. This means that the predator ends up waiting for a successful C-prey encounter taht never comes, 
        %and both P and C ends up not acquiring any resource in their respective bouts
    %-Case B: Competitor *does* successfuly encounter prey at least once:
        %-Case B1: P encounters C *after* the last successful C-prey hunting encounter start time
            %-Case B1a: predator encounters competitor during C's capture of prey from the last successful C-prey encounter -> that is, C has not started
                % consming the prey resource, so there is an opportunity to steal. Then, P's success in stealing is detrmined by some probability of success.
            %-Case B1b: P encounters C during C's feeding from the last C-prey encounter. P doesn't steal since stealing is not viable because not all of the 
                % prey fat and muscle mass is avaialble. Another P-C encounter time is drawn. 
            %-Case B1c: P encounters C *after* the competitor finishes feeding -> P gets nothing out of this foraging bout, because P waits for C's next 
                %successful prey encounter (which doesn;t happen) (this assumes that the P-C encounter occurs after C has left the prey carcass).
        %-Case B2: P-C encounter time < 1st C-prey encounter start time, P successfully steals with some probability.
        %-Case B3: P-C encounter is between ith and (i+1)th successful C-prey encounter start times. Basically, P-C encounters before C's first successful prey encounter 
        %& after C's last successful prey encounters are special cases. The rest can all be treated as P-C encounters berween C's ith and (i+1)th successful prey encs:
            %-Case B3a: P-C encounter is during C's capture of prey for ith C-prey encounter, P successfully teals with some probabilty 
            %-Case B3b: P-C encounter is after (i)th C-prey capture but during C's feeding, the next P-C encounter time is drawn
            %-Case B3c: P-C encounter is after ith C-prey feeding but before (i+1)th C-prey encounter. P waits till i+1)th C-prey encounters, successfully steals with some
                %probability
%-This whole process repeats till either active time limit is reached or till stomach content reach capacity

RhoPerm2_c = AllometricFunctions('rho_perm2_carnivores', Mc); %competitor density in /m^2; 
Velocity_mPerSec_p = AllometricFunctions('v_mpers', Mp); %predator body velocity in m/s; 
RcnDist_m_p = AllometricFunctions('reactiondist_m', Mp, Mc); %Reaction distance in m, for the predator wrt the competitor
ExponentialParam = 1./Velocity_mPerSec_p./RcnDist_m_p./RhoPerm2_c; %parameter for exponential distribution

T = ActiveTime_p; %total foraging bout time (active time) for the predator in hours 

%consumed prey mass (same for hunting and kleptpparasitism
ConsumedMassKg_r = AllometricFunctions('fatmass_kg', Mr) + AllometricFunctions('musmass_kg', Mr); %consumed mass in kg

%To distinguish between resource acquisition times for hunter, scavenger, and kleptoparasite, we will do the following: For a kleptoparasite, since the predator is 
%first stealing from a competitor that has captured prey and then consuming the stolen prey, we need to account for time spent in the antagonistic encounter with 
%the competitior, and for the time spent actually consuming stolen prey. We assume that the former is ~10% of the handling time (T_handle), and ~80% of T_handle goes
%towards consuming all of the prey's fat and muscle mass (i.e., 100% of the consumable mass in kleptoparasitic and hunting scenarios). We will use the actual prey mass
%to compute the time taken to steal prey (T1), and the consumable resource mass for the consumption time (T2), and add the two to get the total resource acquistion time 
T1_Hr = 0.1*AllometricFunctions('thandle_s', Mp, Mr)/60/60; %predator and prey masses in kg, time in hr
T2_Hr = 0.8*AllometricFunctions('thandle_s', Mp, ConsumedMassKg_r)/60/60; 
T_ResourceAcqHr_Klep_pr = T1_Hr + T2_Hr; %suffixes p and r stand for predator and prey

%Now, recall that the predator has to wait for the competitor to actually capture and subdue prey before stealing. 
T_HuntingCaptureHr_cr = 0.2*AllometricFunctions('thandle_s', Mc, Mr)/60/60; %sTime taken for competior to capture prey; suffixes c and r stand for predator and prey

%Thus, at the end of each successful encounter where the predator has successfully stolen prey from teh competitor and consumed said prey, the time elapsed is simply 
% the time corresponding to the start of relevant competitor-prey encounter (say, CR_EncTime) where the competitior has successfully captured prey + the time for the 
% competitor to capture prey (T_CaptureHuntingHr_cr) + the time taken for the predator to steal and consume prey (T_ResourceAcqHr_Klep_pr). Hence, we can update elapsed
% time at the end of a successful poredator-competitor encounter as CR_EncTime + T_CaptureHuntingHr_cr + T_ResourceAcqHr_Klep_pr
T_AddToUpdate_Hr = T_HuntingCaptureHr_cr + T_ResourceAcqHr_Klep_pr;

%Finally, to test for whether P-C encounter is during C's capture of prey or during C's consumption of captured prey or after C's consumption of captured prey,
%we need to know the time it takes for C to consume prey
T_HuntingConsumeHr_cr = 0.8*AllometricFunctions('thandle_s', Mc, ConsumedMassKg_r)/60/60;
T_ResourceAcqHr_cr = T_HuntingCaptureHr_cr + T_HuntingConsumeHr_cr; %time taken for competitor to capture and consume prey

StmSizeKg_p = AllometricFunctions('stm_g', Mp)/1000; %stm size in kg; %predator mass in kg

MaxNumEnc = ceil(StmSizeKg_p/ConsumedMassKg_r); %max number of successful encounters
NumEncounter = 0:MaxNumEnc;
EncounterCountTracker = zeros(size(NumEncounter));

% %--------------------------------------------------------------------------------------------------------------------------------------
% %Lines to do a seeded random generator, for debugging, if necessary
% s_seed = RandStream('mt19937ar','Seed',10); %set a seed for exponential random draw
% RandStream.setGlobalStream(s_seed);
% %--------------------------------------------------------------------------------------------------------------------------------------

for tnum = 1:TrialNum

    t_predator = 0; s_predator = 0; N_SuccessfulEnc = 0; %initialise foraging bout at time = 0 (t_predator), stomach content size at start is 0 (s_predator),
    %and initialise tracker to keep track of num of successful encounters in one foraging bout (N_SuccessfulEnc)

    while 1 %infinite while loop

        t_predator = t_predator + exprnd(ExponentialParam)/60/60; %draw encounter time for (a potentially successful) predator-competitor encounter, in hrs

        if t_predator > T %Is predator within the active time window? break if exceeded
            %find the total number of successful encounters at the end of the foraging bout, and update the corresponding counter tracker by 1
            EncounterCountTracker(NumEncounter == N_SuccessfulEnc) = EncounterCountTracker(NumEncounter == N_SuccessfulEnc) + 1;            
            break

        else %Draw competitor's successful prey encounter times for one realisation of the competitor's hunting process. 
            [EncounterTimes_cr,~] = DrawHuntingEncTimes(Mc,Mr,ActiveTime_c,ProbSuccess_c);  
           
            if ~isnan(EncounterTimes_cr(1)) %Case B: C *does* successfully encounter prey at least once (see algorithm detailed above). Find when P encounters C relative 
                %to C's successful prey encounter times. First append P's active time limit to EncounterTimes_cr. Any P-C encounter has to be before this upper limit. 
                EncounterTimes_cr = [EncounterTimes_cr ActiveTime_p];        

                for i  = 1:numel(EncounterTimes_cr) %Check if P-C encounter falls before any successful C-prey encounter  
                    if (t_predator <= EncounterTimes_cr(i)) 
                        EncounterIndex = i; %EncounterIndex tells us which competitor-prey encounter is relevant to P with respect to its encounter with C
                        break %once the first C-prey encounter that satisfies the condition is met, we break this loop
                    end
                end

                if EncounterIndex == numel(EncounterTimes_cr) %Case B1: P encounters C after the last time C successfully encounters prey

                    if t_predator <= EncounterTimes_cr(end-1) + T_HuntingCaptureHr_cr %Case B1a: P encounters C while it is viable to steal

                        CoinToss = binornd(1,min(1,Mp/Mc)); %determine probability of predator success in stealing. We use the ratio of predator to 
                        %competitor mass to determine this, capping out at 1. That is, if predator is larger than the competitor, the predator is always 
                        %successful in stealing. While this maybe overly siplistic, thsi is only one element that goes into a very complicated simulation
                        %and is unlikely to make a huge difference to results (we have done a number fo sensitivity analyses and have seen that the results don't
                        %change much with small differences in  any one element of the simulations, and it *is* reasonable to assume that predators larger 
                        %than competitores will most likely be successful in stealing)
                        if CoinToss == 1 %if successful, if successful, update time elapsed in foraging bout, size of stomach contents, num fo successful encounters
                            N_SuccessfulEnc = N_SuccessfulEnc + 1; s_predator = s_predator + ConsumedMassKg_r;
                            t_predator = EncounterTimes_cr(end - 1) + T_AddToUpdate_Hr;
                            
                            if (t_predator >= T) || (s_predator >= StmSizeKg_p)
                                EncounterCountTracker(NumEncounter == N_SuccessfulEnc) = EncounterCountTracker(NumEncounter == N_SuccessfulEnc) + 1; 
                                break
                            end
                            
                        else %if predator fails to successfully steal, add time spent waiting for competitor to capture prey to time elapsed
                            t_predator = EncounterTimes_cr(end - 1) + T_HuntingCaptureHr_cr;
                        end

                    elseif t_predator > EncounterTimes_cr(end-1) + T_ResourceAcqHr_cr %Case B1c: P-C encounter after the last P-C encounter and AFTER C has finished feeding.
                        %For Case B1b, where P-C encounter is DURIng C feeding, we don't have to do amythinh because the function will automatically pass to the next P-C encounter time draw
                        EncounterCountTracker(NumEncounter == N_SuccessfulEnc) = EncounterCountTracker(NumEncounter == N_SuccessfulEnc) + 1;
                        break
                    end
                    
                elseif EncounterIndex == 1 %Case B2: P-C encounter is before 1st successful C-prey encounter
                    CoinToss = binornd(1,min(1,Mp/Mc)); %determine probability of predator success in stealing. 
                    if CoinToss == 1 %if successful, update time elapsed in foraging bout, size of stomach contents, num fo successful encounters
                        N_SuccessfulEnc = N_SuccessfulEnc + 1; s_predator = s_predator + ConsumedMassKg_r;
                        t_predator = EncounterTimes_cr(1) + T_AddToUpdate_Hr;
                        
                        if (t_predator >= T) || (s_predator >= StmSizeKg_p)
                            EncounterCountTracker(NumEncounter == N_SuccessfulEnc) = EncounterCountTracker(NumEncounter == N_SuccessfulEnc) + 1; 
                            break
                        end
                        
                    else %if predator fails to successfully steal, add time spent waiting for competitor to capture prey to time elapsed
                        t_predator = EncounterTimes_cr(1) + T_HuntingCaptureHr_cr;
                    end

                else %Case B3: P-C encounter is between ith and i+1th C-prey encounter

                    if t_predator <= EncounterTimes_cr(EncounterIndex - 1) + T_HuntingCaptureHr_cr %Case B3a: P-C encounter occurs when stealing is viable wrt ith 
                        %successful C-prey encounter. 
                        CoinToss = binornd(1,min(1,Mp/Mc)); %determine probability of predator success in stealing. 
                        if CoinToss == 1 %if successful, update time elapsed in foraging bout, size of stomach contents, num fo successful encounters
                            N_SuccessfulEnc = N_SuccessfulEnc + 1; s_predator = s_predator + ConsumedMassKg_r;
                            t_predator = EncounterTimes_cr(EncounterIndex-1) + T_AddToUpdate_Hr;
                            
                            if (t_predator >= T) || (s_predator >= StmSizeKg_p)
                                EncounterCountTracker(NumEncounter == N_SuccessfulEnc) = EncounterCountTracker(NumEncounter == N_SuccessfulEnc) + 1; 
                                break
                            end
                            
                        else %if predator fails to successfully steal, add time spent waiting for competitor to capture prey to time elapsed
                            t_predator = EncounterTimes_cr(EncounterIndex - 1) + T_HuntingCaptureHr_cr;
                        end

                    elseif t_predator > EncounterTimes_cr(EncounterIndex-1) + T_ResourceAcqHr_cr %Case B3c: P-C encounter is before i+1th C-prey encounter, but after ith C feeding
                        %For Case B3b, where P-C encounter is DURIng C feeding, we don't have to do amythinh because the function will automatically pass to the next P-C encounter time draw
                        CoinToss = binornd(1,min(1,Mp/Mc)); %determine probability of predator success in stealing. 
                        if CoinToss == 1 %if successful, update time elapsed in foraging bout, size of stomach contents, num fo successful encounters
                            N_SuccessfulEnc = N_SuccessfulEnc + 1; s_predator = s_predator + ConsumedMassKg_r;
                            t_predator = EncounterTimes_cr(EncounterIndex) + T_AddToUpdate_Hr;
                            
                            if (t_predator >= T) || (s_predator >= StmSizeKg_p)
                                EncounterCountTracker(NumEncounter == N_SuccessfulEnc) = EncounterCountTracker(NumEncounter == N_SuccessfulEnc) + 1; 
                                break
                            end
                            
                        else %if predator fails to successfully steal, add time spent waiting for competitor to capture prey to time elapsed
                            t_predator = EncounterTimes_cr(EncounterIndex) + T_HuntingCaptureHr_cr;
                        end
                    end
                end
            else %if competitor doesn't encounter prey in 12 hours, predator loses
                EncounterCountTracker(NumEncounter == N_SuccessfulEnc) = EncounterCountTracker(NumEncounter == N_SuccessfulEnc) + 1;
                break
            end
        end
    end
end

EncounterProb = EncounterCountTracker/sum(EncounterCountTracker);


