%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                           SurfaceProcessing                           %%
%%                      Last update: November 04, 2023                   %%
%%                             Kévin Daigne                              %%
%%                        kevin.daigne@hotmail.fr                        %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Surface modification based on several options and applies the 
% changes to the coordinates and the connectivity matrix
%% - Inputs -
% connectivity = E0*nNodesPerElement double : connectivity matrix
% x = 1*N0 double : x coordinates
% y = 1*N0 double : y coordinates
%% - Options -
% 'NodesToRemove' = 1*N double : indices of the nodes to be removed
% 'Contour' = 'On' or 'Off' (default) : keeps only the nodes on the contour
% 'Periodic' = [xMin xMax] : some bodies can be split due to periodic boundaries, this option will merge the divided parts
% 'BodyIndex' = 1*N0 double (/!\ MANDATORY for the 'Periodic' option) : body index of each node
% 'Sort' = chars : sorts the nodes according to different modes
%   - 'Neighbor' : their respective neighbors (based on the mesh)
%   - 'Contour' : the curvilinear abscissa (based on the mesh)
%   - 'Angular' : the angular position (based on the coordinates)
%   - 'Radial' : the radial position (based on the coordinates)
%% - Outputs -
% connectivity = E1*nNodesPerElement double : connectivity matrix
% x = 1*N1 double : x coordinates
% y = 1*N1 double : y coordinates
% indNodes = 1*N1 double : indices of the remaining nodes (e.g. xOutput=xInput(indNodes))
%% -

function [connectivity,x,y,indNodes]=SurfaceProcessing(connectivity,x,y,varargin)

%%  #. Options
p=inputParser;
addOptional(p,'NodesToRemove',[]);
addOptional(p,'Contour','Off');
addOptional(p,'Periodic',[]);
addOptional(p,'BodyIndex',[]);
addOptional(p,'BodyIndexMesh',[]);
addOptional(p,'Sort','Off');
parse(p,varargin{:});
opts=p.Results;

%% #. Indices
% Logical indices are not used because the size of x/y may change several times.
% Furthermore, if the sorting option is activated, logical indices cannot be used.
indNodes=1:numel(x);

%% #. Nodes to be removed
% Note that NodesToRemove can be logical or linear indices
if ~isempty(opts.NodesToRemove)
    connectivity=NodesRemoving(connectivity,opts.NodesToRemove);
    indNodes(opts.NodesToRemove)=[]; x(opts.NodesToRemove)=[]; y(opts.NodesToRemove)=[];
    if ~isempty(opts.BodyIndex)
        opts.BodyIndex(opts.NodesToRemove)=[];
    end
    if ~isempty(opts.BodyIndexMesh)
        opts.BodyIndex(opts.NodesToRemove)=[];
    end
end

%% #. Periodic boundaries
% Note that if there are periodic boundaries but the merging of bodies is
% not desired, this option is not necessary for the other operations and
% should therefore be disabled
% --------      --------       ----------------
%  body1  |    |  body1   ->  |      body1     |
% --------      --------       ----------------
if ~isempty(opts.Periodic)
    [connectivity,x,y,indNodesBC,opts.BodyIndexMesh]=PeriodicBoundariesUndo(connectivity,x,y,opts.Periodic,'BodyIndex',opts.BodyIndex,'BodyIndexMesh',opts.BodyIndexMesh);
    indNodes(~indNodesBC)=[];
    if ~isempty(opts.BodyIndex)
        opts.BodyIndex(~indNodesBC)=[];
    end
end

%% #. Contour nodes
% Contour nodes are computed using the connectivity matrix because a contour edge must appear only once in this matrix
if strcmpi(opts.Contour,'on')
    [connectivity,x,y,indNodesContour,~,opts.BodyIndexMesh]=ContourOnly(connectivity,x,y,'BodyIndexMesh',opts.BodyIndexMesh);
    indNodes(~indNodesContour)=[];
    if ~isempty(opts.BodyIndex)
        opts.BodyIndex(~indNodesContour)=[];
    end
end

%% #. Sort
% Can be useful for some post-processing that requires sorted nodes (e.g. polyarea)
if ~strcmpi(opts.Sort,'off')
    [connectivity,x,y,indSort]=SortNodes(connectivity,x,y,opts.Sort,'BodyIndex',opts.BodyIndexMesh);
    indNodes=indNodes(indSort);
    if ~isempty(opts.BodyIndex)
        opts.BodyIndex=opts.BodyIndex(indSort);
    end
    if ~isempty(opts.BodyIndexMesh)
        opts.BodyIndexMesh=opts.BodyIndexMesh(indSort);
    end
end