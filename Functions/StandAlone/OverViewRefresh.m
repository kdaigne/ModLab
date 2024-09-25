%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                            OverViewRefresh                            %%
%%                       Last update: April 02, 2022                     %%
%%                             Kévin Daigne                              %%
%%                        kevin.daigne@hotmail.fr                        %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Updates graphs contain in a figure
%% - Inputs -
% fig = figure : 
%   - Figure containing graphs
% axes : 
%   - Updated axes
%   - 1*NGroups cells and one group contains 1*NAxes cell
%   - e.g. ith axes of the jth group = axes{j}{i}
%% - Options -
% 'View' =
%   - [] : Does not alter the view
%   - 'Equal' : Same view for all surface graphs, images, etc.
%   - 'Follow' : Keeps the width and height of the axes but modifies the central view
%   - The value can be specified using a single value (apply to all groups) or one per group
% 'DataTips' = 0 ou 1 (default) : Enable or disable transfer of data tips (time-consuming)
%% -

function OverViewRefresh(fig,axes,varargin)

% #. Remove empty cells from axes
axes(cellfun(@isempty,axes))=[];
for groupNum=1:numel(axes) % Loop on groups
    axes{groupNum}(cellfun(@isempty,axes{groupNum}))=[];
end
axes(cellfun(@isempty,axes))=[];

% #. Inputs
p=inputParser;
addOptional(p,'View',[]);
addOptional(p,'DataTips',1);
parse(p,varargin{:});
opts=p.Results;
for string=["View" "DataTips"]
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
axesOld=findobj(fig,'Type','axes'); % Overrides existing labels
groupNumber=numel(axes);
axesNumber=sum(cellfun(@(x) size(x,2),axes));
kAxes=axesNumber+1; % The order via copyobj is reversed

