%> @file ccd_FPN_models.m
%> @brief The routine contains various models on simulation of FPN
%> @author Alex Bar Guy
%> 
%> @section fpnsimmodels Models on Simulation of FPN
%> This routine generates various types of random distributions, and is based on the code "randraw"
%> by Alex Bar Guy  &  Alexander Podgaetsky.
%> 
%> Version 1.0 - March 2005 -  Initial version
%>   Alex Bar Guy  &  Alexander Podgaetsky
%>     alex@wavion.co.il
%> 
%>  These programs are distributed in the hope that they will be useful,
%>  but WITHOUT ANY WARRANTY; without even the implied warranty of
%>  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
%> 
%> Any comments and suggestions please send to:
%>     alex@wavion.co.il


function out = tool_rand_distributions_generator(distribName, distribParams, varargin)

distribNameInner = lower( distribName( ~isspace( distribName ) ) );

out = [];

    if prod(sampleSize) > 0
        
          switch lower( distribNameInner )
              

               otherwise
                    fprintf('\n RANDRAW: Unknown distribution name: %s \n', distribName);
                    
          end % switch lower( distribNameInner )
          
     end % if prod(sampleSize)>0
