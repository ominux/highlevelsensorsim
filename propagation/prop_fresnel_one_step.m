%> @file prop_fresnel_one_step.m
%> @brief Calculation of one-step Fresnel diffraction.
%> @author Jason D. Schmidt
%> @date   2 August 2010
%>
%> @section onestepfresnel One-step algorithm of Fresnel integral evaluation
%> The Fresnel integral can be evaluated using the equation:@n
%> \f$U(x_2,y_2) = \frac{e^{ik\Delta z}}{i\lambda \Delta z} e^{i\frac{k}{2\Delta z} (x_2^2+y_2^2)} \int\limits_{-\infty}^{+\infty} \int\limits_{-\infty}^{+\infty} U(x_1,y_1) e^{i\frac{k}{2\Delta z}[(x_1+y_1)^2]}  e^{-i\frac{k}{\Delta z}[(x_1 x_2+y_1 y_2)]} dx_1 dy_1\f$
%>
%> to compute the observation-plane field \f$U(x_2; y_2)\f$ given the source-plane field \f$U(x_1; y_1)\f$ and the propagation geometry. The observation-plane field \f$U(x_2,y_2)\f$ is computed by:
%> - multiplying the source field by a quadratic phase,
%> - Fourier transforming (via FFT) and scaling by a constant \f$f_1 = r_2/(\lambda \Delta z)\f$
%> - multiplying by another quadratic phase factor.
%>
%> @image html FraunhoferDiffraction.png
%> @image latex FraunhoferDiffraction.png "one-step Fresnel diffraction" width=10cm
%>
%> An intuitive explanation is that propagation can be represented as an Fourier transform between confocal spheres centred at the source and observation planes. The spheres' common curvature radius is \f$\Delta z\f$. In order to evaluate the Fresnel integral using one-step algorithm, the sampled version of the source-plane optical field \f$U(x_1,y_1)\f$ is sampled with the spacing \f$\delta_1\f$. The spacing in the frequency domain is \f$\delta_{f1} = 1/(N\delta_1)\f$, so the spacing in the observation plane is \f$\delta_{2} = \frac{\lambda \Delta z}{N\delta_1}\f$
%>
%> The drawback of the one-step method is the absence of control over spacing in the observation grid without changing the geometry since fixed grid spacing in the observation plane is used.
%======================================================================
%> @param Uin = input field passed through circular/rectangular aperture
%> @param lambda = \f$\lambda\f$, optical wavelength [meters]
%> @param delta1 = \f$\delta_1 =\frac{L}{N}\f$ grid spacing [meters]
%> @param Delta_zet = \f$\Delta z\f$ propagation distance [meters]
%>
%> @retval Uout = propagated light field using Fresnel diffraction integral.
%> @retval x2 = observation-plane coordinate x.
%> @retval y2 = observation-plane coordinate y.
% ======================================================================
function [Uout x2 y2] = prop_fresnel_one_step(Uin, lambda, delta1, Delta_zet)
N = size(Uin,1);    %> assume square grid
k = 2*pi/lambda;     %> optical wavevector

delta2 = (lambda*Delta_zet)/(N*delta1); %> grid  spacing in the observation plane.

[x1 y1] = meshgrid((-N/2:1:N/2-1)*delta1); %> source-plane coordinates
[x2 y2] = meshgrid((-N/2:1:N/2-1)*delta2); %>  observation-plane coordinates

h = (1 / (i*lambda*Delta_zet))*exp(i*k/(2*Delta_zet)*(x2.^2 + y2.^2));  %%% impulse response, observation plane;

G = tool_ft2(Uin.*exp(i*k/(2*Delta_zet)*(x1.^2 + y1.^2) ), delta1);

Uout = h.*G;  %> one-step Fresnel integral evaluation.