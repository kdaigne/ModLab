%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                         ConnectivityToBodiesList                      %%
%%                        Last update: July 21, 2022                     %%
%%                               Kévin Daigne                            %%
%%                         kevin.daigne@hotmail.fr                       %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Finds the body index associated to each node from the connectivity matrix.
% Note that the computation depends only on the mesh. Therefore, if some
% bodies are split (e.g. periodic boundaries), inactive, etc., this will 
% not be taken into account.
%% - Input -
% connectivity = nElements*nNodesPerElement double : connectivity matrix
%% - Output -
% bodyIndex = 1*nNodes double : body index of each node (starts from 0)
%% -

function [bodyIndex]=ConnectivityToBodiesList(connectivity)

%% #. Initialization
bodyNum=-1; elementsNumberOld=0;
bodyIndex=NaN(1,max(max(connectivity))); % Note that if the connectivity is not fully entered, the results will be correct for the input range but the size of bodyIndex may not match the size of x, y, etc.
neighbors=[true false(1,size(connectivity,1)-1)]; % Indices of the elements of the current body

%% #. Processing
% A body is defined by the interconnection of edges. Therefore, the index 
% of the body is found by starting from an element, adding the neighbors, 
% then adding the neighbors of the neighbors and so on. When the number of
% neighbors does not change, it means that all the neighbors have been found.
while ~isempty(connectivity)
    % #.#. Current neighbors
    neighbors=any(ismember(connectivity,unique(connectivity(neighbors,:))),2);
    elementsNumber=sum(neighbors);
    if elementsNumber==elementsNumberOld
        % #.#. All the neighbors have been found
        bodyNum=bodyNum+1;
        bodyIndex(unique(connectivity(neighbors,:)))=bodyNum;
        connectivity(neighbors,:)=[]; % Removes these elements for the next loops
        neighbors=[true false(1,size(connectivity,1)-1)]; % Initialization for the next loop
        elementsNumberOld=0;
        continue;
    end
    elementsNumberOld=elementsNumber;
end