%> @file prop_fresnel_angular_spectrum.m
%> @brief Calculation of Fresnel diffraction using convolution approach, or Angular Spectrum Propagation.
%> @author Mikhail V. Konnik
%> @date   3 August 2010
%> 
%> @section angspectrumprop Angular Spectrum Propagation
%> Angular spectrum propagation is another way to evaluate Fresnel diffraction integral: instead of use single FFT (like @ref onestepfresnel "one-step" or @ref twostepfresnel "two-step " methods), Fresnel integral may be represented as a convolution of the source-plane field with the free-space amplitude spread function. The one- and two-step propagation methods are useful for free-space propagation, while angular spectrum method is used for propagation through turbulent media.@n
%> The relations between source and observation plane is as follows:@n 
%> \f$U(x_2,y_2) = U(x_1,y_1)\otimes \left[ \frac{e^{ik\Delta z}}{i\lambda \Delta z} e^{i\frac{k}{2\Delta z}[(x_1+y_1)^2]} \right]\f$
%> 
%> Thus the propagation can be treated as a linear system with unknown impulse response (amplitude spread function). The angular spectrum propagation will be used for evaluation of multi-layered turbulent atmosphere later.
%> 
%> Define operator notations, adopted from~\cite{nazarathy1980fourier,nazarathy1982first}. Define spatial vectors \f$r_1 = x_1\hat{i}+y_1\hat{j}\f$ and \f$r_2 = x_2\hat{i}+y_2\hat{j}\f$. Define spatial-frequency vector \f$f_1 = f_{x_1}\hat{i}+f_{y_1}\hat{j}\f$, where \f$r_1\f$ is in the source plane and \f$r_2\f$ is in the observation plane. The operators' parameters are given in square brackets, and the operand is given in curly braces:@n
%> \f$\mathcal{F}[r,f] \{U(r) \} = \int\limits_{-\infty}^{+\infty} U(r)e^{-i2\pi f r} dr \f$@n
%> \f$\mathcal{F}^{-1}[f,r] \{U(f) \} = \int\limits_{-\infty}^{+\infty} U(f)e^{i2\pi f r} df \f$@n
%> Using operator notation~\cite{schmidtnumericalsimturbMatlab}, the field in observation plain can be expressed as:@n 
%> \f$U(r_2) = \mathcal{F}^{-1}[r_2,f_1] H(f_1) \mathcal{F}[f_1,r_1] \{ U(r_1)\}\f$
%> 
%> where \f$H(f_1)\f$ is the transfer function of free-space propagation given by: \f$H(f_1) = e^{ik\Delta z} e^{-i\pi \lambda\Delta z (f_{x1}^2 + f_{y1}^2)}.\f$@n
%> This equation is actually the angular spectrum form of the Fresnel diffraction integral~\cite{delenfreespecebeampropag,jaremcompmethodsOptics,lanemodelingphasescreen}. The equation of angular spectrum may be augmented by the scaling parameter \f$m = \delta_2 /\delta_1 \f$.
%> 
%> @subsection angspectralgorithm The actual algorithm of Angular Spectrum
%> In the algorithm, the main equation is actually implemented in the form of three phase factors and the resulting observation field. The quadratic phase factors are: @n
%> \f$Q_1 = \exp[\frac{ik}{2}  \frac{(1-m)}{\Delta z} r_1^2]\f$@n
%> \f$Q_2 = \exp[-\frac{i\pi^2 \cdot 2\Delta z}{mk } f_1^2]\f$@n
%> \f$Q_3 = \exp[\frac{ik}{2}  \frac{(m-1)}{m\Delta z} r_2^2]\f$@n
%> And the resulting observation field is: @n 
%> \f$U_{out} = Q_3.*\mathcal{F}^{-1} \left\{  Q_2.*\mathcal{F}\left\{  Q_1.*U_{in}/m   \right\} \right\}\f$
%> 
%> The evaluated field in observation plane is close to two-step propagation result.
% ======================================================================
%> @param Uin = input field passed through circular/rectangular aperture.
%> @param lambda = \f$\lambda\f$, optical wavelength [meters].
%> @param delta1 = \f$\delta_1 =\frac{L}{N}\f$ grid spacing  in the source plane [meters].
%> @param delta2 = \f$\delta_2 = m\cdot\delta_1 \f$ grid spacing in the observation plane  [meters].
%> @param Delta_zet = \f$\Delta z\f$ propagation distance [meters].
%> 
%> @retval Uout = propagated light field using Fresnel diffraction integral.
%> @retval x2 = observation-plane coordinate x.
%> @retval y2 = observation-plane coordinate y.
% ======================================================================
function [Uout x2 y2] = prop_fresnel_angular_spectrum(Uin, lambda, delta1, delta2, Delta_zet)

N = size(Uin,1); % assume square grid
k = 2*pi/lambda; % optical wavevector
L = N*delta1; %> total size of the grid in source/observation plane [meters]

[x1 y1] = meshgrid((-N/2:1: N/2-1)*delta1); % source-plane coordinates
r1sq = x1.^2 + y1.^2;

delta_f1 = 1/(N*delta1); %spatial frequencies in the source plane

[fX fY] = meshgrid((-N/2:1:N/2-1)*delta_f1);
f_squared = fX.^2 + fY.^2;
m = delta2/delta1; % introducing scaling parameter

[x2 y2] = meshgrid((-N/2:1:N/2-1)*delta2); % observation-plane coordinates
r2_squared = x2.^2 + y2.^2;

%%%%== Calculation of quadratic phase factors
Q1 = exp(i*k/2*(1-m)/Delta_zet*r1sq); % quadratic phase factor 1: \f$Q_1 = \exp[\frac{ik}{2}  \frac{(1-m)}{\Delta z} r_1^2]\f$
Q2 = exp(-i*pi^2*2*Delta_zet/m/k*f_squared); % quadratic phase factor 2: \f$Q_2 = \exp[-\frac{i\pi^2 \cdot 2\Delta z}{mk } f_1^2]\f$
Q3 = exp(i*k/2*(m-1)/(m*Delta_zet)*r2_squared); % quadratic phase factor 3:  \f$Q_3 = \exp[\frac{ik}{2}  \frac{(m-1)}{m\Delta z} r_2^2]\f$
%%%%== END Calculation of quadratic phase factors

temp_FFTofUim = (fftshift(fft2(fftshift(Q1.*Uin/m)))*delta1^2);
Uout = Q3.*ifftshift(ifft2(ifftshift(Q2.*temp_FFTofUim)))*(N*delta_f1)^2;%evaluation the propagated field