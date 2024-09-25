%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                           BordersRemoving                             %%
%%                     Last update: January 04, 2022                     %%
%%                             Kévin Daigne                              %%
%%                        kevin.daigne@hotmail.fr                        %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Removes unnecessary edges from a figure so that the size of the figure
% matches the size of the objects (e.g. axes) inside. The size of the
% objects is maximized to be as large as possible without increasing the
% size of the figure. Also works for several objects within one uifigure.
% Can crop a figure by imposing negative margins.
%% - Input -
% fig = figure : figure with objects
%% - Options -
%
% <Basic usage>
%
% 'Margins' :
%   - Space left (see 'Units') between the edges of the figure and the components
%   - [double] -> [left=bottom=right=top]
%   - [double,double] -> [left=right,bottom=top]
%   - [double,double,double,double] -> [left,bottom,right,top]
%   - If the computation is performed on several levels (see 'Type'), it is
%       possible to specify a value per level using the row (e.g.
%       [.10 0 .10 0 ; .5 0 .5 0] will give lateral margins of .5 for all
%       secondary levels)
% 'Units' = 'Pixels' or 'Normalized' (default) :
%   - Unit for margins (if 'Normalized', normalized according to height of
%     figure without border before size modification).
%
% <Advanced usage>
%
% 'Crop' = 'On' or 'Off' (default) :
%   - The limits of a graph can be different than the extremal coordinates
%     (depending on the view). By default, crop to limits ('Off'), but it is
%     also possible to crop to extremal coordinates ('On').
% 'TicksOffset' = 'On' (default) or 'Off' :
%   - To keep horizontal colorbar ticks within the frame
% 'Type' = 'figure', 'uipanel', etc. :
%   - Change parent position until it finds the type (default is to change the position of the fig children only)
% 'Pause' (0.5 s by default) :
%   - Value of pause to avoid update problems during execution (increase if results are unsatisfactory)
%
%% -

function BordersRemoving(fig,varargin)

