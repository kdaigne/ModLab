%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                              MultiPlot                                %%
%%                    Last update: September 19, 2024                    %%
%%                             Kévin Daigne                              %%
%%                        kevin.daigne@hotmail.fr                        %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Plots and processes multiple graph types in one axes (surface, image,
% plot, etc.). The graph type is automatically found according to the
% input. For existing graphs, modification of only certain properties
% optimizes computation time.
%% - Main features -
% Current axes :
%   - Create a new axes -> MultiPlot([...])
%   - Use an existing axis -> MultiPlot(ax,[...])
% Graph types :
%   - Plot : MultiPlot(x[N*1],y[N*1],options)
%   - Plot3 : MultiPlot(x[N*1],y[N*1],z[N*1],options)
%   - Image : MultiPlot(pixels[N*M],options)
%   - Surface : MultiPlot(connectivity[E*3],x[N*1],y[N*1],options)
%       with data : MultiPlot(connectivity[E*3],x[N*1],y[N*1],'Data',Data[N*1],options)
%   - Slice : MultiPlot(x[N*1],y[N*1],z[N*1],options)
%       with data :
%       MultiPlot(x[N*1],y[N*1],z[N*1],'Data',Data[S1*S2*S3],options) /!\ data is 3d
% Graph option (more details given below) :
%   - Specify after data
%   - e.g. MultiPlot(x,y,'LineStyle','--','Color','r','LineWidth',2,...)
% Grounds :
%   - Multiple grounds can be defined (i.e. stacked layer of graphs of various types)
%   - Specify with keyword 'Ground'
%   - e.g. MultiPlot('Ground',connectivity,x,y,'TicksNumber',7,...,'Ground',x,y,'LineWidth',2,...)
%   - Note that for surfaces :
%       . Colormap is an axis option, so all grounds will have the same colormap
%       . By default, the same applies to data limits
%       . It is possible to define independent limits for a ground using the 'Normalized' option
%       . Useful if grounds with very different amplitudes (e.g. stress and strain)
%       . e.g. MultiPlot('Ground',connectivity,x,y,'Data',stress,'Normalized',1,...,'Ground',connectivity,x,y,'Data',strain,'Normalized',1,...)
% Axes option (more details given below) :
%   - Some options are linked to the axis and not the graph (e.g. XLabel, grid, etc.)
%   - Their positions are not important and should be indicated only once
%   - e.g. MultiPlot(x,y,'LineStyle','--','Color','r','LineWidth',2,'XLabel','Hello world!',...)
%% - Options -
% Comments :
%   - Graph options are all available and except in particular cases will not be specified below
%   - Color inputs are compatible with RGB (normalized), matlab ('r', 'b', etc.) and hexadecimal formats
% Figure :
%   - 'Position' = [X0 (left-down corner) Y0 (left-down corner) DX DY] : Figure position (normalized)
%   - 'Clear' = 'On' or 'Off' (default) : Deletes existing graphs
%   - 'Hold' = 'On' or 'Off' (default) : If a graphic is already existing, modify it ('Off') or add another graph ('On')
%   - 'MenuBar' = 'None' (default) or 'Figure' : Displaying the menu on the figure
%   - 'ToolBar' = 'None' (default) or 'Figure' : Displaying the toolbar on the figure
%   - 'Margins' = [left=bottom=right=top] or [left=right,bottom=top] or [left,bottom,right,top] : Normalized space (according to the figure height) left between graphs and figure edges
%   - 'StretchToFill' = 'On' or 'Off' (default) : Modify the limits so that the graph fills all the space on the figure
% Data :
%   - 'Data' = [N*1] : Displayed data (i.e. gives color to the surface)
%   - 'DataLim' = [min max] : Limits of colorbar and caxis
%   - 'DataName' = chars : Data name (used for data tip rows)
%   - 'Normalized' = 0 (default) or 1 : Whether the plan will be normalized to have independent limits
%   - 'Yyaxis' =  [] or 'left' or 'right' : Axis side, useful for plots
%   - 'ShowNodes' = 'On' or 'Off' (default) : Display nodes
% Colors :
%   - 'Colormap' = chars : Colormap of graphs
%   - 'BackgroundColor' : Color of background
% Colorbar :
%   - 'TicksColor' Color of colorbar ticks; if not specified, automatically found according to background color
%   - 'TicksNumber' : Ticks number of colorbar
%   - 'ColorbarLocation' = 'Eastoutside', 'North', etc. or 'Invisible' : Colorbar position; only inside/outside can be specified
%   - 'ColorbarName' : Colorbar label (latex interpreter)
%   - 'ColorbarNameColor' : Color of colorbar label; if not specified, equal to TicksColor
% View :
%   - 'BodiesToRemove' = doubles : Hidden body index (starts from 0)
%   - 'Lagrangian' = node or [node body] : Index of the node in the global reference frame (or of the body if specified) on which the graph will be centered; compatible only with 2D graphs
%   - 'BodyIndex' = [N*1] : Body index for each node; if not specified, will be computed automatically according to certain assumptions; useful only if 'Lagrangian' or 'BodiesToRemove' activated
%   - 'View' = [xmin,xmax,ymin,ymax] or [xmin,xmax,ymin,ymax,zmin,zmax] : Axis view 
%   - 'Rotation' = [az,el] : Axis orientation (azimuth and elevation)
% Axes :
%   - 'XLim' = [min max] : X limits
%   - 'YLim' = [min max] : Y limits
%   - 'ZLim' = [min max] : Z limits
%   - 'Title' = chars : Axis title (latex interpreter)
%   - 'XLabel' = chars : Name displayed on x-axis (latex interpreter)
%   - 'YLabel' = chars : Name displayed on y-axis (latex interpreter)
%   - 'ZLabel' = chars : Name displayed on z-axis (latex interpreter)
%   - 'Grid' =  'On' or 'Off' (default) : Display or not the grid
%   - 'AxisColor' : Axis color; if not specified, automatically found according to background color
% 3D extrapolation :
%   - 'ConversionTo3D'
%       . For planar = [width] : distance between the 2 planes
%       . For axisymmetric = [rMin,rMax,Nrep] : rMin is the minimal crown radius; rMax is the maximal crown radius; Nrep is the number of repetitions of the pattern (a value resulting in entanglement creates a closed crown by adjusting the arc length and number of repetitions, which can therefore be infinite)
%% -

function ax=MultiPlot(varargin)
if isempty(varargin)
    return;
end

%% #. Grounds
shiftAxes=isobject(varargin{1}); % If the axis is specified
if isstruct(varargin{shiftAxes+1})
    % Structured input
    groundsNames=reshape(sort(string(fieldnames(varargin{shiftAxes+1}))),1,[]);
else
    % #.#. Variable by variable input
    indGroundTemp=find(strcmpi(varargin,'Ground'));
    if isempty(indGroundTemp)
        % #.#.#. Grounds not specified
        ind.ground1=[shiftAxes+1 numel(varargin)];
    else
        % #.#.#. Grounds specified
        for groundNum=1:numel(indGroundTemp)
            if groundNum~=numel(indGroundTemp)
                % Grounds
                ind.(['ground' num2str(groundNum)])=[indGroundTemp(groundNum)+1,indGroundTemp(groundNum+1)-1];
            else
                % Last ground
                ind.(['ground' num2str(groundNum)])=[indGroundTemp(groundNum)+1,numel(varargin)];
            end
        end
    end
    groundsNames=reshape(sort(string(fieldnames(ind))),1,[]);
