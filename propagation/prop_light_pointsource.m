%> @file prop_light_pointsource.m
%> @brief Generate a light point sources according to a numerical model.
%>
%> @author Jason D. Schmidt, Mikhail Konnik.
%> @date   11 August 2010, reworked on 23 July 2014.
%> @todo make a point sources with selectable  location via coordinates \f$x_c\f$ and \f$y_c\f$
%>
%> @section pointsource Models of light point sources
%> Point light sources represent a considerable challenge to model. Mathematically, a point light source is represented by the Dirac delta function:
%> 
%> \f$U_{pls}(r_1) = \delta(r_1 - r_c),\f$
%> 
%> where \f$r_c = (x_c,y_c)\f$ is the location of the point source in the \f$(x_1;y_1)\f$ plane.
%> Recall that the Dirac \f$\delta\f$-function can is:
%> 
%> \f$\delta(x) = \begin{cases} +\infty, & x = 0 \\ 0, & x \ne 0 \end{cases}\f$
%> 
%> and which is also constrained to satisfy the identity
%> 
%> \f$    \int_{-\infty}^\infty \delta(x) \, dx = 1. \f$
%> 
%> However, it is not possible to simulate such a point source since it has an infinite spatial bandwidth, while most optical
%> sources are band-limited. Another problem is how to accurately sample a point source: if a propagation grid has spacing \f$\delta_1\f$ in the source plane, then the highest spatial frequency represented on that grid without aliasing is \f$\frac{1}{2\delta_1}\f$. 
%> 
%> The methods considered below use the following definitions: \f$\Delta z\f$ is the full propagation distance [m] (from the source plain to the observation plane), \f$\lambda\f$ is the observation wavelength [m], \f$D_2\f$ is the  diameter of the observation aperture [m], \f$D_1 = \frac{\lambda \Delta z}{DROI}\f$ is the diameter of source plane region of interest, where DROI stands for diameter of region of interest that is \f$DROI = k D_2\f$ (it gives the diameter of the observation-plane region of interest [m], where smaller number of \f$k\f$ results in smaller point source, and larger  number of DROI  produces larger point source). Also, in case of spherical waves, we assume that the radius of the wavefront's curvature \f$R = \Delta z\f$.
%> 
%> 
%> @subsection expexp The exp-exp model by Martin and Flatte
%> Martin and Flatt\'{e}~\cite{martinflattepointsource} and Coles~\cite{colespointsourcemodel} proposed a \textit{narrow Gaussian function with a quadratic phase} that can be used for simulations as a model of the point light source:
%> 
%> \f$U_{pt}(r_1) = A \exp \left[ -\frac{i r_1^2}{2 \sigma_{pt}^2 } \right] \cdot \exp \left[  -\left(\frac{r_1}{\beta D_1} \right)^2  \right],\f$
%> 
%> where \f$A\f$ is the amplitude, \f$D_1 = \frac{\lambda \Delta z}{DROI}\f$ is the diameter of source plane region of interest, and the parameters \f$ \sigma_{pt}\f$ and \f$\beta\f$ are equal to the grid spacing, but can be adjusted to produce any point source of desirable width. The intensity and phase of the propagated \textit{exp-exp} point source with a collimated beam (that is, remove the spherical wave component of the propagated field) is shown in Fig.~\ref{fig:point_source_expexp_observation_all}.
%> 
%> 
%> @subsection paraxialmodels Models based on the paraxial approximation
%> Considering the fact that we are interested mostly in the near-axis results, we can use the paraxial approximation of the spherical wave:
%> 
%> \f$U_s(r) = A \frac{e^{ik R(r) }}{R(r)}\f$
%> 
%> where \f$R(r) = \sqrt{ (x-x_c)^2 + (y-y_c)^2 + (z-z_c)^2 }\f$. The \textit{paraxial approximation} means that the spherical wave travels very close to the optical axis, and therefore we use the Taylor approximation: 
%> 
%> \f$R(r) \approx \Delta z \left[  1+ \frac{1}{2}\left( \frac{x-x_c}{\Delta z} \right)^2  + \frac{1}{2}\left( \frac{y-y_c}{\Delta z} \right)^2  \right]\f$
%> 
%> where \f$\Delta z = |z-z_c|\f$ and the spherical wave is:
%> 
%> \f$U_s(r) \approx  A \frac{e^{ik \Delta z }}{ \Delta z}  \exp \left[  i \frac{k}{2\Delta z} \left(  (x-x_c)^2   + (y-y_c)^2  \right) \right]\f$
%> 
%> The notion of paraxial approximation is important since it is not advisable to move the point source (it introduces an additional phase shift that can be harmful). 
%> 
%> 
%> 
%> @subsection sinsinc The sinc-sinc model
%> The model proposed in~\cite{schmidtnumericalsimturbMatlab} uses two sinc functions to generate narrow point source. For example, if a square region of width \f$D\f$ is used then windows function is the following:
%> 
%> \f$W(r_2-r_c) = A\,\, rect\left(\frac{x_2-x_c}{D_1}\right) rect\left(\frac{y_2-y_c}{D_1}\right),\f$
%> 
%> where \f$A\f$ is an amplitude factor, \f$x_c\f$ and \f$y_c\f$ are coordinates the location of the point source in the \f$(x_1;y_1)\f$ plane. 
%> 
%> 
%> The model of sinc-sinc~\cite{schmidtnumericalsimturbMatlab} point source is given by:
%> 
%> \f$U_{pt}(r_1) = \frac{A}{D_1^2} \exp \left[ -\frac{ik }{2 \Delta z} \,\,r_1^2 \right] \exp \left[ \frac{ik }{2 \Delta z}  \,\,r_c^2  \right] \exp \left[ -\frac{ik }{ \Delta z} \, r_c \,\, r_1\right] * sinc \left[ \frac{x_1 - x_c}{D_1} \right] sinc \left[ \frac{y_1 - y_c}{D_1} \right]\f$
%> 
%> where \f$r_c = (x_c, y_c)\f$ in polar coordinates, \f$\Delta z\f$ is the full propagation distance, \f$D_1 = \frac{\lambda \Delta z}{DROI}\f$ is the diameter of source plane region of interest, where DROI stands for diameter of region of interest that is \f$DROI = k D_2\f$ and \f$D_2\f$ is the  diameter of the observation aperture. 
%> 
%> The grid spacing may be set for arbitrary grid points across the central lobe. The sinc-sinc model has a drawback: an aliasing outside the region of interest occurs. The amplitude and phase in the observation plane for the sinc-sinc model is shown in Fig.~\ref{fig:point_source_sincsinc_observation_all}.
%> 
%> When the don't need to shift the point source, the expression for the sinc-sinc model is simplified:
%> 
%> \f$U_{pt}(r_1) = A \exp \left[ -\frac{ik }{2 \Delta z} \,\,r_1^2 \right] \left( \frac{D_2}{\lambda \Delta z}  \right)^2 sinc \left[ \frac{x_1 }{D_1} \right] sinc \left[ \frac{y_1 }{D_1} \right]\f$
%> 
%> However, this model suffers from aliasing, and is better to be used with the Gaussian window as \textit{sinc-gauss} model described below.
%> 
%> 
%> @subsection singauss The sinc-gauss model
%> We can combine the \textit{sinc-sinc} and \textit{Gaussian} point-source models to reduce the phase aliasing and get a \textit{sinc-gauss}~\cite{schmidtnumericalsimturbMatlab} model:
%> 
%> \f$U_{pt}(r_1) = A \exp \left[ -\frac{ik }{2 \Delta z} \,\,r_1^2 \right] \left( \frac{D_2}{\lambda \Delta z}  \right)^2 sinc \left[ \frac{x_1 }{D_1} \right] sinc \left[ \frac{y_1 }{D_1} \right] \exp \left[ - \left( \frac{r_1}{\beta D_1}\right)^2  \right]\f$
%> 
%> where \f$\Delta z\f$ is the full propagation distance, \f$D_1 = \frac{\lambda \Delta z}{DROI}\f$ is the diameter of source plane region of interest, where DROI stands for diameter of region of interest that is \f$DROI = k D_2\f$ and \f$D_2\f$ is the  diameter of the observation aperture. The latter exponential part makes the phase spectrum more narrow, which reduces aliasing and improves the accuracy of simulations, as seen in Fig.~\ref{fig:point_source_sincgauss_observation_all}.
%> 
%> Later
%> when this model is used for turbulent simulations, the parameter \f$D_2\f$ in
%> the model point source is set to be \textbf{four times larger than the observing telescope diameter}. This ensures that the turbulent fluctuations never cause the window edge to be observed by the telescope\cite{schmidtnumericalsimturbMatlab}.
%> 
%> In the sinc-Gaussian model point source, Gaussian factor reduces the side lobes in the model point source and smooths the irradiation profile in the observation-plane field.
%> 
%> The Gaussian factor reduces the side lobes in the model point source and smooths the irradiance profile in the observation-plane field. One can see in Fig.~\ref{fig:point_source_sincgauss_sincsinc_sourceplain_phase_all} that the problem with \textit{sinc-sinc} model is that the phase in the source plain does not fade to zero, unlike in the \textit{sinc-gauss} model, which has a band-limited phase profile. 
%======================================================================
%> @param N 				= number of grid samples in one direction.
%> @param Delta_zet 			= light propagation distance [meters].
%> @param delta_1 			= source-plane grid spacing [m].
%> @param lambda 			= optical wavelength [meters].
%> @param aperture_diam 		= diameter of the observation aperture, or width of central lobe [m].
%> @param point_source_model 		= choose a model of point source, valid parameters are @b 'sincsinc', @b 'sincgauss', @b 'gaussgauss'.
%> @param amplitude_attenuation_coeff 	=  Attenuation coefficient for the light intensity of the point source.
%>
%> @retval pt = matrix of size [NxN] that contains the point source of the selected model.
% ======================================================================
function pt = prop_light_pointsource(atm);

