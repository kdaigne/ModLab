%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                             PlotManager                               %%
%%                   Last update: September 17, 2024                     %%
%%                             Kévin Daigne                              %%
%%                        kevin.daigne@hotmail.fr                        %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Function used for each graphic displayed by the GUI. This can be used
% to easily modify existing graphs (e.g. reverse them vertically, apply
% coordinate transformations, etc.) or to create custom ones (depending
% on the DataManager.m inputs).
%% - Inputs -
% ax = axes :
%   - Object that contains the graphs
% info = struct :
%   - Contains all the data (and more) being used
%   - Axes (e.g. XLabel) : options concerning axes rather than graphs are stored in info.opts
%   - Graphs (e.g. coordinates) : Data and options for each graph are stored in info.grounds
%   - By modifying these 2 inputs, a complete control of the displayed
%   graphics is possible
%% - Output
% ax = axes : Object that contains the graphs
%% -

function ax=PlotManager(ax,info)


if ~isempty(ax); tagSave=ax.Tag; else; tagSave=''; end % Tag is lost when a plot is created

if ~info.selection.other.customMode

    %% #. STANDARD

    % -> A breakpoint can be inserted here to understand the structure and modify it accordingly <-

    % info=periodicRepetition(info,1,[]); % interesting for a Lagrangian view with periodic conditions

    ax=MultiPlot(ax,info.grounds,info.opts);

