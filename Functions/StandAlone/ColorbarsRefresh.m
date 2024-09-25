%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                           ColorbarsRefresh                            %%
%%                    Last update: February 16, 2022                     %%
%%                             Kévin Daigne                              %%
%%                        kevin.daigne@hotmail.fr                        %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Updates graphs and colorbars when limits change (compatible with multiple
% graphs within the same axes)
%% - Input -
% ax = axes : axes containing graphs and colorbars
%% - Options -
% 'Normalized' =
%   - 0 (default) : Not normalized (if scalar, apply to all colorbars, otherwise 1*NColorbars double)
%   - 1 : Normalized (if scalar, apply to all colorbars, otherwise 1*NColorbars double)
%   - 'First' : Only the 1st colorbar is normalized
%   - 'Last' : Only the last colorbar is normalized
% 'Mode' = 'All' (default) or 'Limit' or 'Plot' :
%   - 'All': Modifies graphics and colorbars
%   - 'Limit': Calculates limits without modification
%   - 'Plot': Modifies plot without modifying colorbars
%   - 'Format': Modifies formatting only (not compatible with tick change)
% The values of the following options can be specified using a single value (apply to all groups) or one per group
% 'NewLimits' = [min max] : New limits for each colorbar (if not specified, found automatically)
% 'OldLimits' = [min max] : Old limits for each colorbar (if not specified, found automatically)
% 'TicksNumber' : Number of ticks on the colorbar (not modified if empty)
% 'TicksColor' : Color of ticks on the colorbar (not modified if empty)
% 'ColorbarName': Name of colorbar label (not modified if empty)
% 'ColorbarNameColor': Color of colorbar label (not modified if empty)
% 'FontSize' : Size of colorbar label (not modified if empty)
%% - Outputs -
% cOld = NColorbars * [min max] : colorbar limits before change
% cNew = NColorbars * [min max] : colorbar limits after change
%% -

function [cOld,cNew]=ColorbarsRefresh(ax,varargin)

% #. Inputs
p=inputParser;
addOptional(p,'OldLimits',[]);
addOptional(p,'NewLimits',[]);
addOptional(p,'Normalized',[]);
addOptional(p,'TicksNumber','auto');
addOptional(p,'TicksColor',[]);
addOptional(p,'ColorbarName',[]);
addOptional(p,'ColorbarNameColor',[]);
addOptional(p,'FontSize',[]);
addOptional(p,'Mode','All');
parse(p,varargin{:});
opts=p.Results;

% #. Finding the colorbars
[colorbars,~,~]=FindObjects(ax);
colorbarsNumber=numel(colorbars);
if colorbarsNumber==0
    % No colorbar
    return;
end

% #. Initialization
cOld=zeros(colorbarsNumber,2); cNew=zeros(colorbarsNumber,2);
if (strcmpi(opts.Normalized,'first') || strcmpi(opts.Normalized,'last')) && colorbarsNumber<=1
    opts.Normalized=zeros(1,colorbarsNumber);
elseif strcmpi(opts.Normalized,'first')
    opts.Normalized=zeros(1,colorbarsNumber);
    opts.Normalized(1)=1;
elseif strcmpi(opts.Normalized,'last')
    opts.Normalized=zeros(1,colorbarsNumber);
    opts.Normalized(end)=1;
elseif isempty(opts.Normalized)
    opts.Normalized=zeros(1,colorbarsNumber);
elseif max(size(opts.Normalized))==1
    opts.Normalized=repmat(opts.Normalized,1,colorbarsNumber);
end
% If the values are not specified for each colorbar
for string=["NewLimits" "OldLimits" "TicksNumber" "TicksColor" "ColorbarName" "ColorbarNameColor" "FontSize"]
    if iscell(opts.(string))
        if max(size(opts.(string)))==1
            opts.(string)=repmat(opts.(string),1,colorbarsNumber); % Indicates the same value for all groups
        elseif max(size(opts.(string)))~=colorbarsNumber
            return;
        end
    else
        opts.(string)=repmat({opts.(string)},1,colorbarsNumber); % Indicates the same value for all groups
    end
end

