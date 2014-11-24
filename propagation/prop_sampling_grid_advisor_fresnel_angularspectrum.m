%> @file prop_sampling_grid_advisor_fresnel_angularspectrum.m
%> @brief The tool for estimation of sampling and propagation requirements for multi-stage Angular Spectrum Propagation.
%> @author Mikhail Konnik
%> @date   16 July 2014
%>
%> @section samplingconstevalMain Sampling constraints for Multiple Partial Angular Spectrum Propagations with absorbing boundaries
%> Using those broad window functions, it is possible to reduce aliasing and consequently relax sampling constraints in Angular Spectrum propagation method. The partial propagation uses the angular spectrum propagation with the following definitions:
%> 
%> - \f$\Delta z_1\f$ is the distance between source plane and the middle plane; 
%> - \f$\Delta z_2\f$ is the distance between middle plane and the observation plane; 
%> - \f$\ alpha = \Delta z_1/\Delta z \f$ fractional distance of first propagation. 
%> 
%> With an arbitrary number of planes and repeated partial propagations, the sampling constraints are different. Rather than trying to satisfy all \f$n\f$ constraints implied by:
%> 
%> \f$N \geq \frac{\lambda \Delta z}{\delta_i \delta_{i+1}}\f$
%> 
%> we need to satisfy only the case for which the right-hand side is maximal. Let's rewrite and re-group the constraints for the partial propagations from Eq.~\ref{eq:angularspectrumsamplingconstraints} as:
%> 
%> \f$\delta_n \leq \frac{\lambda \Delta z - D_2\delta_1 }{D_1}\f$
%> 
%> \f$N \geq \frac{D_1}{2 \delta_1} + \frac{D_n}{2\delta_n} +  \frac{\lambda\Delta z}{2\delta_n\delta_1}\f$
%> 
%> \f$\left(1+\frac{\Delta z}{R} \right)\delta_1 - \frac{\lambda \Delta z}{D_1} \leq \delta_n \leq \left(1+\frac{\Delta z}{R} \right)\delta_1 + \frac{\lambda \Delta z}{D_1} \f$
%> 
%> \f$N \geq \frac{\lambda \Delta z_i}{\delta_i \delta_{i+1}}\f$
%> 
%> The size of a grid \f$N\f$ is already chosen using the first two constraints \eqref{eq:samplingconstraintsmultiprop1} and \eqref{eq:samplingconstraintsmultiprop2}, and the limit on the propagation distance \f$\Delta z\f$ can be found from a modified constraint~\eqref{eq:samplingconstraintsmultiprop4}:
%> 
%> \f$\Delta z_i \leq \frac{\min(\delta_1,\delta_2)^2 N}{\lambda}\f$
%> 
%> The right-hand side of Eq.~\ref{eq:samplingconstraintsmultiprop3_modified} is the maximum possible partial-propagation distance \f$\Delta z_{max}\f$ that can be used. Therefore, we must use at least:
%> 
%> \f$ n = ceil \left(\frac{\Delta z }{\Delta z_{max}} \right) + 1 \f$
%> 
%> partial angular spectrum propagations. The method of choosing the propagation-grid parameters for Angular Spectrum propagation is:
%> 
%> 
%> - First, select \f$N\f$, \f$\delta_1 \f$, and \f$\delta_n\f$ based on Eq.~\ref{eq:samplingconstraintsmultiprop1} and Eq.~\ref{eq:samplingconstraintsmultiprop2}:
%> 
%> \f$\delta_n \leq \frac{\lambda \Delta z - D_2\delta_1 }{D_1}\f$
%> 
%> \f$N \geq \frac{D_1}{2 \delta_1} + \frac{D_n}{2\delta_n} +  \frac{\lambda\Delta z}{2\delta_n\delta_1}\f$
%> 
%> 
%> 
%> - Then use Eq.~\ref{eq:samplingconstraintsmultiprop3}:
%> 
%> \f$\Delta z_i \leq \frac{\min(\delta_1,\delta_2)^2 N}{\lambda}\f$
%> 
%> to determine the maximum partial-propagation distance and the minimum number of partial propagations:
%> 
%> \f$ n = ceil \left(\frac{\Delta z }{\Delta z_{max}} \right) + 1 \f$
%> 
%> - Use more partial propagations; shorter partial-propagation distances still satisfy the fourth inequality.
%> 
%> 
%> 
%> @section samplingconstevalTurb Sampling constraints for Angular Spectrum Propagation in layered turbulent atmosphere
%> As light propagates through turbulence, it spreads due to tilt and higher-order aberrations. High-order aberrations cause the beam to expand beyond the spreading due to diffraction alone. Tilt causes the beam to wander off the optical axis in a random way. Beam spreading due to high-order aberrations can be seen in a short-exposure image, whereas beam spreading due to
%> tilt can only be seen in a long-exposure image.
%> 
%> This turbulence-induced beam spreading makes sampling requirements more restrictive than the vacuum constraints from Section~\ref{subsec:angularspectrumsampling}. One should also take into consideration the sampling constraints for scintillation. The scale size of scintillation is given approximately by the Fresnel length \f$\sqrt{\lambda \Delta z}\f$ (see Subsection~\ref{subsec:fresneldistance}).
%> 
%> The approach of Coy~\cite{coychoosingmeshTwostepprop} is to modify the sampling inequalities to account for turbulence-induced beam spreading as if it were caused by a diffraction grating with period equal to \f$r_0\f$.  
%> 
%> Define new limiting aperture sizes \f$D_{1,spr}\f$ and \f$D_{2,spr}\f$ due to beam spreading as:
%> 
%> \f$D_{1,spr} = D_1 + c\frac{\lambda\Delta z}{r_0}\f$
%> 
%> \f$D_{2,spr} = D_2 + c\frac{\lambda\Delta z}{r_0}\f$
%> 
%> where \f$D_{1,spr}\f$ is the width of central lobe in the source plane, and \f$D_{2,spr}\f$ diameter of the observation aperture. Here \f$r_0\f$ is the coherence diameter (Fried parameter) computed for light propagating from the observation plane to the source plane.  The parameter \f$c\f$ indicates the sensitivity of the model to the turbulence, values of \f$c\f$ range from 2 (captures about 97\% of the light) to 8 (captures all the light). Note that these equations contain the \f$c\frac{\lambda\Delta z}{r_0}\f$ that is proportional to the Fresnel length \f$\sqrt{\lambda \Delta z}\f$.
%> 
%> Now, the constraints for the turbulent propagation are the following:
%> 
%> \f$\delta_n \leq \frac{\lambda \Delta z - D_{2,spr}\delta_1 }{D_{1,spr}}\f$
%> 
%> \f$N \geq \frac{D_{1,spr}\delta_n+D_{2,spr}\delta_1+\lambda\Delta z}{2\delta_n\delta_1}\f$
%> 
%> and the last constraint is the same as in Eq.~\ref{eq:samplingconstraintsmultiprop3} adjusted accordingly:
%> 
%> \f$\left(1+\frac{\Delta z}{R} \right)\delta_1 - \frac{\lambda \Delta z}{D_{1,spr}} \leq \delta_n \leq \left(1+\frac{\Delta z}{R} \right)\delta_1 + \frac{\lambda \Delta z}{D_{1,spr}} \f$
%> 
%> After that, the values of \f$N\f$, \f$\delta_1\f$ and \f$\delta_n\f$ must be chosen. Finally, the maximum \textit{partial} propagation distances and the \textit{minimal number of partial propagations} are chosen from:
%> 
%> \f$\Delta z_{max} =  \frac{\min(\delta_1,\delta_n)^2 \cdot N}{\lambda}\f$
%> 
%> \f$n_{min} = ceil \left(\frac{\Delta z}{\Delta z_{max}}\right) +1\f$
%> 
%> for proper multilayer propagation.
%> 
%> 
%> 
%> @section physicalmeaningconstr Physical meaning of the constraints
%> 
%> Constraint~\ref{eq:turbsamplingconstraintsmultiprop1} ensures that the source-plane grid is sampled finely enough so that all
%> of the rays that land within the observation-plane region of interest are present in the source.
%> 
%> Constraint~\ref{eq:turbsamplingconstraintsmultiprop2} telling the number of grid points (after the grid density has been selected) that are needed to simulate both observation and source planes.
%> 
%> Constraint~\ref{eq:turbsamplingconstraintsmultiprop3} is to avoid the aliasing of the quadratic phase factor inside the FT of the angular-spectrum method. The physical interpretation is that the geometric beam is contained within a region of diameter \f$D_2\f$. This includes diverging source fields and converging source fields that are focused in front of and behind the observation plane.
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
function [Delta_z_max,n_min] = prop_sampling_grid_advisor_fresnel_angularspectrum(N,D1,D2,Delta_z,delta1,deltan,lambda,R,nscr)

