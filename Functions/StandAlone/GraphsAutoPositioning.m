%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                         GraphsAutoPositioning                         %%
%%                      Last update: April 11, 2022                      %%
%%                             Kévin Daigne                              %%
%%                        kevin.daigne@hotmail.fr                        %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% From several groups of non-positioned axes, gives the index position of
% each one in order to maximize their size if we position them all within
% the same figure. Index position corresponds to the position in a table
% (vertical position is given by the line number and the horizontal
% position by the order of appearance in pos). Groups of axes are
% defined so that axes in the same group have a side-by-side position
% and a common label.
%% - Inputs -
% axes = 1*NGroups cell and one group contains 1*NAxes cell
%   - e.g. ith axes of the jth group = axes{j}{i}
% fig = figure : 
%   - Figure containing axes (used only to calculate the width-to-height ratio)
%   - Possibility of directly entering the width-to-height ratio to avoid
%     having to convert units (MATLAB sometimes makes conversion errors)
%% - Options -
% 'View' =
%   - [] : Does not alter the view
%   - 'Equal' : Same view for all surface graphs, images, etc.
%   - 'Follow' : Keeps the width and height of the graph but modifies the central view
%   - The value can be specified using a single value (apply to all groups) or one per group
%   - In practice, within this function, only the fact that this option is empty or not is important
% 'FixedView' = [xMin xMax yMin yMax] or [xMin xMax yMin yMax zMin zMax]
%   - Necessary if View is not empty; determines the view to be fixed
%% - Output -
% pos = [axesNumber*4]
%   - lineNum(:,1) : Axes line index; for a given line, axes are listed from left to right
%   - ratio(:,2) : Axes width/height
%   - resizable(:,3) : 1 if resizable otherwise 0 (i.e. if axis equal activated)
%   - groupNumber(:,4) : Axes group index
%% - Method -
% We treat each group of axes as a rectangle of height 1 and width equal
% to the sum of the ratios (because dx=ratio*dy). This retangle will be
% positioned at the right-hand end of each line already created, leaving
% open the possibility of creating a new one. For each possibility, we
% look at the one that deviates least from the figure ratio.
% e.g.
% o it1: line1 | rect1       |-> OK
%         ------
% o it2: line1 | rect1 rect2 |-> Option 1 -> Ratio=(rect1dx+rect2dx)/~rect1dy
%        line2 |             |
%         ------
%        line1 | rect1       |-> Option 2 -> Ratio=(~rect1dx)/(rect1dy+rect2dy)
%        line2 | rect2       |
% We look at which option (1 or 2) is closest to the ratio (~16/9 in general for a full-screen figure)
%% -

function pos=GraphsAutoPositioning(axes,fig,varargin)

% #. Inputs
p=inputParser;
addOptional(p,'View',0);
addOptional(p,'FixedView',[]);
parse(p,varargin{:});
opts.View=p.Results.View;
FixedView=p.Results.FixedView;
string="View";
if iscell(opts.(string))
    if max(size(opts.(string)))==1
        opts.(string)=repmat(opts.(string),1,max(size(axes))); % Indicates the same value for all groups
    elseif max(size(opts.(string)))~=max(size(axes))
        return;
    end
else
    opts.(string)=repmat({opts.(string)},1,max(size(axes))); % Indicates the same value for all groups
end

% #. Figure
if isobject(fig)
    posFig=ObjectPosition(fig,'Type','Position','Units','Pixels');
    ratioFig=posFig(3)/posFig(4);
else
    ratioFig=fig;
end

% #. Initialization
axesPerGroups=cellfun(@(x) numel(x),axes);
groupNumber=numel(axes);
axesNumber=sum(axesPerGroups);
criterionFunc=@(xMax,yMax) abs(xMax-yMax*ratioFig); % Screen format criteria
xMax=zeros(1,groupNumber); yMax=0; dy=1; kAxes=0;
pos=zeros(axesNumber,6);
criterion=ones(1,groupNumber).*inf; % Set to inf so that rows not yet created do not affect the calculation
dxPerGroup=zeros(1,groupNumber);

