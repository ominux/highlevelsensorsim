%> @file ccd_photosensor_darkcurrentnoise.m
%> @brief This routine for adding dark current noises that consist of Dark FPN and Dark shot noise.
%> 
%> @author Mikhail V. Konnik
%> @date   17 January 2011
%> 
%> @section readnoise Read noise in solid-state photosensors
%> Read noise is defined as any noise that is not a function of signal. Read noise is generally defined as the combination of the remaining circuitry noise between the photoreceptor and the ADC circuitry including pixel reset noise, thermal noise, and other minor contributors like conductor shot noise. Generally, the read noise consists of:
%> - pixel source follower noise
%> - sense node reset noise
%> - thermal dark current shot noise
%> - dark FPN
%> - ADC quantising noise
%> - offset FPN
%> - system noise
%> So the general read noise equation, according to\cite{photontransferbook}, is the following:@n 
%> \f$\sigma_{READ} = \sqrt{\sigma^2_{SF} + \sigma^2_{RESET} + \sigma^2_{DSHOT} + \sigma^2_{DFPN} + \sigma^2_{ADC} + \sigma^2_{OFFSETFPN} + \sigma^2_{SYSTEM}} \f$
%> @subsubsection darkcurr Dark Current generation
%> Dark current noise has the similar statistical character as readout noise and usually it is very small\cite{shwfsnoiseccd}. Read noise and FPN noise are Gaussian distributed. Even in the absence of light, pixels generate unwanted charge that is referred as dark current. Among others, thermally generated dark current is the most common source\cite{photontransferbook}. The dark current is caused by a photodiode leakage current and a pixel will ``fill up'' even if there is no light.  The amount of dark charge varies from pixel to pixel. Physically, dark current is due to the random generation of electrons and holes within the depletion region of the device that are then swept by the high electric field. Dark current in image sensors is leakage current produced by surface generation, thermal generation, also caused by dirty substances, defective crystals due to plasma damage and other anomalies in the semiconductor manufacturing process. It is illumination independent, does not change significantly from image to image, and increases with exposure time\cite{irie2008model}. The dark shot noise resulting from the dark current is always constant regardless of the number of incident photons as long as exposure time is constant.
%> 
%> Dark current noise is caused by dirty substances, defective crystals due to plasma damage and other anomalies in the semiconductor manufacturing process\cite{canonfullframeCMOSwhitepaper}.
%> 
%> The dark current itself can be characterised by \f$D_R\f$ that is the average dark current rate (measured in \f$e^-\f$/sec/pixel) and given by: @n
%> \f$D_R = 2.55\cdot10^{15}P_A D_{FM} T^{1.5} \exp\left[-\frac{E_{gap}}{2\cdot k\cdot T}\right],\f$
%> 
%> - \f$P_A\f$ is the pixel's area [\f$cm^2\f$];
%> - \f$D_{FM}\f$ is the dark current figure-of-merit at 300K [nA/\f$cm^2\f$], varies significantly; with sensor manufacturer, and used in this simulations as 0.5 nA/\f$cm^2\f$;
%> - \f$E_{gap}\f$ is the bandgap energy of the semiconductor wich also varies with temperature;
%> - \f$k\f$ is Boltzman's constant that is \f$8.617\cdot10^{-5} [eV/K].\f$
%>  The relationship between band gap energy and temperature can be described by Varshni's empirical expression\cite{Pinault20011562},@n 
%> \f$ E_{gap}(T)=E_{gap}(0)-\frac{\alpha T^2}{T+\beta},\f$ @n
%> where \f$E_{gap}(0)\f$, \f$\alpha\f$ and \f$\beta\f$ are material constants. The energy bandgap of semiconductors tends to decrease as the temperature is increased.
%> For the Silicon (Original in Janesick book\cite{photontransferbook}), the parameters are: \f$E_{gap}(0) = 1.1557 [eV]\f$,  \f$\alpha = 7.021*10^{-4}\f$ [eV/K], \f$\beta = 1108\f$ [K]. This behaviour can be better understood if one considers that the inter-atomic spacing increases when the amplitude of the atomic vibrations increases due to the increased thermal energy. This effect is quantified by the linear expansion coefficient of a material. Dark current is linear with respect to integration time and doubles with every \f$6-8^{\circ}C\f$ increase in temperature\cite{hornseynoisebook}. There are two forms of thermal dark current: \textit{dark current shot noise} and \textit{dark FPN}.
%======================================================================
%> @param ccd 		= structure of signal without dark current noises.
%> @retval ccd 		= structure of signal WITH added Dark shot noise and dark FPN.
% ======================================================================
function ccd = ccd_photosensor_darkcurrentnoise(ccd)

sensor_signal_rows = size(ccd.Signal_CCD_electrons,1);
sensor_signal_columns = size(ccd.Signal_CCD_electrons,2);

PA = ccd.pixel_size(1)*ccd.pixel_size(1)*10^(4); %% translating the size to square sentimeters, as in Janesick book.



%%%%%% Section: Dark current generation
ccd.Eg = ccd.Eg_0 -( ccd.alpha*(ccd.T^2) )/(ccd.beta + ccd.T);  %% silicon band gap energy, [eV];

ccd.DARK_e = (ccd.t_I)*2.55*10^(15)*PA*ccd.DFM*(ccd.T^(1.5))*exp(-ccd.Eg/(2*ccd.Boltzman_Constant*ccd.T)); %% average amount of dark current that is thermally generated [e]  !!! This ccd.DARK_e is that for equation 11.15 for Janesick D = t_I*D_R
%%%%%% END Section: Dark current generation 


ccd.dark_signal = (ccd.DARK_e).*ones(size(ccd.Signal_CCD_electrons)); %% creating the matrix of dark generated signals.


%%%%%% Section: adding Dark FPN  %%% being added to dark current, it is too small.
if (ccd.flag.darkcurrent_DarkFPN_pixel == 1)
	ccd = ccd_photosensor_darkFPN(ccd);
%  disp('Here dark FPN')
end
%%%%%% END Section: adding Dark FPN  %%% being added to dark current, it is too small.



%%%%%% Section: adding Dark Shot noise
if (ccd.flag.darkcurrent_Dshot == 1)
	ccd = ccd_photosensor_darkshotnoise(ccd);
%  disp('Here dark Dshot')
end
%%%%%% END Section: adding Dark Shot noise




%%%%%% Start: Adding dark noises to signal
ccd.Signal_CCD_electrons = round(ccd.Signal_CCD_electrons+ccd.dark_signal); %% making DFPN as a ROW-repeated noise, just like light FPN;
%%%%%% Start: Adding dark noises to signal