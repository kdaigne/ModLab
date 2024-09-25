%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                               OverView                                %%
%%                       Last update: April 12, 2022                     %%
%%                             Kévin Daigne                              %%
%%                        kevin.daigne@hotmail.fr                        %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Copies a set of axes to a single window. 
% Automatic positioning to maximize size. 
% Common scaling according to certain parameters.
%% - Input -
% axesToImport = cells : 1*N {groups} composed of 1*M {axes}: 
%   - Group : group of axes positioned horizontally and side by side
%   - Axes : axes containing the graphs to be copied
%% - Options -
% 'Parent' : Object containing the overview panel (e.g. figure)
% 'Position' = [x0 y0 dx dy] : Normalized position of the figure to be created if no parent is specified
% 'ManualPositioning' = 0 ou 1 (default): Automatic group positioning or not
% 'DataTips' = 0 ou 1 (default) : Enable or disable transfer of data tips to overview (time-consuming)
%
% The values of the following options can be specified using a single value (apply to all groups) or one per group
% 'View' =
%   - [] : Does not alter the view
%   - 'Equal' : Same view for all surface graphs, images, etc.
%   - 'Follow' : Keeps the width and height of the axes but modifies the central view
% 'Label' = 1*NGroups cell : Title shown above a group of axes
% 'AxisScale' = 1*NGroups double a value from -inf to inf (-2 by default and inf to disable it) : For plot axis, determines the number of label parts (i.e. words) to be taken into account to consider 2 axis as identical and apply common limits (explained below)
% 'ColorScale' = 1*NGroups double a value from -inf to inf (-2 by default and inf to disable it) : For colorbars, determines the number of label parts (i.e. words) to be taken into account to consider 2 colorbars as identical and apply common limits (explained below)
% 'FontSize' : Font size used
% 'TicksNumber' : Number of ticks on colorbars
% 'TicksColor' = 'auto', 'r', etc. : Color of colorbar ticks (found automatically if auto)
%% - Scaling method (AxisScale and ColorScale) -
% Label used: XLabel or YLabel for a plot, colorbar title for others
% Data are indicated by square brackets [var1]*[var2].
% AxisScale and ColorScale function identically, except that each data is treated independently for axes
% Examples for a positive value (starting from the beginning):
% AxisScale=1 : [Force X Contact]*[Force Y Coulomb] -> [Force]*[Force] -> all axes containing this label after transformation will have the same limits
% ColorScale=1: Velocity tensor (magnitude) -> Velocity -> all colorbars containing this label after transformation will have the same limits
% Examples for a negative value (starting from the end):
% AxisScale=-1: [Force X Contact]*[Force Y Coulomb] -> [Force X]*[Force Y] -> all axes containing this label after transformation will have the same limits
% ColorScale=-1 : Velocity tensor (magnitude) -> Velocity tensor -> all colorbars containing this label after transformation will have the same limits
%% -

function OverView(axesToImport,varargin)

% #. Remove empty cells from axes
axesToImport(cellfun(@isempty,axesToImport))=[];
for groupNum=1:numel(axesToImport) % Loop on each group
    axesToImport{groupNum}(cellfun(@isempty,axesToImport{groupNum}))=[];
end
axesToImport(cellfun(@isempty,axesToImport))=[];

% #. Options
p=inputParser;
addOptional(p,'Parent',[]);
addOptional(p,'Position',[0 0 1 1]);
addOptional(p,'Label',[]);
addOptional(p,'ManualPositioning',1);
addOptional(p,'View',0);
addOptional(p,'AxisScale',-2);
addOptional(p,'ColorScale',-2);
addOptional(p,'FontSize',[]);
addOptional(p,'TicksNumber',5);
addOptional(p,'TicksColor',[]);
addOptional(p,'DataTips',1);
parse(p,varargin{:});
opts=p.Results;
for string=["Label" "View" "AxisScale" "ColorScale" "FontSize" "TicksNumber" "TicksColor"]
    if iscell(opts.(string))
        if max(size(opts.(string)))==1
            opts.(string)=repmat(opts.(string),1,max(size(axesToImport))); % Indicates the same value for all groups
        elseif max(size(opts.(string)))~=max(size(axesToImport))
            return;
        end
    else
        opts.(string)=repmat({opts.(string)},1,max(size(axesToImport))); % Indicates the same value for all groups
    end