for colorbarNum=1:colorbarsNumber
    
    % #. Color processing
    % #.#. Ticks color
    if ~isempty(opts.TicksColor{colorbarNum})
        if strcmpi(opts.TicksColor{colorbarNum},'auto')
            if contains(lower(colorbars(colorbarNum).Location),'outside') ...
                    || contains(lower(colorbars(colorbarNum).Location),'manual')
                if isprop(ax.Parent,'BackgroundColor')
                    colorTemp=ax.Parent.BackgroundColor;
                elseif isprop(ax.Parent,'Color')
                    colorTemp=ax.Parent.Color;
                else
                    colorTemp=ax.Color;
                end
            else
                colorTemp=ax.Color;
            end
            nearestColor=imbinarize(rgb2gray(colorTemp),0.5);
            if isequal(nearestColor,[1 1 1])
                opts.TicksColor{colorbarNum}=[0 0 0];
            else
                opts.TicksColor{colorbarNum}=[1 1 1];
            end
        else
            opts.TicksColor{colorbarNum}=ColorConverter(opts.TicksColor{colorbarNum});
        end
    end
    % #.#. Labels color
    if ~isempty(opts.ColorbarNameColor{colorbarNum})
        if strcmpi(opts.ColorbarNameColor{colorbarNum},'auto')
            if contains(lower(colorbars(colorbarNum).Location),'outside') ...
                    || contains(lower(colorbars(colorbarNum).Location),'manual')
                if isprop(ax.Parent,'BackgroundColor')
                    colorTemp=ax.Parent.BackgroundColor;
                elseif isprop(ax.Parent,'Color')
                    colorTemp=ax.Parent.Color;
                else
                    colorTemp=ax.Color;
                end
            else
                colorTemp=ax.Color;
            end
            nearestColor=imbinarize(rgb2gray(colorTemp),0.5);
            if isequal(nearestColor,[1 1 1])
                opts.ColorbarNameColor{colorbarNum}=[0 0 0];
            else
                opts.ColorbarNameColor{colorbarNum}=[1 1 1];
            end
        else
            opts.ColorbarNameColor{colorbarNum}=ColorConverter(opts.ColorbarNameColor{colorbarNum});
        end
    end
    
    if ~strcmpi(opts.Mode,'format')
        % #. Retrieving colorbar limits
        % #.#. Old limits
        cUpdated=0; % Detects whether limits are indicated in inputs
        if colorbarNum<=numel(opts.OldLimits)
            if ~isempty(opts.OldLimits{colorbarNum})
                % #.#.#. Limits are specified
                cUpdated=1;
                cOld(colorbarNum,1)=opts.OldLimits{colorbarNum}(1);
                cOld(colorbarNum,2)=opts.OldLimits{colorbarNum}(2);
            end
        end
        if cUpdated==0
            % #.#.#. Limits are not specified
            if opts.Normalized(colorbarNum)==0
                % This colorbar is not normalized, so we take its limits directly
                cOld(colorbarNum,1)=colorbars(colorbarNum).Limits(1);
                cOld(colorbarNum,2)=colorbars(colorbarNum).Limits(2);
            else
                % Normalized colorbar
                % The limits are determined from the labels (which, even in
                % the case of normalization, will be real) and the tick value
                % #.#.#.#. Ticks value
                ticksValue=colorbars(colorbarNum).Ticks;
                % #.#.#.#. Converting labels into numerical values
                ticksLabelTemp=colorbars(colorbarNum).TickLabels;
                ticksLabel=zeros(1,numel(ticksLabelTemp));
                % Suppress color and convert to numerical
                for ticksNum=1:numel(ticksLabelTemp)
                    if contains(ticksLabelTemp{ticksNum},'\color')
                        ind=strfind(ticksLabelTemp{ticksNum},'}');
                        if ~isempty(ind)
                            ticksLabel(ticksNum)=str2double(ticksLabelTemp{ticksNum}(ind+1:end));
                        else
                            msgbox('Can''t read ticks for one of the colorbar(s)');
                            return;
                        end
                    else
                        ticksLabel(ticksNum)=str2double(ticksLabelTemp{ticksNum});
                    end
                end
                % #.#.#.#. Interpolation
                pol=polyfit(ticksValue,ticksLabel,1);
                cOld(colorbarNum,1)=polyval(pol,colorbars(colorbarNum).Limits(1));
                cOld(colorbarNum,2)=polyval(pol,colorbars(colorbarNum).Limits(2));
            end
        end
        
        % #.#. New limits
        cUpdated=0; % Detects whether limits are indicated in inputs
        if colorbarNum<=numel(opts.NewLimits)
            if ~isempty(opts.NewLimits{colorbarNum})
                % #.#.#. Limits are specified
                cUpdated=1;
                cNew(colorbarNum,1)=opts.NewLimits{colorbarNum}(1);
                cNew(colorbarNum,2)=opts.NewLimits{colorbarNum}(2);
            end
        end
        if cUpdated==0
            % #.#.#. Limits are not specified
            % We take them equal to the old ones
            cNew(colorbarNum,1)=cOld(colorbarNum,1);
            cNew(colorbarNum,2)=cOld(colorbarNum,2);
        end
    end
