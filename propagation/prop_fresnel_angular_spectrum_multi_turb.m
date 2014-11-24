%> @file prop_fresnel_angular_spectrum_multi_turb.m
%> @brief Fresnel propagator for Multi-step Angular spectrum propagation method for Turbulence.
%> @author Mikhail V. Konnik
%> @date   7 July 2014
%> 
%> @section MultiStepAngSpectrPropVac  Multi-step Angular spectrum propagation method for Turbulence.
%> The constrains on the grid size and number of points are quite strict in the Fresnel propagation geometry. More important that the number of grid point \f$N\f$ grows with the propagation distance \f$\Delta z\f$. Proposed approaches for relation of sampling constraints use apodization and attenuation of optical fields~\cite{lanemodelingphasescreen}. Main idea of partial propagations is to attenuate the field at the edges of the grid to suppress the wrap around along the path. It allows to increase the usable range of conditions for our simulation method or reduce the grid size at the cost of execution time.
%>
%> @subsection absorbingsg Apodization of the optical field using absorbing boundaries
%> The attenuation of optical field is performed by multiplication of optical filed by data window at each propagation step. The difference between data windowing and absorbing boundaries is to preserve the data in low spatial frequencies and attenuate only high-frequency data. Thus we need very broad windows like Super-Gaussian and Tukey. Super-Gaussian~\cite{supergaussfunc} function,@n
%> \f$\Omega_{sg}(x,y) = \exp \left[ -\frac{r}{\sigma} \right]^n \f$, where \f$n>2\f$,
%>
%> where the \f$\sigma\f$ is the \f$1/e\f$ radius of the function, also referred as half-widht of function. The lesser \f$n\f$, the more Super-Gaussian is looks like normal Gaussian window; greater values of \f$n\f$ make Super-Gaussian more step and rectangular.@n
%> Using those windows, it is possible to reduce aliasing and consequently relax sampling constraints in Angular Spectrum propagation geometry.
%>
%> @section angularspectrummulti Multiple Angular Spectrum Turbulent Propagation
%> The mathematical apparatus for the multiple turbulent angular spectrum propagation is the same as for Angular spectrum propagation (see @ref angspectrumprop "here") except the multiplication on turbulence power spectrum density.
%>
%> First, the input optical field \f$U_{in}\f$ is multiplied by the first quadratic phase factor: @n
%> \f$Q_1 = \exp[\frac{ik}{2}  \frac{(1-m)}{\Delta z} r_1^2]\f$
%>
%> and then multiplied by the phase screen No1. After that, the field is multiplied by second quadratic phase factor:@n
%> \f$Q_2 = \exp[-\frac{i\pi^2 \cdot 2\Delta z}{mk } f_1^2]\f$
%>
%> and then the resulting field is multiplied by absorbing boundaries such as @ref absorbingsg "SuperGaussian" window. After multiplication by SuperGaussian absorbing function, \f$U_{in}\f$ is multiplied by next turbulence layer. This is actually turbulence propagation: multiply absorbing SiperGaussian window to \f$t\f$ that is turbulence and on \f$U_{in}\f$. At the end of the for..end loop, the propagated field is multiplied by third quadratic phase factor:
%> \f$Q_3 = \exp[\frac{ik}{2}  \frac{(m-1)}{m\Delta z} r_2^2]\f$@n
%======================================================================
%> @param Uin = input field passed through circular/rectangular aperture.
%> @param lambda = \f$\lambda\f$, optical wavelength [meters].
%> @param delta_1 = \f$\delta_1 =\frac{L}{N}\f$ grid spacing  in the source plane [meters].
%> @param delta_n = \f$\delta_2 = m\cdot\delta_1 \f$ grid spacing in the observation plane  [meters].
%> @param layers_z = propagation plane locations, augmenting propagation altitudes  [meters].
%>
%> @retval Uout = the propagated field 2D, complex matrix NxN.
% ======================================================================
function [Uout, xn, yn] = prop_fresnel_angular_spectrum_multi_turb(Uin, lambda, delta1, delta_n, layers_z, t)

N = size(Uin, 1);              % number of grid points
[nx ny] = meshgrid((-N/2 : 1 : N/2 - 1));

k = 2*pi/lambda;             % optical wavevector

absorb_supergauss = prop_absorbing_window_supergaussian(N);

[m_frac,n,delta_frac,Delta_z_frac] = prop_fresnel_angular_spectrum_evaluate_fractional_delta(layers_z,delta1,delta_n);

x1 = nx * delta_frac(1);
y1 = ny * delta_frac(1);
r1sq = x1.^2 + y1.^2;

Q1 = exp(i*k/2*(1-m_frac(1))/Delta_z_frac(1)*r1sq);

Uin = Uin.*Q1.* t(:,:,1);  %% differs from Vacuum!

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
               Uin = absorb_supergauss .* t(:,:,jj+1) ...   %% differs from Vacuum!
                .* tool_ift2(Q2 ...
                .* tool_ft2(Uin / m_frac(jj), delta_frac(jj)), deltaf);
          end

% observation-plane coordinates
xn = nx*delta_frac(n);
yn = ny*delta_frac(n);
rnsq = xn.^2 + yn.^2;

Q3 = exp(i*k/2*(m_frac(n-1)-1)/(m_frac(n-1)*Z)*rnsq);

Uout = Q3.*Uin;