%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                             GraphsLimits                              %%
%%                      Last update: April 02, 2022                      %%
%%                             Kévin Daigne                              %%
%%                        kevin.daigne@hotmail.fr                        %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Gives a set of limits for several graphs according to certain conditions
%% - Input -
% axes = cells : 1*N {groups} composed of 1*M {axes}: 
%   - Group : group of axes positioned horizontally and side by side
%   - Axes : axes containing the graphs to be copied
%% - Outputs -
% spaceScaleLimValue = [xmin xmax ymin ymax] : Spatial limits if applicable
% colorLimValue = 1*N1Label {'label' min max} : Label and limits for colorbar if applicable
% colorLimInd = 1*NGraph double : Index of limits in colorLimValue (as several graphs can share common limits)
% XLimValue = 1*N2Label {'label' min max} : Label and limits for X axis if applicable
% XLimInd = 1*NGraph double : Index of limits in XLimValue (as several graphs can share common limits)
% YLimValue = 1*N3Label {'label' min max} : Label and limits for Y axis if applicable
% YLimInd = 1*NGraph double : Index of limits in YLimValue (as several graphs can share common limits)
%% - Options -
% The values of the following options can be specified using a single value (apply to all groups) or one per group
% 'View' =
%   - [] : Does not alter the view
%   - 'Equal' : Same view for all surface graphs, images, etc.
% 'ColorScale' = 1*NGroups double a value from -inf to inf (-2 by default and inf to disable it) : For colorbars, determines the number of label parts (i.e. words) to be taken into account to consider 2 colorbars as identical and apply common limits (explained below)
%% - Scaling method (ColorScale) -
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

function [XLimValue,XLimInd,YLimValue,YLimInd,spaceScaleLimValue,colorLimValue,colorLimInd]=GraphsLimits(axes,varargin)

% #. Inputs
p=inputParser;
addOptional(p,'View',0);
addOptional(p,'AxisScale',inf);
addOptional(p,'ColorScale',inf);
parse(p,varargin{:});
opts=p.Results;
for string=["View" "AxisScale" "ColorScale"]
    if iscell(opts.(string))
        if max(size(opts.(string)))==1
            opts.(string)=repmat(opts.(string),1,max(size(axes))); % Indicates the same value for all groups
        elseif max(size(opts.(string)))~=max(size(axes))
            return;
        end
    else
        opts.(string)=repmat({opts.(string)},1,max(size(axes))); % Indicates the same value for all groups
    end
end

% #. Initialization
graphsNumber=sum(cellfun(@(x) numel(x),axes));
spaceScaleLimValue=[]; colorLimValue=cell(graphsNumber,3); colorLimInd=zeros(1,graphsNumber);
XLimValue=cell(graphsNumber,3); YLimValue=cell(graphsNumber,3); XLimInd=zeros(1,graphsNumber); YLimInd=zeros(1,graphsNumber);

