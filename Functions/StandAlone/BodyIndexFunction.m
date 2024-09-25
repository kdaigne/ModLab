%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                            BodyIndexFunction                          %%
%%                        Last update: July 16, 2024                     %%
%%                               Kévin Daigne                            %%
%%                          kevin.daigne@hotmail.fr                      %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Computes the body index of each node from the connectivity matrix.
% Compatible with periodic boundaries (i.e. artificially separated bodies).
%% - Inputs -
% connectivity = nElements*nNodesPerElement double : connectivity matrix
% x = 1*N double : x coordinates (useful only if periodic boundaries)
% y = 1*N double : y coordinates (useful only if periodic boundaries)
%% - Option -
% 'PeriodicBoundaries' = [xMin xMax] : x-coordinates of periodic boundaries
%% - Outputs -
% bodyIndex = 1*N double : body index associated with each node (considering periodic boundaries)
% bodyList = 1*B1 double : list of bodies (considering periodic boundaries)
% bodyIndexMesh = 1*N double : body index associated with each node (without considering periodic boundaries)
% bodyListMesh = 1*B2 double : list of bodies (without considering periodic boundaries)
% Note: without periodic boundaries, bodyIndex=bodyIndexMesh and bodyList=bodyListMesh
%% -

function [bodyIndex,bodyList,bodyIndexMesh,bodyListMesh]=BodyIndexFunction(connectivity,x,y,varargin)

% #. Option
p=inputParser;
addOptional(p,'PeriodicBoundaries',[-inf inf]);
parse(p,varargin{:});
opts=p.Results;

% #. Body index without periodic boundaries
% Mesh-based only
bodyIndexMesh=ConnectivityToBodiesList(connectivity);
bodyListMesh=unique(bodyIndexMesh);
bodyNumberMesh=numel(bodyListMesh);
bodyIndex=bodyIndexMesh;
bodyList=bodyListMesh;

% #. Periodic boundaries
if min(x)>opts.PeriodicBoundaries(1) && max(x)<opts.PeriodicBoundaries(2) % only x periodic boundaries currently available
    return;
end

% #. Maximum coordinates of each body
xMax=zeros(1,bodyNumberMesh);
yMax=zeros(1,bodyNumberMesh);
for bodyNum=1:bodyNumberMesh
    indBody=find(bodyIndexMesh==bodyListMesh(bodyNum));
    [xMax(bodyNum),indMax]=max(x(indBody));
    yMax(bodyNum)=y(indBody(indMax)); % y coordinates associated with maximum x
end

% #. Body index, with periodic boundaries, without successive indices
for bodyNum=1:bodyNumberMesh

    % #.#. Main body coordinates
    indBody1st=bodyIndexMesh==bodyListMesh(bodyNum);
    xBody=x(indBody1st);
    yBody=y(indBody1st);

    % #.#. Minimum nodal distance
    % Determines whether two nodes significantly overlap
    % (i.e. correspond to the same body had it not been split)
    cord=unique([xBody yBody],'rows'); % excludes duplicates
    nodalD=pdist(cord);
    nodalD=squareform(nodalD);
    nodalD=nodalD+max(nodalD(:))*eye(size(nodalD)); % ignore zero distances on diagonals
    minNodalD=min(nodalD(:));
    epsi=minNodalD/50; % 5% of this distance is considered arbitrarily significant

    % #.#. Sub bodies to check
    % Sub body: potential part of the main body that has been separated by periodic boundaries
    % Some overlaps are not possible
    bodyNumMaxList=find(abs(min(xBody)+opts.PeriodicBoundaries(2))<=xMax+epsi);
    bodyNumMaxList=setdiff(bodyNumMaxList,bodyNum);

    % #.#. Overlap detection
    % The distance between all the nodes of the main body
    % and the coordinates associated with the maximum x of
    % the sub bodies is determined
    % Bodies can be split more than twice
    for bodyNumMax=bodyNumMaxList % Sub bodies
        dist=[xBody-xMax(bodyNumMax)+opts.PeriodicBoundaries(2) yBody-yMax(bodyNumMax)];
        dist=vecnorm(dist,2,2);
        if any(dist<epsi)  % if the sub body overlaps the main body after an offset defined by periodic boundaries
            indBody2nd=bodyIndexMesh==bodyListMesh(bodyNumMax);
            bodyIndex(indBody2nd)=bodyList(bodyNum);
            bodyList(bodyNumMax)=bodyList(bodyNum);
        end
    end

end

% #. Body index, with periodic boundaries, with successive indices
% bodyIndex can currently be: 0, 1, 3, 2, etc.
% We want: 0, 1, 2, 3, etc.
bodyIndex=cumsum([false bodyIndex(2:end)~=bodyIndex(1:end-1)]);
bodyList=unique(bodyIndex);