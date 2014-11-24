%> @file prop_annular_aperture.m
%> @brief The function calculates the mask for the annular aperture.
%> 
%> @author Curt Vogel, Professor of Mathematics, Department of Mathematical Sciences, Montana State University, Bozeman, MT 59717-2400
%> @date   01 June 2006
%>
%> @section annularmask Making annular mask
%> Construct annular aperture mask with inner radius @b inner_radius and outer radius @b outer_radius. If number of input arguments equals 2, then mask is circular with radius @b outer_radius. The number of samples (grid points) @b nx is assumed to be even integer. The central pixel has index (nx+1)/2. The resulting annular mask is like the following:
%>
%> 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
%>
%> 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
%>
%> 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
%>
%> 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
%>
%> 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  1.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
%>
%> 0.0  0.0  0.0  0.0  0.0  0.0  1.0  1.0  1.0  1.0  1.0  0.0  0.0  0.0  0.0  0.0
%>
%> 0.0  0.0  0.0  0.0  0.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  0.0  0.0  0.0  0.0
%>
%> 0.0  0.0  0.0  0.0  0.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  0.0  0.0  0.0  0.0
%>
%> 0.0  0.0  0.0  0.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  0.0  0.0  0.0
%>
%> 0.0  0.0  0.0  0.0  0.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  0.0  0.0  0.0  0.0
%>
%> 0.0  0.0  0.0  0.0  0.0  1.0  1.0  1.0  1.0  1.0  1.0  1.0  0.0  0.0  0.0  0.0
%>
%> 0.0  0.0  0.0  0.0  0.0  0.0  1.0  1.0  1.0  1.0  1.0  0.0  0.0  0.0  0.0  0.0
%>
%> 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  1.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
%>
%> 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
%>
%> 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
%>
%> 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
%======================================================================
%> @param nx = number of grid samples in one direction; should be the nearest power of 2
%> @param inner_radius = inner radius of the annular mask [part of unity with respect to number of samples, i.e. 0.1]
%> @param outer_radius = outer radius of the annular mask [part of unity with respect to number of samples, i.e. 0.5]
%>
%> @retval mask = annular aperture mask 
% ======================================================================
function mask = prop_annular_aperture(nx,inner_radius,outer_radius)

hx = 2/nx;
x = [-1:hx:1-hx]';
onevec = ones(nx,1);

r = sqrt((x*onevec').^2 + (onevec*x').^2); %% creating the field for aperture annular mask

if nargin == 2
    mask = (r <= outer_radius);
else
    mask = (inner_radius <= r) & (r <= outer_radius);
end

%  dlmwrite(strcat('mask.numdata'), mask, 'precision', '%1.1f',  'delimiter', '\t'); %% outputs the mask into a file mask.numdata for TESTING purposes.