end

%% #. Axes options
% If an entry is not preceded by an 'option', then it will be loaded by
% the first option by mistake. So exclude all entries that don't
% require options (connectivity, etc.).
% #.#. Indices
if isstruct(varargin{shiftAxes+1})
    % #.#.#. Structured input
    if numel(varargin)>shiftAxes+1
        indInputs(2)=2;
        indInputs(3)=3;
    else
        indInputs=[];
    end
else
    % #.#.#. Variable by variable input
    indInputs=1:numel(varargin); % Matrix containing the indices of the elements to be loaded
    if isobject(varargin{1})
        indInputs(1)=0;
    end
    for groundVar=groundsNames
        if ind.(groundVar)(1)-1>=1 % Ground specified
            indInputs(ind.(groundVar)(1)-1)=0;
        end
        indTemp=ind.(groundVar)(1);
        while ~ischar(varargin{indTemp}) && ~isstruct(varargin{indTemp}) % Detects the beginning of an option
            indInputs(indTemp)=0;
            indTemp=indTemp+1;
            if indTemp>ind.(groundVar)(2)
                break;
            end
        end
    end
end
% The indices also contain the options associated with the grounds, but
% they will meet in the unmatched category later on.
indInputs(indInputs==0)=[];
% #.#. Processing
p=inputParser;
p.KeepUnmatched=true;
addOptional(p,'Position',[0.1 0.1 0.8 0.8]);
addOptional(p,'Margins',0);
addOptional(p,'MenuBar','None');
addOptional(p,'ToolBar','None');
addOptional(p,'XLim',[]);
addOptional(p,'YLim',[]);
addOptional(p,'ZLim',[]);
addOptional(p,'AxisColor',[]);
addOptional(p,'Title',[]);
addOptional(p,'XLabel',[]);
addOptional(p,'YLabel',[]);
addOptional(p,'ZLabel',[]);
addOptional(p,'Grid','Off');
addOptional(p,'Clear','Off');
addOptional(p,'Hold','Off');
addOptional(p,'Colormap','turbo');
addOptional(p,'BackgroundColor',[]);
addOptional(p,'View',[]);
addOptional(p,'Rotation',[]);
addOptional(p,'StretchToFill','Off');
parse(p,varargin{indInputs});
info=p.Results;

for groundVar=groundsNames
    %% #. Ground data
    if isstruct(varargin{shiftAxes+1})
        % #.#. Structured input
        fns=string(fieldnames(varargin{shiftAxes+1}.(groundVar)));
        for var=["x" "y" "z" "connectivity" "data"]
            ind=find(strcmpi(fns,var),1,'first');
            if ~isempty(ind)
                info.(groundVar).(var)=varargin{shiftAxes+1}.(groundVar).(fns(ind));
            end
        end
    else
        % #.#. Variable by variable input
        shift=0; % Used to determine the index at which options are processed
        if ind.(groundVar)(2)-ind.(groundVar)(1)==0
            % #.#.#. Image
            % If an input (except for the axis), it necessarily corresponds to the pixel matrix
            info.(groundVar).data=varargin{ind.(groundVar)(1)+shift};
            shift=shift+1;
        else
            if ischar(varargin{ind.(groundVar)(1)+1}) || isstruct(varargin{ind.(groundVar)(1)+1})
                % #.#.#. Image
                % The input following the pixel matrix is necessarily an option (in char or struct form)
                info.(groundVar).data=varargin{ind.(groundVar)(1)+shift};
                shift=shift+1;
            else
                if size(varargin{ind.(groundVar)(1)},2)==3 && size(varargin{ind.(groundVar)(1)},1)>1
                    % #.#.#. Connectivity
                    % If the matrix is of width 3 (triangular mesh) and we
                    % assume that the case where we have a single element
                    % is unlikely (to avoid confusion with a 1xN matrix)
                    info.(groundVar).connectivity=varargin{ind.(groundVar)(1)+shift};
                    shift=shift+1;
                end
                % #.#.#. X
                info.(groundVar).x=varargin{ind.(groundVar)(1)+shift}; % Must be indicated at this level
                % #.#.#. Y
                info.(groundVar).y=varargin{ind.(groundVar)(1)+shift+1}; % Must be indicated at this level
                % #.#.#. Z
                shift=shift+2;
                if numel(varargin)>=ind.(groundVar)(1)+shift && ind.(groundVar)(1)+shift<=ind.(groundVar)(2)
                    if ~ischar(varargin{ind.(groundVar)(1)+shift}) && ~isstruct(varargin{ind.(groundVar)(1)+shift})
                        info.(groundVar).z=varargin{ind.(groundVar)(1)+shift};
                        shift=shift+1;
                    end
                end
            end
        end
    end
    %% #. Ground options
    % #.#. Initialization
    p=inputParser;
    p.KeepUnmatched=true;
    addOptional(p,'Normalized',0);
    addOptional(p,'ShowNodes','Off');
    addOptional(p,'DataLim',[]);
    addOptional(p,'DataName',[]);
    addOptional(p,'Remove',[]);
    addOptional(p,'ColorbarLocation',[]);
    addOptional(p,'ColorbarName',[]);
    addOptional(p,'ColorbarNameColor',[]);
    addOptional(p,'TicksColor',[]);
    addOptional(p,'TicksNumber','auto');
    addOptional(p,'BodiesToRemove',[]);
    addOptional(p,'Lagrangian',[]);
    addOptional(p,'BodyIndex',[]);
    addOptional(p,'FaceColor','interp');
    addOptional(p,'Visible','On');
    addOptional(p,'EdgeColor','none');
    addOptional(p,'EdgeAlpha',1);
    addOptional(p,'Yyaxis',[]);
    addOptional(p,'ConversionTo3D',[]);
    if isstruct(varargin{shiftAxes+1})
        % #.#. Structured input
        if isfield(varargin{shiftAxes+1}.(groundVar),'opts')
            parse(p,varargin{shiftAxes+1}.(groundVar).opts);
        else
            parse(p,varargin{[]});
        end
    else
        % #.#. Variable by variable input
        parse(p,varargin{ind.(groundVar)(1)+shift:ind.(groundVar)(2)});
    end
    info.(groundVar).Opts=p.Results; % Options associated with a ground
    if isfield(p.Unmatched,'Data')
        info.(groundVar).PlotOpts=rmfield(p.Unmatched,'Data'); % Options associated with a graph in a particular ground
        info.(groundVar).data=p.Unmatched.Data; % Data
    else
        info.(groundVar).PlotOpts=p.Unmatched; % Options associated with a graph in a particular ground
    end
    % Ground options can contain global options depending on where they are defined, so they are removed because they have already been imported
    info.(groundVar).PlotOpts=rmfield(info.(groundVar).PlotOpts,intersect(fieldnames(p.Unmatched),(fieldnames(info))));
end

