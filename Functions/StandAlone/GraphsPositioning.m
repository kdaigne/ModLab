%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                           GraphsPositioning                           %%
%%                     Last update: January 03, 2022                     %%
%%                             Kévin Daigne                              %%
%%                        kevin.daigne@hotmail.fr                        %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Gives the normalized position of axes in a figure from their index positions 
% (i.e. position in a table given by the line number for vertical position
% and order of appearance in posTemp for horizontal one). Groups of axes 
% are defined so that axes in the same group have a side-by-side
% position and a common label.
%% - Inputs -
% posIndex = axesNumber*4 double
%   - lineNum(:,1) : Axes line index; for a given line, axes are listed from left to right
%   - ratio(:,2) : Axes width/height
%   - resizable(:,3) : 1 if resizable otherwise 0 (i.e. if axis equal activated)
%   - groupNumber(:,4) : Group index
% fig = figure : Figure containing axes
%% - Options -
% The values of the following options can be specified using a single value (apply to all groups) or one per group
% 'Label' : Title shown above an axes group
% 'FontSize' : Font size used for labels
% 'MinimumlWidth' (0.4 by default) : 
%   - Technically, resizable axes can have a width of almost zero, which leads to unsatisfactory behavior
%   - Resizable axes must have a width greater than opts.MinimumlWidth*[average width of non resizable axes on the line]
%% - Outputs -
% pos = axesNumber * [x0 y0 dx dy] : 
%   - Position of each axes
%   - The first row corresponds to the 1st axes in the 1st group, the
%     2nd to the 2nd axes in the 1st group and so on (i.e. not the order
%     given in posTemp)
% posL = groupNumber * [x0 y0 dx dy] : Position of each label
%% - Method -
% Index positions must be converted to normalized positions. As some
% axes can be resized (no axis equal, so width can be modified without
% affecting height), we need to set their width in relation to the free
% space left by the non-resizable axes on the line, and thus optimize space.
% However, a lower limit must be set, otherwise some axes may become
% unreadable. This is the role of the 'MinimumlWidth' value, which defines
% that the width of a resizable axes must not be less than a certain
% value.
%% -

function [pos,posL]=GraphsPositioning(posIndex,fig,varargin)

% #. Figure
if isobject(fig)
    posFig=ObjectPosition(fig,'Type','Position','Units','Pixels');
    ratioFig=posFig(3)/posFig(4);
else
    posFig=fig;
    ratioFig=posFig(3)/posFig(4);
end

% #. Initialization
p=inputParser;
addOptional(p,'Label',[]);
addOptional(p,'FontSize',[]);
addOptional(p,'MinimumlWidth',0.4);
parse(p,varargin{:});
opts=p.Results;
posIndex=sortrows(posIndex,4);
pos=zeros(size(posIndex,1),4); posL=zeros(max(posIndex(:,end)),4);
dy0=1/max(posIndex(:,1)); % Constant line height
dy1=zeros(size(posIndex,1),1); % Line heights deducted from label heights
posIndex(:,2)=posIndex(:,2)/ratioFig; % Since we use normalized coordinates, 1 in height is not equal to 1 in width, unlike pixels
for string=["Label" "FontSize"]
    if iscell(opts.(string))
        if max(size(opts.(string)))==1
            opts.(string)=repmat(opts.(string),1,max(posIndex(:,end))); % Indicates the same value for all groups
        elseif max(size(opts.(string)))~=max(posIndex(:,end))
            return;
        end
    else
        opts.(string)=repmat({opts.(string)},1,max(posIndex(:,end))); % Indicates the same value for all groups
    end
end

% #. Label dimensions (dx and dy)
figTemp=figure('Units','Pixels','Position',posFig,'Visible','off');
for groupNum=1:max(posIndex(:,end)) % Loop on each group
    if ~isempty(opts.Label)
        % #.#. Create a uicontrol to use the extent feature
        if ~isempty(opts.Label{groupNum}) && ~strcmpi(opts.Label{groupNum},'')
            if ~isempty(opts.FontSize{groupNum})
                labelTemp=uicontrol('Parent',figTemp,'Style', 'text','HorizontalAlignment','center','FontWeight','bold','FontSize',opts.FontSize{groupNum},'FontAngle','italic','String',opts.Label{groupNum});
            else
                labelTemp=uicontrol('Parent',figTemp,'Style', 'text','HorizontalAlignment','center','FontWeight','bold','FontAngle','italic','String',opts.Label{groupNum});
            end
            labelTemp.Position=posFig;
            posLTemp=labelTemp.Extent;
            posL(groupNum,3)=posLTemp(3)/posFig(3);
            posL(groupNum,4)=posLTemp(4)/posFig(4);
        end
    end
end
delete(figTemp);

