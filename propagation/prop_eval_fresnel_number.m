%> @file prop_eval_fresnel_number.m
%> @brief Evaluating the Fresnel Number for differentiating between the near- and far-field diffraction. 
%> @author Mikhail Konnik.
%> @date   12 June 2014
%> 
%> @section FresNum Fresnel Number
%> To distinguish between two diffraction modes, the Fresnel number \f$F\f$ is used. 
%> It is a dimensionless number that is defined as:
%> 
%> \f$ F = \frac{a^{2}}{L \lambda}\f$ 
%> 
%> where
%> 
%> - \f$a\f$ the size of an aperture or slit;
%> - \f$L\f$ is the distance from the aperture to the screen (observation plane);
%> - \f$\lambda\f$ is the incident wavelength.
%> 
%> Depending on the value of \f$F\f$ the diffraction theory can be 
%> simplified in two special cases: 
%> 
%> - @b Fraunhofer @b diffraction  (or far-field) for \f$F \ll 1\f$
%> - @b Fresnel @b diffraction (or near-field) for \f$F \gtrsim 1\f$.
%> 
%> The evaluation of the near-field optical wave propagation is considerably more challenging 
%> than for far-field propagation. The quadratic phase factor inside the Fresnel diffraction integral is not bandlimited, 
%> so it poses some challenges related to sampling.
%======================================================================
%> @param a = the size of an aperture or slit [meters]
%> @param L = propagation distance [meters]
%> @param lambda = \f$\lambda\f$, optical wavelength [meters]
%> 
%> @retval F = Fresnel Number.
% ======================================================================
function F = prop_eval_fresnel_number(a, L, lambda)

F = (a^2)/(lambda*L);

if (F > 10^3)
    fprintf('\nThe Fresnel Number is %4.4f - definitely a Fresnel diffraction.\n', F);
end    

if ( (F < 10^3) && (F > 10^(-2)) )
    fprintf('\nThe Fresnel Number is %4.4f - looks like a Fresnel diffraction.\n', F);
end    

if (F < 10^(-2))
    fprintf('\nThe Fresnel Number is %4.4f - definitely a Fraunhofer diffraction.\n', F);
end    
