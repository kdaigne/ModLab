# Packing2D #

Opens the Packing2D configuration file and a supplementary file to launch it and automatically copy the files created into the simulation folder. 

/!\ Execution must be performed from the main file and not from packing2D directly. If not, the files created will be stored in the interface directory, and not in the simulation directory.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                       %%
%%                      Packing 2D                       %%
%%                                                       %%
%%                     Main Program                      %%
%%              Version 1.2 ; February 2019              %%
%%                                                       %%
%%                Author: Guilhem Mollon                 %%
%%               Supervisor: Jidong Zhao                 %%
%%                                                       %%
%%          Realized at Hong Kong University             %%
%%              of Science and Technology                %%
%%                     Year 2012                         %%
%%                                                       %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



The program Packing2D is a free Matlab software dedicated to
the generation and packing of granular samples for introduction
in any 2D Discrete Modelling software.


This code is freely distributed for use in an academic and
research framework. The humble programmer hastens to say
that he cannot be held responsible for any malfunction
of the software and related consequences. However, he may
provide assistance if needed and kindly asked.


The theoretical background is developped in the journal
paper entitled "Fourier-Voronoi-based generation of realistic
samples for discrete modelling of granular materials", by
Mollon and Zhao and published in Granular Matter 
(DOI 10.1007/s10035-012-0356-x).