%% #. Graph type
% Euler, lagrangian, planar, radial, image, plot
groundNumber=numel(groundsNames);
type=cell(1,groundNumber);
for groundNum=1:groundNumber
    if isfield(info.(groundsNames(groundNum)),'data') && ~isfield(info.(groundsNames(groundNum)),'connectivity')
        if numel(size(info.(groundsNames(groundNum)).data))==2
            % #.#. Image
            type{groundNum}='image';
        elseif numel(size(info.(groundsNames(groundNum)).data))==3
            % #.#. Slices
            type{groundNum}='slices';
        end
    end
    if isempty(type{groundNum})
        if ~isfield(info.(groundsNames(groundNum)),'connectivity')
            % #.#. Plot
            type{groundNum}='plot';
        end
        if isempty(type{groundNum})
            for groundVar=groundsNames
                if ~isempty(info.(groundVar).Opts.Lagrangian)
                    % #.#. Lagrangian
                    type{groundNum}='lagrangian';
                    break;
                end
            end
            if isempty(type{groundNum})
                if isfield(info.(groundsNames(groundNum)),'z')
                    if numel(unique(info.(groundsNames(groundNum)).z))==2
                        % #.#. Planar
                        type{groundNum}='planar';
                    else
                        % #.#. Radial
                        type{groundNum}='radial';
                    end
                end
                if isempty(type{groundNum})
                    if ~isempty(info.(groundsNames(groundNum)).Opts.ConversionTo3D)
                        if isscalar(info.(groundsNames(groundNum)).Opts.ConversionTo3D)
                            % #.#. Planar
                            type{groundNum}='planar';
                        else
                            % #.#. Radial
                            type{groundNum}='radial';
                        end
                    end
                end
            end
        end
    end
    if isempty(type{groundNum})
        %  #.#. Euler
        type{groundNum}='euler';
    end
end
groundsNamesSurface=groundsNames(strcmpi(type,'euler') | strcmpi(type,'lagrangian') | strcmpi(type,'planar') | strcmpi(type,'radial'));
groundsNamesData=groundsNames(~strcmpi(type,'plot'));

%% #. Figure
if ~isobject(varargin{1})
    fig=figure('Units','Normalized','Position',info.Position,'MenuBar',info.MenuBar,'ToolBar',info.ToolBar);
    ax=axes(fig,'Units','Normalized','OuterPosition',[0 0 1 1]);
elseif ~strcmpi(varargin{1}.Type,'axes') && ~strcmpi(varargin{1}.Type,'uiaxes')
    ax=axes(varargin{1},'Units','Normalized','OuterPosition',[0 0 1 1]);
else
    ax=varargin{1};
end
if strcmpi(info.Clear,'on')
    cla(ax,'reset');
end
tagSave=ax.Tag;

%% #. Default global option values

% #.#. BackgroundColor
if isempty(info.BackgroundColor)
    if all(strcmpi(type,'plot'))
        if isprop(ax.Parent,'Color')
            info.BackgroundColor=ax.Parent.Color;
        elseif isprop(ax.Parent,'BackgroundColor')
            info.BackgroundColor=ax.Parent.BackgroundColor;
        end
    else
        info.BackgroundColor=[0.3216    0.3412    0.4314];
    end
else
    [info.BackgroundColor]=ColorConverter(info.BackgroundColor,'Default',[0.3216    0.3412    0.4314]);
end

% #.#. AxisColor
if isempty(info.AxisColor)
    if isprop(ax.Parent,'BackgroundColor')
        nearestColor=imbinarize(rgb2gray(ax.Parent.BackgroundColor),0.5);
        if isequal(nearestColor,[1 1 1])
            info.AxisColor=[0 0 0];
        else
            info.AxisColor=[1 1 1];
        end
    else
        info.AxisColor=[0 0 0];
    end
end

% #.#. Number of colorbars
colorbarList=zeros(1,numel(groundsNames));
groundNum=0;
for groundVar=groundsNames
    groundNum=groundNum+1;
    if isfield(info.(groundVar),'data')
        colorbarList(groundNum)=1;
    end
end
colorbarNumber=sum(colorbarList);

% #.#. Pre-positioning of colorbars
if colorbarNumber>=1
    if colorbarNumber==1
        colorbarLocList="south";
    elseif colorbarNumber==2
        colorbarLocList=["west","east"];
    elseif colorbarNumber==3
        colorbarLocList=["west","east","south"];
    elseif colorbarNumber==4
        colorbarLocList=["west","east","south","north"];
    else
        colorbarLocList=["west","east","south","north" repmat("south",1,colorbarNumber-4)];
    end
    groundNum=0;
    for groundVar=groundsNames
        groundNum=groundNum+1;
        if (strcmpi(info.(groundVar).Opts.ColorbarLocation,'outside') || colorbarNumber>2) &&  ~strcmpi(info.(groundVar).Opts.ColorbarLocation,'invisible') % Otherwise they overlap
            colorbarLocList(sum(colorbarList(1:groundNum)))=strcat(erase(colorbarLocList(sum(colorbarList(1:groundNum))),'Outside'),'Outside');
        end
    end
    kCol=0; % Determines the position of the colorbar
end

% #.#. Labels
% #.#.#. Removes empty values
for axisVar='XYZ'
    if ~isempty(info.([axisVar 'Label'])) ...
            && iscell(info.([axisVar 'Label'])) % e.g. lines with surfaces
        indToRemove=cellfun(@isempty,info.([axisVar 'Label']));
        info.([axisVar 'Label'])(indToRemove)=[];
    end
end
% #.#.#. Plot
if all(strcmpi(type,'plot'))
    if isempty(info.XLabel)
        info.XLabel='X';
    end
    if isempty(info.YLabel)
        info.YLabel='Y';
    end
    if isempty(info.ZLabel)
        info.ZLabel='Z';
    end
end

%% #. Default ground option values

