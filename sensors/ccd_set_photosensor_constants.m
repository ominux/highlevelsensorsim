function ccd = ccd_set_photosensor_constants(ccd, Uin)

ccd.sensor_size = size(Uin); %%% determining the size of the sensor.

%%% pre-allocating the matrices for photons, electrons, voltages and DNs.
    ccd.Signal_CCD_photons   = zeros(ccd.sensor_size);
    ccd.Signal_CCD_electrons = zeros(ccd.sensor_size);
    ccd.Signal_CCD_voltage   = zeros(ccd.sensor_size);
    ccd.Signal_CCD_DN        = zeros(ccd.sensor_size);

%%%%%%% Section: Sensor material constants    
    ccd.Eg_0		= 1.1557; %% bandgap energy for 0 degrees of K. [For Silicon, eV]
	ccd.alpha		= 7.021*10^(-4); %% material parameter, [eV/K].
	ccd.beta		= 1108; %% material parameter, [K].
%%%%%%% END Section: Sensor material constants
    

%%%%%%% Section: Fundamental constants
ccd.h = 6.62606896*10^(-34); %%% Plank's constant, in [Joule*s]
ccd.c = 2.99792458*10^8; %% speed of light, in [m/s].

	ccd.Boltzman_Constant	  = 8.617343*10^(-5); %%% Boltzman constant, [eV/K].
	ccd.Boltzman_Constant_JK  = 1.3806504*10^(-23); %%% Boltzman constant, [J/K].
	ccd.q 			          = 1.602176487*10^(-19); %% a charge of an electron [C], Cylon
	ccd.k1			          = 10.909*10^(-15); %% a constant;
%%%%%%% END Section: Fundamental constants    