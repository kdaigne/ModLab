%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                       %%
%%                      Packing 2D                       %%
%%                                                       %%
%%                     Main Program                      %%
%%             Version 1.3 ; September 2020              %%
%%                                                       %%
%%                Author: Guilhem Mollon                 %%
%%               Supervisor: Jidong Zhao                 %%
%%                                                       %%
%%          Realized at Hong Kong University             %%
%%              of Science and Technology                %%
%%                     Year 2012                         %%
%%                                                       %%
%%            Please read enclosed .txt file             %%
%%                                                       %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% A. INPUT DATA %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Created data files %%%%
FileName='Gouge_Matrix_Sample50_02.mat';         %Name of the created MATLAB data file
PFCFileCreation=0;                                  %0: no PFC2D file created ; 1: creation of a PFC2D file
PFCFileName='Packing2D_Example.dat';                %Name of the created PFC2D file

%%%% Constrained Voronoi Tessellation parameters %%%%
Nparticles=50;                                    %Number of generated points in the domain
DistributionType='UniformD';                        %Type of distribution ('GaussianA','LognormalA','UniformA','UniformD','BimodalA','BimodalD','BimodalLogD', or 'FractalD')
DistributionParameters=[2];                         %Parameters of the distribution
LowerThreshold=0.1;                                 %Ratio of rebuttal for too small grains (with respect to the average area)
TargetMainOrientation=0;                            %Target angle of main orientation
TargetAnisotropy=1;                                 %Target ratio of anisotropy
DomainPoints=[0,0;0,0.002;0.002,0.002;0.002,0;0,0];             %Packing domain. Syntax: [x1,y1;x2,y2;   ;xn,yn;x1,y1] (must be closed, with points order anticlockwise)
NiterMax=10000;                                     %Maximum number of iterations for Constrained Voronoi Tessellation
TargetError=0.1;                                    %Target error for Constrained Voronoi Tessellation
OnlyCells=0;                                        %1 if we only want the Voronoi cells, 0 if we also want the grains

%%%% Cell Filling Parameters %%%%
TargetSolidFraction=0.5;                              %Target solid fraction
NvarOptim=16;%0;                                    %Number of optimization variables for the filling algorithm (optimized for n=2 to n=NvarOptim+1)
RandomOrientation=1;                                %0 if the grains are to be oriented like their surrounding cell, 1 if they are to be randomly oriented

%%%% Fourier Spectrum Properties %%%%
TypeSpectrum=1;                                     %0:Taylored spectrum ; 1:Existing spectrum
COVSpectrum=0;                                      %COV of the Fourier descriptors
TypeCOVSpectrum=1;                                  %0:Modes vary individually ; 1:Spectrum varies altogether

%%%% If TypeSpectrum is 0 %%%%
DescriptorD2=0.10;                                  %Fourier descriptor n=2
DescriptorD3=0.01;                                  %Fourier descriptor n=3
SpectrumDecay1=-2;                                  %Exponential decay from n=3 to n=7
DescriptorD8=1e-10;                                 %Fourier descriptor n=8
SpectrumDecay2=-2;                                  %Exponential decay from n>8

%%%% If TypeSpectrum is 1 %%%%
FileSpectrum='Spectrum_Hostun_from3Dscans_Cutoff_16modes.mat';                %Name of a Spectrum file

%%%% ODECS Algorithm Parameters %%%%
Dmax=0.0001;                                        %Maximum distance for which a contour point is considered as "covered" by a given disc
Rmin=0.0001;                                        %Minimum radius of a given disc
Pmax=0.05;                                          %Accepted proportion of "uncovered" contour points

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% B. COMPUTATIONS %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%     PRESS F5    %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[VoronoiCells,VoronoiVertices,ConvergenceHistory,ODECS,SampleProperties,SolidFraction,CellsSurfaces,CellsOrientations,SampleD50,SampleCu,PDFOrientation,PDFSurface,PDFElongation,PDFRoundness,PDFCircularity,PDFRegularity,Contours,Tcontours]=Secondary_Program(FileName,PFCFileCreation,PFCFileName,Nparticles,DistributionType,DistributionParameters,LowerThreshold,TargetMainOrientation,TargetAnisotropy,DomainPoints,NiterMax,TargetError,TargetSolidFraction,NvarOptim,COVSpectrum,TypeCOVSpectrum,TypeSpectrum,FileSpectrum,DescriptorD2,DescriptorD3,SpectrumDecay1,DescriptorD8,SpectrumDecay2,Dmax,Rmin,Pmax,OnlyCells,RandomOrientation);
if OnlyCells==0
    save(FileName)
end