groundNum=0;
for groundVar=groundsNames
    groundNum=groundNum+1;
    
    % #.#. Color processing
    fields=fieldnames(info.(groundVar).PlotOpts);
    ind=find(contains(lower(fields),'color'));
    for fieldNum=1:numel(ind)
        info.(groundVar).PlotOpts.(fields{ind(fieldNum)})=ColorConverter(info.(groundVar).PlotOpts.(fields{ind(fieldNum)}));
    end
    
    if ~strcmpi(type{groundNum},'plot')

        % #.#. Pixel meshgrid
        % using pcolor avoid mistakes compare to imshow
        if strcmpi(type{groundNum},'image') || strcmpi(type{groundNum},'slices')
            if isfield(info.(groundVar),'x') && isfield(info.(groundVar),'y') && isfield(info.(groundVar),'z')
                if ~isequal(size(info.(groundVar).x),size(info.(groundVar).data)) || ~isequal(size(info.(groundVar).y),size(info.(groundVar).data))
                    [info.(groundVar).x,info.(groundVar).y,info.(groundVar).z]=...
                        meshgrid(info.(groundVar).x,info.(groundVar).y,info.(groundVar).z);
                end
            elseif isfield(info.(groundVar),'x') && isfield(info.(groundVar),'y')
                if ~isequal(size(info.(groundVar).x),size(info.(groundVar).data)) || ~isequal(size(info.(groundVar).y),size(info.(groundVar).data))
                    [info.(groundVar).x,info.(groundVar).y]=...
                        meshgrid(info.(groundVar).x,info.(groundVar).y);
                end
            end
        end

        if ~strcmpi(type{groundNum},'image') && ~strcmpi(type{groundNum},'slices')
            
            % #.#. BodyIndex
            if isempty(info.(groundVar).Opts.BodyIndex)
                if ~isempty(info.(groundVar).Opts.Lagrangian)
                    if max(size(info.(groundVar).Opts.Lagrangian))>1
                        [info.(groundVar).Opts.BodyIndex]=ConnectivityToBodiesList(info.(groundVar).connectivity);
                    end
                elseif ~isempty(info.(groundVar).Opts.BodiesToRemove)
                    [info.(groundVar).Opts.BodyIndex]=ConnectivityToBodiesList(info.(groundVar).Opts.connectivity);
                end
            end
        end
        
        if colorbarList(groundNum)==1
            
            % #.#. ColorbarLocation
            if strcmpi(info.(groundVar).Opts.ColorbarLocation,'invisible')
                % #.#.#. Automatic positioning
                info.(groundVar).Opts.ColorbarLocation='invisible';
            elseif isempty(info.(groundVar).Opts.ColorbarLocation) || strcmpi(info.(groundVar).Opts.ColorbarLocation,'inside') || strcmpi(info.(groundVar).Opts.ColorbarLocation,'outside')
                % #.#.#. Automatic positioning
                kCol=kCol+1;
                info.(groundVar).Opts.ColorbarLocation=char(colorbarLocList(kCol));
            else
                % #.#.#. At least one fixed position
                % We remove this position from the pre-positioning to avoid having the same position twice.
                colorbarLocList(find(strcmpi(colorbarLocList,info.(groundVar).Opts.ColorbarLocation),1,'first'))=[];
            end
            
            % #.#. TicksColor
            if isempty(info.(groundVar).Opts.TicksColor)
                if contains(info.(groundVar).Opts.ColorbarLocation,'Outside') && ~strcmpi(ax.Parent.Type,'figure')
                    % If external colorbar, takes parent color ( = BackgroundColor if figure)
                    if isprop(ax.Parent,'BackgroundColor')
                        colorTemp=ax.Parent.BackgroundColor;
                    elseif isprop(ax.Parent,'Color')
                        colorTemp=ax.Parent.Color;
                    else
                        colorTemp=info.BackgroundColor;
                    end
                else
                    % If interior colorbar, take axis color
                    colorTemp=info.BackgroundColor;
                end
                nearestColor=imbinarize(rgb2gray(colorTemp),0.5);
                if isequal(nearestColor,[1 1 1])
                    info.(groundVar).Opts.TicksColor=[0 0 0];
                else
                    info.(groundVar).Opts.TicksColor=[1 1 1];
                end
            end
            
            % #.#. ColorbarName
            % The default name is given by DataName
            if ~isempty(info.(groundVar).Opts.DataName) && isempty(info.(groundVar).Opts.ColorbarName) && ~strcmpi(info.(groundVar).Opts.ColorbarName,'')
                info.(groundVar).Opts.ColorbarName=info.(groundVar).Opts.DataName;
            elseif isempty(info.(groundVar).Opts.ColorbarName) && ~strcmpi(info.(groundVar).Opts.ColorbarName,'')
                info.(groundVar).Opts.ColorbarName='Data';
            end
            
            % #.#. ColorbarNameColor
            if isempty(info.(groundVar).Opts.ColorbarNameColor)
                info.(groundVar).Opts.ColorbarNameColor=info.(groundVar).Opts.TicksColor;
            end

            % #.#. DataName
            if isempty(info.(groundVar).Opts.DataName) && isfield(info.(groundVar),'data')
                info.(groundVar).Opts.DataName='Data';
            end

        end
    end
end

%% #. Surface processing

if ~isempty(groundsNamesSurface)
    % #.#. Pre-calculation for conversionTo3D (radial)
    if any(strcmpi(type,'radial'))
        radialLimits=[inf -inf];
        for groundVar=groundsNamesSurface
            % If the widths of the planes are different, repeat the pattern according to the greatest width
            radialLimits=[min([radialLimits(1) min(info.(groundVar).x)]) max([radialLimits(2) max(info.(groundVar).x)])];
        end
    end
    for groundVar=groundsNames
        % #.#. Bodie to remove
        if ~isempty(info.(groundVar).Opts.BodiesToRemove)
            nodesToRemove=ismember(info.(groundVar).Opts.BodyIndex,info.(groundVar).Opts.BodiesToRemove);
            info.(groundVar).connectivity=NodesRemoving(info.(groundVar).connectivity,nodesToRemove);
            info.(groundVar).x(nodesToRemove)=[];
            info.(groundVar).y(nodesToRemove)=[];
            if isfield(info.(groundVar),'z')
                info.(groundVar).z(nodesToRemove)=[];
            end
            if isfield(info.(groundVar),'data')
                info.(groundVar).data(nodesToRemove)=[];
            end
        end
        % #.#. conversionTo3D
        if ~isempty(info.(groundVar).Opts.ConversionTo3D) && ~isfield(info.(groundVar),'z')
            if isscalar(info.(groundVar).Opts.ConversionTo3D)
                % #.#. Planar
                if isfield(info.(groundVar),'data')
                    [info.(groundVar).x,info.(groundVar).y,info.(groundVar).z,info.(groundVar).data,info.(groundVar).connectivity]=Function2DTo3DPlanar(info.(groundVar).x,info.(groundVar).y,info.(groundVar).data,info.(groundVar).connectivity,info.(groundVar).Opts.ConversionTo3D(1));
                else
                    [info.(groundVar).x,info.(groundVar).y,info.(groundVar).z,~,info.(groundVar).connectivity]=Function2DTo3DPlanar(info.(groundVar).x,info.(groundVar).y,[],info.(groundVar).connectivity,info.(groundVar).Opts.ConversionTo3D(1));
                end
            elseif numel(info.(groundVar).Opts.ConversionTo3D)>=3
                % #.#. Radial
                if isfield(info.(groundVar),'data')
                    [info.(groundVar).x,info.(groundVar).y,info.(groundVar).z,info.(groundVar).data,info.(groundVar).connectivity]=Function2DTo3DRadial(info.(groundVar).x,info.(groundVar).y,info.(groundVar).data,info.(groundVar).connectivity,info.(groundVar).Opts.ConversionTo3D(1),info.(groundVar).Opts.ConversionTo3D(2),info.(groundVar).Opts.ConversionTo3D(3),'Limits',radialLimits);
                else
                    [info.(groundVar).x,info.(groundVar).y,info.(groundVar).z,~,info.(groundVar).connectivity]=Function2DTo3DRadial(info.(groundVar).x,info.(groundVar).y,[],info.(groundVar).connectivity,info.(groundVar).Opts.ConversionTo3D(1),info.(groundVar).Opts.ConversionTo3D(2),info.(groundVar).Opts.ConversionTo3D(3),'Limits',radialLimits);
                end
            end
        elseif isfield(info.(groundVar),'z')==0
            info.(groundVar).z=zeros(size(info.(groundVar).x));
        end
    end
end

