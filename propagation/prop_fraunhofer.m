%> @file prop_fraunhofer.m
%> @brief Calculation of Fraunhofer diffraction, or Far-field approximation.
%> @author Mikhail V. Konnik
%> @date   2 August 2010
%>
%> @section farfield Fraunhofer or Far-field diffraction integral approximation
%> Fraunhofer diffraction deals with the limiting cases where the light approaching the diffracting object is parallel and monochromatic, and where the image plane is at a distance large compared to the size of the diffracting object:@n
%> \f$\Delta z > \frac{2D^2}{\lambda}\f$
%> 
%> where \f$\Delta z\f$ is the propagation distance, \f$D\f$ is the diameter of the source aperture, and \f$\lambda\f$ is the optical wavelength.
%> @image html FraunhoferDiffraction.png
%> @image latex FraunhoferDiffraction.png "Fraunhofer diffraction" width=10cm
%> 
%> Here \f$L\f$ is the total size of the grid in source/observation plane [meters], \f$D\f$ is the diameter of the aperture [meters]. Then the grid spacing is calculated: \f$\delta_1 = L / N\f$ is grid spacing in source plain [m], and \f$\delta_2 = \lambda*\Delta_{z}/(N*\delta_1)\f$  grid spacing in intermediate/observation plane (for two-step propagation) [m].
%> 
%> In this case, we can approximate the quadratic phase factor in the exponent as being flat. This is the Fraunhofer approximation, which leads to the Fraunhofer diffraction integral:@n
%> \f$U(x_2,y_2) = \frac{e^{ik\Delta z}  e^{i \frac{k}{2 \Delta z} (x_2^2+y_2^2)} }{i\lambda \Delta z} \int\limits_{-\infty}^{+\infty} \int\limits_{-\infty}^{+\infty} U(x_1,y_1) e^{-i\frac{k}{2\Delta z}(x_1x_2+y_1y_2)} dx_1 dy_1\f$
%> 
%> Fraunhofer integral can be calculated from Fourier transform using FFT that boosts simulation of the light propagation:@n
%> \f$U(x_2,y_2) = \frac{e^{ik\Delta z}  e^{i \frac{k}{2 \Delta z} (x_2^2+y_2^2)} }{i\lambda \Delta z} \cdot \mathcal{F}\{ U(x_1,y_1) \}\f$
%> 
%> The Fraunhofer diffraction integral can be used in case of Natural Guide Stars only. More general case of the diffraction is Fresnel diffraction (near-field approximation).
%======================================================================
%> @param Uin = input field passed through circular/rectangular aperture
%> @param lambda = \f$\lambda\f$, optical wavelength [meters]
%> @param delta1 = \f$\delta_1 =\frac{L}{N}\f$ grid spacing [meters]
%> @param Delta_zet = \f$\Delta z\f$ propagation distance [meters]
%> 
%> @retval Uout = propagated light field using Fraunhofer diffraction integral.
% ======================================================================
function [Uout x2 y2 ] = prop_fraunhofer(Uin, lambda, delta1, Delta_zet)

N = size(Uin,1);    %> assume square grid
k = 2*pi/lambda;     %> optical wavenumber
delta2 = (lambda*Delta_zet)/(N*delta1); %> grid  spacing in the observation plane.

% delta2 = delta1; %> grid  spacing in the observation plane.

%%%%%### Checking whenever Far-field propagation mode is appropriate for this geometry
%  if (Delta_zet < ((2*N^2)/lambda) )
%  	disp('AORTA: Selected Fraunhofer approximation is not appropriate for this geometry.');
%  	Uout=0; x2=0; y2=0; return;
%  end
%%%%%### END Checking whenever Far-field propagation mode is appropriate for this geometry

%  [x2 y2] = meshgrid(((-nx/2:1:nx/2-1)/(nx*delta1))*lambda*Delta_zet, ((-ny/2:1:ny/2-1)/(ny*delta1))*lambda*Delta_zet); % observation-plane coordinates [FOR FUTURE DEVELOPMENTS]


[x2 y2] = meshgrid((-N/2:1:N/2-1)*delta2); %>  observation-plane coordinates

Uout = (exp((i*k/(2*Delta_zet))*(x2.^2+y2.^2))/((i*lambda*Delta_zet))).*(fftshift(fft2(fftshift(Uin)))*delta1^2); %> Fraunhofer diffraction integral.