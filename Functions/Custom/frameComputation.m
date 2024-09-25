%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                           frameComputation                            %%
%%                   Last update: September 17, 2024                     %%
%%                             Kévin Daigne                              %%
%%                        kevin.daigne@hotmail.fr                        %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Find the spatial limits (y extremums) of the area containing the third body
% In particular, to find the midline of the upper and lower body
%% -

function frame=frameComputation(CONNECTIVITY,X,Y,body_index,periodicboundaries)

%% #. Body indices
[~,ind]=min(Y); lowerBody=body_index(ind);
[~,ind]=max(Y); upperBody=body_index(ind);
%% #. Keeps only the contours
[~,X,Y,indNodes]=SurfaceProcessing(CONNECTIVITY,X,Y,'Periodic',periodicboundaries,'BodyIndex',body_index,'Contour','On','Sort','Contour','NodesToRemove',~(body_index==lowerBody | body_index==upperBody));
body_index=body_index(indNodes);
%% #. Computation
for numBody=[lowerBody upperBody]
    % #.#. Nodes indices
    indBody=find(body_index==numBody);
    % #.#. Center
    % A node of the boundary is often an extremal y coordinate
    if numBody==lowerBody
        [~,indCenter]=max(Y(indBody));
    else
        [~,indCenter]=min(Y(indBody));
    end
    % #.#. Left periodic boundary
    indLeft=find(X(indBody)<=periodicboundaries(1));
    if numBody==lowerBody
        [~,indLeftToKeep]=max(Y(indBody(indLeft)));
    else
        [~,indLeftToKeep]=min(Y(indBody(indLeft)));
    end
    indLeftToKeep=indLeft(indLeftToKeep);
    % #.#. Right periodic boundary
    indRight=find(X(indBody)>=periodicboundaries(2));
    if numBody==lowerBody
        [~,indRightToKeep]=max(Y(indBody(indRight)));
    else
        [~,indRightToKeep]=min(Y(indBody(indRight)));
    end
    indRightToKeep=indRight(indRightToKeep);
    % #.#. Clockwise or counterclockwise
    % Does not work if the center is coincident with the boundaries
    if indCenter>1
        if X(indBody(indCenter))>X(indBody(indCenter-1))
            clockwise=true;
        else
            clockwise=false;
        end
    else
        if X(indBody(indCenter))<X(indBody(indCenter+1))
            clockwise=true;
        else
            clockwise=false;
        end
    end
    % #.#. Frame indices
    if clockwise && indLeftToKeep<=indRightToKeep % Clockwise without concatenation [x0:x1]
        indToKeep=indLeftToKeep:indRightToKeep;
    elseif ~clockwise && indLeftToKeep>=indRightToKeep % Counterclockwise without concatenation [x0:x1]
        indToKeep=indLeftToKeep:-1:indRightToKeep;
    elseif clockwise && indLeftToKeep>=indRightToKeep  % Clockwise with concatenation [x0:end 1:x1]
        indToKeep=[indLeftToKeep:numel(indBody) 1:indRightToKeep];
    elseif ~clockwise && indLeftToKeep<=indRightToKeep  % Counterclockwise with concatenation [x0:end 1:x1]
        indToKeep=[indRightToKeep:numel(indBody) 1:indLeftToKeep];
    end
    % #.#. Output
    if numBody==lowerBody
        frame.yMin=mean(Y(indBody(indToKeep)));
    else
        frame.yMax=mean(Y(indBody(indToKeep)));
    end
end

end