%% #. Limits processing (CAxis, DataLim, XLim, YLim and ZLim)
% By default, we take the limits for caxis via the Data extremums, but may
% differ depending on whether the planes are normalized. Calculate
% beforehand, as this may be necessary for correction purposes if the plot
% has not yet been drawn.
% #.#. Initialization
cAxisValue=[inf -inf]; lim.X=[inf -inf]; lim.Y=[inf -inf]; lim.Z=[inf -inf];
% #.#. Processing
for groundVar=groundsNames
    if isfield(info.(groundVar),'data')
        if isempty(info.(groundVar).Opts.DataLim)
            info.(groundVar).Opts.DataLim=[min(min(info.(groundVar).data)) max(max(info.(groundVar).data))]; % 2 min/max for pixel matrix
            if info.(groundVar).Opts.DataLim(1)==info.(groundVar).Opts.DataLim(2)
                info.(groundVar).Opts.DataLim=[-1 1];
            end
        end
        if info.(groundVar).Opts.Normalized==0
            cAxisValue=[min([cAxisValue(1) info.(groundVar).Opts.DataLim(1)]) max([cAxisValue(2) info.(groundVar).Opts.DataLim(2)])];
        end
    end
    for cord=['X' 'Y' 'Z']
        if isempty(info.([cord 'Lim'])) && isfield(info.(groundVar),lower(cord)) && ~all(strcmpi(type,'plot'))
            lim.(cord)=[min([lim.(cord)(1) min(info.(groundVar).(lower(cord)),[],'all')]) max([lim.(cord)(2) max(info.(groundVar).(lower(cord)),[],'all')])];
        elseif ~isempty(info.(groundVar).Opts.ConversionTo3D)
            % After conversion, the limits are no longer the same
            lim.(cord)=[min([info.([cord 'Lim'])(1) lim.(cord)(1) min(info.(groundVar).(lower(cord)),[],'all')]) max([info.([cord 'Lim'])(2) lim.(cord)(2) max(info.(groundVar).(lower(cord)),[],'all')])];
        end
    end
end
if isequal(cAxisValue,[inf -inf])
    cAxisValue=[-1 1];
end
for cord=['X' 'Y' 'Z']
    if ~all(strcmpi(type,'plot')) && (isempty(info.([cord 'Lim'])) && isfield(info.(groundVar),lower(cord))) || any(strcmpi(type,'planar')) || any(strcmpi(type,'radial')) % After conversion, the limits are no longer the same
        info.([cord 'Lim'])=lim.(cord);
    end
end

%% #. Correction if Normalized
% As the foreground and background can have different orders of magnitude,
% 2 colormap limits must be used, otherwise one will have very few color
% shades. Matlab doesn't offer this function, so we “normalize” the
% background values manually so that it has the same colors as if we were
% drawing it alone. We then adapt the values displayed on the colorbar.
if ~isempty(groundsNamesData)
    if isempty(ax.Children)
        cAxisValueTemp=cAxisValue;
    else
        cAxisValueTemp=clim(ax); % If the graph is already drawn, the caxis will not change and will therefore not be equal to cAxisValue
    end
    for groundVar=groundsNamesData
        info.(groundVar).corr=zeros(1,3); % Contains normalization factors
        if info.(groundVar).Opts.Normalized~=0
            if isfield(info.(groundVar),'data')
                if info.(groundVar).Opts.DataLim(2)==info.(groundVar).Opts.DataLim(1)
                    info.(groundVar).corr(1)=sum(cAxisValueTemp)/2;
                    info.(groundVar).corr(2)=0;
                    info.(groundVar).corr(3)=0;
                else
                    info.(groundVar).corr(1)=cAxisValueTemp(1);
                    info.(groundVar).corr(2)=(cAxisValueTemp(2)-cAxisValueTemp(1))/(info.(groundVar).Opts.DataLim(2)-info.(groundVar).Opts.DataLim(1));
                    info.(groundVar).corr(3)=info.(groundVar).Opts.DataLim(1);
                end
                info.(groundVar).data=info.(groundVar).corr(1)+info.(groundVar).corr(2).*(info.(groundVar).data-info.(groundVar).corr(3));
            end
        else
            info.(groundVar).corr(1)=0;
            info.(groundVar).corr(2)=1;
            info.(groundVar).corr(3)=0;
        end
    end
end


% Graph processing
kLeft=0; kRight=0;
if isempty(ax.Children)==0 && strcmpi(info.Hold,'Off')==1
    %% #. Existing graphs
    % Direct modification
    % Properties are modified instead of recreating a graph if one already
    % exists. Reduces computation time.
    for groundVar=flip(groundsNames) % The 1st child is the most recent

        % #.#. Initialization
        if ~isempty(info.(groundVar).Opts.Yyaxis)
            yyaxis(ax,info.(groundVar).Opts.Yyaxis);
            if strcmpi(info.(groundVar).Opts.Yyaxis,'left')
                kLeft=kLeft+1;
                groundNum=kLeft;
            elseif strcmpi(info.(groundVar).Opts.Yyaxis,'right')
                kRight=kRight+1;
                groundNum=kRight;
            end
        else
            kLeft=kLeft+1;
            groundNum=kLeft;
        end
        typeTemp=type{numel(type)-groundNum+1};

        if strcmpi(typeTemp,'image')

            % #.#. Image

            if isfield(info.(groundVar),'z')
                set(ax.Children(groundNum),'XData',info.(groundVar).x,'YData',info.(groundVar).y,'ZData',info.(groundVar).z,'CData',info.(groundVar).data);
            elseif isfield(info.(groundVar),'y')
                set(ax.Children(groundNum),'XData',info.(groundVar).x,'YData',info.(groundVar).y,'CData',info.(groundVar).data);
            elseif isfield(info.(groundVar),'x')
                set(ax.Children(groundNum),'XData',info.(groundVar).x,'CData',info.(groundVar).data);
            else
                set(ax.Children(groundNum),'CData',info.(groundVar).data);
            end

        elseif strcmpi(typeTemp,'slices')

            % #.#. Slices
            % The slice function creates a surface per plane, which is
            % difficult to modify directly. As a result, a temporary
            % axes is created, which is then copied onto the existing
            % axes.

            % #.#.#. Initialization
            h=flip(findobj(ax,'type','Surface'));
            figTemp=figure('Visible','off'); axTemp=axes;
            % #.#.#. Processing
            for hNum=1:numel(h)
                % #.#.#.#. Find previous slices
                if isscalar(unique(h(hNum).XData))
                    xslice=unique(h(hNum).XData); yslice=[]; zslice=[];
                elseif isscalar(unique(h(hNum).YData))
                    xslice=[]; yslice=unique(h(hNum).YData); zslice=[];
                elseif isscalar(unique(h(hNum).ZData))
                    xslice=[]; yslice=[]; zslice=unique(h(hNum).ZData);
                end
                % #.#.#.#. Copy
                hTemp=slice(axTemp,info.(groundVar).x,info.(groundVar).y,info.(groundVar).z,info.(groundVar).data,...
                xslice,yslice,zslice);
                set(h(hNum),'XData',hTemp.XData,'YData',hTemp.YData,'ZData',hTemp.ZData,'CData',hTemp.CData);
            end
            delete(figTemp);

        elseif strcmpi(typeTemp,'euler') || strcmpi(typeTemp,'lagrangian')

            % #.#. 2D surface

            if isfield(info.(groundVar),'data')
                set(ax.Children(groundNum),'FaceVertexCData',info.(groundVar).data,...
                    'Vertices',[info.(groundVar).x info.(groundVar).y info.(groundVar).z],...
                    'Faces',info.(groundVar).connectivity);
            else
                set(ax.Children(groundNum),'Vertices',[info.(groundVar).x info.(groundVar).y info.(groundVar).z],...
                    'Faces',info.(groundVar).connectivity);
            end
            if strcmpi(info.(groundVar).Opts.ShowNodes,'On')
                scatterPlot=findall(ax,'type','scatter');
                if ~isempty(scatterPlot)
                    set(scatterPlot(groundNum),'XData',info.(groundVar).x,'YData',info.(groundVar).y,'ZData',info.(groundVar).z);
                else
                    scatter3(info.(groundVar).x,info.(groundVar).y,info.(groundVar).z,'k.','MarkerEdgeAlpha',1,'HandleVisibility','Off','Parent',ax);
                end
            end

        elseif strcmpi(typeTemp,'planar') || strcmpi(typeTemp,'radial')

            % #.#. 3D surface

            if isfield(info.(groundVar),'data')
                set(ax.Children(groundNum),'FaceVertexCData',info.(groundVar).data,...
                    'Vertices',[info.(groundVar).x info.(groundVar).y info.(groundVar).z],...
                    'Faces',info.(groundVar).connectivity);
            else
                set(ax.Children(groundNum),'Vertices',[info.(groundVar).x info.(groundVar).y info.(groundVar).z],...
                    'Faces',info.(groundVar).connectivity);
            end
            if strcmpi(info.(groundVar).Opts.ShowNodes,'On')
                scatterPlot=findall(ax,'type','scatter');
                if ~isempty(scatterPlot)
                    set(scatterPlot(groundNum),'XData',info.(groundVar).x,'YData',info.(groundVar).y,'ZData',info.(groundVar).z);
                else
                    scatter3(info.(groundVar).x,info.(groundVar).y,info.(groundVar).z,'k.','MarkerEdgeAlpha',1,'HandleVisibility','Off','Parent',ax);
                end
            end

        elseif strcmpi(typeTemp,'plot')

            % #.#. Plot

            if ~isfield(info.(groundVar),'z')
                set(ax.Children(groundNum),'XData',info.(groundVar).x,'YData',info.(groundVar).y);
            else
                set(ax.Children(groundNum),'XData',info.(groundVar).x,'YData',info.(groundVar).y,'ZData',info.(groundVar).z);
            end

        end
        
    end