Code-users are encouraged to refer to this paper
(available for download on http://guilhem.mollon.free.fr)
for any theoretical concern. Besides, we kindly request
this article to be cited if this software is to be used in any
published work.





To use the software, open the file "Packing2D_Main_Program"
in matlab. The following fields should be filled:


-FileName
	String: A matlab data (.mat) file name used to save
	the results of computations.

-PFCFileCreation
	Boolean: 1 if the program is required to generate
	a data file directly readable by the commercial
	software PFC2D. 0 otherwise.

-PFCFileName
	String: A PFC2D data (.dat) file name used to save
	the generated packing if PFCFileCreation=1.

-Nparticles
	Positive Integer: Number of generated particles
	(exact number in a rectangular domain, approximate
	otherwise).

-DistributionType
	String : defines the type of statistical
	distribution used for the particles sizes
	'GaussianA': Gaussian distribution of the grains areas
	'LogormalA': Lognormal distribution of the grains areas
	'UniformA': Uniform distribution of the grains areas
	'UniformD': Uniform distribution of the grains diameters
	'BimodalA': Bimodal (gaussian) distribution of the grains areas
	'BimodalD': Bimodal (gaussian) distribution of the grains diameters
	'BimodalLogD': Bimodal distribution of the grains diameters, log scale
	'FractalD': Fractal distribution of the grains diameters
	
-DistributionParameters
	Array : defines the parameters of the statistical
	distribution used for the particles sizes
	'GaussianA': [Coefficient of variation of the grains areas]
	'LogormalA': [Coefficient of variation of the grains areas]
	'UniformA': [Ratio between larger and smaller grain area]
	'UniformD': [Ratio between larger and smaller grain diameter]
	'BimodalA': [Coefficient of variation of the grains areas for family 1,
				 Coefficient of variation of the grains areas for family 2,
				 Ratio between the average grains areas of family 2 and family 1,
				 Ratio between the peaks of the distributions of family 2 and family 1]
	'BimodalD': [Coefficient of variation of the grains diameters for family 1,
				 Coefficient of variation of the grains diameters for family 2,
				 Ratio between the average grains diameters of family 2 and family 1,
				 Ratio between the peaks of the distributions of family 2 and family 1]
	'BimodalLogD': [Coefficient of variation of the grains diameters for family 1,
				   Coefficient of variation of the grains diameters for family 2,
				   Ratio between the average grains diameters of family 2 and family 1,
				   Ratio between the peaks of the distributions of family 2 and family 1]
	'FractalD': [Fractal Dimension]
	
-LowerThreshold
	Real : Lower size threshold ; all grains with an area lower
	than the average area times this ratio will be ignored in the
	output array "Tcontours", but will still be present in "Contours"

-TargetMainOrientation
	Real between -90 and 90: Direction (in degrees) of
	the main orientation of the Voronoi cells (and
	hence of the final particles). Irrelevant if
	TargetAnisotropy=1.

-TargetAnisotropy
	Real between 0 and 1: Anisotropy ratio as defined
	in Mollon and Zhao (2012)

-DomainPoints
	Array: coordinates of the n points (x,y) of the polygonal
	domain in which the particles will be generated. Syntax:
	[x1,y1;x2,y2; ... ;xn,yn;x1,y1]. This domain should
	be closed, and the points listed in the counterclockwise
	order. Rounded domains can be defined using a large
	number of segments.

-NiterMax
	Positive Integer: Maximum number of iterations
	(successful or not) in the Constained Voronoi Tessellation
	algorithm. The algorithm stops when reached.

-TargetError
	Positive Real: Error value for which the Constrained
	Voronoi Tessellation is considered as having converged.

-TargetSolidFraction
	Real between 0 and 1: Desired solid fraction of the final
	sample. The obtained solid fraction is systematically
	smaller than the prescribed value. Slightly smaller for
	some configurations and much smaller for others.
	More details are provided in Mollon and Zhao (2012).

-NvarOptim
	Positive Integer: Number of Fourier descriptors used as
	optimization variables in the cell-filling algorithm. The
	phase angles of modes Dn with 1<n<NvarOptim+2 are optimized.
	Increasing this number may lead to denser packings, but
	also increases the computation time.
	
-OnlyCells
	Boolean : 1 if the user only wants to get the geometry of the
	Voronoi cells, 0 if he/she also wants some grains inside it.
	
-RandomOrientation
	Boolean : 0 if the grains are to be oriented like their
	surrounding cell (will allow to maximize packing density),
	1 if the grains are to be oriented randomly (will prevent
	a dense packing, but allow loose samples).

-COVSpectrum
	Positive Real: COV to apply to the Fourier descriptors
	if one wants them to exhibit some variability.
	0 otherwise.

-TypeCOVSpectrum
	Boolean: 0 if COVSpectrum is to be applied to each mode
	amplitude independantly (i.e. all the amplitudes are
	perfectly uncorrelated). 1 if COVSpectrum is to be applied
	homogeneously to all the modes (i.e. all the amplitudes
	are perfectly correlated).

-TypeSpectrum
	Boolean: 0 if the spectrum is taylored from a limited
	number of key descriptors (see Mollon and Zhao (2012) for
	more details). 1 if one wishes to use a specific existing
	spectrum.

-DescriptorD2
-DescriptorD3
-SpectrumDecay1
-DescriptorD8
-SpectrumDecay2
	Reals: If TypeSpectrum=0, key desciptors used to generate
	a taylored Fourier spectrum.

-FileSpectrum
	String: Matlab data (.mat) file containing a spectrum to
	be used if TypeSpectrum=1. Spectrums for nine real sands
	are provided in the package.
	-Obtained from Das (2007):
		-Toyoura Sand
		-Daytona Sand
		-Michigan Beach Sand
		-Tecate Sand
		-Kahala Sand
		-US Silica #1 Sand
	-Obtained from the pictures of Vardhanabhuti (2006):
		-Niigata Sand
		-Ottawa Sand
		-Michigan Dune Sand

-Dmax
	Real: Parameter of the ODEC algorithm proposed in Ferellec
	and McDowell (2008). Maximum distance for which a given
	contour point is considered as "covered" by one of the
	overlapping discs.

-Rmin
	Real: Parameter of the ODEC algorithm proposed in Ferellec
	and McDowell (2008). Minimum radius of any overlapping
	disc.

-Pmax
	Real: Parameter of the ODEC algorithm proposed in Ferellec
	and McDowell (2008). Accepted proportions of contour points
	not "covered" by any overlapping disc.





Each of these fields should be filled with something even if the
corresponding variable is irrelevant to the considered problem
(if so, the variable will be ignored), otherwise errors are to be
expected. You may for example fill '' when a string is asked (or
leave the field in its current state if a string is already there).


When done, press F5 to launch the program, and go have some coffee
because it might take some time before it comes to something.


At the end of the computations, the program provides several figures,
as well as the following matlab variables (which are also stored in
FileName):


-VoronoiCells
	Description of the Voronoi cells obtained at the end of the
	Constrained Voronoi Tessellation, defined by indices
	corresponding to lines in VoronoiVertices

-VoronoiVertices
	Vertices of the Contrained Voronoi Tessellation (columns
	are for x and y)

-ConvergenceHistory
	Record of the convergence of the Constrained Tessellation
	algorithm (columns 1 to 4: successful iteration number,
	error on surfaces, error on orientations, global error).

-ODECS
	Final particles packing as a collection of Overlapping
	Discrete Element Clusters (ODECS). For each ODEC, the
	columns 1 to 3 correspond to x and y coordinates of the disc
	centre and to the disc radius respectively.

-SampleProperties
	Properties of each particle (i.e. each ODEC). the columns
	of the matrix respectively correspond to:
	-1. Number of discs in the ODEC
	-2. Particle orientation
	-3. Particle large dimension L
	-4. Particle small dimension S
	-5. Particle elongation
	-6. Particle surface
	-7. Particle perimeter
	-8. X-coordinate of particle centre of mass
	-9. Y-coordinate of particle centre of mass
	-10. Particle rotational inertia
	-11. Particle equivalent radius
	-12. Particle convex perimeter
	-13. Particle inscribed radius
	-14. Particle circumscibed radius
	-15. X-coordinate of particle centre of mass
		(approximation 1 : same mass for all discs)
	-16. Y-coordinate of particle centre of mass
		(approximation 1 : same mass for all discs)
	-17. Particle rotational inertia
		(approximation 1 : same mass for all discs)
	-18. X-coordinate of particle centre of mass
		(approximation 2 : same density for all discs)
	-19. Y-coordinate of particle centre of mass
		(approximation 2 : same density for all discs)
	-20. Particle rotational inertia
		(approximation 2 : same density for all discs)
	-21. Particle roundness
	-22. Particle circularity
	-23. Particle regularity

-SolidFraction
	Final solid fraction of the sample in its container.

-CellsSurfaces
	Surfaces of the Voronoi cells.

-CellsOrientations
	Orientations of the Voronoi cells.

-SampleD50
	Computed D50 of the sample (equivalent diameter of grain,
	for which half of the matter belongs to grains of larger
	equivalent diameters and half to grains of smaller
	equivalent diameters).

-SampleCu
	Computed coefficient of uniformity of the sample.

-PDFOrientation
	Probability Density Function of the particles orientations

-PDFSurface
	Probability Density Function of the particles surfaces

-PDFElongation
	Probability Density Function of the particles elongations

-PDFRoundness
	Probability Density Function of the particles roundnesses

-PDFCircularity
	Probability Density Function of the particles circularities

-PDFRegularity
	Probability Density Function of the particles regularities

-Contours
	Geometry of the generated grains. This is a cell variable with
	6 columns, each line being a grain.
	Column 1: coordinates of the contour points (cartesian and polar frames)
	Column 2: "An" (real) part of the Fourier spectrum of the grain
	Column 3: "Bn" (imaginary) part of the Fourier spectrum of the grain
	Column 4: coordinates of the center of the grain (i.e. of its polar frame)
	Column 5: index of the grain
	Column 6: area of the grain

-Tcontours
	Same content than in "Contours", but only for the grains with an area
	larger than the threshold value (small grains are ignored)


Any claim or assistance inquiry can be addressed at
guilhem.mollon@gmail.com, provided that they are justified. So far,
this software has been tested on a large number of cases and has
always proved satisfactory, but I do not provide any guarrantee.


Finally, I wish you the best luck in using this software.