%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                           PeriodicBoundariesUndo                      %%
%%                      Last update: November 04, 2023                   %%
%%                               Kévin Daigne                            %%
%%                         kevin.daigne@hotmail.fr                       %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% 
%% - Abstract -
% Some bodies are split due to periodic boundaries. This function will
% merge the divided parts.
%% - Inputs -
% connectivity = E0*nNodesPerElement double : connectivity matrix (before merging)
% x = 1*N0 double : x coordinates (before merging)
% y = 1*N0 double : y coordinates (before merging)
% periodicboundaries = [xMin xMax] : x coordinates of periodic boundaries
%% - Options -
% 'BodyIndex' = 1*N0 double : body index of each node based on input data
% 'BodyIndexMesh' = 1*N0 double : 
%   - Body index of each node based on the mesh (it does not take into account the deactivations, periodic boundaries, etc.)
%   - It will be computed automatically if it is not defined here
%% - Outputs
% connectivity = E1*nNodesPerElement double : connectivity matrix (after merging)
% x = 1*N1 double : x coordinates (after merging)
% y = 1*N1 double : y coordinates (after merging)
% indNodes = 1*N0 logical : logical indices of the kept nodes
% 'BodyIndexMesh' = 1*N1 double : body index of each node (after merging)
%% -

function [connectivity,x,y,indNodes,BodyIndexMesh]=PeriodicBoundariesUndo(connectivity,x,y,periodicBoundaries,varargin)

%%  #. Options
p=inputParser;
addOptional(p,'BodyIndex',[]);
addOptional(p,'BodyIndexMesh',[]);
parse(p,varargin{:});
opts=p.Results;
if isempty(opts.BodyIndexMesh)
    BodyIndexMesh=ConnectivityToBodiesList(connectivity);
else
    BodyIndexMesh=opts.BodyIndexMesh;
end
bodyIndex=opts.bodyIndex;

%% #. Initialization
bodiesList=unique(bodyIndex); bodiesNumber=numel(bodiesList); 
nodesNumber=numel(x); indNodes=true(1,nodesNumber);
shift=abs(periodicBoundaries(2)-periodicBoundaries(1));


