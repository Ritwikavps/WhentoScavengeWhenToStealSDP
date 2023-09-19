%Ritwika VPS
%UC Merced, Oct 2019

%updated Feb 2022

%This function with nested sub-functions inside has all the functions
%reuiqred to generate allomteric scaling relationships used in the model

function varargout = AllometricFunctions(varargin) %master function to define all allometric variables
   [varargout{1:nargout}] = feval(varargin{:});
end

function [fm] = fatmass_kg(M) %fat mass in kg; M in kg; fm = fat mass fraction * body mass
    fm = M.*(0.075.*M.^(0.19));
end

function [mm] = musmass_kg(M) %muscle mass in kg; M in kg; mm = muscle mass fraction * body mass
    mm = 0.383*M;
end

function [sm] = skeletalmass_g(M) %skeletal mass in g; mass in kg
    sm = M.*(0.061*(M.^0.090)); 
    sm = sm/0.75; %the allometric relationship is for dry skeleton and dry is approx 75% of wet.
    sm = sm*1000; %converts to g
end

function [bmr] = bmr_Jpers(M) %BMR in j/s; body mass in kg
    bmr = 3.20*(M.^0.75); 
end

function [fmr] = fmr_Jpers(M) %FMR in j/s; body mass in kg 
    fmr = 8.36*(M.^0.75);
end

function [mmr] = mmr_Jpers(M) %MMR in j/s; mass in kg 
    mmr = 39.597*(M.^0.872);
end

function [v] = v_mpers(M) %body velocity in m/s; mass in kg
    v = 0.33*(M.^0.21);
end

function [d] = reactiondist_m(M,Mr) %reaction distance in m; masses in kg
    d = 1.62*((M.*Mr).^0.21);
end

function [thandle] = thandle_s(M,Mr) %handling time in s; masses in kg
    thandle = 8912.*Mr.*(M.^(-1.02));
end

function [stms] = stm_g(M) %stomach size in g (converted from kg); mass in kg
    stms = 1000*0.107*(M.^1.062);
end

function [mss] = mu_pers(M) %baseline mortality in per s; mass in kg
    mss = 2.3*(10^(-9))*(M.^(-0.24));
end

function [rho_herb] = rho_perm2_herbivores(M)  %herbivore (preimary consumers) density in perm2; mass is in kg; Damuth ref in paper 
    rho_herb = (91.20)*(M.^(-0.73));
    rho_herb = rho_herb./1000000; %convert to per m2
end

function [rho_carn] = rho_perm2_carnivores(M)  %secondary consumers (vertebrate-consumers) in perm2; mass is in kg; Damuth ref in paper 
    rho_carn = (3.89)*(M.^(-0.96));
    rho_carn = rho_carn./1000000;
end




