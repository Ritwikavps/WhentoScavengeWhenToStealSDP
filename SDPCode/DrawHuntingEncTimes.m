function [EncounterTimes,N_SuccessfullEnc] = DrawHuntingEncTimes(Mp,Mr,ActiveTime,ProbSuccess)

%function to draw the number (N_SuccessfulEnc, double) and start times (EncounterTimes, vector) of successful encounters for
%a predator engaged in hunting for one instance of a foraging bout

%inputs: predator mass (Mp, kg), prey mass (Mr, kg), Upper limit of predator's active time in hours (ActiveTime) to terminate each trial if this limit is reached, 
        %Probability that the predator is able to successfully pursue and subdue prey once encountered (ProbSuccess) 

%outputs: -N_SuccessfullEnc: Total number of successful encounters in the bout
         %-EncounerTimes: start times of each successful encounter, where the first element in the vector corresponds to the first
             %successful encounter in the bout, the second elemenet corresponds to teh second successful encounter in the bout and so on and so
             %forth, and the last element corresponds to the start time of the N_SuccessfullEnd-th successful encounter in the bout

Velocity_mPerSec_p = AllometricFunctions('v_mpers', Mp); %predator body velocity in m/s; %predator mass in kg
RhoPerm2_r = AllometricFunctions('rho_perm2_herbivores', Mr); %prey denisty in /m^2; prey mass in kg
RcnDist_m_p = AllometricFunctions('reactiondist_m', Mp, Mr); %Reaction distance; input masses in kg, distance in m
ExponentialParam = 1./Velocity_mPerSec_p./RcnDist_m_p./RhoPerm2_r; %parameter for exponential distribution

T = ActiveTime; %total foraging bout time (active time) in hours

ConsumedMassKg_r = AllometricFunctions('fatmass_kg', Mr) + AllometricFunctions('musmass_kg', Mr); %consumed prey mass in kg

%since we have to distinguish between resource acquisition times for hunter, scavenger, and kleptoparasite, we will do the following:
%For hunting, we assume that ~20% of handling time (T_handle) is spent in pursuing and subduing prey and ~80% in actual consumption. We will use the actuall 
%prey mass to compute the pursue and subdue time (T1), and the consumable resource mass for the consumption time (T2), and add the two to get the total resource acquistion time 
T1_Hr = 0.2*AllometricFunctions('thandle_s', Mp, Mr)/60/60; %predator and prey masses in kg, time in s (converted to hr)
T2_Hr = 0.8*AllometricFunctions('thandle_s', Mp, ConsumedMassKg_r)/60/60; 
T_ResourceAcqHr_pr = T1_Hr + T2_Hr; %suffixes p and r stand for predator and prey

StmSizeKg_p = AllometricFunctions('stm_g', Mp)/1000; %stm size in kg; %predator mass in kg

% %--------------------------------------------------------------------------------------------------------------------------------------
% %Lines to do a seeded random generator, for debugging, if necessary
% s1 = RandStream('mt19937ar','Seed',1); %set a seed for exponential random draw
% RandStream.setGlobalStream(s1);
% %--------------------------------------------------------------------------------------------------------------------------------------

t = 0; %initialise foraging bout at t = 0 
s = 0; %stomach content size at start is 0
    
N_SuccessfullEnc = 0; %tracker to keep track of num of successful encounters in one foraging bout
EncounterTimes = NaN; %initialise EncounterTimes as NaN; if there are no encounters, then the output for this would be NaN
%If there are encountersm this gets updated as a vector

while 1 %inifinte while loop

    t = t + exprnd(ExponentialParam)/60/60; %draw time of (a potential successful) encounter from exponential distribution and convert to hours
    %Note that this is will only become a successful encounter if the predator is able to capture prey
    
    if t > T %check that predator is within the active time window; break if exceeded

        break 

    else %if the foraging bout has not been exceeded, we can check if the predator is able to actually capture prey 

        CoinToss = binornd(1,ProbSuccess); %coin toss for success; binomially distributed

        if CoinToss == 1 %if successful, update time elapsed in foraging bout, size of stomach contents, number fo successful encounters, and the time
            %of the start of the current successful encounter

           N_SuccessfullEnc = N_SuccessfullEnc + 1; %update number of successful encounters
           EncounterTimes(N_SuccessfullEnc) = t; %update EncounterTimes vector
           t = t + T_ResourceAcqHr_pr;  %updated elapsed time
           s = s + ConsumedMassKg_r; %update stomach content size

        end
        
        if (t >= T) || (s >= StmSizeKg_p) %check if time has exceeded 12 hours

            break %if yes, break

        end
    end
end



