%> @file tool_circ.m
%> @brief Generation of a circular aperture.
%> @author Prof. Jason Schmidt.
%> 
%======================================================================
%> @param x     = x-grid, meters/pixels.
%> @param y     = y-grid, meters/pixels.
%> @param D     = diameter of the aperture, [m].
%> 
%> @retval z      = generated circular aperture, matrix [NxM].
% ======================================================================
function z = tool_circ(x, y, D)

    r = sqrt(x.^2+y.^2);
    z = double(r<D/2);
    z(r==D/2) = 0.5;