%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                           Function2DTo3DRadial                        %%
%%                      Last update: December 17, 2021                   %%
%%                               Kévin Daigne                            %%
%%                         kevin.daigne@hotmail.fr                       %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Transforms a 2D surface into a 3D surface using axial symmetry (a crown)
%% - Inputs -
% xIni = N2*1 double : 2D x-coordinates
% yIni = N2*1 double : 2D y-coordinates
% data = N2*1 double : 2D data field
% connectivity = E2*3 double : 2D connectivity matrix
% rMin = double : Lower radius of the crown (can be zero)
% rMax = double : Upper radius of the crown
% N = double : Number of pattern repetitions; if overlapping, closes the contour (set N=inf if desired)
%% - Options -
% 'r0' = double (mean radius by default) :
%   - Radius on which the input plane is located
%   - The closer this radius is to rMax, the more the plane will be
%     distorted close to rMin (and vice versa)
% 'Limits' = [xMin xMax] : 
%   - Limits considered for pattern repetition. By default, the extreme
%     coordinates of the plane are taken. Useful, for example, if
%     several graphs are drawn and one is wider than the other.
%% - Outputs -
% x = N3*1 double : 3D x-coordinates
% y = N3*1 double : 3D y-coordinates
% z = N3*1 double : 3D z-coordinates
% data = N3*1 double : 3D data field
% connectivity = E3*3 double : 3D connectivity matrix
%% - Method -
% “Projection” of the plane onto a circular arc at r0
% N repetitions of the pattern at r0
% “Projection” onto rMin and rMax
% Creation of 2D elements linking rMin and rMax (producing shells rather than 3D volumes)
%% -

function [x,y,z,data,connectivity]=Function2DTo3DRadial(xIni,yIni,data,connectivity,rMin,rMax,N,varargin)

% #. Inputs
p=inputParser;
addOptional(p,'r0',(rMin+rMax)/2);
addOptional(p,'Limits',[]);
parse(p,varargin{:});
r0=p.Results.r0;
Limits=p.Results.Limits;
xNumber=numel(xIni);
elementNumber=size(connectivity,1);

% #. Maximum number of repetitions
% Allows you to make no more than one revolution and apply a
% corrective factor for the arc length to make
% exactly one revolution, whatever the length
if isempty(Limits)
    xMin=min(xIni); % To obtain relative coordinates
    L0=max(xIni)-min(xIni); % Arc length
else
    xMin=Limits(1); % To obtain relative coordinates
    L0=Limits(2)-xMin;
end
Nrep=(2*pi*r0)/(L0); % Number of repetitions to complete a revolution
if N>Nrep
    % #.#.#.#. More than one revolution requested -> correction
    N=floor(Nrep); % Lower rounding
    alphar0=(2*pi*r0)/(N*L0); % Enlarge the length to make exactly one revolution
else
    % #.#.#.#. Less than one revolution requested -> no correction
    N=floor(N);
    alphar0=1;
end

% #. Initialization
x=zeros(N*xNumber*2,1); y=zeros(N*xNumber*2,1); z=zeros(N*xNumber*2,1); connectArc=zeros(size(connectivity,1)*N*2,3);

% #. Projection on rMin
theta0=0; % Angle between lower x-limit, center of symmetry and upper x-limit (looking in the z direction)
gammaLow=(2*pi*rMin)/(Nrep*L0); % Scaling factor for dTheta preservation
for repNum=1:N
    if rMin==0
        x((repNum-1)*xNumber+1:repNum*xNumber,1)=0;
        z((repNum-1)*xNumber+1:repNum*xNumber,1)=0;
    else
        x((repNum-1)*xNumber+1:repNum*xNumber,1)=rMin*sin((xIni-xMin).*alphar0.*gammaLow./rMin+theta0);
        z((repNum-1)*xNumber+1:repNum*xNumber,1)=rMin*cos((xIni-xMin).*alphar0.*gammaLow./rMin+theta0);
    end
    y((repNum-1)*xNumber+1:repNum*xNumber,1)=yIni;
    % Connectivity
    connectArc((repNum-1)*elementNumber+1:repNum*elementNumber,:)=connectivity+xNumber*(repNum-1);
    % Shift if several repetitions
    if repNum~=N
        theta0=theta0+L0.*alphar0.*gammaLow./rMin;
    end
end

% #. Projection on rMax
theta0=0; % Angle between lower x-limit, center of symmetry and upper x-limit (looking in the z direction)
gammaSup=(2*pi*rMax)/(Nrep*L0); % Scaling factor for dTheta preservation
for repNum=1:N
    x((repNum-1)*xNumber+N*xNumber+1:repNum*xNumber+N*xNumber,1)=rMax*sin((xIni-xMin).*alphar0.*gammaSup./rMax+theta0);
    y((repNum-1)*xNumber+N*xNumber+1:repNum*xNumber+N*xNumber,1)=yIni;
    z((repNum-1)*xNumber+N*xNumber+1:repNum*xNumber+N*xNumber,1)=rMax*cos((xIni-xMin).*alphar0.*gammaSup./rMax+theta0);
    % Connectivity
    connectArc((repNum-1)*elementNumber+N*elementNumber+1:repNum*elementNumber+N*elementNumber,:)=connectivity+xNumber*(repNum+N-1);
    % Shift if several repetitions
    if repNum~=N
        theta0=theta0+L0*alphar0.*gammaSup./rMax;
    end
end

% #. Elements between each arc
% #.#. External body elements
% Segments belonging only to one element are found (i.e. body contour)
% Avoid building the inside of volumes unnecessarily, as this causes slowdowns
nodesPerElement=size(connectivity,2);
if nodesPerElement==2
    edgesFormat=[1 2];
else
    edgesFormat=[1 sort(repmat(2:nodesPerElement,1,2)) 1]; % e.g. for an element [1 2 3], the edges are [1 2], [2 3] and [3 1].
end
edges=connectArc(1:size(connectArc,1)/2,edgesFormat); edges=reshape(edges',2,[]); % List of all the edges E*[starting index ; ending index]
edges=sort(edges)'; % Sorts the indices of each edge otherwise [i j] and [j i] will be considered as 2 different edges
% #.#. Matrix creation
% The 1st plane is copied with a shift equal to the number of nodes
% For each pair of segments (1 per side), we draw the
% rectangle that connects them with 2 triangles
nbP=numel(x)/2;
connectElements=[[edges(:,1) edges(:,2) edges(:,1)+nbP];[edges(:,1)+nbP edges(:,2)+nbP edges(:,2)]];

% #. Outputs
connectivity=[connectArc;connectElements];
data=repmat(data,N*2,1);