%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                               SortNodes                               %%
%%                        Last update: July 24, 2022                     %%
%%                               Kévin Daigne                            %%
%%                         kevin.daigne@hotmail.fr                       %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%
%% - Abstract -
% Sorts the nodes according to several modes. Can be useful for some
% post-processing that requires sorted nodes (e.g. polyarea)
%% - Inputs -
% connectivity = E*nNodesPerElement double : connectivity matrix
% x = 1*N double : x coordinates
% y = 1*N double : y coordinates
% mode = chars : sorts the nodes according to different modes
%   - 'Neighbor' : their respective neighbors (based on the mesh)
%   - 'Contour' : the curvilinear abscissa (based on the mesh)
%   - 'Angular' : the angular position (based on the coordinates)
%   - 'Radial' : the radial position (based on the coordinates)
%% - Options -
% 'SortBodies' = 'On' (default) or 'Off' : 
%   - Sorts the nodes according to the body index (e.g. x=[x(BodyIndex==0),x(BodyIndex==1),...]
%   - Different from the mode which changes the way nodes are sorted for a given body (e.g. x(BodyIndex==0))
% 'BodyIndex' = 1*N double : 
%   - Body index of each node that will be computed automatically if it is not defined here
%   - It is the body index according to the mesh, if for some reasons certain bodies are divided
%     (e.g. periodic boundaries), they are no longer considered as the same body
%% - Outputs -
% connectivity = E*nNodesPerElement double : connectivity matrix
% x = 1*N double : x coordinates
% y = 1*N double : y coordinates
% indSort = 1*N double : indices of the sorted nodes (e.g. xSorted=x(indSort))
% indSortInv = 1*N double : inverse indices of the sorted nodes (e.g. x=xSorted(indSortInv))
%% -

function [connectivity,x,y,indSort,indSortInv]=SortNodes(connectivity,x,y,mode,varargin)

%%  #. Options
p=inputParser;
addOptional(p,'SortBodies','On');
addOptional(p,'BodyIndex',[]);
parse(p,varargin{:});
opts=p.Results;
if isempty(opts.BodyIndex)
    opts.BodyIndex=ConnectivityToBodiesList(connectivity);
end

%% #. Initialization
opts.BodyIndex=reshape(opts.BodyIndex,1,[]);
bodiesList=unique(opts.BodyIndex); bodiesList(isnan(bodiesList))=[]; bodiesNumber=numel(bodiesList);
indSort=repmat(-1,1,numel(x));

%% #. Contour mode
if strcmpi(mode,'contour')
    nodesPerElement=size(connectivity,2);
    if nodesPerElement==2
        edgesFormat=[1 2];
    else
        edgesFormat=[1 sort(repmat(2:nodesPerElement,1,2)) 1]; % e.g. for a triangle [1 2 3], the edges are [1 2], [2 3] and [3 1]
    end
    edges=connectivity(:,edgesFormat); edges=reshape(edges',2,[]); % List of all the edges E*[starting index ; ending index]
    edges=sort(edges)'; % Sorts the indices of each edge otherwise [i j] and [j i] will be considered as 2 different edges
    edgesUnique=unique(edges,'rows'); % Groupcounts gives the result for a unique matrix
    edges=edgesUnique(groupcounts(edges)==1,:); % An edge is a contour edge only if it is used only once
end

for bodyNum=1:bodiesNumber
    
    %% #. Mode
    modeTemp=mode; % Allows to change the mode for a given body
    
    %% #. Indices
    indBodyNodes=find(opts.BodyIndex==bodiesList(bodyNum)); % Indices of the current body nodes
    
    %% #. Center
    % The starting node is often the closest node to the center.
    % Note that the center corresponds to the arithmetic mean of the
    % coordinates, which can be inaccurate if the nodes are inhomogeneously
    % dispersed
    xBodyM=mean(x(indBodyNodes)); yBodyM=mean(y(indBodyNodes)); % body center
    xBodyTemp=reshape(x(indBodyNodes)-xBodyM,1,[]); yBodyTemp=reshape(y(indBodyNodes)-yBodyM,1,[]); zBodyTemp=zeros(1,numel(x(indBodyNodes)));
    u=[xBodyTemp ; yBodyTemp ; zBodyTemp];
    
    %% #. Neighbor/Contour
    % Uses the connectivity to find the neighboring nodes
    % If all the nodes are on the contour, the sorting is done according to
    % the curvilinear abscissa. Allows to use functions like polyarea.
    % Otherwise, the result is similar to the radial mode in most cases.
    if strcmpi(modeTemp,'neighbor') || strcmpi(modeTemp,'contour')
        % #.#. Connectivity of the body
        % Allows to search only the elements of the current body
        if strcmpi(modeTemp,'contour')
            connectivityTemp=edges(ismember(edges(:,1),indBodyNodes),:); % Uses the edges and not the elements to follow the contour path
        else
            connectivityTemp=connectivity(ismember(connectivity(:,1),indBodyNodes),:);
        end
        if isequal(unique(connectivityTemp)',indBodyNodes)
            % #.#. Starting nodes
            [~,indCenter]=min(vecnorm(u));
            nodesNew=indBodyNodes(indCenter);
            indSort(indBodyNodes(1:numel(nodesNew)))=nodesNew; % Adds the new nodes
            if strcmpi(modeTemp,'contour')
                % By default, the neighbors of all the already found nodes
                % are searched. However, to sort by curvilinear abscissa
                % (i.e. follow the contour), it is easier to add one neighbor
                % per iteration, which is allowed by removing one element at
                % the beginning :
                %          Removed  
                %        x----------x   ---> follows the contour
                %                   x----------x
                %               Starting node
                connectivityTemp(find(any(ismember(connectivityTemp,indBodyNodes(indCenter)),2),1,'first'),:)=-1; % -1 = removed
            end
            % #.#. Neighbors
            while ~isempty(nodesNew)
                neighbors=any(ismember(connectivityTemp,nodesNew),2); % Elements that contain new neighbors
                nodesOld=indSort(indBodyNodes(indSort(indBodyNodes)~=-1)); % Indices of the nodes already added
                nodesNew=setdiff(indBodyNodes(ismember(indBodyNodes,connectivityTemp(neighbors,:))),nodesOld); % Indices of the nodes to be added
                indSort(indBodyNodes(numel(nodesOld)+1:numel(nodesOld)+numel(nodesNew)))=nodesNew; % Adds the new nodes
            end
            % #.#. Missing nodes
            % Prevents further errors
            if any(indSort(indBodyNodes)==-1)
                indSort(indBodyNodes)=-1; % Resets the indices
                if strcmpi(mode,'contour')
                    modeTemp='angular'; % Closer to the contour mode
                elseif strcmpi(mode,'neighbor')
                    modeTemp='radial'; % Closer to the neighbor mode
                end
            else
                continue;
            end
        else
            % #.#. Missing nodes
            % Some nodes may not appear in the connectivity. In this case, the
            % neighbor mode will fail. Therefore, an other mode is selected
            % for the current body.
            indSort(indBodyNodes)=-1; % Resets the indices
            if strcmpi(mode,'contour')
                modeTemp='angular'; % Closer to the contour mode
            elseif strcmpi(mode,'neighbor')
                modeTemp='radial'; % Closer to the neighbor mode
            end
        end
    end
    
    %% #. Angular
    if strcmpi(modeTemp,'angular')
        % Sorts the <alpha> values:
        %              (x)
        %   (x)        /
        %             / alpha
        %   (x)   (center) -----     (x)
        %
        %                   (x)
        % #.#. Angular position [0-pi]
        v=[ones(1,numel(xBodyTemp)) ; zBodyTemp ; zBodyTemp];
        alpha=acos(xBodyTemp./vecnorm(u)); % Dot product
        % #.#. Angular position [0-2pi]
        % The dot product gives results from 0 to pi, which is not
        % satisfactory for sorting the nodes. Therefore, the cross product
        % is used to find alpha in the range of 0 to 2 pi
        indSortBodies=cross(u,v); indSortBodies=indSortBodies(3,:)>0; alpha(indSortBodies)=pi-alpha(indSortBodies)+pi;
        % #.#.#. Sort
        [~,indSortTemp]=sort(alpha); indSort(indBodyNodes)=indBodyNodes(indSortTemp);
        continue;
    end
    
    %% #. Radial
    if strcmpi(modeTemp,'radial')
        % Sorts the <d> values:
        %             (x)
        %    (x)
        %                       d
        %    (x)   (center) <-------> (x)
        %
        %                    (x)
        % #.#. Distance
        dist=vecnorm(u);
        % #.#. Sort
        [~,indSortTemp]=sort(dist); indSort(indBodyNodes)=indBodyNodes(indSortTemp);
        continue;
    end
    
    %% #. Unknown mode
    indSort(indBodyNodes)=indBodyNodes;
end

%% #. Body sorting
if strcmpi(opts.SortBodies,'on')
    [~,indSortBodies]=sort(opts.BodyIndex);
    indSort=indSort(indSortBodies);
end

%% #. Inverse indices
[~,indSortInv]=sort(indSort);

%% #. Processing
connectivity=reshape(indSortInv(reshape(connectivity,1,[])),[],size(connectivity,2));
x=x(indSort); y=y(indSort);