for groupNum=1:groupNumber % Loop on groups
    for axesNum=1:numel(axes{groupNum}) % Loop on axes within the group
        kAxes=kAxes-1; % Objects in fig are not in the form (1*NGroups)(1*NAxes) but (NGroups*NAxes)
        for plotNum=1:numel(axes{groupNum}{axesNum}.Children) % Loop on each plot of each axes
            
            % #. Modification
            
            if isprop(axesOld(kAxes).Children(plotNum),'FaceVertexCData') ...
                    && isprop(axesOld(kAxes).Children(plotNum),'Vertices') ...
                    && isprop(axesOld(kAxes).Children(plotNum),'Faces')
                % #.#. Limits
                [~,cNew]=ColorbarsRefresh(axesOld(kAxes),'Normalized','first','Mode','Limit');
                [cOld,~]=ColorbarsRefresh(axes{groupNum}{axesNum},'Normalized','first','Mode','Limit');
                % #.#. Surface
                set(axesOld(kAxes).Children(plotNum),'FaceVertexCData',get(axes{groupNum}{axesNum}.Children(plotNum),'FaceVertexCData'), ...
                    'Vertices',get(axes{groupNum}{axesNum}.Children(plotNum),'Vertices'), ...
                    'Faces',get(axes{groupNum}{axesNum}.Children(plotNum),'Faces'));
                % #.#. Colorbar and colormap processing
                colorbarNumber=size(cOld,1);
                if colorbarNumber>0
                    OldLimits=cell(1,colorbarNumber);
                    NewLimits=cell(1,colorbarNumber);
                    for clorbarNum=1:colorbarNumber
                        OldLimits{clorbarNum}=cOld(clorbarNum,1:2);
                        NewLimits{clorbarNum}=cNew(clorbarNum,1:2);
                    end
                    ColorbarsRefresh(axesOld(kAxes),'OldLimits',OldLimits,'NewLimits',NewLimits,'Mode','Plot','Normalized','first');
                end
            elseif isprop(axesOld(kAxes).Children(plotNum),'CData')
                % #.#. Image
                set(axesOld(kAxes).Children(plotNum),'CData',get(axes{groupNum}{axesNum}.Children(plotNum),'CData'));
                
            elseif isprop(axesOld(kAxes).Children(plotNum),'XData') ...
                    && isprop(axesOld(kAxes).Children(plotNum),'YData') ...
                    && isprop(axesOld(kAxes).Children(plotNum),'ZData')
                % #.#. Plot
                for sideNum=1:numel(axes{groupNum}{axesNum}.YAxis)
                    if numel(axes{groupNum}{axesNum}.YAxis)>1
                        if sideNum==1
                            yyaxis(axes{groupNum}{axesNum},'left');
                            yyaxis(axesOld(kAxes),'left');
                        else
                            yyaxis(axes{groupNum}{axesNum},'right');
                            yyaxis(axesOld(kAxes),'right');
                        end
                    end
                    set(axesOld(kAxes).Children(plotNum),'XData',get(axes{groupNum}{axesNum}.Children(plotNum),'XData'), ...
                        'YData',get(axes{groupNum}{axesNum}.Children(plotNum),'YData'), ...
                        'ZData',get(axes{groupNum}{axesNum}.Children(plotNum),'ZData'));
                end
            end
            
            % #. Data Tips
            if opts.DataTips{groupNum}==1
                % #.#. Load DataTips if necessary
                if ~isprop(axesOld(kAxes).Children(plotNum),'DataTipTemplate')
                    if numel(axesOld(kAxes))/2==2 % Axes dimension
                        % Axes 2D
                        dt=datatip(axesOld(kAxes).Children(plotNum),0,0,'Visible','off');
                    else
                        % Axes 3D
                        dt=datatip(axesOld(kAxes).Children(plotNum),0,0,0,'Visible','off');
                    end
                    delete(dt);
                end
                if ~isprop(axes{groupNum}{axesNum}.Children(plotNum),'DataTipTemplate')
                    if numel(axes{groupNum}{axesNum})<=4 % Axes dimension
                        % Axes 2D
                        dt=datatip(axes{groupNum}{axesNum}.Children(plotNum),0,0,'Visible','off');
                    else
                        % Axes 3D
                        dt=datatip(axes{groupNum}{axesNum}.Children(plotNum),0,0,0,'Visible','off');
                    end
                    delete(dt);
                end
                % #.#. Processing
                if isprop(axesOld(kAxes).Children(plotNum),'DataTipTemplate') && isprop(axes{groupNum}{axesNum}.Children(plotNum),'DataTipTemplate')
                    axesOld(kAxes).Children(plotNum).DataTipTemplate.DataTipRows=axes{groupNum}{axesNum}.Children(plotNum).DataTipTemplate.DataTipRows;
                end
            end
            
        end
        
        % #. Scatter
        scatterOld=findall(axesOld(kAxes),'type','scatter');
        scatterNew=findall(axes{groupNum}{axesNum},'type','scatter');
        if ~isempty(scatterOld) && ~isempty(scatterNew)
            for scatterNum=1:numel(scatterOld)
                set(scatterOld(scatterNum),'XData',get(scatterNew(scatterNum),'XData'), ...
                    'YData',get(scatterNew(scatterNum),'YData'), ...
                    'ZData',get(scatterNew(scatterNum),'ZData'));
            end
        end
        
        % #. View
        if isempty(opts.View{groupNum})
            % #.#. Update
            axis(axesOld(kAxes),axis(axes{groupNum}{axesNum}));
            [az,el]=view(axes{groupNum}{axesNum});
            view(axesOld(kAxes),[az,el]);
        elseif strcmpi(opts.View{groupNum},'Follow')
            % #.#. Follow
            % Use reshape to be valid in 2D and 3D
            delta=reshape(axis(axesOld(kAxes)),2,[])';
            delta=delta(:,2)-delta(:,1); % Axis width (max-min)
            center=reshape(axis(axes{groupNum}{axesNum}),2,[]);
            center=mean(center)'; % Coordinates of the center of the original axes
            pos=[center-delta/2 center+delta/2];
            pos=reshape(pos',1,[]); % Axis final position
            axis(axesOld(kAxes),pos);
            [az,el]=view(axes{groupNum}{axesNum});
            view(axesOld(kAxes),[az,el]);
        end
    end
end