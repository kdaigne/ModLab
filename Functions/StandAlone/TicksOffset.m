%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                             TicksOffset                               %%
%%                       Last update: March 01, 2022                     %%
%%                             Kévin Daigne                              %%
%%                        kevin.daigne@hotmail.fr                        %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Ticks at the end of the colorbar are shifted into the frame
%% - Input -
% ax = axes : axes with colorbar
%% - Method -
% In order not to alter the colorbar position (otherwise it will not
% resize correctly when the axes is modified), we add spaces (' ') to the
% ticks so that they fit within the frame.
%% -

function TicksOffset(ax,varargin)

% #. Colorbars
[colorbars,~,~]=FindObjects(ax);
colorbarsNumber=numel(colorbars);

% #. Axes
posAxes=ObjectPosition(ax,'Type','InnerPosition','Units','Pixels'); % Position does not always produce satisfactory results
ratioAxes=posAxes(3)/posAxes(4);

for colorbarNum=1:colorbarsNumber
    if colorbars(colorbarNum).Label.Rotation==0 % Tick shifting only applies to horizontal colorbars
        % #. Frame
        posColorbar=ObjectPosition(colorbars(colorbarNum),'Type','Position','Units','Pixels');
        % #. dFree
        % Free space between the end of the colorbar and the edge of the figure
        % <-----------> dTicks
        %    |
        % XXX|XXXXXXXXX
        %    |  |=========|(colorbar)
        %    <--> dFree
        % <-> dOffset (offset to be corrected with spaces)
        % #.#. Graph position
        % We don't know the position of the graph frame, which may differ
        % from that of the axis, depending on the ratio. We therefore need
        % to compare the ratios to find out whether the graph's x0 is equal
        % to the frame's x0.
        if contains(colorbars(colorbarNum).Location,'outside') ...
                || contains(colorbars(colorbarNum).Location,'manual')
            dFree=[posColorbar(1) posColorbar(1)];
        else
            v=axis(ax);
            if numel(v)<=4
                % 2D
                ratioPatch=(v(2)-v(1))/(v(4)-v(3));
            else
                % 3D
                [~,ratioPatch]=Projection3Dto2D(ax);
            end
            if ratioPatch<ratioAxes && isequal(ax.DataAspectRatio,[1 1 1]) && numel(v)<=4
                % x0 graph/figure different, so we compare the width of
                % the colorbar and the width of the graph to deduce the
                % free space. Does not work well for 3D figures.
                dFree=repmat((posAxes(4)*ratioPatch-posColorbar(3))/2,1,2);
            else
                % x0 graph/figure identical, so colorbar x0 is equal to dFree
                dFree=repmat(posColorbar(1)-posAxes(1),1,2);
            end
        end
        % #. Text width
        % Use the extent property to determine the exact width of characters
        % dTicks: Width of left and right ticks
        % dSpace: Width added per space
        % #.#. Removes possible tick color
        % #.#.#. Tick min
        tickMin=colorbars(colorbarNum).TickLabels{1};
        if contains(tickMin,'\color')
            ind=strfind(tickMin,'}');
            if ~isempty(ind)
                tickMinColor=tickMin(1:ind(1));
                tickMin=erase(tickMin(ind(1)+1:end),' ');
            else % Format not recognized
                tickMinColor=[];
                tickMin=erase(tickMin,' ');
            end
        else
            tickMinColor=[];
            tickMin=erase(tickMin,' ');
        end
        % #.#.#. Tick max
        tickMax=colorbars(colorbarNum).TickLabels{end};
        if contains(tickMax,'\color')
            ind=strfind(tickMax,'}');
            if ~isempty(ind)
                tickMaxColor=tickMax(1:ind(1));
                tickMax=erase(tickMax(ind(1)+1:end),' ');
            else % Format not recognized
                tickMaxColor=[];
                tickMax=erase(tickMax,' ');
            end
        else
            tickMaxColor=[];
            tickMax=erase(tickMax,' ');
        end
        % #.#. Object creation
        % For some unknown reason (tex format?), uicontrols give wrong
        % dimensions. We therefore use the extent property of the label
        labelSave=colorbars(colorbarNum).Label.String;
        interpreterSave=colorbars(colorbarNum).Label.Interpreter;
        if ~strcmpi(colorbars(colorbarNum).TickLabelInterpreter,interpreterSave)
            colorbars(colorbarNum).Label.String=''; % Avoids error message if format not compatible
            colorbars(colorbarNum).Label.Interpreter=colorbars(colorbarNum).TickLabelInterpreter;
        end
        colorbars(colorbarNum).Label.String=tickMin;
        pos=ObjectPosition(colorbars(colorbarNum).Label,'Type','Extent','Units','Pixels');
        dTicks(1)=pos(3);
        colorbars(colorbarNum).Label.String=tickMax;
        pos=ObjectPosition(colorbars(colorbarNum).Label,'Type','Extent','Units','Pixels');
        dTicks(2)=pos(3);
        colorbars(colorbarNum).Label.String=[tickMin '  '];
        pos=ObjectPosition(colorbars(colorbarNum).Label,'Type','Extent','Units','Pixels');
        space1=pos(3);
        colorbars(colorbarNum).Label.String=[tickMin '   '];
        pos=ObjectPosition(colorbars(colorbarNum).Label,'Type','Extent','Units','Pixels');
        space2=pos(3);
        dSpace(1)=space2-space1;
        colorbars(colorbarNum).Label.String=[tickMax '  '];
        pos=ObjectPosition(colorbars(colorbarNum).Label,'Type','Extent','Units','Pixels');
        space1=pos(3);
        colorbars(colorbarNum).Label.String=[tickMax '   '];
        pos=ObjectPosition(colorbars(colorbarNum).Label,'Type','Extent','Units','Pixels');
        space2=pos(3);
        dSpace(2)=space2-space1;
        if ~strcmpi(colorbars(colorbarNum).TickLabelInterpreter,interpreterSave)
            colorbars(colorbarNum).Label.Interpreter=interpreterSave;
        end
        colorbars(colorbarNum).Label.String=labelSave;

        % #. Offset calculation
        % dOffset : Offset to be corrected with spaces
        dOffset=dTicks/2-dFree;

        % #. Calculates number of spaces to add
        % #.#. Left tick
        if dOffset(1)>0
            nMin=ceil((dTicks(1)-2*dFree(1))/dSpace(1));
            decMin=repmat({' '},nMin,1);
            colorbars(colorbarNum).TickLabels{1}=[tickMinColor decMin{:} tickMin];
        else % Correction not necessary
            colorbars(colorbarNum).TickLabels{1}=[tickMinColor tickMin];
        end
        % #.#. Right tick
        if dOffset(2)>0
            nMax=ceil((dTicks(2)-2*dFree(2))/dSpace(2));
            decMax=repmat({' '},nMax,1);
            colorbars(colorbarNum).TickLabels{end}=[tickMaxColor tickMax decMax{:}];
        else % Correction not necessary
            colorbars(colorbarNum).TickLabels{end}=[tickMaxColor tickMax];
        end
    end
end