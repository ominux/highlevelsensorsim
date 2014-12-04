%> @file ccd_photosensor_darkshotnoise.m
%> @brief This routine adds dark shot noise in electrons.
%> 
%> @author Mikhail V. Konnik
%> @date   17 January 2011
%> 
%> @section darkshot Dark Shot Noise
%> The dark current shot noise can be described as:@n
%> \f$ \sigma_{D_{shot}} = \sqrt{D},\f$ @n
%> where \f$D\f$ is the average dark current: \f$D = t_I D_R\f$\cite{photontransferbook}. Here \f$D_R\f$ is the average dark current rate (measured in \f$e^-\f$/sec/pixel) and given by\cite{janesickscintificCCD}: @n
%>  \f$D_R = 2.55\cdot10^{15}P_A D_{FM} T^{1.5} \exp\left[-\frac{E_{gap}}{2\cdot k\cdot T}\right],\f$ @n
%> 
%> where:
%> - \f$P_A\f$ is the pixel's area [\f$cm^2\f$];
%> - \f$D_{FM}\f$ is the dark current figure-of-merit at 300K [nA/\f$cm^2\f$], varies significantly; with sensor manufacturer, and used in this simulations as 0.5 nA/\f$cm^2\f$;
%> -  \f$E_{gap}\f$ is the bandgap energy of the semiconductor wich also varies with temperature;
%> -  \f$k\f$ is Boltzman's constant that is \f$8.617\cdot10^{-5} [eV/K].\f$
%>
%> The relationship between band gap energy and temperature can be described by Varshni's empirical expression\cite{Pinault20011562},@n 
%> \f$E_{gap}(T)=E_{gap}(0)-\frac{\alpha T^2}{T+\beta},\f$ @n
%> where \f$E_{gap}(0)\f$, \f$\alpha\f$ and \f$\beta\f$ are material constants. The energy bandgap of semiconductors tends to decrease as the temperature is increased. This behaviour can be better understood if one considers that the interatomic spacing increases when the amplitude of the atomic vibrations increases due to the increased thermal energy. This effect is quantified by the linear expansion coefficient of a material.
%> 
%> For  Silicon (Original in Janesick book\cite{photontransferbook}): @n
%> \f$E_{gap}(0) = 1.1557 [eV]\f$ @n
%> \f$\alpha = 7.021*10^{-4}\f$ [eV/K] @n
%> \f$\beta = 1108\f$ [K] @n
%======================================================================
%> @param dark_signal 	= matrix [NxM] of dark signals that contain @b only dark current noise [e-].
%> @retval dark_signal 	= matrix [NxM] of dark signals that contain Dark shot noise [e-].
% ======================================================================
function ccd = ccd_photosensor_darkshotnoise(ccd)

%%% Since this is a dark current shot noise, it must be random every time we apply it, unlike the Fixed Pattern Noise (PRNU or DSNU).
                    rand('state', sum(100*clock));
                    randn('state', sum(100*clock));

%%% Apply the Poisson noise to the dark signal.
ccd.dark_signal = poissrnd(ccd.dark_signal); %% adding shot noise to the dark signal