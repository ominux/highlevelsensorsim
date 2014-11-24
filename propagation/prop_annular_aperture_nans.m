%> @file prop_annular_aperture_nans.m
%> @brief Generates the annular aperture, including the central obscuration, using either zeros or nans.
%> 
%> @author Mikhail Konnik.
%> @date   01 June 2014

function [mask, out] = prop_annular_aperture_nans(mask, phase_screens)

nx = mask.nx;

 if (isfield(mask,'idx') == 0);      
    x = (-1+1/nx):(2/nx):1;
    [X,Y] = meshgrid(x,x);
    [theta,rho] = cart2pol(X,Y);
    mask.idx  = rho<mask.outer_radius; %%%% parameter!
 end    

 
  if ((isfield(mask,'idx2') == 0) && (mask.inner_radius > 0))
    x = (-1+1/nx):(2/nx):1;
    [X,Y] = meshgrid(x,x);
    [theta,rho] = cart2pol(X,Y);
    mask.idx2 = rho>mask.inner_radius; %%%% parameter!
  end


if (strcmp(mask.padding,'zeros') ==1)
    z = zeros(nx); %%
else
    z = nan(nx); %%
end

z(mask.idx) = phase_screens(mask.idx);

out = z;

if (mask.inner_radius > 0)

    if (strcmp(mask.padding,'zeros') ==1)
        z2 = zeros(nx); %%
    else
            z2 = nan(nx); %%
    end
    z2(mask.idx2) = z(mask.idx2);
    out =z2;
end 