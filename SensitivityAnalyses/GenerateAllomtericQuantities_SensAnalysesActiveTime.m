function AllometricStruct = GenerateAllomtericQuantities_SensAnalysesActiveTime(Mp,Mr,Mc,ActiveTimeScaleFactor)

%generates structure containing metabolic rates, fat mass, muscle mass,
%etc. using allometric relationships, modified so that we account for a
%split of the 24-hr day that is not 12 hour rest and 12 hour active time. 
%This is relevant in computing the BMR total for the resting time.

%Inputs: Predator mass (Mp), Prey mass (Mr), and Competitior mass (Mc)

%_p indicates that is a quantity computed using teh predator mass,
%similarly, _r and _c for prey and competitor, respectively
%_pr would symbolise that teh quanity was computed using Mp and Mr, and so
%on and so forth

RestTimeScaleFactor = (abs(2 - ActiveTimeScaleFactor)); %essentially, if active time is scaled by 0.5, rest time is scaled by 1.5, etc. 

AllometricStruct.FmJ_p = 20000*1000*(AllometricFunctions('fatmass_kg', Mp)); %predator fat mass in g (converted from kg), converted to energy units (J)

AllometricStruct.Bmr12hr_p = (AllometricFunctions('bmr_Jpers', Mp))*60*60*12*RestTimeScaleFactor; %bmr (J/s) for inactive window - Mass in kg; scaled for 12 hour inactive window
%note that thsi is scaled accordingly for the active time sensitivity
%analysis by implementing the rest time scale factor
AllometricStruct.FmrJperSec_p = (AllometricFunctions('fmr_Jpers', Mp)); %Fmr in J/s - Mass in kg; for normal active times - 12 hour active window minus period of actvely pursuing and subduing prey
AllometricStruct.MmrJperSec_p = (AllometricFunctions('mmr_Jpers', Mp)); %Max metabolic rate J/s; Mass in kg; for periods of high actvity (period of actvely pursuing and subduing prey)

AllometricStruct.MuPerSec_p = (AllometricFunctions('mu_pers', Mp)); %base mortality (scaled by appropariate factors during 
                                                 %interactions with prey or competitor during hunting an dstealing); 
                                                 %in seconds; %mass in kg 

a = 2.51; %to determine linking probability between carnivore and prey; %units don't matter because ratio of masses is used
b = 0.79;
g = (-0.37);

AllometricStruct.StmGm_p = (AllometricFunctions('stm_g', Mp));%stomach size in g, mass in kg

%prey quantities (subscript r indicates prey)
AllometricStruct.ConsumedMassGm_r = 1000*(AllometricFunctions('fatmass_kg', Mr) + AllometricFunctions('musmass_kg', Mr)); %consumed mass, or mass of consumed resource = fat + muscle mass; 
                                                                                               %converted from kg to g; body mass in kg; this is for hunting and kleptoparasitsim
AllometricStruct.ConsumedMassGmSc_r = (Mr*1000) - AllometricStruct.ConsumedMassGm_r - AllometricFunctions('skeletalmass_g',Mr); 
%consumed mass for scavenger (converted to g; body mass - skeletal, fat, and muscle mass)

%lengths of predator, prey, and competitor vectors
lp = length(Mp);
lr = length(Mr);
lc = length(Mc);

AllometricStruct.ThandleSec_pr = zeros(lp,lr); %handling time for the predator to pursue, subdue, and consume prey (note that this is simply 
AllometricStruct.LinkProb_pr = zeros(lp,lr); %probabilty that a food web link exists between predator (p) and prey (r)
AllometricStruct.LinkProb_cr = zeros(lc,lr); %probabilty that a food web link exists between competitor (c) and prey (r)

%correct from mathias: predmass/preymass
for pp = 1:lp
    for rr = 1:lr
        AllometricStruct.ThandleSec_pr(pp,rr) = AllometricFunctions('thandle_s', Mp(pp), Mr(rr)); %Handling time for hunter; s
        exponent_con = a + b.*log10(Mp(pp)./Mr(rr)) + g.*(log10(Mp(pp)./Mr(rr))).^2; %there is a link probability for each predator mass
        AllometricStruct.LinkProb_pr(pp,rr) =(10.^exponent_con)/(1 + (10.^exponent_con)); %link probability for each predator for given prey
    end
end

AllometricStruct.LinkProb_cr = AllometricStruct.LinkProb_pr; %the linking prob for competitor and prey is the same as that for predator and prey, 
                   %since we are using the same mass vectors for predator and competitor
    
AllometricStruct.RhoPerm2_r = AllometricFunctions('rho_perm2_herbivores', Mr); %prey population density in per m2
AllometricStruct.RhoPerm2_c = AllometricFunctions('rho_perm2_carnivores', Mc); %competitor population density in per m2