%%%#### Calculating the number of grid points
   [x1 y1] = meshgrid((-atm.nx/2:1:atm.nx/2-1)*atm.delta1);
   [theta1 r1] = cart2pol(x1, y1);
   %%%#### Calculating the number of grid points

   
%%%#### Computing the auxiliary parameters
if (isfield(atm.point_source, 'amplitude_attenuation_coeff') == 1)
    A = atm.point_source.amplitude_attenuation_coeff; %%% amplitude of the point source
else 
    Delta_zet = atm.Delta_z;
    A = atm.lambda*Delta_zet;   % sets field amplitude to 1 in obs plane
end
%%%#### Computing the auxiliary parameters



%%% <-- This is the code for the future developments - the point source that can be shifted:
% % pt_offset = [0, 0]; %%% [col_shift, row_shift] for the tool_fourier_shifter
% pt_offset = [0,0]; %%% [col_shift, row_shift] for the tool_fourier_shifter

% N_pt_offset = [60,60];
%%%% The code with the shifted centre
% N_offset = -40;
% r_c = N_offset*delta1;
% r_c = 0;

% % N_offset = 80;
% % x_c_coord = N_offset*atm.delta1;
% % x_c = x_c_coord*ones(atm.nx,atm.nx);
% % y_c = x_c;
% % [thetaC rC] = cart2pol(x_c, y_c);
%%% <-- This is the code for the future developments - the point source that can be shifted:



