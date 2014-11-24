%> @file prop_propagator.m
%> @brief Evaluation of propagation in turbulent media. The purpose of this routine is to use Angular Spectrum propagation by caching everything we can.
%> @author Jason D. Schmidt, Mikhail Konnik.
%> @date   13 August 2010, re-written 1 August 2014.
%>
%======================================================================
%> @param N = number of grid samples in one direction; should be the nearest power of 2 and larger than 2*D/r0.
%> @param lgs = laser guide star (LGS) structure with LGS parameters
%> @param lambda = wavelenght in meters.
%> @param averaging_of_propagation = how many timis the averaging accurs [usually 1].
%> @param D2 = Telescope's diameter [meters].
%> @param point_source_model = Guide stars parameters - model of the light point source, valid are 'sincsinc', 'sincgauss', 'gaussgauss'.
%> @param turb_layers_number = amount of turbulent layers of the atmosphere [2 and more].
%> @param phazescreens = calculated distribution of phase [cell array of layers].
%> @param z = propagation distance [meters]
%> @param N_source =  grid points in Star (source) plain::: a) small number = narrow point source, b) large number = broader point source,
%> @param DROI = diam of obs-plane region of interest [m] :: a) lesser number in front of DROI -> larger D1 = 0.0112, smaller point source b) bigger number -> smaller D1 = 0.0028, larger point source
%> @param amplitude_attenuation_coeff 	=  Attenuation coefficient for the light intensity of the point source.
%>
%> @retval Uout = propagated light field using Fresnel diffraction integral.
% ======================================================================
function [Uout, atm] = prop_propagator(pt,atm)


if isfield(atm, 'cache2accelerate') == 0
    [nx ny] = meshgrid((-atm.nx/2 : 1 : atm.nx/2 - 1));
    atm.cache2accelerate.nx = nx;
    atm.cache2accelerate.ny = ny;
    
    atm.cache2accelerate.absorb_supergauss = prop_absorbing_window_supergaussian(atm.nx);
end


[m_frac,n,delta_frac,Delta_z_frac] = prop_fresnel_angular_spectrum_evaluate_fractional_delta(atm.z, atm.delta1, atm.deltan);


if isfield(atm.cache2accelerate, 'r1sq') == 0
x1 = nx * delta_frac(1);
y1 = ny * delta_frac(1);
atm.cache2accelerate.r1sq = x1.^2 + y1.^2;

atm.cache2accelerate.Q1 = exp(i*atm.k/2*(1-m_frac(1))/Delta_z_frac(1)*atm.cache2accelerate.r1sq);
end


Uin = pt.*(atm.cache2accelerate.Q1).*exp( i*atm.phase_screens(:,:,1) );  %% differs from Vacuum!


          for jj = 1:(n-1) %%% begin propagating the light field through the turbulent layers

                deltaf = 1 / (atm.nx*delta_frac(jj));

              if (isfield(atm.cache2accelerate,'Q2_isfull') == 0)
                % spatial frequencies (of i^th plane)
                fX = atm.cache2accelerate.nx * deltaf;
                fY = atm.cache2accelerate.ny * deltaf;
                fsq = fX.^2 + fY.^2;

                % quadratic phase factor
                atm.cache2accelerate.Q2(:,:,jj) = exp(-i*pi^2*2*Delta_z_frac(jj)/m_frac(jj)/atm.k*fsq);
              end %%% if (isfiled(atm.cache2accelerate,'Q2_isfull')

                % compute the propagated field
               Uin = atm.cache2accelerate.absorb_supergauss .*exp( i*atm.phase_screens(:,:,jj+1) )...   %% differs from Vacuum!
                .* tool_ift2(atm.cache2accelerate.Q2(:,:,jj) ...
                .* tool_ft2(Uin / m_frac(jj), delta_frac(jj)), deltaf);
            
          end %% for jj = 1:(n-1) %%% begin propagating
          
%%% this is to prevent the Q2 to be recalculated - a simple flag
atm.cache2accelerate.Q2_isfull = 1;
          
% observation-plane coordinates
if isfield(atm.cache2accelerate, 'rnsq') == 0
xn = atm.cache2accelerate.nx*delta_frac(n);
yn = atm.cache2accelerate.ny*delta_frac(n);
atm.cache2accelerate.rnsq = xn.^2 + yn.^2;

atm.cache2accelerate.Q3 = exp(i*atm.k/2*(m_frac(n-1)-1)/(m_frac(n-1)*Delta_z_frac(n-1))*(atm.cache2accelerate.rnsq));
end

Uout = atm.cache2accelerate.Q3.*Uin;

Uout = Uout.*exp(-i*pi/(atm.lambda*atm.R)*( atm.cache2accelerate.rnsq )); % collimate the beam