%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                              ContourOnly                              %%
%%                      Last update: November 04, 2023                   %%
%%                             Kévin Daigne                              %%
%%                        kevin.daigne@hotmail.fr                        %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% 
%% - Abstract -
% Keeps only the contour nodes of several bodies
%% - Inputs -
% connectivity = E0*nNodesPerElement double : connectivity matrix
% x = 1*N0 double : x coordinates
% y = 1*N0 double : y coordinates
%% - Options -
% 'BodyIndexMesh' = 1*N0 double : 
%   - Body index of each node based on the mesh (it does not take into account the deactivations, periodic boundaries, etc.)
%   - It will be computed automatically if it is not defined here
%% - Ouputs -
% connectivity = E1*nNodesPerElement double : connectivity matrix
% x = 1*N1 double : x coordinates
% y = 1*N1 double : y coordinates
% indNodes = 1*N0 logical : Logical indices of the nodes that define the contour of each body
% edges = E*[node1,node2] : Linear indices of the nodes that define each edge on the contour of each body (beam connectivity matrix)
% BodyIndexMesh = 1*N1 double : body index of each node (/!\ based on the mesh, it does not take into account the deactivations, periodic boundaries, etc.)
%% -

function [connectivity,x,y,indNodes,edges,BodyIndexMesh]=ContourOnly(connectivity,x,y,varargin)

%%  #. Options
p=inputParser;
addOptional(p,'BodyIndexMesh',[]);
parse(p,varargin{:});
opts=p.Results;
if isempty(opts.BodyIndexMesh)
    BodyIndexMesh=ConnectivityToBodiesList(connectivity);
else
    BodyIndexMesh=opts.BodyIndexMesh;
end

%% #. Initialization
nodesPerElement=size(connectivity,2);
nodesNumber=numel(x);

%% #. Duplicated nodes
% Some nodes may be duplicated (e.g. periodic boundaries). They must be 
% corrected otherwise the condition "an edge belongs to the contour
% if it is used only once" is not satisfied. The indices of the duplicated 
% nodes are replaced by a single one in the connectivity matrix.
% e.g.
% Without correction:
% (1) -- (2 4) -- (5)
%         | | -> These 2 edges are used once each -> The contour is 1->2->3->4->5
%         (3)
% With correction:
% (1) -- (2 2) -- (5)
%         | | -> These 2 edges are used 2 times -> The contour is 1->2->5
%         (3)
nodesDup=unique([x y],'rows');
nodesDup=nodesDup(groupcounts([x y])>1,:); % Coordinates for which multiple nodes are found
for nodeNum=1:numel(nodesDup)/2
    indNodesToChange=find(nodesDup(nodeNum,1)==x & nodesDup(nodeNum,2)==y); % Duplicated nodes for these coordinates
    connectivity(ismember(connectivity,indNodesToChange))=indNodesToChange(1); % Changes all the indices of the duplicated nodes by the index of the first node found
end

%% #. Edges
if nodesPerElement==2
    edgesFormat=[1 2];
else
    edgesFormat=[1 sort(repmat(2:nodesPerElement,1,2)) 1]; % e.g. for a triangle [1 2 3], the edges are [1 2], [2 3] and [3 1]
end
edges=connectivity(:,edgesFormat); edges=reshape(edges',2,[]); % List of all the edges E*[starting index ; ending index]
edges=sort(edges)'; % Sorts the indices of each edge otherwise [i j] and [j i] will be considered as 2 different edges

%% #. Edges on the contour
edgesUnique=unique(edges,'rows'); % Groupcounts gives the result for a unique matrix
edges=edgesUnique(groupcounts(edges)==1,:); % An edge is a contour edge only if it is used only once

%% #. nodesInd
indNodes=false(1,nodesNumber); indNodes(unique(edges))=1; % Logical indices of the nodes on the contour

%% #. Body index
% [BodyIndexMeshTemp]=ConnectivityToBodiesList(edges);
% BodyIndexMesh=[BodyIndexMeshTemp NaN(1,nodesNumber-numel(BodyIndexMeshTemp))]; % Otherwise the size may be different than x/y

%% #. Connectivity
% As several nodes have been removed, the mesh must be regenerated
bodiesList=unique(BodyIndexMesh(indNodes)); bodiesList(isnan(bodiesList))=[]; bodiesNumber=numel(bodiesList);
connectivity=cell(1,bodiesNumber);
for bodyNum=1:bodiesNumber
    % #.#. Indices
    indBodyNodes=indNodes & reshape(BodyIndexMesh==bodiesList(bodyNum),1,[]); % Indices of the current body nodes
    indBodyNodesLinear=find(indBodyNodes); % Linear indices are required
    % #.#. Edges on the contour
    % Useful for isInterior
    [edgesTemp]=NodesRemoving(edges,~indBodyNodes); % This function is used because the indices of the nodes change as the mesh is generated in a body frame
    % #.#. Connectivity - Without boundaries - Body frame
    lastwarn('');
    connectivityTemp=delaunayTriangulation(x(indBodyNodes),y(indBodyNodes),edgesTemp);
    if ~isempty(lastwarn)
        % Some bodies may have mesh overlapping and nodes may be
        % created which leads to several issues thereafter. Therefore, in 
        % this case, the body is just ignored. Note that it only affects 
        % the connectivity, not the x/y coordinates
        connectivity{bodyNum}=[]; warning('The connectivity of the body has been ignored but the nodes still exist.'); lastwarn(''); continue;
    end
    % #.#. Connectivity - With boundaries - Body frame
    % With delaunayTriangulation, it is possible to specify edges but not
    % boundaries. Therefore, for some angular contours, several edges can
    % be created outside the contour and isInterior corrects this.
    connectivityTemp=connectivityTemp(isInterior(connectivityTemp),:);
    % #.#. Connectivity - With boundaries - Global frame
    % The connectivity matrix was computed in the body frame, 
    % therefore a shift must be applied to find the global
    % connectivity matrix
    connectivity{bodyNum}=reshape(indBodyNodesLinear(reshape(connectivityTemp,1,[])),[],nodesPerElement); % The connectivity matrix is used as indices for indBodyNodes, and then a reshape is performed to retrieve the connectivity matrix form
end
connectivity=vertcat(connectivity{:}); % Global connectivity matrix

%% #. Nodes removing
connectivity=NodesRemoving(connectivity,~indNodes);
x(~indNodes)=[];
y(~indNodes)=[];
BodyIndexMesh(~indNodes)=[];