deltan_max = -delta1.*D2/D1 + (lambda*Delta_z)/D1;

fprintf('\nHi, I am the Sampling Grid Advisor function.\nI will make sure you picked up correct sampling settings for optical simulations!\n');

% Constraint 1
ineq1 = ( deltan <= -delta1.*D2/D1 + (lambda*Delta_z)/D1);
if (double(ineq1) == 0)
    fprintf('\n      The grid density in the observation plane must be at least: %3.8f, now it is only %3.8f !\n', deltan, deltan_max);
    error('AORTA:: increase the grid density!')
else
    fprintf('\n      Constraint 1 is OK, the grid density in the observation plane is: %3.4f (must be denser than %3.4f)\n', deltan, deltan_max)
end


% Constraint 2
N_min = round(D1/(2.*delta1) + D2/(2.*deltan) + (lambda*Delta_z)./(2*delta1.*deltan));
ineq2 = (N >= D1/(2.*delta1) + D2/(2.*deltan) + (lambda*Delta_z)./(2*delta1.*deltan));

if (double(ineq2) == 0)
    fprintf('\n      The number of grid points must be at least: %d! \n', N_min )
    error('AORTA:: increase the number of grid points!')
else
    fprintf('\n      Constraint 2 is OK, the number of grid points is %d (must be more than %d)\n', N, N_min)