end

% #. Stop if Mode='Limit'
if strcmpi(opts.Mode,'limit')
    return;
end

% #. caxis
if ~strcmpi(opts.Mode,'format')
    cAxisOld=clim(ax);
    cAxisNew=[min(cNew(opts.Normalized==0,1)) max(cNew(opts.Normalized==0,2))];
    if ~isempty(cAxisNew) && strcmpi(opts.Mode,'all')
        clim(ax,cAxisNew);
    else
        cAxisNew=cAxisOld;
    end
end

% #. Modification of certain results
for colorbarNum=1:colorbarsNumber
    
    if ~strcmpi(opts.Mode,'format')
        % #.#. Axes
        % If the reference is changed, then the values in the normalized
        % plane will also change. The following relationship allows us to
        % find the new values in the case where all limits change
        % (normalized plane and reference)
        if opts.Normalized(colorbarNum)==1
            cBMinOld=cOld(colorbarNum,1); cBMaxOld=cOld(colorbarNum,2);
            cFMinOld=cAxisOld(1); cFMaxOld=cAxisOld(2);
            cBMinNew=cNew(colorbarNum,1); cBMaxNew=cNew(colorbarNum,2);
            cFMinNew=cAxisNew(1); cFMaxNew=cAxisNew(2);
            dBOld=cBMaxOld-cBMinOld; dBNew=cBMaxNew-cBMinNew;
            dFOld=cFMaxOld-cFMinOld; dFNew=cFMaxNew-cFMinNew;
            if isprop(ax.Children(colorbarsNumber-colorbarNum+1),'FaceVertexCData')
                % The order of the plots is reversed in relation to that of the legends
                set(ax.Children(colorbarsNumber-colorbarNum+1),'FaceVertexCData',...
                    cFMinNew+(cFMinOld+(cBMinOld+(get(ax.Children(colorbarsNumber-colorbarNum+1),'FaceVertexCData')...
                    -cFMinOld).*(dBOld/dFOld)-cBMinNew).*(dFOld/dBNew)-cFMinOld).*(dFNew/dFOld));
            end
        end
        
        % #.#. Continue if Mode='Plot'
        if strcmpi(opts.Mode,'plot')
            continue;
        end
        
        % #.#. Mode
        colorbars(colorbarNum).TicksMode='manual';
        
        % #.#. Colorbar limits
        if opts.Normalized(colorbarNum)==1
            colorbars(colorbarNum).Limits=cAxisNew;
        else
            colorbars(colorbarNum).Limits=cNew(colorbarNum,:);
        end
        
        % #.#. Ticks
        % #.#.#. TicksNumber
        if isempty(opts.TicksNumber{colorbarNum})
            TicksNumberTemp=numel(colorbars(colorbarNum).Ticks);
        elseif strcmpi(opts.TicksNumber{colorbarNum},'auto')
            colorbars(colorbarNum).TicksMode='auto';
            TicksNumberTemp=numel(colorbars(colorbarNum).Ticks);
            if TicksNumberTemp>7
                TicksNumberTemp=7; % No more than 7 ticks
            elseif TicksNumberTemp>3
                TicksNumberTemp = 2*floor(TicksNumberTemp/2)+1; % Central value
            elseif TicksNumberTemp<=1
                TicksNumberTemp=2;
            end
            colorbars(colorbarNum).TicksMode='manual';
        else
            TicksNumberTemp=opts.TicksNumber{colorbarNum};
        end
        % #.#.#. Affectation
        if opts.Normalized(colorbarNum)==1
            colorbars(colorbarNum).Ticks=linspace(cAxisNew(1),cAxisNew(2),TicksNumberTemp);
        else
            colorbars(colorbarNum).Ticks=linspace(cNew(colorbarNum,1),cNew(colorbarNum,2),TicksNumberTemp);
        end
    end
    
    % #.#. TickLabels
    % #.#.#. TicksColor
    if isempty(opts.TicksColor{colorbarNum})
        % We find the color if it is in latex form
        if contains(colorbars(colorbarNum).TickLabels{1},'\color')
            ind=strfind(colorbars(colorbarNum).TickLabels{1},'}');
            if ~isempty(ind)
                TicksColorTemp=colorbars(colorbarNum).TickLabels{1}(1:ind(1));
            else
                TicksColorTemp=[];
            end
        else
            TicksColorTemp=[];
        end
    else
        TicksColorTemp=ColorConverter(opts.TicksColor{colorbarNum});
        TicksColorTemp=['\color[rgb]{' num2str(TicksColorTemp) '}'];
    end
    % #.#.#. Assignment
    if ~strcmpi(opts.Mode,'format')
        % #.#.#.#. Modification of TickLabels with possible modification of limits
        colorbars(colorbarNum).TickLabels=strcat(TicksColorTemp,...
            arrayfun(@(x) num2str(x,'%.1e'),linspace(cNew(colorbarNum,1),cNew(colorbarNum,2),TicksNumberTemp),'UniformOutput',false));
    else
        if ~isempty(opts.TicksColor{colorbarNum})
            % #.#.#.#. Modification of TickLabels with possible modification of limits
            ticksNumber=numel(colorbars(colorbarNum).TickLabels);
            tickLabelsTemp=cell(1,ticksNumber);
            for ticksNum=1:ticksNumber
                if contains(colorbars(colorbarNum).TickLabels{ticksNum},'\color')
                    ind=strfind(colorbars(colorbarNum).TickLabels{ticksNum},'}');
                    if ~isempty(ind)
                        tickLabelsTemp{ticksNum}=colorbars(colorbarNum).TickLabels{ticksNum}(ind(1)+1:end);
                    else
                        tickLabelsTemp{ticksNum}=colorbars(colorbarNum).TickLabels{ticksNum};
                    end
                else
                    tickLabelsTemp{ticksNum}=colorbars(colorbarNum).TickLabels{ticksNum};
                end
            end
            colorbars(colorbarNum).TickLabels=strcat(TicksColorTemp,tickLabelsTemp);
        end
    end
    
    % #.#. Label
    if ~isempty(opts.ColorbarName{colorbarNum}) || ~isempty(opts.ColorbarNameColor{colorbarNum})
        if contains(colorbars(colorbarNum).Label.String,'\color')
            ind=strfind(colorbars(colorbarNum).Label.String,'}');
        else
            ind=[];
        end
        % #.#.#. ColorbarName
        if ~isempty(opts.ColorbarName{colorbarNum})
            ColorbarNameTemp=opts.ColorbarName{colorbarNum};
        elseif ~isempty(ind)
            ColorbarNameTemp=colorbars(colorbarNum).Label.String(ind(1)+1:end);
        else
            ColorbarNameTemp=colorbars(colorbarNum).Label.String;
        end
        % #.#.#. ColorbarNameColor
        if ~isempty(opts.ColorbarNameColor{colorbarNum})
            colorbars(colorbarNum).Label.Color=opts.ColorbarNameColor{colorbarNum};
            ColorbarNameColorTemp=[];
        elseif ~isempty(ind)
            ColorbarNameColorTemp=colorbars(colorbarNum).Label.String(1:ind(1));
        else
            ColorbarNameColorTemp=[];
        end
        % #.#.#. Assignment
        colorbars(colorbarNum).Label.String=[ColorbarNameColorTemp ColorbarNameTemp]; 
    end
    
    % #.#. FontSize
    if ~isempty(opts.FontSize{colorbarNum})
        colorbars(colorbarNum).Label.FontSize=opts.FontSize{colorbarNum};
    end
end

% #. Shifting ticks
if ~strcmpi(opts.Mode,'format')
    TicksOffset(ax);
end