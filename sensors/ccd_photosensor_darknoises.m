%> @file ccd_photosensor_darknoises.m
%> @brief This routine for adding dark current noises that consist of Dark FPN and Dark shot noise.
%> 
%> @author Mikhail V. Konnik
%> @date   17 January 2011, reworked on 5 December 2014.
%> 
%> @section readnoise Read noise in solid-state photosensors
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