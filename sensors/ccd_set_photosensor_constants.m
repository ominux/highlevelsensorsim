function ccd = ccd_set_photosensor_constants(ccd)

	ccd.Boltzman_Constant	  = 8.617343*10^(-5); %%% Boltzman constant, [eV/K].
	ccd.Boltzman_Constant_JK  = 1.3806504*10^(-23); %%% Boltzman constant, [J/K].
	ccd.q 			          = 1.602176487*10^(-19); %% a charge of an electron [C], Cylon
	ccd.k1			          = 10.909*10^(-15); %% a constant;

    
    ccd.Eg_0		= 1.1557; %% bandgap energy for 0 degrees of K. [For Silicon, eV]
	ccd.alpha		= 7.021*10^(-4); %% material parameter, [eV/K].
	ccd.beta		= 1108; %% material parameter, [K].
