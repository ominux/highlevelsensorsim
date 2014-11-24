%> @file prop_rectangular_aperture.m
%> @brief The function generates RECT function.
%> @author Jason D. Schmidt
%> @date   10 May 2010
%>
%> @section rectfun Rect function
%> The rectangle function is defined as: @n
%> \f$ rect\left(\frac{x}{a}\right) = \left\{ \begin{array}{cc}  1 & x< \frac{a}{2} \\ \frac{1}{2} & x=\frac{a}{2} \\ 0 & x>\frac{a}{2} \\  \end{array} \right. \f$
%> 
%======================================================================
%> @param x = input array
%> @param a = value of the amplitude of the RECT function
%>
%> @retval y = numerical evaluation of rect function
% ======================================================================
function tmp_aperture = prop_rectangular_aperture(x,y,a,b)

tmp_aperture = tools_rect(x/a) .* tools_rect(y/b);

function y = tools_rect(x, D)
    if nargin == 1, D = 1; end
    x = abs(x);
    y = double(x<D/2);
    y(x == D/2) = 0.5;