end

% #. Axis limits
[XLimValue,XLimInd,YLimValue,YLimInd,spaceScaleLimValue,colorLimValue,colorLimInd]=GraphsLimits(axesToImport,'View',opts.View,'AxisScale',opts.AxisScale,'ColorScale',opts.ColorScale);

% #. Figure
if isempty(opts.Parent)
    opts.Parent=figure('Name','Overview','Units','Normalized','Position',[0.1 0.1 0.8 0.8],'Color',[1 1 1]);
end
posFig=ObjectPosition(opts.Parent,'Type','Position','Units','Pixels');
ratioFig=posFig(3)/posFig(4);

% #. Normalized positions by line height
posTemp=GraphsAutoPositioning(axesToImport,ratioFig,'View',opts.View,'FixedView',spaceScaleLimValue);

% #. Fixed position
% We need to modify the line number (1), x0 (2) and y0 (3).
if opts.ManualPositioning
    posTemp=sortrows(posTemp,4); % To return to the same order as axes
    [~,ind,~]=unique(posTemp(:,4));
    groupList=posTemp(ind,4);
    if ~isempty(opts.Label)
        prompt=strcat('Group',{' '},cellfun(@num2str,num2cell(1:numel(axesToImport)),'UniformOutput',false),' (',reshape(opts.Label,1,[]),'):');
    else
        prompt=strcat('Group',{' '},cellfun(@num2str,num2cell(1:numel(axesToImport)),'UniformOutput',false),':');
    end
    dlgtitle='Enter the line number for each group';
    dims=[1 100];
    definput=num2cell(num2str(posTemp(ind,1)));
    answer=inputdlg(prompt,dlgtitle,dims,definput);
    if ~isempty(answer) && ~all(strcmpi(answer,definput))
        for groupNum=1:1:numel(answer)
            posTemp(posTemp(:,end)==groupList(groupNum),1)=str2double(answer{groupNum}); % lineNumber
        end
    end
end

% #. Normalized positions according to figure
[pos,posL]=GraphsPositioning(posTemp,posFig,'Label',opts.Label,'FontSize',opts.FontSize);