%% #. Shift
for bodyNum=1:bodiesNumber
    % #.#. Indices
    indBodyNodes=find(bodyIndex==bodiesList(bodyNum)); % Indices of the current body nodes
    if numel(unique(BodyIndexMesh(indBodyNodes)))>1 % if a body is divided in several parts
        % #.#. Reference body part
        % By default, the part with the max x coordinate is fixed
        [~,indNew]=max(x(indBodyNodes));
        BodyIndexMeshFixed=BodyIndexMesh(indBodyNodes(indNew));
        indBodyNodesRealFixed=find(BodyIndexMesh==BodyIndexMeshFixed);
        % #.#. Other body parts (to the left)
        BodyIndexMeshToChange=unique(BodyIndexMesh(indBodyNodes));
        BodyIndexMeshToChange(BodyIndexMeshToChange==BodyIndexMeshFixed)=[]; % Removes the fixed part
        indBodyNodesToChange=find(ismember(BodyIndexMesh,BodyIndexMeshToChange)); % Corresponding node indices
        % #.#. Typical distance between neighboring nodes
        % Allows to detects if one part is too far away from another
        dRef=pdist([reshape(x(indBodyNodesRealFixed),[],1),reshape(y(indBodyNodesRealFixed),[],1)]); dRef(dRef==0)=NaN; dRef=mean(dRef(:),'omitnan');
        % #.#. Computation
        % Checks the bodies from right to left, for unknown reasons, more than 
        % two divided parts can be detected, requiring an iterative method
        alpha=5; % Checks whether the distance between the current part and the previous part is greater than alpha*dRef
        beta=0.01; % Some nodes overlap near the boundaries (i.e. one node is created several times), checks if the distance between any nodes is less than beta*dRef and replace all these nodes by a single one (including in the connectivity)
        xMinOld=min(x(indBodyNodesRealFixed));
        while ~isempty(indBodyNodesToChange)
            % #.#.#. New leftmost part
            [xMaxNew,indNew]=max(x(indBodyNodesToChange));
            bodyNew=BodyIndexMesh(indBodyNodesToChange(indNew));
            indNodesNew=find(BodyIndexMesh(indBodyNodesToChange)==bodyNew);
            % #.#.#. Processing
            if abs(xMaxNew-xMinOld)>alpha*dRef
                % #.#.#. Shift
                x(indBodyNodesToChange(indNodesNew))=x(indBodyNodesToChange(indNodesNew))+shift;
                % #.#.#. Overlapping nodes
                % #.#.#.#. Broad detection
                % Some nodes cannot overlap with the current part, so they are removed from the computation to reduce the number of operations
                indBodyNodesOther=indBodyNodes(~ismember(indBodyNodes,indBodyNodesToChange(indNodesNew))); % All the nodes except the current part
                xMaxOther=max(x(indBodyNodesOther));
                %xMinNew=min(x(indBodyNodesToChange(indNodesNew)));
                %xMaxNew=max(x(indBodyNodesToChange(indNodesNew)));
                %indBroadOld=indBodyNodesOther(x(indBodyNodesOther)>=xMinNew-beta*dRef & x(indBodyNodesOther)<=xMaxNew+beta*dRef);
                indBroadOld=indBodyNodes;
                indBroadNew=indBodyNodesToChange(indNodesNew(x(indBodyNodesToChange(indNodesNew))<=xMaxOther+beta*dRef));
                % #.#.#.#. Detection
                % Computes the Euclidean norm to detect overlapping nodes
                for nodeOldNum=1:numel(indBroadNew)
                    distTemp=((x(indBroadOld)-x(indBroadNew(nodeOldNum))).^2 ...
                    +(y(indBroadOld)-y(indBroadNew(nodeOldNum))).^2).^0.5;
                nodesToChange=[reshape(indBroadOld(distTemp<=beta*dRef),1,[]) indBroadNew(nodeOldNum)]; % More than 2 nodes may overlap
                indNodesTemp=find(~indNodes); nodesToChange(ismember(nodesToChange,indNodesTemp))=[]; % Excludes previously deleted nodes
                [~,nodeToKeep]=min(x(nodesToChange)); nodeToKeep=nodesToChange(nodeToKeep); % Keeps the leftmost node
                nodesToChange(nodesToChange==nodeToKeep)=[];
                if ~isempty(nodesToChange)
                    indNodes(nodesToChange)=0;
                    connectivity(ismember(connectivity,nodesToChange))=nodeToKeep; % Replaced by a single node
                end
                end
            end
            % #.#.#. Update old leftmost part
            xMinOld=min(x(indBodyNodesToChange(indNodesNew)));
            indBodyNodesToChange(indNodesNew)=[];
        end
        % #.#. New real body index
        BodyIndexMesh(indBodyNodes)=BodyIndexMeshFixed; % Body index is now the same for all the nodes of the current body
    end
end

%% #. Duplicated elements
% Some elements may be duplicated if overlapping nodes come from the same element
connectivityTemp=sort(connectivity,2); % Temporary connectivity to prevent sorting the original matrix
connectivityUnique=unique(connectivityTemp,'rows'); % Groupcounts gives the result for a unique matrix
elementsToRemove=connectivityUnique(groupcounts(connectivityTemp)>1,:);
for elemNum=1:size(elementsToRemove,1)
    indToRemove=find(ismember(connectivityTemp,elementsToRemove(elemNum,:),'rows'));
    connectivityTemp(indToRemove(2:end),:)=[]; % Keeps only one of the elements
    connectivity(indToRemove(2:end),:)=[];  % Keeps only one of the elements
end

%% #. Nodes removing
connectivity=NodesRemoving(connectivity,~indNodes);
x(~indNodes)=[]; y(~indNodes)=[]; BodyIndexMesh(~indNodes)=[];