%% #. Options
p=inputParser;
addOptional(p,'Crop','Off');
addOptional(p,'Margins',[0 0 0 0]);
addOptional(p,'Units','Normalized');
addOptional(p,'Pause',0.5);
addOptional(p,'TicksOffset','On');
addOptional(p,'Type',[]);
parse(p,varargin{:});
crop=p.Results.Crop;
marginsInput=p.Results.Margins;
units=p.Results.Units;
type=p.Results.Type;
pauseValue=p.Results.Pause;
TicksOffsetOption=p.Results.TicksOffset;
kGround=0;
while 1
    kGround=kGround+1;

    %% #. Margins
    if kGround<=size(marginsInput,1)
        kMargins=kGround;
    else
        kMargins=size(marginsInput,1);
    end
    if isempty(marginsInput)
        margins=[0 0 0 0];
    elseif size(marginsInput,2)==1
        margins=[marginsInput(kMargins,1) marginsInput(kMargins,1) marginsInput(kMargins,1) marginsInput(kMargins,1)];
    elseif size(marginsInput,2)==2
        margins=[marginsInput(kMargins,1) marginsInput(kMargins,2) marginsInput(kMargins,1) marginsInput(kMargins,2)];
    elseif size(marginsInput,2)==4
        margins=[marginsInput(kMargins,1) marginsInput(kMargins,2) marginsInput(kMargins,3) marginsInput(kMargins,4)];
    else
        return;
    end

    %% #. Parent
    posFig=ObjectPosition(fig,'Type','Position','Units','Pixels');
    if isempty(posFig)
        return;
    end
    ratioFig=posFig(3)/posFig(4); % dxFig/dyFig
    autoSave=fig.AutoResizeChildren;
    if ~strcmpi(autoSave,'off')
        set(fig,'AutoResizeChildren','off');
    end

    %% #. Pre-calculation of positions
    % The aim here is to find the box that encompasses all the object's elements
    % posChild0: Object position excluding axes, title, etc. (before transformation)
    % posChild1: Object position including all (and only) its elements (before transformation)
    % offset: Offset between the position we set and the frame we're actually interested in
    % Axes:
    %   posChild1(3)
    %   |------|
    %   posChild0(3)
    %    |-----|
    %    ^        -              -
    %    |        |              |
    %   Y|        | posChild0(4) |
    %    |        |              | posChild1(4)
    %    ------>  -              |
    %       X                    -
    % uicontrol:
    %   -----------------
    %   |  Hello World  |
    %   -----------------
    %      posChild1(3)
    %      <--------->
    %      posChild0(3)
    %   <--------------->
    %
    posChild0=zeros(numel(fig.Children),4);
    posChild1=zeros(numel(fig.Children),4);
    childNumSave=zeros(1,numel(fig.Children)); % Only certain types of Childrens need to be treated
    offset=zeros(numel(fig.Children),4);
    for childNum=numel(fig.Children):-1:1
        % #.#. Position
        if isprop(fig.Children(childNum),'Position') && isprop(fig.Children(childNum),'Units')
            childNumSave(childNum)=childNum;
            posChild0(childNum,:)=ObjectPosition(fig.Children(childNum),'Type','Position','Units','Pixels');
            if isprop(fig.Children(childNum),'Extent') || strcmpi(fig.Children(childNum).Type,'uilabel') || strcmpi(fig.Children(childNum).Type,'uicontrol')

                % #.#.#. uicontrol or label
                % Extent gives the cropped position
                % Note that the extent property does not give x0 and y0
                posChildTemp=ObjectPosition(fig.Children(childNum),'Type','Position','Units','Pixels');
                if strcmpi(fig.Children(childNum).Type,'uilabel') || strcmpi(fig.Children(childNum).Type,'label')
                    figTemp=figure('Units','Pixels','Position',fig.Position,'Visible','off');
                    labelTemp=uicontrol(figTemp,'Units','Pixels','Position',posFig,'HorizontalAlignment',fig.Children(childNum).HorizontalAlignment,'FontAngle',fig.Children(childNum).FontAngle,'FontWeight',fig.Children(childNum).FontWeight,'Style', 'text','FontName',fig.Children(childNum).FontName,'FontSize',fig.Children(childNum).FontSize,'String',fig.Children(childNum).Text);
                    delete(figTemp);
                else
                    labelTemp.Extent=ObjectPosition(fig.Children(childNum),'Type','Extent','Units','Pixels');
                end
                if strcmpi(fig.Children(childNum).HorizontalAlignment,'center')
                    posChild1(childNum,:)=[posChildTemp(1)+(posChildTemp(3)-labelTemp.Extent(3))/2 ...
                        posChildTemp(2)+(posChildTemp(4)-labelTemp.Extent(4))/2 ...
                        labelTemp.Extent(3)...
                        labelTemp.Extent(4)];
                else
                    posChild1(childNum,:)=[posChildTemp(1) ...
                        posChildTemp(2)...
                        labelTemp.Extent(3)...
                        labelTemp.Extent(4)];
                end

            elseif isprop(fig.Children(childNum),'TightInset')

                % #.#.#. axes
                offset(childNum,:)=ObjectPosition(fig.Children(childNum),'Type','TightInset','Units','Pixels');
                if isequal(fig.Children(childNum).DataAspectRatio,[1 1 1])
                    % #.#.#.#. axis equal
                    % To find the exact position of the graph, use the plot
                    % ratio (valid only if all axes have the same scale). 
                    % The Position property does not give this data, but
                    % the box enclosing the graph.
                    xMax=[]; xMin=[]; yMax=[]; yMin=[];

                    if strcmpi(crop,'on')
                        % By default, the current view of the axis is used,
                        % but you can take only the extremal coordinates
                        for plotNum=1:numel(fig.Children(childNum).Children)
                            xMin=min([xMin min(min(fig.Children(childNum).Children(plotNum).XData))]);
                            xMax=max([xMax max(max(fig.Children(childNum).Children(plotNum).XData))]);
                            yMin=min([yMin min(min(fig.Children(childNum).Children(plotNum).YData))]);
                            yMax=max([yMax max(max(fig.Children(childNum).Children(plotNum).YData))]);
                        end
                        axis(fig.Children(childNum),[xMin xMax yMin yMax]);
                    end
                    v=axis(fig.Children(childNum));
                    if numel(v)<=4
                        % 2D
                        ratioPlot=(v(2)-v(1))/(v(4)-v(3));
                    else
                        % 3D
                        [~,ratioPlot]=Projection3Dto2D(fig.Children(childNum));
                    end
                else
                    % #.#.#.#. ~axis equal
                    % The axes can be modified independently, so we take
                    % the current ratio (unlike the previous case, the
                    % Position property gives the position of the graph).
                    %ratioPlot=posChild0(childNum,3)/posChild0(childNum,4);
                    ratioPlot=(fig.Children(childNum).PlotBoxAspectRatio(1)*posChild0(childNum,3)+offset(1)+offset(3)) ...
                        ./(fig.Children(childNum).PlotBoxAspectRatio(2)*posChild0(childNum,4)+offset(2)+offset(4));
                    %ratioPlot=(posChild0(childNum,3)-offset(1)-offset(3))/(posChild0(childNum,4)-offset(2)-offset(4));
                end
                % #.#.#.#. Calculation posChild1
                ratioAxis=posChild0(childNum,3)/posChild0(childNum,4); % Ratio of axis containing plots
                if ratioPlot>=ratioAxis
                    % ----------
                    % |  Axes  |
                    % |--------|
                    % |  Plot  |
                    % |--------|
                    % |  Axes  |
                    % ----------
                    longPos=1; longWidth=3; shortPos=2; shortWidth=4;
                else
                    % ----------------------
                    % |      |      |      |
                    % | Axes | Plot | Axes |
                    % |      |      |      |
                    % ----------------------
                    longPos=2; longWidth=4; shortPos=1; shortWidth=3;
                    ratioPlot=1/ratioPlot; % Ratio>1 for subsequent calculation
                end
                posChild1(childNum,longPos)=posChild0(childNum,longPos)-offset(childNum,longPos);
                posChild1(childNum,longWidth)=posChild0(childNum,longWidth)+offset(childNum,longPos)+offset(childNum,longWidth);
                posChild1(childNum,shortWidth)=posChild0(childNum,longWidth)/ratioPlot+offset(childNum,shortPos)+offset(childNum,shortWidth);
                posChild1(childNum,shortPos)=posChild0(childNum,shortPos)+(posChild0(childNum,shortWidth)-posChild1(childNum,shortWidth))/2-offset(childNum,shortPos);
                % #.#.#.#. Legends
                % External legends are not included in the TightInset
                % property, so they must be detected separately.
                colorbars=FindObjects(fig.Children(childNum)); colorbarsNumber=numel(colorbars); posColorbars=zeros(colorbarsNumber,4);
                if colorbarsNumber>0
                    for colorbarNum=1:colorbarsNumber
                        % #.#.#.#.#. Contours box
                        % Box containing legend, ticks and label
                        posColorbarTemp=ObjectPosition(colorbars(colorbarNum),'Type','Position','Units','Pixels');
                        posLabelTemp=ObjectPosition(colorbars(colorbarNum).Label,'Type','Position','Units','Pixels');
                        labelSize=ObjectPosition(colorbars(colorbarNum).Label,'Type','Extent','Units','Pixels');
                        % #.#.#.#.#.#. Position
                        % - Depending on the location, the positions to be
                        % taken into account are different. We don't use
                        % the location property directly, as it can no
                        % longer be interpreted in manual mode (unlike
                        % those shown below).
                        % - Note that we sometimes take the position of
                        % the plot and not the colorbar. For example, a
                        % horizontal colorbar will be wider than the plot
                        % because it will be the size of the axis. Since
                        % we want to cropper, we potentially want to reduce
                        % the width of the axis and therefore reduce the
                        % width of the colorbar.
                        if contains(colorbars(colorbarNum).Location,'outside') ...
                                || contains(colorbars(colorbarNum).Location,'manual')
                            if colorbars(colorbarNum).Label.Rotation==0
                                if colorbars(colorbarNum).Label.Position(2)<0
                                    % Type south
                                    posColorbars(colorbarNum,1)=posChild1(childNum,1);
                                    posColorbars(colorbarNum,2)=posColorbarTemp(2)+posLabelTemp(2)-labelSize(4);
                                    posColorbars(colorbarNum,3)=posChild1(childNum,3);
                                    posColorbars(colorbarNum,4)=posColorbarTemp(4)-posLabelTemp(2)+labelSize(4);
                                else
                                    % Type north
                                    posColorbars(colorbarNum,1)=posChild1(childNum,1);
                                    posColorbars(colorbarNum,2)=posColorbarTemp(2);
                                    posColorbars(colorbarNum,3)=posChild1(childNum,3);
                                    posColorbars(colorbarNum,4)=posLabelTemp(2)+labelSize(4);
                                end
                            else
                                if colorbars(colorbarNum).Label.Position(1)<0
                                    % Type west
                                    posColorbars(colorbarNum,1)=posColorbarTemp(1)+posLabelTemp(1)-labelSize(3);
                                    posColorbars(colorbarNum,2)=posChild1(childNum,2);
                                    posColorbars(colorbarNum,3)=posColorbarTemp(3)-posLabelTemp(1)+labelSize(3);
                                    posColorbars(colorbarNum,4)=posChild1(childNum,4);
                                else
                                    % Type east
                                    posColorbars(colorbarNum,1)=posColorbarTemp(1);
                                    posColorbars(colorbarNum,2)=posChild1(childNum,2);
                                    posColorbars(colorbarNum,3)=posLabelTemp(1)+labelSize(3);
                                    posColorbars(colorbarNum,4)=posChild1(childNum,4);
                                end
                                % Extremal ticks
                                % They potentially have some part higher
                                % than the colorbar (e.g. half-height if
                                % Ticks=lim) and if we don't take this
                                % into account, they'll be cropped. Note
                                % that for horizontal ticks, the problem
                                % is almost the same, and this is corrected
                                % later via the TicksOffset function.
                                % - Figure to use the extent property to determine tick heights
                                figTemp=figure('Units','Normalized','Position',[0 0 1 1],'Visible','off');
                                ticksMinLabel=uicontrol(figTemp,'Units','Pixels','Style', 'text','FontSize',colorbars(colorbarNum).FontSize,'String',colorbars(colorbarNum).TickLabels{1},'Position',get(figTemp,'Position'));
                                ticksMaxLabel=uicontrol(figTemp,'Units','Pixels','Style', 'text','FontSize',colorbars(colorbarNum).FontSize,'String',colorbars(colorbarNum).TickLabels{end},'Position',get(figTemp,'Position'));
                                dTicks(1)=ticksMinLabel.Extent(4); dTicks(2)=ticksMaxLabel.Extent(4);
                                delete(figTemp);
                                % - Determining the offset
                                yTicks=posColorbars(colorbarNum,4).*(colorbars(colorbarNum).Ticks([1 end])-colorbars(colorbarNum).Limits(1))...
                                    ./(colorbars(colorbarNum).Limits(2)-colorbars(colorbarNum).Limits(1))-dTicks/2; % y0 of the tick in relation to the lower edge of the colorbar
                                for tickNum=1:2
                                    if yTicks(tickNum)+dTicks(tickNum)>posColorbars(colorbarNum,4)
                                        shift(tickNum)=yTicks(tickNum)+dTicks(tickNum)-posColorbars(colorbarNum,4); % Tick above the colorbar
                                    elseif yTicks(tickNum)<0
                                        shift(tickNum)=abs(yTicks(tickNum)); % Tick below the colorbar
                                    else
                                        shift(tickNum)=0; % No offset required
                                    end
                                end
                                % - Processing
                                posColorbars(colorbarNum,2)=posColorbars(colorbarNum,2)-shift(1);
                                posColorbars(colorbarNum,4)=posColorbars(colorbarNum,4)+shift(1)+shift(2);
                            end
                            % #.#.#.#.#. Offset
                            offset(childNum,1)=max([offset(childNum,1);posChild1(childNum,1)-posColorbars(:,1)]);
                            offset(childNum,2)=max([offset(childNum,2);posChild1(childNum,2)-posColorbars(:,2)]);
                            offset(childNum,3)=max([offset(childNum,3);posColorbars(:,1)+posColorbars(:,3)-(posChild1(childNum,1)+posChild1(childNum,3))]);
                            offset(childNum,4)=max([offset(childNum,4);posColorbars(:,2)+posColorbars(:,4)-(posChild1(childNum,2)+posChild1(childNum,4))]);
                            % #.#.#.#.#. Position
                            posChild1(childNum,:)=[min([posChild1(childNum,1);posColorbars(:,1)])...
                                min([posChild1(childNum,2);posColorbars(:,2)])...
                                max([posChild1(childNum,1)+posChild1(childNum,3);posColorbars(:,1)+posColorbars(:,3)])-min([posChild1(childNum,1);posColorbars(:,1)])...
                                max([posChild1(childNum,2)+posChild1(childNum,4);posColorbars(:,2)+posColorbars(:,4)])-min([posChild1(childNum,2);posColorbars(:,2)])];
                        end
                    end
                end
            else
                % #.#.#. Other
                offset(childNum,:)=[0 0 0 0];
                posChild1(childNum,:)=posChild0(childNum,:);
            end
        end
    end
    % #.#. Unprocessed objects
    % Type AnnotationPane, etc.
    childNumSave(childNumSave==0)=[];

    %% #. Borders
    %           borders1:
    % ----------------------------- -
    % |         borders0:         | | Margin(4)*H
    % | ------------------------- | -
    % | | Object 1 |            | | |
    % | |-----------            | | |
    % | |                       | | | H
    % | |            -----------| | |
    % | |            | Object 2 | | |
    % | ------------------------- | -
    % |                           | | Margin(2)*H
    % ----------------------------- -
    % #.#. borders0
    % Encompasses posChild1
    borders0=[min(posChild1(childNumSave,1)) min(posChild1(childNumSave,2)) max(posChild1(childNumSave,1)+posChild1(childNumSave,3))-min(posChild1(childNumSave,1)) max(posChild1(childNumSave,2)+posChild1(childNumSave,4))-min(posChild1(childNumSave,2))];
    if ~strcmpi(units,'pixels')
        margins=margins*borders0(4);
    end
    % #.#. borders1
    % Encompasses posChild1 by adding margins (useful only for ratio calculation)
    borders1=[borders0(1)-margins(1) borders0(2)-margins(2) borders0(3)+margins(1)+margins(3) borders0(4)+margins(2)+margins(4)];
    ratioBorders1=borders1(3)/borders1(4);
    % #.#. borders2
    % Final edge calculated from the figure, removing margins and
    % maintaining the ratio given by borders1. This is done because the
    % final size is constrained by the size of the figure (we maximize
    % the size of the elements without increasing the size of the figure).
    borders2=zeros(1,4);
    if ratioBorders1>=ratioFig
        %              fig:
        % ----------------------------- -
        % |         borders2:         | | >=Margin(4)*H
        % | ------------------------- | -
        % | |       borders1:       | |
        % | |        ------         | |
        % | |        |    |         | |  (ratioBorders1=ratioBorders2)>ratioFig
        % | |        ------         | |
        % | |                       | |
        % | ------------------------- | -
        % |                           | | >=Margin(2)*H
        % ----------------------------- -
        % <-> =Margin(1)*H          <-> =Margin(3)*H
        longPos=1; longWidth=3; shortPos=2; shortWidth=4;
    else
        %              fig:  <--------> >=Margin(3)*H
        % ----------------------------- -
        % |         borders2:         | | =Margin(4)*H
        % |       ------------        | -
        % |       | borders1:|        |
        % |       |   ----   |        |
        % |       |   |  |   |        |  (ratioBorders1=ratioBorders2)<ratioFig
        % |       |   ----   |        |
        % |       |          |        |
        % |       ------------        | -
        % |                           | | =Margin(2)*H
        % ----------------------------- -
        % <-------> >=Margin(1)*H
        longPos=2; longWidth=4; shortPos=1; shortWidth=3;
    end
    borders2(longPos)=margins(longPos);
    borders2(longWidth)=posFig(longWidth)-margins(longPos)-margins(longWidth);
    borders2(shortWidth)=borders2(longWidth)*borders1(shortWidth)/borders1(longWidth);
    borders2(shortPos)=margins(shortPos);
    scale=borders2(longWidth)/borders0(longWidth);
    if scale<0
        msgbox('Reduce the margins value.','Information','help'); return;
    end

    %% #. Final positions

    % #.#. Objects
    % posChild2 : Final position of object excluding axes, title, etc. (after transformation)
    % #.#.#. Non-label items
    posChild2=[(posChild1(:,1)-borders0(1)).*scale+offset(:,1)+margins(1)...
        (posChild1(:,2)-borders0(2)).*scale+offset(:,2)+margins(2)...
        posChild1(:,3).*scale.*(1-(offset(:,1)+offset(:,3))./posChild1(:,3))... % We have calculated the increase in (delta+offset) so we correct to have only delta
        posChild1(:,4).*scale.*(1-(offset(:,2)+offset(:,4))./posChild1(:,4))];
    % #.#.#. Labels
    % Since we're using the extent property, we can't have a smaller width,
    % otherwise the text won't be displayed completely, which may be the
    % case if we multiply it by scale.
    for childNum=childNumSave
        if isprop(fig.Children(childNum),'Extent') || strcmpi(fig.Children(childNum).Type,'uilabel') || strcmpi(fig.Children(childNum).Type,'label')
            posChild2(childNum,1)=posChild2(childNum,1)+(posChild2(childNum,3)-posChild1(childNum,3))/2;
            posChild2(childNum,3)=posChild1(childNum,3);
        end
    end

    % #.#. Actual size of figure
    % It is assumed that the size of an object set (posChild1) is modified
    % by a scale factor. However, only elements corresponding to posChild0
    % will be affected (e.g. the thickness of the colorbar does not change
    % when the size of the axis is modified). This assumption is necessary
    % when you have several objects, but gives unsatisfactory results on
    % the edges of the figure (~=margins). We therefore calculate the real
    % final edge.
    xMin=min(posChild2(childNumSave,1)-offset(childNumSave,1));
    yMin=min(posChild2(childNumSave,2)-offset(childNumSave,2));
    xMax=max(posChild2(childNumSave,1)+posChild2(childNumSave,3)+offset(childNumSave,3));
    yMax=max(posChild2(childNumSave,2)+posChild2(childNumSave,4)+offset(childNumSave,4));
    dxFig=xMax-xMin+margins(1)+margins(3);
    dyFig=yMax-yMin+margins(2)+margins(4);

    %% #. Modifying objects
    % #.#. Crop fig
    % For the figure to be exactly the size of borders 2 + margins
    % Note that we keep the same center for the figure
    ObjectPosition(fig,'Type','InnerPosition','Units','Pixels','Set',[posFig(1)+posFig(3)/2-dxFig/2 posFig(2)+posFig(4)/2-dyFig/2 dxFig dyFig]);
    drawnow;

    % #.#. Object position
    pause(pauseValue);
    for childNum=childNumSave
        % #.#.#. Objects
        ObjectPosition(fig.Children(childNum),'Type','Position','Units','Pixels','Set',posChild2(childNum,:));
        % #.#.#. Tick correction
        % To prevent horizontal colorbar ticks from leaving the frame
        if strcmpi(fig.Children(childNum).Type,'axes') && strcmpi(TicksOffsetOption,'On')
            TicksOffset(fig.Children(childNum))
        end
    end

    %% #. Final processing
    if ~strcmpi(autoSave,'off')
        % #.#. Property reset
        set(fig,'AutoResizeChildren','on');
    end
    if isempty(fig.Type) || strcmpi(fig.Type,type) || isempty(fig.Parent) || strcmpi(fig.Parent.Type,'root')
        % #.#. Stop criterion
        break;
    else
        % #.#. New parent
        fig=fig.Parent;
    end

end

end