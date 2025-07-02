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
        frame.lower.min=min(Y(indBody(indToKeep)));
        frame.lower.mean=mean(Y(indBody(indToKeep)));
        frame.lower.max=max(Y(indBody(indToKeep)));
        frame.lower.X=X(indBody(indToKeep));
        frame.lower.Y=Y(indBody(indToKeep));
    else
        frame.upper.min=min(Y(indBody(indToKeep)));
        frame.upper.mean=mean(Y(indBody(indToKeep)));
        frame.upper.max=max(Y(indBody(indToKeep)));
        frame.upper.X=X(indBody(indToKeep));
        frame.upper.Y=Y(indBody(indToKeep));
    end
end
% #. Box
% The comment text corresponds to a version where the junction between the
% upper and lower bodies is discretized to avoid numerical issues in
% certain functions.
% Counterclockwise
if frame.lower.X(1)<frame.lower.X(end)
    frame.box.X=frame.lower.X;
    frame.box.Y=frame.lower.Y;
else
    frame.box.X=flip(frame.lower.X);
    frame.box.Y=flip(frame.lower.Y);
end
%borderDelta=sqrt((frame.box.X(2)-frame.box.X(1)).^2+(frame.box.Y(2)-frame.box.Y(1)).^2);
if frame.upper.X(1)>frame.upper.X(end)
    % % Right
    % borderRightHeight=frame.upper.Y(1)-frame.box.Y(end);
    % borderRightN=round(borderRightHeight./borderDelta-1);
    % borderRightY=linspace(frame.box.Y(end),frame.upper.Y(1),borderRightN)';
    % borderRightY(1)=[];
    % borderRightY(end)=[];
    % borderRightX=ones(size(borderRightY)).*frame.box.X(end);
    % % Left
    % borderLeftHeight=frame.upper.Y(end)-frame.box.Y(1);
    % borderLeftN=round(borderLeftHeight./borderDelta-1);
    % borderLeftY=linspace(frame.box.Y(1),frame.upper.Y(end),borderLeftN)';
    % borderLeftY(1)=[];
    % borderLeftY(end)=[];
    % borderLeftX=ones(size(borderLeftY)).*frame.box.X(1);
    % % Concat
    % frame.box.X=[frame.box.X ; borderRightX ; frame.upper.X ; borderLeftX];
    % frame.box.Y=[frame.box.Y ; borderRightY ; frame.upper.Y ; borderLeftY];
    % Light
    frame.box.X=[frame.box.X ; frame.upper.X];
    frame.box.Y=[frame.box.Y ; frame.upper.Y];
else
    % % Right
    % borderRightHeight=frame.upper.Y(end)-frame.box.Y(end);
    % borderRightN=round(borderRightHeight./borderDelta-1);
    % borderRightY=linspace(frame.box.Y(end),frame.upper.Y(end),borderRightN)';
    % borderRightY(1)=[];
    % borderRightY(end)=[];
    % borderRightX=ones(size(borderRightY)).*frame.box.X(end);
    % % Left
    % borderLeftHeight=frame.upper.Y(1)-frame.box.Y(1);
    % borderLeftN=round(borderLeftHeight./borderDelta-1);
    % borderLeftY=linspace(frame.box.Y(1),frame.upper.Y(1),borderLeftN)';
    % borderLeftY(1)=[];
    % borderLeftY(end)=[];
    % borderLeftX=ones(size(borderLeftY)).*frame.box.X(1);
    % % Concat
    % frame.box.X=[frame.box.X ; borderRightX ; flip(frame.upper.X) ; borderLeftX];
    % frame.box.Y=[frame.box.Y ; borderRightY ; flip(frame.upper.Y) ; borderLeftY];
    % Light
    frame.box.X=[frame.box.X ; flip(frame.upper.X)];
    frame.box.Y=[frame.box.Y ; flip(frame.upper.Y)];
end
%frame.box.X=[frame.box.X ; frame.box.X(1)]; % closed contour
%frame.box.Y=[frame.box.Y ; frame.box.Y(1)]; % closed contour
end