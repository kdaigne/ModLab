%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                           Function2DTo3DPlanar                        %%
%%                      Last update: July 05, 2021                   %%
%%                               Kévin Daigne                            %%
%%                         kevin.daigne@hotmail.fr                       %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Transforms a 2D surface into a 3D surface using planar symmetry
%% - Inputs -
% x = N2*1 double : 2D x-coordinates
% y = N2*1 double : 2D y-coordinates
% data = N2*1 double : 2D data field
% connectivity = E2*3 double : 2D connectivity matrix
% width = double : distance between planes
%% - Outputs -
% x = N3*1 double : 3D x-coordinates
% y = N3*1 double : 3D y-coordinates
% z = N3*1 double : 3D z-coordinates
% data = N3*1 double : 3D data field
% connectivity = E3*3 double : 3D connectivity matrix
%% - Method -
% Z-shift by -width/2
% Add an identical plane with Z coordinates shifted by +width/2
% Add elements linking the 2 planes (producing shells rather than 3D volumes)
%% -

function [x,y,z,data,connectivity] = Function2DTo3DPlanar(x,y,data,connectivity,width)


%% #. Edges
nodesPerElement=size(connectivity,2);
if nodesPerElement==2
    edgesFormat=[1 2];
else
    edgesFormat=[1 sort(repmat(2:nodesPerElement,1,2)) 1]; % e.g. for an element [1 2 3], the edges are [1 2], [2 3] and [3 1].
end
edges=connectivity(:,edgesFormat); edges=reshape(edges',2,[]); % List of all the edges E*[starting index ; ending index]
edges=sort(edges)'; % Sorts the indices of each edge otherwise [i j] and [j i] will be considered as 2 different edges

%% #. Matrix creation
% For each pair of segments (1 per side), we draw the
% rectangle that connects them with 2 triangles
nbP=size(x,1);
connectivity=[[connectivity;connectivity+nbP];[[edges(:,1) edges(:,2) edges(:,1)+nbP];[edges(:,1)+nbP edges(:,2)+nbP edges(:,2)]]];

%% #. Outputs
x=[x;x];
z=[zeros(size(y))-width/2;zeros(size(y))+width/2];
y=[y;y];
data=[data;data];