%> @file ccd_photosensor_darknoises.m
%> @brief This routine for adding dark current noises that consist of Dark FPN and Dark shot noise.
%> 
%> @author Mikhail V. Konnik
%> @date   17 January 2011, reworked on 5 December 2014.
%> 
%> @section readnoise Dark signal in solid-state photosensors
%> The dark signal is calculated for all pixels in the model. It is implemented using @b ones function in MATLAB as a matrix of the same size as the simulated photosensor. For each \f$(i,j)\f$-th pixel we have:
%> 
%> \f$I_{dc.e^-} = t_I\cdot D_R, \f$
%> 
%> where \f$D_R\f$ is the average dark current: 
%> 
%> \f$D_R = 2.55\cdot10^{15}P_A D_{FM} T^{1.5} \exp\left[-\frac{E_{gap}}{2\cdot k\cdot T}\right],\f$ @n
%> 
%> where:
%>  - \f$P_A\f$ is the pixel's area [\f$cm^2\f$];
%>  - \f$D_{FM}\f$ is the dark current figure-of-merit at 300K [nA/\f$cm^2\f$], varies significantly; with sensor manufacturer, and used in this simulations as 0.5 nA/\f$cm^2\f$;
%>  -  \f$E_{gap}\f$ is the bandgap energy of the semiconductor which also varies with temperature;
%>  -  \f$k\f$ is Boltzman's constant that is \f$8.617\cdot10^{-5} [eV/K].\f$
%> 
%> The relationship between band gap energy and temperature can be described by Varshni's empirical expression, @n 
%> \f$E_{gap}(T)=E_{gap}(0)-\frac{\alpha T^2}{T+\beta},\f$ @n
%> where \f$E_{gap}(0)\f$, \f$\alpha\f$ and \f$\beta\f$ are material constants. The energy bandgap of semiconductors tends to decrease as the temperature is increased. This behaviour can be better understood if one considers that the inter-atomic spacing increases when the amplitude of the atomic vibrations increases due to the increased thermal energy. This effect is quantified by the linear expansion coefficient of a material.
%> 
%> For the Silicon: @n
%>  - \f$E_{gap}(0) = 1.1557 [eV]\f$ @n
%>  - \f$\alpha = 7.021*10^{-4}\f$ [eV/K] @n
%>  - \f$\beta = 1108\f$ [K] @n
%> 
%======================================================================
%> @param ccd 		= structure of signal without dark current noises.
%> @retval ccd 		= structure of signal WITH added Dark shot noise and dark FPN.
% ======================================================================
function ccd = ccd_photosensor_darknoises(ccd)


%%%%% <----- ### Start:: Dark current generation
PA = ccd.pixel_size(1)*ccd.pixel_size(1)*10^(4); %% translating the size to square sentimeters, as in Janesick book.

ccd.Eg = ccd.Eg_0 - ( ccd.alpha*(ccd.T^2) )/(ccd.beta + ccd.T);  %% silicon band gap energy, [eV];

ccd.DARK_e = (ccd.t_I)*2.55*10^(15)*PA*ccd.DFM*(ccd.T^(1.5))*exp(-ccd.Eg/(2*ccd.Boltzman_Constant*ccd.T)); %% average amount of dark current that is thermally generated [e]  !!! This ccd.DARK_e is that for equation 11.15 for Janesick D = t_I*D_R

ccd.dark_signal = (ccd.DARK_e).*ones(size(ccd.Signal_CCD_electrons)); %% creating the matrix of dark signal of electrons.
%%%%% <----- ### END:: Dark current generation 



%%%%% <----- ### Start:: adding Dark Shot noise
if (ccd.flag.darkcurrent_Dshot == 1)
	ccd = ccd_photosensor_darkshotnoise(ccd);
end
%%%%% <----- ### END:: adding Dark Shot noise



%%%%% <----- ### Start:: adding Dark FPN  %%% being added to dark current, it is too small.
if (ccd.flag.darkcurrent_DarkFPN_pixel == 1)
    ccd = ccd_photosensor_darkFPN(ccd);
end
%%%%% <----- ### END:: adding Dark FPN  %%% being added to dark current, it is too small.



%%%%% <----- ### Start:: adding the Source follower noise in electrons.
if ( isfield(ccd.flag,'sourcefollowernoise') == 0 ) %% Just in case - if the field ccd.flag.sourcefollowernoise does NOT exist, make it zero to prevent the code from crashing.
    ccd.flag.sourcefollowernoise = 0;
end

if (ccd.flag.sourcefollowernoise == 1)

    ccd = ccd_source_follower_noise(ccd); %% caclulation of the source follower noise sigma_FS.
    
    %%% ranomising the state of the noise generators
                    rand('state', sum(100*clock));
                    randn('state', sum(100*clock));
                    
    ccd.dark_signal = ccd.dark_signal + (ccd.noise.sf.sigma_SF) * randn(ccd.sensor_size(1),ccd.sensor_size(2));
end 
%%%%% <----- ### END:: adding the Source follower noise in electrons.