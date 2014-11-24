%> @file prop_fresnel_two_step.m
%> @brief Calculation of two-step Fresnel diffraction with varying grids.
%> @author Jason D. Schmidt
%> @date   2 August 2010
%> 
%> @section twostepfresnel Two-step algorithm of Fresnel integral evaluation. 
%> In order overcome fixed grid spacing in the one-step propagation method (implemented in tool_fresnel_one_step_propagation.m), a more flexible two-step Fresnel propagation method was presented~\cite{coychoosingmeshTwostepprop,RydbergTwoStepPropagFresnel} that allows selecting the grids spacings~\cite{coychoosingmeshTwostepprop}. In this method, \f$U(x_1 , y_1 )\f$ propagates from the source plane at \f$z_1\f$ to an intermediate plane located at \f$z_{1a}\f$ and then propagates to the observation plane at \f$z_2\f$. Hence one can choose \f$z_{1a}\f$ such that \f$m\f$ (or, equivalently  \f$\delta_2\f$) has the desired value. The propagation geometries are presented in the Figure below.
%> @image html FresnelGeometryofPropagation.png
%> @image latex FresnelGeometryofPropagation.png "Propagation geometry" width=10cm
%> 
%> The source plane is at \f$z= z_1\f$, and the observation plane is at \f$z = z_2\f$ with \f$\Delta z = z_2 - z_1\f$, and scaling parameter of \f$m = \delta_2 /\delta_1 \f$. Define the intermediate plane at \f$z = z_{1a}\f$ with coordinates \f$(x_{1a} , y_{1a})\f$ coordinates] such that the distance of the first propagation is \f$\Delta z_1 = z_{1a} - z_1\f$ and the distance of the second is \f$\Delta z_2 = z_2 - z_{1a}\f$. Hence a choice of \f$m\f$, which directly sets the sizes of the grids, defines the location of the intermediate plane: @n
%> \f$ m = \frac{\Delta z_2}{\Delta z_1}.\f$
%> 
%> If we examine the spacings \f$\delta_{1a}\f$ in the intermediate plane and \f$\delta_2\f$ in the observation plane, we can express~\cite{schmidtnumericalsimturbMatlab} both spacings via \f$\delta_1\f$:@n
%> \f$\delta_{1a} = \frac{\lambda |\Delta z_1|}{N \delta_1}\f$
%> 
%> and @n 
%> \f$\delta_{2} = \frac{\lambda |\Delta z_2|}{N \delta_{1a}} = \dots = m\delta_1\f$.
%> 
%> There must be a trade-off between the source and observation grids: a finer source grid produces a coarser observation grid and vice-versa.
%======================================================================
%> @param Uin = input field passed through circular/rectangular aperture
%> @param lambda = \f$\lambda\f$, optical wavelength [meters]
%> @param delta1 = \f$\delta_1 =\frac{L}{N}\f$ grid spacing in source plain [meters]
%> @param delta2 = \f$\delta_{2} = \frac{\lambda \Delta z}{N\delta_1}\f$ grid spacing in observation plane [meters]
%> @param Delta_zet = \f$\Delta z\f$ propagation distance [meters]
%> 
%> @retval x2 = observation-plane coordinate x.
%> @retval y2 = observation-plane coordinate y.
%> @retval Uout = propagated light field using Fresnel diffraction integral.
% ======================================================================
function [Uout x2 y2] = prop_fresnel_two_step(Uin,lambda,delta1,delta2,Delta_zet)

N = size(Uin, 1); %> number of grid points.
k = 2*pi/lambda; %> optical wavevector.
L = N*delta1; %> total size of the grid in source/observation plane [meters]
aperture_size=0; %> change this if you have real aperture; required for correct estimation of grid size.
m = delta2/delta1; %> scaling parameter; a choice of \f$m\f$, which directly sets the sizes of the grids, defines the location of the intermediate plane \f$m = \frac{\Delta z_2}{\Delta z_1}\f$.

[x1 y1] = meshgrid((-N/2:1:N/2-1)*delta1); %> source-plane coordinates.


%%%%### Section: Propagation of Light in Intermediate plane.
Delta_zet1 = Delta_zet/(1 - m); % propagation distance.
delta1a = lambda * abs(Delta_zet1)/(N * delta1); % grid space in intermediate plane.

[x1a y1a] = meshgrid((-N/2:1:N/2-1)*delta1a); % coordinates in intermediate plane.

Uitm = 1 / (i*lambda*Delta_zet1).* exp(i*k/(2*Delta_zet1) * (x1a.^2+y1a.^2)).*(fftshift(fft2(fftshift( Uin.*exp(i*k/(2*Delta_zet1)*(x1.^2 + y1.^2)) ) ))*delta1^2); %> evaluate the Fresnel-Kirchhoff integral at intermediate plane
%%%%### END Section: Propagation of Light in Intermediate plane.



%%%%### Section: Propagation of Light in observation plane
Delta_zet2 = Delta_zet-Delta_zet1; %> propagation distance

[x2 y2] = meshgrid((-N/2:1:N/2-1)*delta2); %> coordinates in observation plane

Uout = 1 / (i*lambda*Delta_zet2).* exp(i*k/(2*Delta_zet2) * (x2.^2+y2.^2)).*(fftshift(fft2(fftshift( Uitm .* exp(i * k/(2*Delta_zet2)*(x1a.^2 + y1a.^2)) )  ))*delta1a^2); %> evaluate the Fresnel diffraction integral
%%%%### END Section: Propagation of Light in observation plane