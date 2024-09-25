%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                           Projection3Dto2D                            %%
%%                     Last update: January 04, 2022                     %%
%%                             Kévin Daigne                              %%
%%                        kevin.daigne@hotmail.fr                        %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Projects 3D coordinates into the 2D plane of the current view
%% - Inputs -
% ax = axes : Object containing data
% data3D = nNodes * [x y z] : Nodes to be projected
%% - Outputs -
% data : Projected nodes
%   - data(:,1) : horizontal vector in 2D plane
%   - data(:,2) : normal vector in 2D plane
%   - data(:,3) : vertical vector in 2D plane
% ratio = double : Format of current graph view (width/height)
%% -

function [data,ratio]=Projection3Dto2D(ax,data3D)

% #. Pre-calculation
v=axis(ax); [az,el]=view(ax);
az=az*pi/180; el=el*pi/180;
extremumNodes=[ ...
    v(1) v(3) v(5); ...
    v(1) v(3) v(6); ...
    v(1) v(4) v(5); ...
    v(1) v(4) v(6); ...
    v(2) v(3) v(5); ...
    v(2) v(3) v(6); ...
    v(2) v(4) v(5); ...
    v(2) v(4) v(6)]'; % Cube vertices defining the view

% #. Calculation of base change matrices
% Calculated using the scalar product
% Base 0: Initial base
% Base 1: Base with a rotation of az from base 0 and around z0=z1
% Base 2: Base with a rotation of el from base 1 and around y1=y2
% x2: horizontal vector in the 2D plane
% y2: normal vector in the 2D plane
% z2: vertical vector in the 2D plane
mat0to1=[cos(az) cos(3*pi/2+az) 0 ;...
    cos(az+pi/2) cos(az) 0;...
    0 0 1];
mat1to2=[1 0 0 ;...
    0 cos(el) cos(3*pi/2+el);...
    0 cos(pi/2+el) cos(el)];

% #. Final calculation
% #.#. Ratio
vectIn2=mat1to2*(mat0to1*extremumNodes);
ratio=(abs(max(vectIn2(1,:))-min(vectIn2(1,:)))/abs(max(vectIn2(3,:))-min(vectIn2(3,:))));
% #.#. Data
data=[];
if exist('data3D','var')
    if ~isempty(data3D)
        data=(mat1to2*(mat0to1*data3D'))';
    end
end