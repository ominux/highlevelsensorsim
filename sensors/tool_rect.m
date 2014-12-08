%> @file tool_rect.m
%> @brief Generation of a rectangular aperture.
%> @author Prof. Jason Schmidt.
%> 
%======================================================================
%> @param x     = x-grid, meters/pixels.
%> @param D     = diameter of the aperture, [m].
%> 
%> @retval z      = generated rectangular aperture, matrix [NxM].
% ======================================================================
function y = tool_rect(x, D)

if nargin == 1, D = 1; end

    x = abs(x);
    y = double(x<D/2);
    y(x == D/2) = 0.5;