else
    %% #. New graphs
    hold(ax,'on'); groundNum=0; nodes=cell(1,numel(groundsNames));
    for groundVar=groundsNames
        groundNum=groundNum+1;

        if strcmpi(type{groundNum},'image')

            % #.#. Image

            if isfield(info.(groundVar),'y')
                h=pcolor(ax,info.(groundVar).x,info.(groundVar).y,info.(groundVar).data);
            elseif isfield(info.(groundVar),'x')
                h=pcolor(ax,info.(groundVar).x,info.(groundVar).data);
            else
                h=pcolor(ax,info.(groundVar).data);
            end
            h.Visible=info.(groundVar).Opts.Visible;
            h.EdgeColor=info.(groundVar).Opts.EdgeColor;
            view(ax,2); % For the graphic to be correctly detected as 2D

        elseif strcmpi(type{groundNum},'slices')

            % #.#. Slices

            if isfield(info.(groundVar),'x') && isfield(info.(groundVar),'y') && isfield(info.(groundVar),'z')
                h=slice(ax,info.(groundVar).x,info.(groundVar).y,info.(groundVar).z,info.(groundVar).data,...
                info.(groundVar).PlotOpts.xslice,info.(groundVar).PlotOpts.yslice,info.(groundVar).PlotOpts.zslice);
            else
                h=slice(ax,info.(groundVar).data,...
                info.(groundVar).PlotOpts.xslice,info.(groundVar).PlotOpts.yslice,info.(groundVar).PlotOpts.zslice);
            end
            for hNum=1:numel(h)
                h(hNum).Visible=info.(groundVar).Opts.Visible;
                h(hNum).EdgeColor=info.(groundVar).Opts.EdgeColor;
            end
            view(ax,3); % For the graphic to be correctly detected as 3D

        elseif strcmpi(type{groundNum},'euler') || strcmpi(type{groundNum},'lagrangian') || strcmpi(type{groundNum},'planar') || strcmpi(type{groundNum},'radial')
            
            if strcmpi(type{groundNum},'euler') || strcmpi(type{groundNum},'lagrangian')

                % #.#. 2D surface

                if isfield(info.(groundVar),'data')
                    h=trisurf(info.(groundVar).connectivity, info.(groundVar).x,info.(groundVar).y,info.(groundVar).z,info.(groundVar).data,...
                        'FaceColor',info.(groundVar).Opts.FaceColor,'EdgeColor',info.(groundVar).Opts.EdgeColor,'EdgeAlpha',info.(groundVar).Opts.EdgeAlpha,'Visible',info.(groundVar).Opts.Visible,'Parent',ax);
                else
                    h=trisurf(info.(groundVar).connectivity, info.(groundVar).x,info.(groundVar).y,info.(groundVar).z,repmat(mean(cAxisValue),1,max(size(info.(groundVar).x))),...
                        'FaceColor',info.(groundVar).Opts.FaceColor,'EdgeColor',info.(groundVar).Opts.EdgeColor,'EdgeAlpha',info.(groundVar).Opts.EdgeAlpha,'Visible',info.(groundVar).Opts.Visible,'Parent',ax);
                end
                if strcmpi(info.(groundVar).Opts.ShowNodes,'On')
                    nodes{groundNum}=scatter3(info.(groundVar).x,info.(groundVar).y,info.(groundVar).z,'k.','MarkerEdgeAlpha',1,'HandleVisibility','Off','Visible',info.(groundVar).Opts.Visible,'Parent',ax);
                end
                view(ax,2); % For the graphic to be correctly detected as 2D

            else

                % #.#. 3D surface

                if isfield(info.(groundVar),'data')
                    h=trisurf(info.(groundVar).connectivity, info.(groundVar).x,info.(groundVar).y,info.(groundVar).z,info.(groundVar).data,...
                        'FaceColor',info.(groundVar).Opts.FaceColor,'EdgeColor',info.(groundVar).Opts.EdgeColor,'EdgeAlpha',info.(groundVar).Opts.EdgeAlpha,'Visible',info.(groundVar).Opts.Visible,'Parent',ax);
                else
                    h=trisurf(info.(groundVar).connectivity, info.(groundVar).x,info.(groundVar).y,info.(groundVar).z,repmat(mean(cAxisValue),1,max(size(info.(groundVar).x))),...
                        'FaceColor',info.(groundVar).Opts.FaceColor,'EdgeColor',info.(groundVar).Opts.EdgeColor,'EdgeAlpha',info.(groundVar).Opts.EdgeAlpha,'Visible',info.(groundVar).Opts.Visible,'Parent',ax);
                end
                if strcmpi(info.(groundVar).Opts.ShowNodes,'On')
                    nodes{groundNum}=scatter3(info.(groundVar).x,info.(groundVar).y,info.(groundVar).z,'k.','MarkerEdgeAlpha',1,'HandleVisibility','Off','Visible',info.(groundVar).Opts.Visible,'Parent',ax);
                end
                view(ax,3); % For the graphic to be correctly detected as 3D

            end

            % #.#. Format

            set(h,info.(groundVar).PlotOpts);
            if strcmpi(type{groundNum},'planar') || strcmpi(type{groundNum},'radial') || strcmpi(type{groundNum},'slices')
                set(ax,'Clipping','off'); % Avoids cropping the figure when zooming in, however the figure is out of frame, but no solution at present
            end

        else

            % #.#. Plot

            if ~isempty(info.(groundVar).Opts.Yyaxis)
                yyaxis(ax,info.(groundVar).Opts.Yyaxis);
            end
            if ~isfield(info.(groundVar),'z')
                % #.#.#. 2D
                h=plot(ax,info.(groundVar).x,info.(groundVar).y,'Visible',info.(groundVar).Opts.Visible,info.(groundVar).PlotOpts);
            else
                % #.#.#. 3D
                h=plot3(ax,info.(groundVar).x,info.(groundVar).y,info.(groundVar).z,'Visible',info.(groundVar).Opts.Visible,info.(groundVar).PlotOpts);
            end

        end

        % #.#. DataTipRows initialization
        for hNum=1:numel(h)
            try
                dh = datatip(h(hNum),0,0,'Visible','off'); % La création d'un datatip permet d'actualiser le graphique, sinon ils ne sont pas detectés
            catch
                dh = datatip(h(hNum),0,0,0,'Visible','off'); % La création d'un datatip permet d'actualiser le graphique, sinon ils ne sont pas detectés
            end
            delete(dh);
        end

        set(ax,'Tag',tagSave);

    end
    
    %% #. Axis
    % #.#. Format
    grid(ax,info.Grid);
    if ~isempty(info.Title)
        title(ax,['$\mathrm{' info.Title '}$'],'Interpreter','latex');
        ax.Title.Color=info.AxisColor;
    end
    if numel(axis(ax))/2==3 % Graph dimension
        axis(ax,'vis3d');
    end
    % #.#. Color
    if any(strcmpi(type,'euler') | strcmpi(type,'lagrangian') | strcmpi(type,'planar') | strcmpi(type,'radial') | strcmpi(type,'image') | strcmpi(type,'slices'))
        if isempty(info.XLabel)
            set(ax,'xtick',[]);
            set(ax,'XColor','none');
        else
            xlabel(ax,info.XLabel);
            set(ax,'XColor',info.AxisColor);
        end
        if isempty(info.YLabel)
            set(ax,'ytick',[]);
            set(ax,'YColor','none');
        else
            ylabel(ax,info.YLabel);
            set(ax,'YColor',info.AxisColor);
        end
        if isempty(info.ZLabel)
            set(ax,'ztick',[]);
            set(ax,'ZColor','none');
        else
            zlabel(ax,info.ZLabel);
            set(ax,'ZColor',info.AxisColor);
        end
        clim(ax,cAxisValue);
        colormap(ax,[info.Colormap '(256)']);
    end
    % #.#. String
    % X
    if ~isempty(info.XLabel)
        xlabel(ax,strcat('$\mathrm{',info.XLabel,'}$'),'Interpreter','latex');
    end
    % Y
    if ~isempty(info.YLabel)
        groundNum=0;
        for groundVar=groundsNames
            groundNum=groundNum+1;
            if ~isempty(info.(groundVar).Opts.Yyaxis)
                yyaxis(ax,info.(groundVar).Opts.Yyaxis);
                ind=groundNum;
            else
                ind=1:numel(info.YLabel);
            end
            if numel(info.YLabel)>=max(ind)
                ylabel(ax,strcat('$\mathrm{',info.YLabel(ind),'}$'),'Interpreter','latex');
            end
            if isempty(info.(groundVar).Opts.Yyaxis)
                break;
            end
        end
    end
    % Z
    if ~isempty(info.ZLabel)
        zlabel(ax,strcat('$\mathrm{',info.ZLabel,'}$'),'Interpreter','latex');
    end
    
    %% #. Figure
    if strcmpi(ax.Parent.Type,'figure')
        set(ax.Parent,'color',info.BackgroundColor);
    end
    if ~isequal(info.BackgroundColor,[0.94 0.94 0.94])
        set(ax,'color',info.BackgroundColor);
    end
    
    %% #. Limits
    % #.#. Margins
    if all(strcmpi(type,'image') | strcmpi(type,'slices'))
        ax.XLimitMethod='tight';
        ax.YLimitMethod='tight';
        ax.ZLimitMethod='tight';
    end
    % #.#. Values
    if ~isempty(info.XLim)
        set(ax,'XLim',info.XLim);
    else
        set(ax,'XLimMode','auto');
    end
    if ~isempty(info.YLim)
        set(ax,'YLim',info.YLim);
    else
        set(ax,'YLimMode','auto');
    end
    if ~isempty(info.ZLim) && info.ZLim(1)~=info.ZLim(2)
        set(ax,'ZLim',info.ZLim);
    else
        set(ax,'ZLimMode','auto');
    end
    % #.#. View
    if ~isempty(info.View)
        axis(ax,info.View);
    end
    if ~isempty(info.Rotation)
        view(ax,info.Rotation);
    end

    %% #. Colorbar
    groundNum=0;
    for groundVar=groundsNames
        groundNum=groundNum+1;
        if colorbarList(groundNum)==1
            %% #.#. Ticks
            if strcmpi(info.(groundVar).Opts.ColorbarLocation,'invisible')
                c=colorbar(ax,'south','HandleVisibility','off');
            else
                c=colorbar(ax,info.(groundVar).Opts.ColorbarLocation,'HandleVisibility','off');
            end
            c.Ruler.TickLabelRotation=0; % avoid rotation
            % #.#.#. Limits
            c.TicksMode='manual';
            if info.(groundVar).Opts.Normalized==0
                c.Limits=info.(groundVar).Opts.DataLim;
            else
                c.Limits=info.(groundVar).corr(1)+info.(groundVar).corr(2).*(info.(groundVar).Opts.DataLim-info.(groundVar).corr(3));
            end
            % #.#.#. TicksNumber
            if isempty(info.(groundVar).Opts.TicksNumber)
                info.(groundVar).Opts.TicksNumber=numel(c.Ticks);
            elseif strcmpi(info.(groundVar).Opts.TicksNumber,'auto')
                c.TicksMode='auto';
                info.(groundVar).Opts.TicksNumber=numel(c.Ticks);
                if info.(groundVar).Opts.TicksNumber>7
                    info.(groundVar).Opts.TicksNumber=7; % No more than 7 ticks
                elseif info.(groundVar).Opts.TicksNumber>3
                    info.(groundVar).Opts.TicksNumber = 2*floor(info.(groundVar).Opts.TicksNumber/2)+1; % To obtain the central value
                elseif info.(groundVar).Opts.TicksNumber<=1
                    info.(groundVar).Opts.TicksNumber=2;
                end
                c.TicksMode='manual';
            end
            % #.#.#. Processing
            c.Ticks=linspace(c.Limits(1),c.Limits(2),info.(groundVar).Opts.TicksNumber);
            c.TickLabels=strcat(['\color[rgb]{' num2str(info.(groundVar).Opts.TicksColor) '}'],arrayfun(@(x) num2str(x,'%.1e'),linspace(info.(groundVar).Opts.DataLim(1),info.(groundVar).Opts.DataLim(2),info.(groundVar).Opts.TicksNumber),'UniformOutput',false));
            %% #.#. Label
            if ~isempty(info.(groundVar).Opts.ColorbarName) && ~strcmpi(info.(groundVar).Opts.ColorbarName,'')
                lastwarn('','');
                c.Label.Interpreter='latex';
                % Interpreteur latex par compatible avec \color
                %c.Label.String=['\color[rgb]{' num2str(info.(groundVar).Opts.ColorbarNameColor) '}' info.(groundVar).Opts.ColorbarName];
                c.Label.String=['$\mathrm{' info.(groundVar).Opts.ColorbarName '}$'];
                c.Label.Color=info.(groundVar).Opts.ColorbarNameColor; % must have at least one action after the title update, otherwise the warning is not updated
                [~,warnId] = lastwarn();
                if ~isempty(warnId) % invalid format
                    c.Label.Interpreter='none';
                    c.Label.String=info.(groundVar).Opts.ColorbarName;
                end
            end
            % Visibility
            if strcmpi(info.(groundVar).Opts.ColorbarLocation,'invisible') || strcmpi(info.(groundVar).Opts.Visible,'off') % visibility must be on to trigger the warning
                c.Visible='off';
            end
        end
    end
    
    %% #. Toolbar
    if (strcmpi(type{groundNum},'plot') && ~isfield(info.ground1,'z')) || strcmpi(type{groundNum},'image') || strcmpi(type{groundNum},'euler') || strcmpi(type{groundNum},'lagrangian')
        % #.#. 2D
        pan(ax,'on');
    else
        % #.#. 3D
        rotate3d(ax,'on');
    end

    %% #. Axis equal
    if any(strcmpi(type,'image') | strcmpi(type,'slices') | strcmpi(type,'euler') | strcmpi(type,'lagrangian') | strcmpi(type,'planar') | strcmpi(type,'radial'))
        % addlistener 'View' is not working as zoom does not change view
        % addlistener(ax,'View','PostSet',@(o,e) viewFormatCallback(o,e,ax));
        % addlistener 'XLim' is not working as XLim is trigger right after click
        % and before final selection
        % addlistener(ax,'XLim','PostGet',@(o,e) viewFormatCallback(o,e,ax));
        % Zoom is stored in figure, therefore it is trigger for all the figures at
        % each zoom
        % zoomObj=zoom(ax);
        % set(zoomObj,'ActionPostCallback',@(o,e)viewFormatCallback(o,e,ax));
        limits=axis(ax);
        axis(ax,'equal');
        if numel(axis(ax))/2==2 && strcmpi(info.StretchToFill,'on')
            pos=getpixelposition(ax);
            axisRatio=pos(3)/pos(4);
            xRange = diff(limits(1:2));
            yRange = diff(limits(3:4));
            centerX = mean(limits(1:2));
            centerY = mean(limits(3:4));
            coordRatio=xRange/yRange;
            if coordRatio<axisRatio
                xRange=yRange*axisRatio;
            else
                yRange=xRange/axisRatio;
            end
            axis(ax,[centerX - xRange/2, centerX + xRange/2, centerY - yRange/2, centerY + yRange/2]);
        else
            axis(ax,limits);
        end
    end
    
    %% #. Borders
    if ~isempty(info.Margins) && (strcmpi(ax.Parent.Type,'figure') || strcmpi(ax.Parent.Type,'uifigure'))
        BordersRemoving(ax.Parent,'Margins',info.Margins,'Pause',0.1,'Crop','Off','TicksOffset','Off');
    end
    
    %% #. Tick shifting
    TicksOffset(ax);
    
