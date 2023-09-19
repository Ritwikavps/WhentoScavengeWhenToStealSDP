function [NumEncounter,EncounterProb] = ComputeEncounterProb_Scav(TrialNum,Mp,Mr,Mc,ActiveTime_p,ActiveTime_c,ProbSuccess_c)

%function to compute encounter probability for successful scavenging encounters. Note that all input masses are in kg

%inputs: predator mass (Mp), prey mass (Mr), competitor mass (Mc), Number of independent trials to run to compute encounter probabilty (TrialNum),
        %Upper limite of predator's active time in hours (ActiveTime_p) to terminate each trial if this limit is reached, 
        %Upper limite of competitor's active time in hours (ActiveTime_c) as input for the DrawHuntingEncTimes function, which outputs the start time of 
            %the compeitor's successful prey encounters, based on a single realisation of the search process,
        %Probability that the competitor is able to successfully pursue and subdue prey once encountered (ProbSuccess_c), also as input for the 
            %DrawHuntingEncTimes function

%outputs: -NumEncounter: vector of the form 0:max number of possible successful encounters for the given predator, competitior and prey combo 
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
%this encounter. If this time is greater than the predator's activity time limte, we end the bout. In this case, the predator has not had any successful encounters in 
%the bout. Alternatively, if this time is within the activity time for the predator, we use this time relative to the EncounterTimes_cr vector to determine how the P-C
%encounter pans out. The key point here is that once the predator encounters a competitor, the predator waits for a successful competitor-prey encounter, and then consumes
%leftovers from that encounter. This gives rise to several possibilties:
    %-Case A: C has not successfully encountered prey during its bout. This means that the predator ends up waiting for a successful C-prey encounter taht never comes, 
        %and both P and C ends up not acquiring any resource in their respective bouts
    %-Case B: Competitor *does* successfuly encounter prey at least once:
        %-Case B1: P encounters C after the last successful C-prey hunting encounter start time
            %-Case B1a: P encounters C after the competitor finishes feeding -> P gets nothing out of this foraging bout, because P waits for C's next 
                %successful prey encounter (which doesn;t happen) (this assumes that the P-C encounter occurs after C has left the prey carcass).
            %-Case B1b: predator encounters competitor during C's feeding from the last successful C-prey encounter -> P gets leftovers. Here, P has to wait till 
                %C has finished eating, so the time elapsed is simply the time at which C finishes eating (which is given by C's resource acquisition time added to the 
                %start time of C's encounter with prey) + P's resource acquisition time. 
        %-Case B2: P-C encounter time < 1st C-prey encounter start time, P simply waits out C's feeding from this first successful C-prey encounter and consumes leftovers.
        %-Case B3: P-C encounter is between ith and (i+1)th successful C-prey encounter start times. Basically, P-C encounters before C's first successful prey encounter 
        %& after C's last successful prey encounters are special cases. The rest can all be treated as P-C encounters berween C's ith and (i+1)th successful prey encs:
            %-Case B3a: P-C encounter is while C is consuming resource from ith successful prey encounter. P simply waits and consumes leftovers. 
            %-Case B3b: P-C encounter is before (i+1)th C-prey encounter, but not within ith C feeding: P waits out for ith C-prey encounter and eats
%-This whole process repeats till either active time limit is reached or till stomach content reach capacity

Velocity_mPerSec_p = AllometricFunctions('v_mpers', Mp); %predator body velocity in m/s; %predator mass in kg
RhoPerm2_c = AllometricFunctions('rho_perm2_carnivores', Mc); %competitor denisty in /m^2, since the predator is encountering the competitor
RcnDist_m_p = AllometricFunctions('reactiondist_m', Mp, Mc); %Reaction distance in m, for the predator wrt the competitor
ExponentialParam = 1./Velocity_mPerSec_p./RcnDist_m_p./RhoPerm2_c; %parameter for exponential distribution

T = ActiveTime_p; %total foraging bout time (active time) for the predator in hours 

%consumed prey mass (for hunting and scavenging)
ConsumedMassKg_Hunting_r = AllometricFunctions('fatmass_kg', Mr) + AllometricFunctions('musmass_kg', Mr); %consumed mass in kg
ConsumedMassKg_Scav_r = Mr - ConsumedMassKg_Hunting_r - (AllometricFunctions('skeletalmass_g',Mr)/1000); %leftovers is mass - muscle - fat - bones - mass consumed by ss; in kg

%since we have to distinguish between resource acquisition times for hunter, scavenger, and kleptoparasite, we will do the following: For scavenging, since the 
%predator is only consuming the leftovers (prey mass minus fat, muscle, and skeletal mass), we will scale the computation of the resource acquisition time accordingly. 
%For hunting, we assumed about 80% of the handling time formula is spent in actually consuming prey and used the consumable mass for hunting to compute that 
%portion of the resource acquistiion time. Similarly, here, we use the consumable mass for scavenging to compute the relevant resource acquisition time. Since 
%scavenging does not involve capturing prey, the time spent consuming is the only time spent in acquiring the resource 
T_ResourceAcqHr_pr = 0.8*AllometricFunctions('thandle_s', Mp, ConsumedMassKg_Scav_r)/60/60;  %in hrs; %suffixes p and r stand for predator and prey

%Now, we also need to compute the time the competitor spends consuming prey fat and muscle mass. The predator may encounter the competitor at any
%point during the competitor's foraging bout, and the predator has to wait out the competitor consuming prey fat and muscle mass before getting
%to the leftovers (ie. the predator has to wait during the competitor's resource acquistion time) (more details about how this works below)
T1_Hr = 0.2*AllometricFunctions('thandle_s', Mc, Mr)/60/60; %predator and prey masses in kg, time in s (converted to hr)
T2_Hr = 0.8*AllometricFunctions('thandle_s', Mc, ConsumedMassKg_Hunting_r)/60/60; 
T_ResourceAcqHr_cr = T1_Hr + T2_Hr; %suffixes c and r stand for competitor and prey

StmSizeKg_p = AllometricFunctions('stm_g', Mp)/1000; %stm size in kg; %predator mass in kg

MaxNumEnc = ceil(StmSizeKg_p/ConsumedMassKg_Scav_r); %max possible number of successful encounters
NumEncounter = 0:MaxNumEnc; %vector of possible number of encounters
EncounterCountTracker = zeros(size(NumEncounter)); %placeholder to track the number of occurences of each total number of successful encounters; 
% That is, if out of TrialNum total trials, there are n0 times where the number of successful encounters at the end of the foraing bout is 0, 
% n1 times where the number fo successful encounters at the end of the foraging bout is 1, and so on and so forth, this tracker would look like [n0 n1....]
% at the end of the function. Then, we will normalise this and assign this to as the probability

% %--------------------------------------------------------------------------------------------------------------------------------------
% %Lines to do a seeded random generator, for debugging, if necessary
% s1 = RandStream('mt19937ar','Seed',1); %set a seed for exponential random draw
% RandStream.setGlobalStream(s1);
% %--------------------------------------------------------------------------------------------------------------------------------------

for tnum = 1:TrialNum %repeat for TrialNum number of trials

    t_predator = 0; s_predator = 0; N_SuccessfulEnc = 0; %initialise foraging bout at time = 0 (t_predator), stomach content size at start is 0 (s_predator),
    %and initialise tracker to keep track of num of successful encounters in one foraging bout (N_SuccessfulEnc)

    while 1 %infinite while loop

        t_predator = t_predator + exprnd(ExponentialParam)/60/60; %draw time of (a potential successful) encounter from exponential distribution and convert to hours
        %Note that here, the encounter time is for the predator encountering the competitor

        if t_predator > T %Is predator within the active time window? break if exceeded
            %find the total number of successful encounters at the end of the foraging bout, and update the corresponding counter tracker by 1
            EncounterCountTracker(NumEncounter == N_SuccessfulEnc) = EncounterCountTracker(NumEncounter == N_SuccessfulEnc) + 1;         
            break

        else %Draw competitor's successful prey encounter times for one realisation of the competitor's hunting process. 
            [EncounterTimes_cr,~] = DrawHuntingEncTimes(Mc,Mr,ActiveTime_c,ProbSuccess_c); 

            if ~isnan(EncounterTimes_cr(1)) %Case B: C *does successfully encounter prey at least once (see algorithm detailed above). Find when P encounters C relative 
                %to C's successful prey encounter times. First append P's active time limit to EncounterTimes_cr. Any P-C encounter has to be before this upper limit. 
                EncounterTimes_cr = [EncounterTimes_cr ActiveTime_p];

                for i  = 1:numel(EncounterTimes_cr) %Check if P-C encounter falls before any successful C-prey encounter 
                    if (t_predator <= EncounterTimes_cr(i)) 
                        EncounterIndex = i; %EncounterIndex tells us which competitor-prey encounter is relevant to P with respect to its encounter with C
                        break %once the first C-prey encounter that satisfies the condition is met, we break this loop
                    end
                end
                
                if EncounterIndex == numel(EncounterTimes_cr) %Case B1: P encounters C after the last time C successfully encounters prey
                    
                    if t_predator > EncounterTimes_cr(end-1) + T_ResourceAcqHr_cr %Case B1a: P encounters after C is done feeding-> update tracker and break
                        EncounterCountTracker(NumEncounter == N_SuccessfulEnc) = EncounterCountTracker(NumEncounter == N_SuccessfulEnc) + 1; 
                        break

                    else %Case B1b: P-C encounter occurs while C is consuming the resource, P gets leftovers; update stomach content, number of successful enc
                        N_SuccessfulEnc = N_SuccessfulEnc + 1; s_predator = s_predator + ConsumedMassKg_Scav_r;
                        t_predator = EncounterTimes_cr(end-1) + T_ResourceAcqHr_cr + T_ResourceAcqHr_pr; %Update elapsed time. We use (end-1) because we have appended 
                        %EncounterTimes_cr with P's active time limit

                        if (t_predator > T) || (s_predator > StmSizeKg_p) %do checks and update
                            EncounterCountTracker(NumEncounter == N_SuccessfulEnc) = EncounterCountTracker(NumEncounter == N_SuccessfulEnc) + 1;  
                            break
                        end
                    end

                elseif EncounterIndex == 1 %Case B2: P encounters C before the first time C successfully encounters prey. 
                    N_SuccessfulEnc = N_SuccessfulEnc + 1; s_predator = s_predator + ConsumedMassKg_Scav_r;
                    t_predator = EncounterTimes_cr(1) + T_ResourceAcqHr_cr + T_ResourceAcqHr_pr;

                    if (t_predator > T) || (s_predator > StmSizeKg_p) %do stomach content and time elapsed checks
                        EncounterCountTracker(NumEncounter == N_SuccessfulEnc) = EncounterCountTracker(NumEncounter == N_SuccessfulEnc) + 1; 
                        break
                    end

                else %Case B3: P-C encounter is between ith and (i+1)th successful competitor-prey encounter.

                    if t_predator < EncounterTimes_cr(EncounterIndex - 1) + T_ResourceAcqHr_cr %case B3a: P-C encounter is while C is consuming resource from ith 
                        % successful prey encounter. Update time elapsed. We can update the other things at the end of the else condition this if..else is nested within, 
                        %since if the simulation enters the encompasing else statement that checkls if P-C encounter is between C's ith and i+1th prey encounter, 
                        % P can wait and consume leftovers for either case. 
                        t_predator = EncounterTimes_cr(EncounterIndex - 1) + T_ResourceAcqHr_cr + T_ResourceAcqHr_pr;

                    else %case B3b: P-C encounter is before (i+1)th competitor-prey encounter, but not within ith C feeding: P waits out for ith competitor-prey encounter 
                        %and eats
                        t_predator = EncounterTimes_cr(EncounterIndex) + T_ResourceAcqHr_cr + T_ResourceAcqHr_pr;
                    end

                    N_SuccessfulEnc = N_SuccessfulEnc + 1; s_predator = s_predator + ConsumedMassKg_Scav_r; %update stimach content and number of successful encounters

                    if (t_predator > T) || (s_predator > StmSizeKg_p) %do checks
                        EncounterCountTracker(NumEncounter == N_SuccessfulEnc) = EncounterCountTracker(NumEncounter == N_SuccessfulEnc) + 1;  
                        break
                    end
                end

            else %Case A: if C doesn't encounter prey in 12 hours, P doesn't have any successful encounter in this foraging bout. Update accordingly
                EncounterCountTracker(NumEncounter == N_SuccessfulEnc) = EncounterCountTracker(NumEncounter == N_SuccessfulEnc) + 1; 
                break
            end
        end
    end
end

%once all trials are done, normalise count tracker and assign probability
EncounterProb = EncounterCountTracker/sum(EncounterCountTracker);