% #. Loop on lines
for lineNum=1:max(posIndex(:,1))
    
    % #.#. Index
    indVect=find(posIndex(:,1)==lineNum); % Axes indexes on lineNum in posTemp
    indNonResizable=intersect(find(posIndex(:,3)==0),indVect); % Axes indexes on lineNum in posTemp
    indResizable=intersect(find(posIndex(:,3)==1),indVect); % Plot indices on lineNum in posTemp
    groupNumVect=unique(posIndex(indVect,end)); % Indices of groups present on lineNum in posTemp
    
    % #.#. Height for each axes
    dy1(indVect)=dy0-posL(posIndex(indVect,end),4); % The height available for axes is adapted to the size of the label
    
    % #.#. dxNR
    nR=numel(indNonResizable); % Number of resizable axes
    nNR=numel(indResizable); % Number of non-resizable axes
    if nR>0
        lR=sum(dy1(indNonResizable).*posIndex(indNonResizable,2)); % Cumulative width of resizable axes
    else
        lR=0;
    end
    if nNR>0
        dxNR=(1-lR)/nNR; % Cumulative width of non-resizable axes
    else
        dxNR=0;
    end
    
    % #.#. Correction
    % If resizables are too small and/or non-resizables alone exceed the limits (if lR>1)
    if dxNR<opts.MinimumlWidth*lR/nR && nNR>0
        % Width resizable + non-resizable too large
        alpha=1/(lR*(1+opts.MinimumlWidth*nNR/nR));
        dxNR=(1-lR*alpha)/nNR;
    elseif lR>1
        % Non-resizable width too large
        alpha=1/lR;
    else
        % No correction is required
        alpha=1;
    end
    
    % #.#. Processing
    % Centers the entire line horizontally if its width is smaller than
    % the figure, and each axes vertically in relation to its line
    % #.#.#. Non-resizable
    if nR>0
        pos(indNonResizable,3)=dy1(indNonResizable).*posIndex(indNonResizable,2)*alpha; % Width
        pos(indNonResizable,4)=dy1(indNonResizable).*alpha; % Height
    end
    % #.#.#. Resizable
    if nNR>0
        pos(indResizable,3)=dxNR; % Width
        for groupNum=1:numel(groupNumVect)
            % The height of resizable axes is equal to the maximum height of group non-resizable on the line
            maxValue=max(pos(intersect(indNonResizable,find(posIndex(:,end)==groupNumVect(groupNum))),4));
            if ~isempty(maxValue)
                pos(intersect(indResizable,find(posIndex(:,4)==groupNumVect(groupNum))),4)=max(pos(intersect(indNonResizable,find(posIndex(:,4)==groupNumVect(groupNum))),4));
            else % Only resizable on the line
                pos(intersect(indResizable,find(posIndex(:,4)==groupNumVect(groupNum))),4)=dy1(intersect(indResizable,find(posIndex(:,4)==groupNumVect(groupNum))));
            end
        end
    end
    
    % #.#.#. General
    pos(indVect(2:end),1)=cumsum(pos(indVect(1:end-1),3)); % X0
    pos(indVect,2)=1-lineNum*dy0+(dy1(indVect)-pos(indVect,4))/2; % Y0, the figure may be smaller than dy0, so it must be centered on its line
    pos(indVect,1)=pos(indVect,1)+(1-sum(pos(indVect,3)))/2; % Center the line horizontally if its width is less than 1
    
    % #.#.#. Label positions
    % The labels must be centered in relation to the group, and their Y0
    % must be at the height of the largest figure in the group, but may
    % still be smaller than dy0. The unit is always the pixel.
    
    for groupNum=1:numel(groupNumVect)
        
        if ~isempty(opts.Label{groupNumVect(groupNum)}) && ~strcmpi(opts.Label{groupNumVect(groupNum)},'')
            
            % #.#.#.#. Index
            indTempGroup=find(posIndex(:,end)==groupNumVect(groupNum)); % Looking for common groups
            indGroupVect=intersect(indTempGroup,indVect); % Group element index on the line
            
            % #.#.#.#. Text width
            % Depending on the width of the text, it may be larger or
            % smaller than the width of the group
            xMin=min(pos(indGroupVect,1));
            xMax=max(pos(indGroupVect,1)+pos(indGroupVect,3));
            xMean=((xMin+xMax)/2);
            
            % #.#.#.#. Text width correction
            % We take the higher value between its width via extent and
            % the width of the axes in the group to ensure that the text
            % is displayed completely.
            posL(groupNumVect(groupNum),3)=max([posL(groupNumVect(groupNum),3) sum(pos(indGroupVect,3))]);
            
            % #.#.#.#. Text X0
            xL=(xMean-posL(groupNumVect(groupNum),3)/2);
            
            % #.#.#.#. Text Y0
            % We want the label to be just above the highest axes
            yL=max(pos(indGroupVect,2)+pos(indGroupVect,4));
            
            % #.#.#.#. Processing
            posL(groupNumVect(groupNum),1:1:4)=[xL*posFig(3) yL*posFig(4) posL(groupNumVect(groupNum),3)*posFig(3) posL(groupNumVect(groupNum),4)*posFig(4)];
            
            % #.#.#.#. Correction if label out of bounds
            shiftInPixel=posL(groupNumVect(groupNum),2)+posL(groupNumVect(groupNum),4)-(1-dy0*lineNum+dy0)*posFig(4);
            if shiftInPixel>0
                posL(groupNumVect(groupNum),2)=posL(groupNumVect(groupNum),2)-shiftInPixel+1;
            end
        end
    end

end