end


% Constraint 3
ineq31 =  ((1 + (Delta_z/R))*delta1 - (lambda*Delta_z/D1) <= deltan);
ineq32 =  ( deltan <= (1 + (Delta_z/R))*delta1 + (lambda*Delta_z/D1) );

if (double(ineq31)+double(ineq32) > 1)
     fprintf('\n      Constraint 3 is OK, the observation-plane grid spacing is:  %3.4f \n', deltan);
else
     error('AORTA:: Constraint 3 is failed, increase the grid density in the observation plane!')        
end %% if (check_scorecard > 1)


% Checking all constraints and estimating the Max. partial propagation distance
scorecard_angular_spectrum_sampling = double(ineq1*ineq2*ineq31*ineq32);

if (scorecard_angular_spectrum_sampling > 0)

    Delta_z_max = (min(delta1,deltan))^2 * N / lambda;   %%%% Maximum propagation distance for Angular Spectrum.

    n_min = ceil(Delta_z/Delta_z_max) + 1;  % Minimal number of partial propagations

else
    error('AORTA::: Selected grid size / spacing is too rough for the Angular Spectrum propagation - increase Delta!')
end %% if (scorecard_angular_spectrum_sampling > 0)


if (nscr < n_min)
    error('AORTA::: Increase the number of partial propagations nscr - must be at least %d propagations!', n_min)
else
    fprintf('\nAll constraints for the Multi-Step Angular Spectrum propagation are satisfied, performing:\n   %d minimum partial propagations\n   %4.3f [m] maximum partial propagation distance.\n', n_min, Delta_z_max);
    fprintf('OK, go ahead with the N, delta1 and deltan settings that you picked up.\n');
end %% if (nscr < n_min)
