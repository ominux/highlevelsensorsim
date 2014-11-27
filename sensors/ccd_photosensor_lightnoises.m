%> @file ccd_photosensor_lightnoises.m
%> @brief This routine for adding dark current noises that consist of Dark FPN and Dark shot noise.
%> 
%> @author Mikhail V. Konnik
%> @date   17 January 2011
%> 
function ccd = ccd_photosensor_lightnoises(ccd, Uin)

           
    %%%%% Calculating the area of the pixel (in [m^2]).
    if (strcmp('CMOS',ccd.SensorType) == 1)
        PA = ccd.FillFactor*ccd.pixel_size(1)*ccd.pixel_size(2); %% PA is pixel area [m^2].
    else
        PA = ccd.pixel_size(1)*ccd.pixel_size(2); %% PA is pixel area, [m^2].
    end
    %%%%% END:: Calculating the area of the pixel (in [m^2]).



    %%%% Calculation of irradiance of the input light field. The input is the sensor irradiance  |Uin|^2  in [W/m^2].
    Uin_irradiance =  PA * abs(Uin).^2;  %% Converting to radiant flux per pixel in [W].

    P_photon = (ccd.h * ccd.c)/ ccd.lambda;   %% Power of a single photon, in [Joule = Watt*s]
    ccd.Signal_CCD_photons = round(Uin_irradiance * ccd.t_I / P_photon); %% the result is the average number of photons (rounded).
    %%%% END:: Calculation of irradiance of the input light field. The input is the sensor irradiance  |Uin|^2  in [W/m^2].



    %%%%%%%%%%%######       Section: Photon Shot Noise
    if (ccd.flag.photonshotnoise == 1)
        ccd.Signal_CCD_photons = ccd_photosensor_photonshotnoise(ccd.Signal_CCD_photons);     %%% adding the Photon Shot noise to the Signal_CCD_photons.
    end
    %%%%%%%%%%%######### END Section: Photon Shot Noise



    %%%%%%% Converting the signal from Photons to Electrons:
    QE = (ccd.QE_I)*(ccd.QuantumYield);  %% Quantum Efficiency = Quantum Efficiency Interaction X Quantum Yield Gain.
    ccd.Signal_CCD_electrons = ccd.Signal_CCD_photons*QE; %% output signal of the CCD in electrons [e]


    %%%%%%%%%%%#####      Section: Photo Response Non-Uniformity
    if (ccd.flag.PRNU == 1)
       ccd = ccd_photosensor_lightFPN(ccd); %%introducing the PRNU that is QE non-uniformity
    end
    %%%%%%%%%%%####### END Section: Photo Response Non-Uniformity