% #. Processing each group
kAxes=0; kColorbar=0;
for groupNum=1:numel(axes) % Loop on each group
    for graphNum=1:numel(axes{groupNum})
        
        if isequal(axes{groupNum}{graphNum}.DataAspectRatio,[1 1 1])
            
            % #.#. Non-resizable graphic type
            
            % #.#.#. Spatial limits
            kAxes=kAxes+1;
            if ~isempty(opts.View{groupNum})
                v=axis(axes{groupNum}{graphNum});
                if isempty(spaceScaleLimValue) % Initial value
                    spaceScaleLimValue=v(1:4);
                else
                    if spaceScaleLimValue(1)>v(1)
                        spaceScaleLimValue(1)=v(1);
                    end
                    if spaceScaleLimValue(2)<v(2)
                        spaceScaleLimValue(2)=v(2);
                    end
                    if spaceScaleLimValue(3)>v(3)
                        spaceScaleLimValue(3)=v(3);
                    end
                    if spaceScaleLimValue(4)<v(4)
                        spaceScaleLimValue(4)=v(4);
                    end
                end
            end
            
            % #.#.#. Colorbar limits
            axescolorbar=FindObjects(axes{groupNum}{graphNum});
            if numel(axescolorbar)>1
                % #.#.#.#. Several colorbars
                [cOld,~]=ColorbarsRefresh(axes{groupNum}{graphNum},'Mode','Limit','Normalized','last');
            end
            if ~isempty(axescolorbar)
                for colorbarNum=1:numel(axescolorbar)
                    kColorbar=kColorbar+1; labNew=[];
                    % #.#.#.#. Name processing
                    % #.#.#.#.#. Add direction if necessary
                    labOld=replace(axescolorbar(colorbarNum).Label.String,'~',' '); % If ever latex type, there may be unbreakable spaces
                    if ~isempty(labOld) % If there's a label
                        % #.#.#.#.#.#. Color removal
                        if contains(labOld,'\color')
                            ind=strfind(labOld,'}'); % We don't delete the cell directly because it may be of the form {'\color{black}velocity' 'magnitude'}
                            if ~isempty(ind)
                                labOld(1:ind(1))=[]; % e.g. {'\color{black}' 'velocity' 'magnitude'} -> {'' 'velocity' 'magnitude'}
                            end
                        end
                        if ~strcmpi(labOld(end),')')
                            labOld=char(strcat(labOld,{' '},'(magnitude)')); % Some titles don't contain this precision, so we add it to make it easier to use the factors
                        end
                        labOld=strsplit(labOld,{' ' '(' ')'}); % e.g. \color{black} velocity (magnitude) -> {'\color{black}' 'velocity' 'magnitude'}
                        labOld(cellfun(@isempty,labOld))=[]; % e.g. {'' 'velocity' 'magnitude'} -> {'velocity' 'magnitude'}
                        if abs(opts.ColorScale{groupNum})==inf
                            % #.#.#.#.#.#. Common scale deactivated -> Gives a unique name
                            labNew=tempname;
                        elseif opts.ColorScale{groupNum}==0
                            % #.#.#.#.#.#. Common scale for all -> Give an empty name
                            labNew='';
                        elseif abs(opts.ColorScale{groupNum})>=numel(labOld)
                            % #.#.#.#.#.#. Exceeds the number of parts -> Give the full name
                            labNew=strjoin(labOld); % Otherwise cell
                        elseif opts.ColorScale{groupNum}>0
                            % #.#.#.#.#.#. Positive instruction
                            labNew=strjoin(labOld(1:opts.ColorScale{groupNum}),' ');
                        elseif opts.ColorScale{groupNum}<0
                            % #.#.#.#.#.#. Negative instruction
                            labNew=strjoin(labOld(1:end+opts.ColorScale{groupNum}),' ');
                        end
                        labNew=erase(labNew,{'~' ' '});
                    else % No label
                        labNew=tempname; % Create a new element in all cases
                    end
                    % #.#.#.#.#. Limits processing
                    if isscalar(axescolorbar)
                        % #.#.#.#.#.#. One colorbar
                        colorBarLimTemp=axescolorbar(colorbarNum).Limits;
                    else
                        % #.#.#.#.#.#. Several colorbars
                        if colorbarNum==1
                            colorBarLimTemp=cOld(1,:);
                        else
                            colorBarLimTemp=cOld(2,:);
                        end
                    end
                    % #.#.#.#.#. Comparaison avec l'existant
                    indLabel=find(strcmpi(colorLimValue(:,1),labNew));
                    if isempty(indLabel)
                        % #.#.#.#.#.#. New entry
                        colorLimValue{kColorbar,1}=labNew;
                        colorLimValue{kColorbar,2}=colorBarLimTemp(1); % min
                        colorLimValue{kColorbar,3}=colorBarLimTemp(2); % max
                        colorLimInd(kColorbar)=sum(~cellfun(@isempty,colorLimValue(:,1)));
                    else
                        % #.#.#.#.#.#. Existing entry
                        if colorLimValue{indLabel,2}>colorBarLimTemp(1) % min
                            colorLimValue{indLabel,2}=colorBarLimTemp(1); % min
                        end
                        if colorLimValue{indLabel,3}<colorBarLimTemp(2) % max
                            colorLimValue{indLabel,3}=colorBarLimTemp(2); % max
                        end
                        colorLimInd(kColorbar)=indLabel-sum(cellfun(@isempty,colorLimValue(1:indLabel,1))); % empty as these lines will be removed
                    end
                end
            end
        else
            
            % #.#. Plot
            
            % #.#.#. Loop on X Y
            
            for axeName=['X' 'Y']
                
                for sideNum=1:numel(axes{groupNum}{graphNum}.([axeName 'Axis']))
                    
                    % #.#.#.#. Name processing
                    % The aim is to isolate the parameters so that they can
                    % be trimmed according to the number of parts taken
                    % into account
                    % #.#.#.#.#. Label
                    kAxes=kAxes+1;
                    labOld=replace(axes{groupNum}{graphNum}.([axeName 'Axis'])(sideNum).Label.String,'~',' '); % If ever latex type, there may be unbreakable spaces
                    if ~iscell(labOld)
                        labOld={labOld};
                    end
                    labNew=cell(1,numel(labOld));
                    for labNum=1:numel(labOld)
                        % #.#.#.#.#. Remove indices [variable](indices)
                        bracketInd=strfind(labOld{labNum},'](');
                        for bracketNum=numel(bracketInd):-1:1
                            closingBracket=find(labOld{labNum}(bracketInd(bracketNum):end)==')',1,'first')+bracketInd(bracketNum)-1;
                            labOld{labNum}(bracketInd(bracketNum)+1:closingBracket)=[];
                        end
                        % #.#.#.#.#. Preprocessing data
                        % They are transformed according to the number of parts taken into account
                        bracketInf=strfind(labOld{labNum},'['); bracketSup=strfind(labOld{labNum},']');
                        if isempty(bracketInf)
                            bracketInf=1; bracketSup=numel(labOld{labNum});
                        end
                        varOld=cell(1,numel(bracketInf)); varNew=cell(1,numel(bracketInf));
                        for varNum=1:numel(bracketInf)
                            varOld{varNum}=labOld{labNum}(bracketInf(varNum)+1:bracketSup(varNum)-1);
                            varTemp=split(varOld{varNum},' ');
                            if abs(opts.AxisScale{groupNum})==inf
                                % #.#.#.#.#.#. Common scale deactivated -> Gives a unique name
                                varTemp=tempname;
                            elseif opts.AxisScale{groupNum}==0
                                % #.#.#.#.#.#. Common scale for all -> Give an empty name
                                varTemp='';
                            elseif abs(opts.AxisScale{groupNum})>=numel(varTemp)
                                % #.#.#.#.#.#. Exceeds the number of parts -> Give the full name
                                varTemp=strjoin(varTemp); % Otherwise cell
                            elseif opts.AxisScale{groupNum}>0
                                % #.#.#.#.#.#. Positive instruction
                                varTemp=strjoin(varTemp(1:opts.AxisScale{groupNum}),' ');
                            elseif opts.AxisScale{groupNum}<0
                                % #.#.#.#.#.#. Negative instruction
                                varTemp=strjoin(varTemp(1:end+opts.AxisScale{groupNum}),' ');
                            end
                            varNew{varNum}=erase(strtrim(varTemp),{'~' ' '});
                        end
                        labNew{labNum}=erase(regexprep(labOld{labNum},varOld,varNew),{'~' ' '});
                    end
                    labNew=strcat(labNew{:});
                    % #.#.#.#. Limits processing
                    if axeName=='X'
                        % #.#.#.#.#. X
                        plotLim=axes{groupNum}{graphNum}.([axeName 'Axis'])(sideNum).Limits;
                        indLabel=find(strcmpi(XLimValue(:,1),labNew));
                        if isempty(indLabel)
                            % #.#.#.#.#.#. New entry
                            XLimValue{kAxes,1}=labNew;
                            XLimValue{kAxes,2}=plotLim(1); % min
                            XLimValue{kAxes,3}=plotLim(2); % max
                            XLimInd(kAxes)=sum(~cellfun(@isempty,XLimValue(:,1)));
                        else
                            % #.#.#.#.#.#. Existing entry
                            if XLimValue{indLabel,2}>plotLim(1) % min
                                XLimValue{indLabel,2}=plotLim(1); % min
                            end
                            if XLimValue{indLabel,3}<plotLim(2) % max
                                XLimValue{indLabel,3}=plotLim(2); % max
                            end
                            XLimInd(kAxes)=indLabel-sum(cellfun(@isempty,XLimValue(1:indLabel,1))); % empty as these lines will be removed
                        end
                    else
                        % #.#.#.#.#. Y
                        plotLim=axes{groupNum}{graphNum}.([axeName 'Axis'])(sideNum).Limits;
                        indLabel=find(strcmpi(YLimValue(:,1),labNew));
                        if isempty(indLabel)
                            % #.#.#.#.#.#. New entry
                            YLimValue{kAxes,1}=labNew;
                            YLimValue{kAxes,2}=plotLim(1); % min
                            YLimValue{kAxes,3}=plotLim(2); % max
                            YLimInd(kAxes)=sum(~cellfun(@isempty,YLimValue(:,1)));
                        else
                            % #.#.#.#.#.#. Existing entry
                            if YLimValue{indLabel,2}>plotLim(1) % min
                                YLimValue{indLabel,2}=plotLim(1); % min
                            end
                            if YLimValue{indLabel,3}<plotLim(2) % max
                                YLimValue{indLabel,3}=plotLim(2); % max
                            end
                            YLimInd(kAxes)=indLabel-sum(cellfun(@isempty,YLimValue(1:indLabel,1))); % empty as these lines will be removed
                        end
                    end
                end
            end
        end
    end
end

% #. Deleting empty elements
colorLimValue(cellfun(@isempty,colorLimValue(:,1)),:)=[];
colorLimInd(:,colorLimInd==0)=[];
XLimValue(cellfun(@isempty,XLimValue(:,1)),:)=[];
YLimValue(cellfun(@isempty,YLimValue(:,1)),:)=[];
XLimInd(:,XLimInd==0)=[];
YLimInd(:,YLimInd==0)=[];