%> @file prop_circular_aperture.m
%> @brief The function generates CIRC function.
%> @author adapted from the software from Jason D. Schmidt
%> @date   10 May 2010
%>
%> @section circfun Circ function
%> The circ function is defined as:@n
%> \f$ circ\left(\frac{\sqrt{x^2+y^2}}{a}\right) = \left\{ \begin{array}{cc} 1 & \sqrt{x^2+y^2} < a \\  \frac{1}{2} & \sqrt{x^2+y^2} = a \\  0 & \sqrt{x^2+y^2} > a  \\  \end{array} \right. \f$
%> 
%======================================================================
%> @param x = input array
%> @param y = input array
%> @param a = value of the amplitude of the RECT function
%>
%> @retval z = numerical evaluation of rect function
% ======================================================================
function z = prop_circular_aperture(x,y,a)
r = sqrt(x.^2+y.^2);
z = double(r<a/2);
z(r==a/2) = 0.5;