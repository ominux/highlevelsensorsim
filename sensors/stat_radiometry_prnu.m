%> @file stat_radiometry_prnu.m
%> @brief Tool for making measurings on radiometry and generating data for the plots in radiometry.
%> 
%> @author Mikhail V. Konnik
%> @date   17 January 2011
%> 
%  function stat_radiometry_prnu()

%%% <--- Initial parameters block
kmvFormat = '.tiff';% target filetype
kmvBlackLevelOffset=0;
kmvEndOfLinearity=1024; %%where linear dynamic range endes - data dot
kmvCompleteSaturation=1024; %%where linear dynamic range endes - data dot
%%% <--- Initial parameters block


%%%% <------ Range of interests selection from given image  ------
	kmvLeft=	276; %% left corner coordinates
	kmvTop=		268; %% top corner coordinates
	kmvWidth=	512; %% width of region
	kmvHeight=	512; %% height of region
%%%% <------ Range of interests selection from given image  ------


%%% <--- Preparing variables block
kmvGraphicalFiles = dir(strcat('*', kmvFormat )); % working with files in current directory
kmvGraphicalFilesSize = size(kmvGraphicalFiles,1);
%%% <--- Preparing variables block


%%%%%%%%################### MAIN MODULE ########################
%%% ATTENTION! WORKING IN CURRENT DIRECTORY ONLY!!!!!
for zzz=1:kmvGraphicalFilesSize; %collecting filenames of images
kmvGraphicalFileName = regexprep(kmvGraphicalFiles(zzz).name, kmvFormat, '', 'ignorecase');
	kmvMassive = double(imread(kmvGraphicalFiles(zzz).name)-kmvBlackLevelOffset);

	kmvRegion = kmvMassive(kmvTop:(kmvTop+kmvHeight), kmvLeft:(kmvLeft+kmvWidth)); %% relative coordinates from left-bootom region of interest

%%%% <------ Range of interests selection from given image  ------
figure(20), hist(kmvRegion(10:20,1:kmvWidth),100),title('Probability density function'); %% plot the Probability Density Function

%%%%%%%%################### DATA OUTPUT MODULE ########################
%  viz_pictures_for_moviemaker(20); %%% the plot to be printed for the movie

end
%%%%%%%%################### MAIN MODULE ########################