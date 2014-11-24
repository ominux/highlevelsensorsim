%> @file prop_fresnel_angular_spectrum_multi_vacuum.m
%> @brief Fresnel propagator for Multi-step Angular spectrum propagation method in vacuum.
%> @author Mikhail V. Konnik
%> @date   7 July 2014
%> 
%> @section MultiStepAngSpectrPropVac  Multi-step Angular spectrum propagation method in vacuum
%> The problem is that the angular spectrum propagation method is better suited for propagation on short distances, as it has been already mentioned in the beginning of Subsection~\ref{subsec:validityofpropagation}.  The key difficulty is the need to  mitigate is wrap-around of frequencies in quadratic phase component caused by aliasing. The variations in the free-space transfer function (in Eq.~\ref{eq:freespacetransferfunangularspectrum}, repeated here for convenience):
%> 
%> \f$H(f_1) = e^{ik\Delta z} e^{-i\pi \lambda\Delta z (f_{x1}^2 + f_{y1}^2)},\f$
%> 
%> becomes increasingly rapid as the propagation distance \f$\Delta z\f$ increases. Therefore, wrap-around effects will creep into the centre of the grid from the edge\cite{schmidtnumericalsimturbMatlab}. 
%> 
%> A simple way to circumvent this problem is to use multiple partial propagations of the angular-spectrum method with boundary absorbing to significantly relax sampling constraints (see Subsection~\ref{subsec:validityofpropagation}). The approach is to use apodization with a certain types of windows to attenuate the optical fields~\cite{lanemodelingphasescreen}.
%> 
%======================================================================
%> @param Uin = input field passed through circular/rectangular aperture.
%> @param lambda = \f$\lambda\f$, optical wavelength [meters].
%> @param delta_1 = \f$\delta_1 =\frac{L}{N}\f$ grid spacing  in the source plane [meters].
%> @param delta_n = \f$\delta_2 = m\cdot\delta_1 \f$ grid spacing in the observation plane  [meters].
%> @param layers_z = propagation plane locations, augmenting propagation altitudes  [meters].
%>
%> @retval Uout = the propagated field 2D, complex matrix NxN.
% ======================================================================
function [Uout, xn, yn] = prop_fresnel_angular_spectrum_multi_vacuum(Uin, lambda, delta1, delta_n, layers_z)

N = size(Uin, 1);              % number of grid points
[nx ny] = meshgrid((-N/2 : 1 : N/2 - 1));

k = 2*pi/lambda;             % optical wavevector

absorb_supergauss = prop_absorbing_window_supergaussian(N);

[m_frac,n,delta_frac,Delta_z_frac] = prop_fresnel_angular_spectrum_evaluate_fractional_delta(layers_z,delta1,delta_n);

x1 = nx * delta_frac(1);
y1 = ny * delta_frac(1);
r1sq = x1.^2 + y1.^2;

Q1 = exp(i*k/2*(1-m_frac(1))/Delta_z_frac(1)*r1sq);
Uin = Uin.*Q1;

          for jj = 1:(n-1)
                % spatial frequencies (of i^th plane)
                deltaf = 1 / (N*delta_frac(jj));
                fX = nx * deltaf;
                fY = ny * deltaf;
                fsq = fX.^2 + fY.^2;
                Z = Delta_z_frac(jj); % current propagation distance

                % quadratic phase factor
                Q2 = exp(-i*pi^2*2*Z/m_frac(jj)/k*fsq);

                % compute the propagated field
               Uin = absorb_supergauss ...
                .* tool_ift2(Q2 ...
                .* tool_ft2(Uin / m_frac(jj), delta_frac(jj)), deltaf);
            
          end

% observation-plane coordinates
xn = nx*delta_frac(n);
yn = ny*delta_frac(n);
rnsq = xn.^2 + yn.^2;

Q3 = exp(i*k/2*(m_frac(n-1)-1)/(m_frac(n-1)*Z)*rnsq);

Uout = Q3.*Uin;