else

    %% #. CUSTOM

    switch info.selection.data.global.rough.cat{1}

        case '[ISAAC - Contact pressure]'

            % #. Pressure
            % #.#. Data
            fnsData=fieldnames(info.data);
            indPres0=contains(fnsData,'pres');
            pres=info.data.(fnsData{indPres0});
            % #.#. Limits
            fnsLimits=fieldnames(info.limits.(fnsData{indPres0}));
            indData1=find(contains(fnsLimits,'pres'));
            limData=[mean(table2array(info.limits.(fnsData{indPres0}).([fnsLimits{indData1(1)}]))) ...
                mean(table2array(info.limits.(fnsData{indPres0}).([fnsLimits{indData1(2)}])))];
            % #. Shear
            indShear0=contains(fnsData,'shear');
            shear=info.data.(fnsData{indShear0});
            % #. X
            % #.#. Data
            x=info.grounds.ground2.X;
            % #.#. Limits
            limX=[min([min(table2array(info.limits.(fnsData{indPres0}).X_MIN)) min(table2array(info.limits.(fnsData{indShear0}).X_MIN))]) ...
                max([max(table2array(info.limits.(fnsData{indPres0}).X_MAX)) max(table2array(info.limits.(fnsData{indShear0}).X_MAX))])];
            % #. Format
            sz=size(pres);
            pres=pres(round(sz(1)/2),:);
            shear=shear(round(sz(1)/2),:);
            pH=max(pres);
            a=1.5;
            pres=pres./pH;
            shear=shear./pH;
            x=x./a;
            % #. Plot
            plot(ax,x,pres,'-b','LineWidth',2,'DisplayName','Pressure');
            hold(ax,'on')
            plot(ax,x,shear,'-r','LineWidth',2,'DisplayName','Shear');
            legend(ax,'HandleVisibility','off');
            xlabel(ax,'$\mathrm{\frac{x}{a}}$','Interpreter','latex');
            ylabel(ax,'$\mathrm{\frac{P}{P_h} / \frac{q}{P_h}}$','Interpreter','latex');
            axis(ax,'padded');
            xlim(ax,limX);
            ylim(ax,limData);
            grid(ax,'on');
            hold(ax,'off')

        case '[MELODY - Velocity profile]'

            % #. Velocity
            % #.#. Data
            fnsData=fieldnames(info.data);
            indVel0=contains(fnsData,'velocity'); % the name contains the step which varies
            v=info.data.(fnsData{indVel0});
            % #.#. Limits
            fnsLimits=fieldnames(info.limits.(fnsData{indVel0}));
            indVel1=find(contains(fnsLimits,'velocity'));
            limVel=[mean(table2array(info.limits.(fnsData{indVel0}).([fnsLimits{indVel1(1)}]))) ...
                mean(table2array(info.limits.(fnsData{indVel0}).([fnsLimits{indVel1(2)}])))];

            % #.#. Y
            % #.#. Data
            y=info.grounds.ground2.Y;
            % #.#. Limits
            limY=[min([min(table2array(info.limits.(fnsData{indVel0}).Y_MIN)) min(table2array(info.limits.(fnsData{indVel0}).Y_MIN))]) ...
                max([max(table2array(info.limits.(fnsData{indVel0}).Y_MAX)) max(table2array(info.limits.(fnsData{indVel0}).Y_MAX))])];
            limDY=(limY(2)-limY(1))*0; % 0.07 margins
            limY=limY+[-limDY limDY];

            % #. Removes null velocity
            % Rigid bodies with zero acceleration give zero velocity,
            % which is inaccurate. To correct this, rigorously zero
            % velocities are excluded from the regression. This is appropriate,
            % as bodies may have a velocity close to 0, but a velocity equal
            % to 0 is unlikely.
            indToRemove=v==0;
            if ~all(indToRemove)
                v(indToRemove)=[];
                y(indToRemove)=[];
            end

            % #. Regression
            Width=(max(y)-min(y))/100;
            yReg=linspace(min(y),max(y),100);
            [vReg,vRegStd]=SmoothSparseData(y,v,yReg,Width);

            % #. Plot
            ax=MultiPlot(ax,...
                'Ground',vReg,yReg,'Color','k','LineWidth',2, ...
                'Ground',vReg+vRegStd,yReg,'LineStyle','--','Color','k','LineWidth',1, ...
                'Ground',vReg-vRegStd,yReg,'LineStyle','--','Color','k','LineWidth',1, ...
                'XLim',limVel,'YLim',limY,...
                'XLabel','V_L~[m.s^{-1}]','YLabel','y~[m]','AxisColor',[0 0 0],'Grid','On');

        case {'[MELODY - Body index and velocity]' '[MELODY - von Mises and velocity]'}

            % #. Velocity
            % #.#. Data
            fnsData=fieldnames(info.data);
            indVel0=contains(fnsData,'velocity'); % the name contains the step which varies
            v=info.data.(fnsData{indVel0});
            % #.#. Limits
            %fnsLimits=fieldnames(info.limits.(fnsData{indVel0}));
            %indVel1=find(contains(fnsLimits,'velocity'));
            %limVel=[mean(table2array(info.limits.(fnsData{indVel0}).([fnsLimits{indVel1(1)}]))) ...
            %    mean(table2array(info.limits.(fnsData{indVel0}).([fnsLimits{indVel1(2)}])))];

            % #. Y
            % #.#. Data
            PB=info.data.periodicboundaries; % periodic boundaries
            connectivity=info.grounds.ground2.CONNECTIVITY;
            x=info.grounds.ground2.X;
            x(x<PB(1))=PB(1);
            x(x>PB(2))=PB(2);
            y=info.grounds.ground2.Y;
            % #.#. Limits
            limY=[min([min(table2array(info.limits.(fnsData{indVel0}).Y_MIN)) min(table2array(info.limits.(fnsData{indVel0}).Y_MIN))]) ...
                max([max(table2array(info.limits.(fnsData{indVel0}).Y_MAX)) max(table2array(info.limits.(fnsData{indVel0}).Y_MAX))])];
            limDY=(limY(2)-limY(1))*0; % 0.07 margins
            limY=limY+[-limDY limDY];

            % #. Removes null velocity
            % Rigid bodies with zero acceleration give zero velocity,
            % which is inaccurate. To correct this, rigorously zero
            % velocities are excluded from the regression. This is appropriate,
            % as bodies may have a velocity close to 0, but a velocity equal
            % to 0 is unlikely.
            indToRemove=v==0;
            vTemp=v;
            yTemp=y;
            if ~all(indToRemove)
                vTemp(indToRemove)=[];
                yTemp(indToRemove)=[];
            end

            % #. Regression
            Width=(max(yTemp)-min(yTemp))/100;
            yReg=linspace(min(yTemp),max(yTemp),100);
            [vReg,vRegStd]=SmoothSparseData(yTemp,vTemp,yReg,Width);
            indToRemove=imag(yReg') | imag(vReg) | imag(vRegStd);
            yReg(indToRemove)=[];
            vReg(indToRemove)=[];
            vRegStd(indToRemove)=[];
            VS=[vReg(1) vReg(end)]; % Can be modified for greater accuracy by indicating actual conditions
            if VS(1)==VS(2)
                VS=[0 1]; % gives poor initialization if zero velocity at the beginning and a delta of velocity between the upper and lower body
            end

            % #. Normalization
            vReg=vReg./diff(VS);
            vRegStd=vRegStd./diff(VS);
            x=(x-PB(1))./diff(PB)+(VS(1)./diff(VS));
            y=y./diff(PB);
            yReg=yReg./diff(PB);
            limY=limY./diff(PB);

            % #. Surface
            % #.#. Options
            switch info.selection.data.global.rough.cat{1}
                case '[MELODY - Body index and velocity]'
                    indData0=contains(fnsData,'body_index');
                    fnsLimits=fieldnames(info.limits.(fnsData{indData0}));
                    indData1=find(contains(fnsLimits,'body_index'));
                    colorbarMode='invisible';
                    colormapMode='abyss';
                    dataName='Body~index~[-]';
                case'[MELODY - von Mises and velocity]'
                    indData0=contains(fnsData,'von_mises_stress');
                    fnsLimits=fieldnames(info.limits.(fnsData{indData0}));
                    indData1=find(contains(fnsLimits,'von_mises_stress'));
                    colorbarMode='southoutside';
                    colormapMode='turbo';
                    dataName='von~Mises~stress~[Pa]';
            end
            % #.#. Data
            data=info.data.(fnsData{indData0});
            % #.#. Limits
            limData=[mean(table2array(info.limits.(fnsData{indData0}).([fnsLimits{indData1(1)}]))) ...
                mean(table2array(info.limits.(fnsData{indData0}).([fnsLimits{indData1(2)}])))];

            % #. Plot
            ax=MultiPlot(ax,...
                'Ground',connectivity,x,y,'Data',data,'ColorbarLocation',colorbarMode,'ColorbarName',dataName,'TicksColor',[0 0 0],'DataLim',limData, ...
                'Ground',vReg,yReg,'Color','w','LineWidth',4, ...
                'Ground',vReg+vRegStd,yReg,'LineStyle','--','Color','w','LineWidth',2, ...
                'Ground',vReg-vRegStd,yReg,'LineStyle','--','Color','w','LineWidth',2, ...
                'XLim',[0 1]+(VS(1)./diff(VS)),'YLim',limY,'Colormap',colormapMode,...
                'XLabel','\frac{V_L}{\Delta V_S}~[-]','AxisColor',[0 0 0]);
            set(ax,'YColor','none');

    end

end

%% #.#. Post-processing
ax.Visible='on';
ax.Tag=tagSave; % Tag is lost when a plot is created

end

function info=periodicRepetition(info,repetition,xPeriodicCondition)
% Abstract: repetition according to x of the surfaces
% repetition = double : number of added repetition on each side (in total the pattern will be displayed 2*repetition+1 times)
% xPeriodicCondition = [xMin xMax] : x coordinates of periodic conditions if applicable
fns=string(fieldnames(info.grounds))';
for name=fns
    % #. Periodic conditions
    % Must be corrected otherwise a gap appears between each repetition
    info.grounds.(name).X(info.grounds.(name).X<xPeriodicCondition(1))=xPeriodicCondition(1);
    info.grounds.(name).X(info.grounds.(name).X>xPeriodicCondition(2))=xPeriodicCondition(2);
    % #. Pre-processing
    nodesNumber=numel(info.grounds.(name).X); elementsNumber=size(info.grounds.(name).CONNECTIVITY,1);
    width=max(info.grounds.(name).X)-min(info.grounds.(name).X);
    % #. Shift computation
    shiftConnectivity=repmat(reshape(repmat(0:nodesNumber:nodesNumber*repetition*2,elementsNumber,1),[],1),1,size(info.grounds.(name).CONNECTIVITY,2));
    shiftCoordinates=[-1*reshape(repmat(0:width:width*repetition,nodesNumber,1),[],1) ; reshape(repmat(width:width:width*repetition,nodesNumber,1),[],1)];
    % #. Repetition
    for field=["CONNECTIVITY" "X" "Y" "Data"]
        info.grounds.(name).(field)=repmat(info.grounds.(name).(field),repetition*2+1,1);
    end
    % #. Shift application
    info.grounds.(name).CONNECTIVITY=info.grounds.(name).CONNECTIVITY+shiftConnectivity;
    info.grounds.(name).X=info.grounds.(name).X+shiftCoordinates;
end
end