end

%% #. DataTipRows
groundNum=0;
plotNum=numel(groundsNames)+1;
for groundVar=groundsNames
    groundNum=groundNum+1;
    plotNum=plotNum-1; % The 1st child is the most recent
    if (strcmpi(type{groundNum},'image') || strcmpi(type{groundNum},'slices') || strcmpi(type{groundNum},'euler') || strcmpi(type{groundNum},'lagrangian') || strcmpi(type{groundNum},'planar') || strcmpi(type{groundNum},'radial')) ...
            && isfield(info.(groundVar),'data')
        % Applies corrective factors if ever the ground is normalized
        h=ax.Children(plotNum); % DataTipRows is not recognized if there is no this assignment (if we try to access ax.Children directly). There are a lot of issues with this property in general.
        h.DataTipTemplate.DataTipRows(end)=dataTipTextRow(replace(info.(groundVar).Opts.DataName,{'_' '~'},{' ' ' '}), ...
            (h.CData-info.(groundVar).corr(1))./info.(groundVar).corr(2)+info.(groundVar).corr(3));
        h.DataTipTemplate.DataTipRows(end).Format='%.5e';
        h.DataTipTemplate.Interpreter='latex';
    end
end

%% #. Lagrangian view
% Local coordinates (relative to each node) are used because the number of
% nodes for some bodies may change, and therefore the index of the node
% we're targeting
if any(strcmpi(type,'lagrangian'))
    for groundVar=groundsNamesSurface
        if ~isempty(info.(groundVar).Opts.Lagrangian)
            if numel(info.(groundVar).Opts.Lagrangian)>1
                if ~isempty(info.(groundVar).Opts.Lagrangian(2))
                    % If body is specified, the node is taken from the body's frame of reference.
                    body=info.(groundVar).Opts.Lagrangian(1);
                    indLocalNode=info.(groundVar).Opts.Lagrangian(2:end);
                    indGlobalNode=find(info.(groundVar).Opts.BodyIndex==body);
                    indGlobalNode=indGlobalNode(indLocalNode);
                else
                    % Otherwise, we take the node in the global reference frame
                    indGlobalNode=info.(groundVar).Opts.Lagrangian(1);
                end
            else
                % Otherwise, we take the node in the global reference frame
                indGlobalNode=info.(groundVar).Opts.Lagrangian(1);
            end
            v=axis(ax);
            deltaX=v(2)-v(1); deltaY=v(4)-v(3);
            xM=mean(info.(groundVar).x(indGlobalNode)); yM=mean(info.(groundVar).y(indGlobalNode)); 
            axis(ax,[xM-deltaX/2 xM+deltaX/2 yM-deltaY/2 yM+deltaY/2]);
            break;
        end
    end
