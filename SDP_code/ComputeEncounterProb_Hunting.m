function [NumEncounter,EncounterProb] = ComputeEncounterProb_Hunting(Mp,Mr,TrialNum,ActiveTime,ProbSuccess)

%function to compute encounter probability for successful hunting encounters. Note that all input masses are in kg

%inputs: predator mass (Mp), prey mass (Mr), Number of independent trials to run to compute encounter probabilty (TrialNum),
        %Upper limite of predator's active time in hours (ActiveTime) to terminate each trial if this limit is reached, 
        %Probability that the predator is able to successfully pursue and subdue prey once encountered (ProbSuccess) 

%outputs: -NumEncounter: vector of the form 0:max number of possible successful encounters for the given predator and prey combo
         %-EncounterProb: corresponding vector of the probabiltities of n successful encounters, where n = 0:max num of possible successful encounters

Velocity_mPerSec_p = AllometricFunctions('v_mpers', Mp); %predator body velocity in m/s; %predator mass in kg
RhoPerm2_r = AllometricFunctions('rho_perm2_herbivores', Mr); %prey denisty in /m^2; prey mass in kg
RcnDist_m_p = AllometricFunctions('reactiondist_m', Mp, Mr); %Reaction distance; input masses in kg, distance in m
ExponentialParam = 1./Velocity_mPerSec_p./RcnDist_m_p./RhoPerm2_r; %parameter for exponential distribution

T = ActiveTime; %total foraging bout time (active time) in hours 

%consumed prey mass (= fat + muscle mass)
ConsumedMassKg_r = AllometricFunctions('fatmass_kg', Mr) + AllometricFunctions('musmass_kg', Mr); %consumed mass in kg

%since we have to distinguish between resource acquisition times for hunter, scavenger, and kleptoparasite, we will do the following:
%For hunting, we assume that ~20% of handling time (T_handle) is spent in pursuing and subduing prey and ~80% in actual consumption. We will use the actuall 
%prey mass to compute the pursue and subdue time (T1), and the consumable resource mass for the consumption time (T2), and add the two to get the total resource acquistion time 
T1_Hr = 0.2*AllometricFunctions('thandle_s', Mp, Mr)/60/60; %predator and prey masses in kg, time in s (converted to hr)
T2_Hr = 0.8*AllometricFunctions('thandle_s', Mp, ConsumedMassKg_r)/60/60; 
T_ResourceAcqHr_pr = T1_Hr + T2_Hr; %suffixes p and r stand for predator and prey

StmSizeKg_p = AllometricFunctions('stm_g', Mp)/1000; %stm size in kg; %predator mass in kg

MaxNumEnc = ceil(StmSizeKg_p/ConsumedMassKg_r); %max possible number of successful encounters
NumEncounter = 0:MaxNumEnc; %vector of possible number of encounters
EncounterCountTracker = zeros(size(NumEncounter)); %placeholder to track the number of occurences of each total number of successful encounters; 
% That is, if out of TrialNum total trials, there are n0 times where the number of successful encounters at the end of the foraing bout is 0, 
% n1 times where the number fo successful encounters at the end of the foraging bout is 1, and so on and so forth, this tracker would look like [n0 n1....]
% at the end of the function. Then, we will normalise this and assign this to as the probability

% %--------------------------------------------------------------------------------------------------------------------------------------
% %Lines to do a seeded random generator, for debugging, if necessary
% % s1 = RandStream('mt19937ar','Seed',1); %set a seed for exponential random draw
% % RandStream.setGlobalStream(s1);
% %--------------------------------------------------------------------------------------------------------------------------------------

for tnum = 1:TrialNum %repeat for TrialNum number of trials

    t = 0; %initialise foraging bout at t = 0 
    s = 0; %stomach content size at start is 0
        
    N_SuccessfulEnc = 0; %tracker to keep track of num of successful encounters in one foraging bout
    
    while 1 %inifinte while loop

        t = t + exprnd(ExponentialParam)/60/60; %draw time of (a potential successful) encounter from exponential distribution and convert to hours
        %Note that this is will only become a successful encounter if the predator is able to capture prey

        if t > T %check that predator is within the active time window; break if exceeded

            %find the total number of successful encounters at the end of the foraging bout, and update the corresponding counter tracker by 1
            EncounterCountTracker(NumEncounter == N_SuccessfulEnc) = EncounterCountTracker(NumEncounter == N_SuccessfulEnc) + 1;  
            break 

        else %if the foraging bout has not been exceeded, we can check if the predator is able to actually capture prey

            CoinToss = binornd(1,ProbSuccess); %coin toss for success; binomially distributed

            if CoinToss == 1 %if successful, update time elapsed in foraging bout, size of stomach contents, and the number fo successful encounters

                N_SuccessfulEnc = N_SuccessfulEnc + 1; %update number of successful encounters
                t = t + T_ResourceAcqHr_pr; %update time elapsed in the bout by adding the time spent acuiqring (Capturing and consuming resource)
                s = s + ConsumedMassKg_r; %update stimach content size

            end
        
            if (t >= T) || (s >= StmSizeKg_p) %check if time has exceeded 12 hours or is stomach content is max

                %find the total number of successful encounters at the end of the foraging bout, and update the corresponding counter tracker by 1
                EncounterCountTracker(NumEncounter == N_SuccessfulEnc) = EncounterCountTracker(NumEncounter == N_SuccessfulEnc) + 1; 
                break
                
            end

        end
    end
end

%once all trials are done, normalise count tracker and assign probability
EncounterProb = EncounterCountTracker/sum(EncounterCountTracker);