% #. Loop on groups
kAxes=0; kXResizable=0; kYResizable=0; kColorbar=0;
for groupNum=1:numel(axesToImport)
    
    % #.#. Label
    % They must be in front of the axes so as not to hide the toolbar
    if ~isempty(opts.Label)
        if ~isempty(opts.Label{groupNum}) && ~strcmpi(opts.Label{groupNum},'')
            try
                % Compatible with figure
                if ~isempty(opts.FontSize{groupNum})
                    label=uicontrol(opts.Parent,'Units','Normalized','Style','text','String',opts.Label{groupNum},'HorizontalAlignment','center','FontWeight','bold','FontAngle','italic','FontSize',opts.FontSize{groupNum},'BackgroundColor',[1 1 1]);
                else
                    label=uicontrol(opts.Parent,'Units','Normalized','Style','text','String',opts.Label{groupNum},'HorizontalAlignment','center','FontWeight','bold','FontAngle','italic','BackgroundColor',[1 1 1]);
                end
                label.Position=posL(groupNum,1:1:4)./posFig([3 4 3 4]); % For some reason, if the position isn't normalized, the label won't be positioned exactly right (normalized is not compatible with uilabel, but it doesn't have this problem)
            catch
                % Compatible with uifigure
                if ~isempty(opts.FontSize{groupNum})
                    label=uilabel(opts.Parent,'Text',opts.Label{groupNum},'HorizontalAlignment','center','FontWeight','bold','FontSize',opts.FontSize{groupNum},'FontAngle','italic','FontColor',[0 0 0]);
                else
                    label=uilabel(opts.Parent,'Text',opts.Label{groupNum},'HorizontalAlignment','center','FontWeight','bold','FontAngle','italic','FontColor',[0 0 0]);
                end
                label.Position=posL(groupNum,1:1:4);
            end 
        end
    end
    
    % #.#. Loop on axes
    for axesNum=1:numel(axesToImport{groupNum})
        kAxes=kAxes+1;
        if isequal(axesToImport{groupNum}{axesNum}.DataAspectRatio,[1 1 1])
            
            % #.#.#. Non-resizable axes type
            
            % #.#.#.#. Color background for 3D figures
            % Matlab colors a 3D volume, not the complete background of
            % the axis. We therefore add a background axis which will not
            % contain any data.
            if numel(axis(axesToImport{groupNum}{axesNum}))/2>=3 % Axes dimension
                axCadre=uiaxes('Units','normalized','Position',pos(kAxes,:),'Parent',opts.Parent,'Box','on','LineWidth',1,'HandleVisibility','Off');
                axCadre.XColor=axesToImport{groupNum}{axesNum}.Color;
                axCadre.YColor=axesToImport{groupNum}{axesNum}.Color;
                set(axCadre,'color',axesToImport{groupNum}{axesNum}.Color);
                set(axCadre,'xtick',[]);
                set(axCadre,'ytick',[]);
                set(axCadre,'ztick',[]);
                set(axCadre,'XColor','none');
                set(axCadre,'YColor','none');
                set(axCadre,'ZColor','none');
                axCadre.Toolbar.Visible = 'off'; % The frame toolbar can be overlapped with the axes toolbar
            end
            
            % #.#.#.#. Copy
            [~,indObjects,indAxes]=FindObjects(axesToImport{groupNum}{axesNum});
            set(0,'showhiddenhandles','on');
            ax=copyobj(axesToImport{groupNum}{axesNum}.Parent.Children([indAxes indObjects]),opts.Parent);
            ObjectPosition(ax(1),'Type','Position','Units','Normalized','Set',pos(kAxes,:));
            set(0,'showhiddenhandles','off');
            
            % #.#.#.#. Spatial limits
            if strcmpi(opts.View{groupNum},'Equal')==1
                axis(ax(1),spaceScaleLimValue);
            elseif strcmpi(opts.View{groupNum},'Follow')==1
                % Use reshape to be valid in 2D and 3D
                delta=reshape(spaceScaleLimValue,2,[])';
                delta=delta(:,2)-delta(:,1); % Axis width (max-min)
                center=reshape(axis(axesToImport{groupNum}{axesNum}),2,[]);
                center=mean(center)'; % Coordinates of the center of the original axes
                posLag=[center-delta/2 center+delta/2];
                posLag=reshape(posLag',1,[]); % Axis final position
                axis(ax(1),posLag);
            end
            
            % #.#.#.#. Colorbar and colormap processing
            colorbarNumber=numel(ax)-1;
            for colorbarNum=1:colorbarNumber
                % #.#.#.#.#. Position change
                if colorbarNumber==1
                    ax(1+colorbarNum).Location='South';
                elseif colorbarNumber==2
                    if colorbarNum==1
                        ax(1+colorbarNum).Location='west';
                    else
                        ax(1+colorbarNum).Location='east';
                    end
                end
                % #.#.#.#.#. FontSize
                if ~isempty(opts.FontSize{groupNum})
                    ax(1+colorbarNum).Label.FontSize=opts.FontSize{groupNum};
                    ax(1+colorbarNum).FontSize=opts.FontSize{groupNum};
                end
            end
            % #.#.#.#.#. TicksColor
            optsTemp=struct();
            if ~isempty(opts.TicksColor{groupNum})
                if strcmpi(opts.TicksColor{groupNum},'auto')
                    nearestColor=imbinarize(rgb2gray(axesToImport{groupNum}{axesNum}.Color),0.5);
                    if isequal(nearestColor,[1 1 1])
                        color=[0 0 0];
                    else
                        color=[1 1 1];
                    end
                else
                    color=opts.TicksColor{groupNum};
                end
                optsTemp.TicksColor=color;
                optsTemp.ColorbarNameColor=color;
            end
            % #.#.#.#.#. TicksNumber
            if ~isempty(opts.TicksNumber)
                optsTemp.TicksNumber=opts.TicksNumber{groupNum};
            end
            % #.#.#.#.#. Limits
            if colorbarNumber==1
                optsTemp.NewLimits={[colorLimValue{colorLimInd(kColorbar+1),2:3}]};
            elseif colorbarNumber==2
                optsTemp.NewLimits={[colorLimValue{colorLimInd(kColorbar+1),2:3}] [colorLimValue{colorLimInd(kColorbar+2),2:3}]};
            elseif colorbarNumber>2
                optsTemp.NewLimits=cell(1,colorbarNumber);
                for colorbarNum=1:1:colorbarNumber
                    optsTemp.NewLimits{colorbarNum}=[colorLimValue{colorLimInd(kColorbar+colorbarNum),2:3}];
                end
            end
            % #.#.#.#.#. Processing
            if colorbarNumber>=1
                ColorbarsRefresh(ax(1),optsTemp,'Normalized','last');
            end
            % #.#.#.#. Data Tips
            % Labels are not copied with copyobj
            if opts.DataTips==1
                for plotNum=numel(axesToImport{groupNum}{axesNum}.Children):-1:1
                    % #.#.#.#.#. Creating temporary datatips
                    % The creation of a datatip allows the axes to be updated, otherwise they are not detected.
                    if numel(axis(axesToImport{groupNum}{axesNum}))/2==2 % Axes dimension
                        % 2D
                        dt1 = datatip(ax(1).Children(plotNum),0,0,'Visible','off');
                        dt2 = datatip(ax(1).Children(plotNum),0,0,'Visible','off');
                    else
                        % 3D
                        dt1 = datatip(ax(1).Children(plotNum),0,0,0,'Visible','off');
                        dt2 = datatip(ax(1).Children(plotNum),0,0,0,'Visible','off');
                    end
                    % #.#.#.#.#. Processing
                    if isprop(axesToImport{groupNum}{axesNum}.Children(plotNum),'DataTipTemplate')
                        ax(1).Children(plotNum).DataTipTemplate.DataTipRows=axesToImport{groupNum}{axesNum}.Children(plotNum).DataTipTemplate.DataTipRows;
                    end
                    delete(dt1); delete(dt2);
                end
            end
             
            % #.#.#.#. Color background for 3D figures
            % We remove the color from the figure because we've already
            % added a background, and the axis frame can overlap slightly
            % from the background.
            if numel(axis(axesToImport{groupNum}{axesNum}))/2>=3 % Axes dimension
                ax(1).Color='none';
            end
            
            % #.#.#.#. Toolbar
            axtoolbar(ax(1),{'export','brush','datacursor','rotate','pan','zoomin','zoomout'});
            kColorbar=kColorbar+colorbarNumber;
        else
            
            % #.#.#. Plot
            
            if isscalar(axesToImport{groupNum}{axesNum}.YAxis)
                ax=copyobj(axesToImport{groupNum}{axesNum},opts.Parent);
            elseif numel(axesToImport{groupNum}{axesNum}.YAxis)==2
                ax=CopyobjYyaxis(axesToImport{groupNum}{axesNum},opts.Parent);
                % For double yaxis, the position is relative to the origin,
                % while for single yaxis it is relative to the axis labels
            else
                continue;
            end
            for axeName=['X' 'Y']
                for sideNum=1:numel(ax(end).([axeName 'Axis'])) % If several axis e.g. yyaxis
                    if axeName=='X'
                        kXResizable=kXResizable+1;
                        ax(end).([axeName 'Axis'])(sideNum).Limits=cell2mat(XLimValue(XLimInd(kXResizable),2:3));
                    else
                        kYResizable=kYResizable+1;
                        ax(end).([axeName 'Axis'])(sideNum).Limits=cell2mat(YLimValue(YLimInd(kYResizable),2:3));
                    end
                end
            end
            ObjectPosition(ax(end),'Type','Position','Units','Normalized','Set',pos(kAxes,:));
            axtoolbar(ax(end),{'export','brush','datacursor','rotate','pan','zoomin','zoomout'});
        end
        
        % #.#.#. FontSize
        if ~isempty(opts.FontSize{groupNum})
            ax(1).FontSize=opts.FontSize{groupNum};
            for axeName=['X' 'Y']
                for sideNum=1:numel(ax(1).([axeName 'Axis'])) % If several axis e.g. yyaxis
                    ax(1).([axeName 'Axis'])(sideNum).FontSize=opts.FontSize{groupNum};
                    ax(1).([axeName 'Axis'])(sideNum).FontSize=opts.FontSize{groupNum};
                end
            end
        end
        
        % #.#.#. Pan
        pan(ax(1),'on');
        
    end
end

% #. Removes unused edges from a figure
if strcmpi(opts.Parent.Type,'figure') || strcmpi(opts.Parent.Type,'uifigure')
    BordersRemoving(ax.Parent,'Margins',0,'Pause',0.5,'Crop','Off','TicksOffset','Off');
end