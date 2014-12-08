%> @file ccd_illumination_prepare.m
%> @brief This routine performs makes a simple illuminated circle with blurred boundaries.
%> @author Mikhail V. Konnik
%> @date   9 December 2014.
%> 
%======================================================================
%> @param ccd       = structure that contains parameters of the sensor (exposure time and so on).
%> @param N     = row size of the sensor/light field, [pix]
%> @param M     = column size of the sensor/light field, [pix]
%>
%> @retval Uin      = light field incident on the photosensor [matrix NxM], [Watt/m2].
% ======================================================================
function Uin = ccd_illumination_prepare(ccd, N, M)


delta_x = ccd.illumination.input_screen_size / N; %src sample interval
delta_y = ccd.illumination.input_screen_size / M; %src sample interval

[x1 y1] = meshgrid( (-N/2 : N/2-1)*delta_x, (-M/2 : M/2-1)*delta_y);%> the grid spacing x1 and y1 in the source plane for generation of aperture.

Uin = ccd.illumination.amplitude_coeff * tool_circ(x1, y1, ccd.illumination.input_screen_hole_size);

H = fspecial('disk', round(ccd.illumination.input_screen_blur / max(delta_x,delta_y))  );
Uin = imfilter(Uin,H,'replicate');


    %%%%%%%%%%%% Visualisation subsection.
    if (ccd.flag.plots.irradiance == 1)
    Uin_irradiance = abs(Uin).^2; %% computing the Irradiance [W/m^2] of the input optical field Uin.
    
    figure, imagesc(Uin_irradiance), title('Irradiance map of the light field [W/m^2].'); %% Irradiance map of the optical field.
%     figure, plot(Uin_irradiance(round(N/2),1:M)), title('profile of the Irradiance map of the light field [W/m^2].'), xlabel('Number of Pixel on the photo sensor'), ylabel('Irradiance, [W/m^2]');  %% the profile of the Irradiance map
 
    end %% if (ccd.flag.plots.irradiance
    %%%%%%%%%%%% Visualisation subsection.