% #. Loop on all the axes
for groupNum=1:groupNumber % Loop on groups
    for axesNum=1:numel(axes{groupNum}) % Loop on axes within the group
        kAxes=kAxes+1;
        if isequal(axes{groupNum}{axesNum}.DataAspectRatio,[1 1 1])
            
            % #.#. Non-resizable axes
            
            % #.#.#. Type
            pos(kAxes,5)=0;

            % #.#.#. Ratio
            if ~isempty(opts.View{groupNum}) && ~isempty(FixedView)
                % #.#.#.#. Imposed by the fixed view
                ratio=(FixedView(2)-FixedView(1))/(FixedView(4)-FixedView(3));
            else
                % #.#.#.#. Imposed by the current view
                v=axis(axes{groupNum}{axesNum});
                if numel(axis(axes{groupNum}{axesNum}))/2<3 % Axes dimension
                    % 2D
                    ratio=(v(2)-v(1))/(v(4)-v(3));
                else
                    % 3D
                    [~,ratio]=Projection3Dto2D(axes{groupNum}{axesNum});
                end
            end
            
        else
            
            % #.#. Resizable axes
            
            % #.#.#. Type
            pos(kAxes,5)=1;

            % #.#.#. Ratio
            posForRatio=ObjectPosition(axes{groupNum}{axesNum},'Type','Position','Units','Pixels');
            ratio=posForRatio(3)/posForRatio(4); % Do not use axes limits as there is no axis equal
            
        end

        % #.#. Outputs
        pos(kAxes,4)=ratio; % Ratio = width
        pos(kAxes,6)=groupNum; % Group index
        dxPerGroup(groupNum)=dxPerGroup(groupNum)+ratio; % Group width

    end
end

% #. Group positioning
dxMeanPerGroup=mean(dxPerGroup); 
if min(dxPerGroup)>dxMeanPerGroup*0.95 && max(dxPerGroup)<dxMeanPerGroup*1.05 && isscalar(unique(axesPerGroups))
    
    % #.#. Homogeneous group sizes
    % Processed differently to obtain axes in left-to-right and top-to-bottom order
    % #.#.#. Criterion calculation
    for columnNumber=1:groupNumber
        xMaxTemp=columnNumber*dxMeanPerGroup;
        yMaxTemp=ceil(axesNumber/columnNumber);
        criterion(columnNumber)=criterionFunc(xMaxTemp,yMaxTemp);
    end
    [~,columnNumber]=min(criterion);
    % #.#.#. Positioning
    kAxes=0; lineNum=1; columnNum=0;
    for groupNum=1:groupNumber % Loop on groups
        columnNum=columnNum+1;
        if columnNum>columnNumber
            columnNum=1; lineNum=lineNum+1;
        end
        for axesNum=1:numel(axes{groupNum}) % Loop on axes within the group
            kAxes=kAxes+1;
            pos(kAxes,1)=lineNum;
        end
    end
    
else
    
    % #.#. Non-homogeneous group sizes
    % xMax: width of each validated line from the previous iteration
    % xMaxTemp: width of each line having temporarily added the new group (for calculation)
    % y: line index from top
    % yMax: total height (number of lines)
    for groupNum=1:groupNumber % Loop on groups
        
        % #.#.#. Loop on each line
        for y=1:yMax+dy
            % We want to retrieve the width (xMax) and height
            % (yMax) of the window for each possibility to
            % deduce the ratio
            % #.#.#.#. Total width
            xMaxTemp=xMax; % Retrieves line widths
            xMaxTemp(y)=xMaxTemp(y)+dxPerGroup(groupNum); % Look at the width of line y if the new group is added
            xMaxTemp=max(xMaxTemp); % Total width = largest width
            % #.#.#.#. Total height
            if y==yMax+dy
                yMaxTemp=yMax+dy; % If new line, height changes
            else
                yMaxTemp=yMax; % If no new line, the height is the same as before
            end
            % #.#.#.#. Criterion calculation
            if xMaxTemp<=max(xMax)*1.2 && yMaxTemp<=yMax*1.2
                % If one of the figures hardly modifies the
                % maximum width without adding a line, then we
                % keep this location
                criterion(y)=0; % To minimize
                break;
            else
                % Otherwise we use the criterion
                criterion(y)=criterionFunc(xMaxTemp,yMaxTemp);
            end
        end
        
        % #.#.#. Processing results
        [~,lineNum]=min(criterion);
        % #.#.#.#. If adding a new line
        if lineNum==yMax+dy
            yMax=yMax+dy;
        end
        
        % #.#.#. Save position
        indInPos=find(pos(:,6)==groupNum); % Axes indices in pos
        pos(indInPos,1)=lineNum; % Line number
        pos(indInPos,3)=lineNum; % Y
        % We only know the position of the lower left edge and the total
        % width of the group, so for each axes in the group we need to
        % add the width of the previous one to find its position
        pos(indInPos(1),2)=xMax(lineNum);
        for axesNum=2:numel(axes{groupNum})
            pos(indInPos(axesNum),2)=pos(indInPos(axesNum-1),2)+pos(indInPos(axesNum-1),4);
        end
        
        % #.#.#. Adds the new width to the group
        xMax(lineNum)=xMax(lineNum)+dxPerGroup(groupNum);

    end
end

% #. Final processing
pos=sortrows(pos,[1 6 2]);
pos(:,2:3)=[];