%% preparing the point sources for the propagation:
pt_source_sharpness = atm.point_source.pt_source_sharpness;

switch atm.point_source.model

    case 'expexpmartinflatte'

        sigma = atm.point_source.sigma;
        
        pt = A*exp(-(i*r1.^2)./(2*sigma^2))...
          .*exp(-(r1/(pt_source_sharpness*atm.D1)).^2); %% Gaussian model by Martin and Flatt\'{e}
    
    case 'sincgauss'
               
        pt = A*exp(-i*atm.k.*r1.^2 /(2*atm.R) ) / atm.D1^2  ...
            .*sinc(x1/atm.D1) .* sinc(y1/atm.D1)...
            .*exp(-(r1/(pt_source_sharpness*atm.D1)).^2);
  

	case 'sincsinc' 
% % % %           pt_source_sharpness = 1;
% % % % % %   The code with the shifted centre::
% % % %         pt = A*exp(-i*k*r1.^2/(2*R)).*exp(i*k*rC.^2/(2*R)).*exp(-i*k*rC.*r1/(R)) / D1^2 ...
% % % %             .*sinc((x1-x_c)/D1).*sinc((y1-y_c)/D1); %% sincsinc point source model by Schmidt

        pt = A*exp(-i*k.*r1.^2/(2*atm.R)) / atm.D1^2 ...
            .*sinc(x1/atm.D1).*sinc(y1/atm.D1); %% sincsinc point source model by Schmidt

    otherwise

        error('AORTA:: Wrong point_source_model parameter name - check input!')

end %% switch point_source_model


% % % % 
% % % % if (pt_offset(1)*pt_offset(2) > 1)
% % % %     pt = tool_fourier_shifter(pt, pt_offset); %%% this is to shift the point source in the Source plain.
% % % % end    