%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                            NodesRemoving                              %%
%%                       Last update: July 14, 2022                      %%
%%                             Kévin Daigne                              %%
%%                        kevin.daigne@hotmail.fr                        %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Removes nodes from the connectivity matrix and updates the indices
%% - Inputs -
% connectivity = E0*nNodesPerElement double : connectivity matrix
% nodesToRemove = 1*N double : logical or linear indices of the nodes to be removed
%% - Outputs -
% connectivity = E1*nNodesPerElement double : connectivity matrix
% indElements = 1*E0 double : logical indices of the kept elements
%%

function [connectivity,indElements]=NodesRemoving(connectivity,nodesToRemove)

%% #. Initialization
nodesPerElement=size(connectivity,2);
nodesNumber=max(max(connectivity));

%% #. Linear indices
if islogical(nodesToRemove)
    nodesToRemove=find(nodesToRemove);
end

%% #. Elements to be removed
% Note that if a node is removed, all the elements connected to that node are
% removed. In some cases, this may be an unwanted behavior, but this is the 
% only way to delete nodes without regenerating a mesh
indElements=ismember(connectivity,nodesToRemove);
indElements=~any(indElements,2)';
connectivity(~indElements,:)=[]; % Removes unwanted elements

%% #. Shift for each node
% e.g. if a node is removed, all the following nodes are shifted by one
% index in the connectivity matrix
shiftRow=zeros(nodesNumber,1); shiftRow(nodesToRemove)=1; shiftRow=cumsum(shiftRow);

%% #. Shift matrix
% All the nodes in the connectivity matrix are replaced by their
% corresponding shift. The connectivity matrix is used as indices for 
% shiftRow, and then a reshape is performed to retrieve the connectivity 
% matrix form.
shiftMatrix=reshape(shiftRow(reshape(connectivity,1,[])),[],nodesPerElement);

%% #. Shifted matrix
connectivity=connectivity-shiftMatrix;
