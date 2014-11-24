%> @file prop_sampling_grid_advisor_fresnel_onetwostep.m
%> @brief The tool for estimation of sampling and propagation requirements for multi-stage Angular Spectrum Propagation.
%> @author Mikhail Konnik
%> @date   16 July 2014
%>
%======================================================================
%> @param N = number of grid samples in one direction.
%> @param D1 = diameter of the aperture in the source plane [m].
%> @param D2 = diameter of the observation aperture [m].
%> @param Delta_z = light propagation distance.
%> @param lambda = optical wavelength [meters].
%> @param delta1 = source-plane grid spacing [m].
%> @param deltan = observation-plane grid spacing [m].
%> @param R = radius of the spherical wave (Inf if the wave is plain) [m].
%> @param nscr = proposed number of phase screens.
%>
%> @retval Delta_z_max = maximum propagation distance [m].
%> @retval n_min = minimum number of partial propagations.
% ======================================================================
function [Delta_z_max,Nmin] = prop_sampling_grid_advisor_fresnel_onetwostep(N,D1,D2,Delta_z,delta1,lambda,R)

numerical_infinity =  10^9; %% when the wavefront may be considered flat?

fprintf('\nHi, I am the Sampling Grid Advisor function for one-two step propagation.\nI will make sure you picked up correct sampling settings for optical simulations!\n');

%% Step 0: sanity check - the propagation distance must be positive.
if ((lambda*Delta_z - D2*delta1) > 0) %%% the propagation distance must be positive
    fprintf('\n0. The propagation distance is reasonable (positive).\n');
else
    error('AORTA:: The propagation distance is NEGATIVE, check Dz!'); 
end



%% Step 1: checking the sufficient propagation distance.
if (R > numerical_infinity)
    Delta_zet_trial = D1*delta1 / lambda;
else
    Delta_zet_trial = D1*delta1*R / (lambda*R - D1*delta1);
end %% if (R > numerical_infinity)


fprintf('\n1. Minimal propagation distance for the One-step propagator is %4.5f \n', Delta_zet_trial);
if (Delta_z > Delta_zet_trial)
    fprintf('     Selected propagation distance Dz=%4.5f > %4.5f \n         ==> SATISFIED, OK. \n', Delta_z,Delta_zet_trial);
    Delta_z_max = Delta_zet_trial;
else
    error('     Selected propagation distance Dz=%4.5f is TOO SHORT!\n', Delta_z);
end


%% Step 2: checking for the minimum number of grid points.
Nmin_rough = D1*lambda*Delta_z / (delta1 * (lambda*Delta_z - D2*delta1)); %% bare minimum of the grid points for the propagation.
Nmin = 2^ceil(log2(Nmin_rough));    % number of grid pts per side

fprintf('\n2. Minimum number of sampling grid points for the One-step propagator is %4.5f \n', Nmin_rough );
    fprintf('     The recommended number of grid points (closest 2^n) is N=%d \n', Nmin);












% deltan_max = -delta1.*D2/D1 + (lambda*Delta_z)/D1;
% 
% fprintf('\nHi, I am the Sampling Grid Advisor function.\nI will make sure you picked up correct sampling settings for optical simulations!\n');
% 
% % Constraint 1
% ineq1 = ( deltan <= -delta1.*D2/D1 + (lambda*Delta_z)/D1);
% if (double(ineq1) == 0)
%     fprintf('\n      The grid density in the observation plane must be at least: %3.4f, now it is only %3.4f !\n', deltan, deltan_max);
%     error('AORTA:: increase the grid density!')
% else
%     fprintf('\n      Constraint 1 is OK, the grid density in the observation plane is: %3.4f (must be denser than %3.4f)\n', deltan, deltan_max)
% end
% 
% 
% % Constraint 2
% N_min = round(D1/(2.*delta1) + D2/(2.*deltan) + (lambda*Delta_z)./(2*delta1.*deltan));
% ineq2 = (N >= D1/(2.*delta1) + D2/(2.*deltan) + (lambda*Delta_z)./(2*delta1.*deltan));
% 
% if (double(ineq2) == 0)
%     fprintf('\n      The number of grid points must be at least: %d! \n', N_min )
%     error('AORTA:: increase the number of grid points!')
% else
%     fprintf('\n      Constraint 2 is OK, the number of grid points is %d (must be more than %d)\n', N, N_min)
% end
% 
% 
% % Constraint 3
% ineq31 =  ((1 + (Delta_z/R))*delta1 - (lambda*Delta_z/D1) <= deltan);
% ineq32 =  ( deltan <= (1 + (Delta_z/R))*delta1 + (lambda*Delta_z/D1) );
% 
% if (double(ineq31)+double(ineq32) > 1)
%      fprintf('\n      Constraint 3 is OK, the observation-plane grid spacing is:  %3.4f \n', deltan);
% else
%      error('AORTA:: Constraint 3 is failed, increase the grid density in the observation plane!')        
% end %% if (check_scorecard > 1)
% 
% 
% % Checking all constraints and estimating the Max. partial propagation distance
% scorecard_angular_spectrum_sampling = double(ineq1*ineq2*ineq31*ineq32);
% 
% if (scorecard_angular_spectrum_sampling > 0)
% 
%     Delta_z_max = (min(delta1,deltan))^2 * N / lambda;   %%%% Maximum propagation distance for Angular Spectrum.
% 
%     n_min = ceil(Delta_z/Delta_z_max) + 1;  % Minimal number of partial propagations
% 
% else
%     error('AORTA::: Selected grid size / spacing is too rough for the Angular Spectrum propagation - increase Delta!')
% end %% if (scorecard_angular_spectrum_sampling > 0)
% 
% 
% if (nscr < n_min)
%     error('AORTA::: Increase the number of partial propagations nscr - must be at least %d propagations!', n_min)
% else
%     fprintf('\nAll constraints for the Multi-Step Angular Spectrum propagation are satisfied, performing:\n   %d minimum partial propagations\n   %4.3f [m] maximum partial propagation distance.\n', n_min, Delta_z_max);
%     fprintf('OK, go ahead with the N, delta1 and deltan settings that you picked up.\n');
% end %% if (nscr < n_min)