end

% #. Visibility
% View graph only when loaded
% #.#. Colorbars
% #.#.#. All
objects=FindObjects(ax);
if ~isempty(objects)
    offCell= num2cell(ones(1,numel(objects))); % Created a cell filled with 1
    [objects(:).Visible] = offCell{:};
end
% #.#.#. Invisible colorbars
cTemp=FindObjects(ax,'Type','colorbar'); % The 1st element is the most recent
groundNum=0; kCol=sum(colorbarList)+1; % The 1st element is the most recent
for groundVar=groundsNames
    groundNum=groundNum+1;
    if colorbarList(groundNum)==1
        kCol=kCol-1; % The 1st element is the most recent
        if strcmpi(info.(groundVar).Opts.ColorbarLocation,'invisible')
            cTemp(kCol).Visible='off';
        end
    end
end
% #.#. Graphics
for childNum=1:numel(ax.Children) % The 1st element is the most recent
    if ~isempty(info.(groundVar).Opts.Yyaxis)
        yyaxis(ax,'left');
        ax.Children(childNum).Visible='on';
        yyaxis(ax,'right');
        ax.Children(childNum).Visible='on';
    else
        ax.Children(childNum).Visible='on';
    end
end
% #.#. Nodes
if exist('nodes','var')~=0
    for nodesNum=1:numel(nodes)
        if ~isempty(nodes{nodesNum})
            nodes{nodesNum}.Visible='on';
        end
    end
end
% #.#. Background
ax.Visible='on';

end