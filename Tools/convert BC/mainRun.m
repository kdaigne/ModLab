%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                            BoundariesConverter                        %%
%%                       Last update: January 05, 2022                   %%
%%                               Kévin Daigne                            %%
%%                         kevin.daigne@hotmail.fr                       %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract - 
% GUI for converting velocity to position, position to velocity, etc.
%% -

% #. GUI creation
fig=uifigure('Name','Boundaries conversion tool','Units','Normalized','Position',[0.15 0.2 0.7 0.6],'Color',[.98 .98 .98]);

% #. Dimensions
% #.#. GUI
set(fig,'Units','Pixel');
pos=fig.Position;
L=pos(3); % Figure width
H=pos(4); % Figure height
h=20; % Height of small components and gaps
lSpace=h; % Gap width between components
lComp=(L-4*lSpace)/3; % Column width
% #.#. Time/position section
hComp1=(H-11*h)/2; % Height of scatter texts and graphics for the time/position section
% #.#. Velocity section
hComp2=4*h+hComp1; % Text height
hComp3=2*h+hComp1; % Height of graph

% #. Input 1 (Time or Position)
uilabel(fig,'Position',[lSpace H-2*h lComp h],'Text',' #. Time','fontweight','bold','fontsize',16,'Tag','input1Label');
% #.#. Scatter
uilabel(fig,'Position',[lSpace H-3*h lComp h],'Text',' #.#. Scatter (reads 1st column):','fontweight','bold','fontsize',12);
uitextarea(fig,'Position',[lSpace H-3*h-hComp1 lComp hComp1],'Tag','input1Scatter');
% #.#. Evaluation
uilabel(fig,'Position',[lSpace H-4*h-hComp1 lComp h],'Text',' #.#. Evaluation (Min Max N):','fontweight','bold','fontsize',12);
uieditfield(fig,'Position',[lSpace H-5*h-hComp1 (lComp-2*lSpace)/3 h],'Tag','input1EvalMin');
uieditfield(fig,'Position',[2*lSpace+(lComp-2*lSpace)/3 H-5*h-hComp1 (lComp-2*lSpace)/3 h],'Tag','input1EvalMax');
uieditfield(fig,'Position',[3*lSpace+2*(lComp-2*lSpace)/3 H-5*h-hComp1 (lComp-2*lSpace)/3 h],'Tag','input1EvalN');

% #. Input 2 (Position or Velocity)
uilabel(fig,'Position',[lComp+2*lSpace H-2*h lComp h],'Text',' #. Position','fontweight','bold','fontsize',16,'Tag','input2Label');
% #.#. Scatter
uilabel(fig,'Position',[lComp+2*lSpace H-3*h lComp h],'Text',' #.#. Scatter (reads last column):','fontweight','bold','fontsize',12);
uitextarea(fig,'Position',[lComp+2*lSpace H-3*h-hComp1 lComp hComp1],'Tag','input2Scatter');
% #.#. Evaluation
uilabel(fig,'Position',[lComp+2*lSpace H-4*h-hComp1 lComp h],'Text',' #.#. Evaluation (use "t" as variable):','fontweight','bold','fontsize',12,'Tag','input2EvalLabel');
uieditfield(fig,'Position',[lComp+2*lSpace H-5*h-hComp1 lComp h],'Tag','input2Eval');

% #. Input plot (Position or Velocity)
btnInput=uibutton(fig,'push','Text', 'PLOT','fontweight','bold','Position',[lSpace H-7*h-hComp1 2*lComp+lSpace h],'ButtonPushedFcn', @(btnInput,event) converterInput(btnInput,fig));
inputAxes=uiaxes(fig,'Position',[lSpace H-8*h-2*hComp1 2*lComp+lSpace hComp1],'Tag','inputAxes');
xlabel(inputAxes,'Time');
ylabel(inputAxes,'Position');
grid(inputAxes,'On');

% #. Computation
uilabel(fig,'Position',[lSpace 2*h lComp h],'Text','Enter the initial velocity (not mandatory) :','fontweight','bold','fontsize',12,'Tag','initialLabel');
uieditfield(fig,'Position',[lSpace h lComp h],'Tag','initialValue');
btnOuput=uibutton(fig,'push','Text','COMPUTE','fontweight','bold','Position',[lComp+2*lSpace 1*h lComp h],'ButtonPushedFcn', @(btnOuput,event) converterOutput(btnOuput,btnInput,fig));
uilabel(fig,'Position',[lSpace 0 lComp*2+lSpace h],'Text','','fontangle','italic','fontsize',12,'Tag','initialLabelWarning');

% #. Output (Velocity or Position)
uilabel(fig,'Position',[2*lComp+lSpace*3 H-2*h lComp h],'Text',' #.','fontweight','bold','fontsize',16);
bg=uibuttongroup(fig,'Position',[2*lComp+lSpace*4.2 H-2*h lComp-lSpace*1.2 h],'BorderType','none','SelectionChangedFcn',@(bg,event) converterSwitch(bg,fig),'Tag','outputRadio','BackgroundColor',[.98 .98 .98]);
uiradiobutton(bg,'Position',[0 0 (lComp-lSpace*1.2)/3 h],'Text','Velocity','fontweight','bold','fontsize',16);
uiradiobutton(bg,'Position',[(lComp-lSpace*1.2)/3 0 (lComp-lSpace*1.2)/3 h],'Text','Position','fontweight','bold','fontsize',16);
uiradiobutton(bg,'Position',[(lComp-lSpace*1.2)/3*2 0 (lComp-lSpace*1.2)/3 h],'Text','Time','fontweight','bold','fontsize',16);
uilabel(fig,'Position',[2*lComp+lSpace*3 H-3*h lComp/2-lSpace/3 h],'Text',' #.#. Velocity only','fontweight','bold','fontsize',12,'Tag','outputLabelOnly');
uilabel(fig,'Position',[2*lComp+lSpace*3+lComp/2-lSpace/3+2*lSpace/3 H-3*h lComp/2-lSpace/3 h],'Text',' #.#. [Num Time Velocity]','fontweight','bold','fontsize',12);
uitextarea(fig,'Position',[2*lComp+lSpace*3 H-3*h-hComp2 lComp/2-lSpace/3 hComp2],'Tag','outputOnly');
uitextarea(fig,'Position',[2*lComp+lSpace*3+lComp/2-lSpace/3+2*lSpace/3 H-3*h-hComp2 lComp/2-lSpace/3 hComp2],'Tag','outputWithFormat');
outputAxes=uiaxes(fig,'Position',[2*lComp+lSpace*3 h lComp hComp3],'Tag','outputAxes');
xlabel(outputAxes,'Time');
ylabel(outputAxes,'Velocity');
grid(outputAxes,'On');

function converterSwitch(~,fig)
% Abstract: defines whether it is a change from velocity to position,
% position to velocity, etc.

% #. Indices
for ind=1:numel(fig.Children)
    if strcmp(fig.Children(ind).Tag,'inputAxes')
        indinputAxes=ind;
    elseif strcmp(fig.Children(ind).Tag,'outputRadio')
        indoutputRadio=ind;
    elseif strcmp(fig.Children(ind).Tag,'input1Label')
        indinput1Label=ind;
    elseif strcmp(fig.Children(ind).Tag,'input2Label')
        indinput2Label=ind;
    elseif strcmp(fig.Children(ind).Tag,'input2EvalLabel')
        indinput2EvalLabel=ind;
    elseif strcmp(fig.Children(ind).Tag,'outputAxes')
        indoutputAxes=ind;
    elseif strcmp(fig.Children(ind).Tag,'initialLabel')
        indinitialLabel=ind;
    elseif strcmp(fig.Children(ind).Tag,'outputLabelOnly')
        outputLabelOnlyLabel=ind;
    elseif strcmp(fig.Children(ind).Tag,'initialLabelWarning')
        indinitialLabelWarning=ind;
    end
end

% #. Reset interface
fig.Children(indinitialLabelWarning).Text='';
cla(fig.Children(indinputAxes),'reset');
set(fig.Children(indinputAxes),'Tag','inputAxes');
grid(fig.Children(indinputAxes),'On');
cla(fig.Children(indoutputAxes),'reset');
set(fig.Children(indoutputAxes),'Tag','outputAxes');
grid(fig.Children(indoutputAxes),'On');

% #. Modification of some components
if fig.Children(indoutputRadio).Children(3).Value==1
    % #. Type time + position -> Velocity
    
    % #.#. Input
    % #.#.#. Label
    fig.Children(indinput1Label).Text=' #. Time';
    fig.Children(indinput2Label).Text=' #. Position';
    % #.#.#. Evaluation
    fig.Children(indinput2EvalLabel).Text=' #.#. Evaluation (use "t" as variable):';
    % #.#.#. Plot
    xlabel(fig.Children(indinputAxes),'Time');
    ylabel(fig.Children(indinputAxes),'Position');
    % #.#.#. Initial condition
    fig.Children(indinitialLabel).Text='Enter the initial velocity (not mandatory):';
    
    % #.#. Output
    % #.#.#. Plot
    xlabel(fig.Children(indoutputAxes),'Time');
    ylabel(fig.Children(indoutputAxes),'Velocity');
    % #.#.#. Label
    fig.Children(outputLabelOnlyLabel).Text='#.#. Velocity only';
    
elseif fig.Children(indoutputRadio).Children(2).Value==1
    % #. Type time + velocity -> Position
    
    % #.#. Input
    % #.#.#. Label
    fig.Children(indinput1Label).Text=' #. Time';
    fig.Children(indinput2Label).Text=' #. Velocity';
    % #.#.#. Evaluation
    fig.Children(indinput2EvalLabel).Text=' #.#. Evaluation (use "t" as variable):';
    % #.#.#. Plot
    xlabel(fig.Children(indinputAxes),'Time');
    ylabel(fig.Children(indinputAxes),'Velocity');
    % #.#.#. Initial condition
    fig.Children(indinitialLabel).Text='Enter the initial position (not mandatory):';
    
    % #.#. Output
    % #.#.#. Plot
    xlabel(fig.Children(indoutputAxes),'Time');
    ylabel(fig.Children(indoutputAxes),'Position');
    % #.#.#. Label
    fig.Children(outputLabelOnlyLabel).Text='#.#. Position only';
    
elseif fig.Children(indoutputRadio).Children(1).Value==1
    % #. Type time + velocity -> Position
    
    % #.#. Input
    % #.#.#. Label
    fig.Children(indinput1Label).Text=' #. Position';
    fig.Children(indinput2Label).Text=' #. Velocity';
    % #.#.#. Evaluation
    fig.Children(indinput2EvalLabel).Text=' #.#. Evaluation (use "p" as variable):';
    % #.#.#. Plot
    xlabel(fig.Children(indinputAxes),'Position');
    ylabel(fig.Children(indinputAxes),'Velocity');
    % #.#.#. Initial condition
    fig.Children(indinitialLabel).Text='Enter the initial time (not mandatory):';
    
    % #.#. Output
    % #.#.#. Plot
    xlabel(fig.Children(indoutputAxes),'Time');
    yyaxis(fig.Children(indoutputAxes),'left');
    ylabel(fig.Children(indoutputAxes),'Position');
    yyaxis(fig.Children(indoutputAxes),'right');
    ylabel(fig.Children(indoutputAxes),'Velocity');
    % #.#.#. Label
    fig.Children(outputLabelOnlyLabel).Text='#.#. Time only';
end
end

function [input1Vect,input2Vect]=converterInput(~,fig)
% Abstract: reads and plots input conditions

% #. Indices
for ind=1:numel(fig.Children)
    if strcmp(fig.Children(ind).Tag,'input1Scatter')
        indinput1Scatter=ind;
    elseif strcmp(fig.Children(ind).Tag,'input1EvalMin')
        indinput1EvalMin=ind;
    elseif strcmp(fig.Children(ind).Tag,'input1EvalMax')
        indinput1EvalMax=ind;
    elseif strcmp(fig.Children(ind).Tag,'input1EvalN')
        indinput1EvalN=ind;
    elseif strcmp(fig.Children(ind).Tag,'input2Scatter')
        indinput2Scatter=ind;
    elseif strcmp(fig.Children(ind).Tag,'input2Eval')
        indinput2Eval=ind;
    elseif strcmp(fig.Children(ind).Tag,'inputAxes')
        indinputAxes=ind;
    elseif strcmp(fig.Children(ind).Tag,'outputAxes')
        indoutputAxes=ind;
    elseif strcmp(fig.Children(ind).Tag,'outputRadio')
        indoutputRadio=ind;
    elseif strcmp(fig.Children(ind).Tag,'initialLabelWarning')
        indinitialLabelWarning=ind;
    end
end

% #. Initialization
input1Vect=[]; input2Vect=[];

% #. Input 1 (Time or Position)
if ~isempty(fig.Children(indinput1Scatter).Value{1})
    % #.#. Scatter
    input1Vect=cellfun(@(x) strsplit(x, ' '),fig.Children(indinput1Scatter).Value, 'UniformOutput', false);
    input1Vect=horzcat(input1Vect{:});
    % Reading the 1st column
    columnsNumber=size(input1Vect,2)/size(fig.Children(indinput1Scatter).Value,1); % Number of columns
    input1Vect=cellfun(@eval,input1Vect(1:columnsNumber:end-columnsNumber+1));
elseif ~isempty(fig.Children(indinput1EvalMin).Value) && ~isempty(fig.Children(indinput1EvalMax).Value) && ~isempty(fig.Children(indinput1EvalN).Value)
    % #.#. Evaluation
    input1Min=eval(fig.Children(indinput1EvalMin).Value);
    input1Max=eval(fig.Children(indinput1EvalMax).Value);
    input1N=eval(fig.Children(indinput1EvalN).Value);
    input1Vect=input1Min:(input1Max-input1Min)/(input1N-1):input1Max;
else
    % #.#. No input
    if fig.Children(indoutputRadio).Children(3).Value==1 || fig.Children(indoutputRadio).Children(2).Value==1
        msgbox('Time vector cannot be found.','Information','help');
    elseif fig.Children(indoutputRadio).Children(1).Value==1
        msgbox('Position vector cannot be found.','Information','help');
    end
    return;
end

% #. Input 2 (Position or Velocity)
if ~isempty(fig.Children(indinput2Scatter).Value{1})
    % #.#. Scatter
    input2Vect=cellfun(@(x) strsplit(x, ' '),fig.Children(indinput2Scatter).Value, 'UniformOutput', false);
    input2Vect=horzcat(input2Vect{:});
    % Reading the last column
    columnsNumber=size(input2Vect,2)/size(fig.Children(indinput2Scatter).Value,1); % Number of columns
    input2Vect=cellfun(@eval,input2Vect(columnsNumber:columnsNumber:end));
elseif ~isempty(fig.Children(indinput2Eval).Value)
    % #.#. Evaluation
    if fig.Children(indoutputRadio).Children(1).Value==0
        inputFunc=str2func(['@(t)',fig.Children(indinput2Eval).Value]);
    else
        inputFunc=str2func(['@(p)',fig.Children(indinput2Eval).Value]);
    end
    input2Vect=inputFunc(input1Vect);
else
    % #.#. No input
    if fig.Children(indoutputRadio).Children(1).Value==1 || fig.Children(indoutputRadio).Children(2).Value==1
        msgbox('Velocity vector cannot be found.','Information','help');
    elseif fig.Children(indoutputRadio).Children(3).Value==1
        msgbox('Position vector cannot be found.','Information','help');
    end
    return;
end

% #. If different sizes
if size(input1Vect,2)~=size(input2Vect,2)
    if fig.Children(indoutputRadio).Children(3).Value==1
        msgbox('Position and velocity vectors have not the same length.','Information','help');
    elseif fig.Children(indoutputRadio).Children(2).Value==1
        msgbox('Position and time vectors have not the same length.','Information','help');
    elseif fig.Children(indoutputRadio).Children(1).Value==1
        msgbox('Velocity and time vectors have not the same length.','Information','help');
    end
    return;
end

% #. Processing to avoid duplication of time values
if fig.Children(indoutputRadio).Children(1).Value==0
    [~,ia,~] = unique(arrayfun(@(x) num2str(x,15), input1Vect, 'UniformOutput', 0),'stable'); % Accuracy to be used for subsequent calculations
    if size(ia,1)~=size(input1Vect,2)
        if size(input1Vect,2)-size(ia,1)==1
            msgbox([num2str(size(input1Vect,2)-size(ia,1)) ' time step has been deleted because it was too close from others.'],'Information','help');
        else
            msgbox([num2str(size(input1Vect,2)-size(ia,1)) ' time steps have been deleted because they were too close from others.'],'Information','help');
        end
        input1Vect=input1Vect(ia);
        input2Vect=input2Vect(ia);
    end
end

% #. Plot
cla(fig.Children(indinputAxes),'reset');
set(fig.Children(indinputAxes),'Tag','inputAxes');
grid(fig.Children(indinputAxes),'On');
cla(fig.Children(indoutputAxes),'reset');
set(fig.Children(indoutputAxes),'Tag','outputAxes');
grid(fig.Children(indoutputAxes),'On');
fig.Children(indinitialLabelWarning).Text='';
plot(fig.Children(indinputAxes),input1Vect,input2Vect,'bx')
set(fig.Children(indinputAxes),'Tag','inputAxes');
grid(fig.Children(indinputAxes),'On');
if fig.Children(indoutputRadio).Children(3).Value==1
    % #. Type time + position -> Velocity
    xlabel(fig.Children(indinputAxes),'Time');
    ylabel(fig.Children(indinputAxes),'Position');
    xlabel(fig.Children(indoutputAxes),'Time');
    ylabel(fig.Children(indoutputAxes),'Velocity');
elseif fig.Children(indoutputRadio).Children(2).Value==1
    % #. Type time + position -> Velocity
    xlabel(fig.Children(indinputAxes),'Time');
    ylabel(fig.Children(indinputAxes),'Velocity');
    xlabel(fig.Children(indoutputAxes),'Time');
    ylabel(fig.Children(indoutputAxes),'Velocity');
elseif fig.Children(indoutputRadio).Children(1).Value==1
    % #. Type position + velocity -> Time
    xlabel(fig.Children(indinputAxes),'Position');
    ylabel(fig.Children(indinputAxes),'Velocity');
    xlabel(fig.Children(indoutputAxes),'Time');
    yyaxis(fig.Children(indoutputAxes),'left');
    ylabel(fig.Children(indoutputAxes),'Position');
    yyaxis(fig.Children(indoutputAxes),'right');
    ylabel(fig.Children(indoutputAxes),'Velocity');
end
end

function converterOutput(~,btnInput,fig)
% Abstract: output calculation
% Note: the custom function can be replaced by matlab's built-in spline function

% #. Input
[input1Vect,input2Vect]=converterInput(btnInput,fig);
if isempty(input1Vect) || isempty(input2Vect)
    return;
end
if size(input1Vect,2)<2
    msgbox('It is necessary at least 2 data points to compute.','Information','help');
    return;
end

% #. Indices
for ind=1:numel(fig.Children)
    if strcmp(fig.Children(ind).Tag,'inputAxes')
        indinputAxes=ind;
    elseif strcmp(fig.Children(ind).Tag,'initialValue')
        indinitialValue=ind;
    elseif strcmp(fig.Children(ind).Tag,'outputAxes')
        indoutputAxes=ind;
    elseif strcmp(fig.Children(ind).Tag,'outputWithFormat')
        indoutputWithFormat=ind;
    elseif strcmp(fig.Children(ind).Tag,'outputOnly')
        indoutputOnly=ind;
    elseif strcmp(fig.Children(ind).Tag,'outputRadio')
        indoutputRadio=ind;
    elseif strcmp(fig.Children(ind).Tag,'initialLabelWarning')
        indinitialLabelWarning=ind;
    end
end

% #. Initial condition
if isempty(fig.Children(indinitialValue).Value)==1
    % #.#. If empty
    if fig.Children(indoutputRadio).Children(3).Value==1
        % #.#.#. Type Time + Position -> Velocity = the tangent is taken on the following segment
        t0=input1Vect(1,1); t1=input1Vect(1,2);
        p0=input2Vect(1,1); p1=input2Vect(1,2);
        V0=(p1-p0)/(t1-t0);
        fig.Children(indinitialLabelWarning).Text=['Warning: Initial velocity has been taken as ' num2str(V0,'%e')];
    elseif fig.Children(indoutputRadio).Children(2).Value==1
        % #.#.#. Type Time + Velocity -> Position = take 0 as the starting position
        P0=0;
        fig.Children(indinitialLabelWarning).Text=['Warning: Initial position has been taken as ' num2str(P0,'%e')];
    elseif fig.Children(indoutputRadio).Children(1).Value==1
        % #.#.#. Type Position + Velocity -> Time = take 0 as the starting time
        T0=0;
        fig.Children(indinitialLabelWarning).Text=['Warning: Initial time has been taken as ' num2str(T0,'%e')];
    end
else
    % #.#. Otherwise, the value is retrieve
    fig.Children(indinitialLabelWarning).Text='';
    if fig.Children(indoutputRadio).Children(3).Value==1
        % #.#.#. Type Time + Position -> Velocity
        V0=eval(fig.Children(indinitialValue).Value);
    elseif fig.Children(indoutputRadio).Children(2).Value==1
        % #.#.#. Type Time + Velocity -> Position
        P0=eval(fig.Children(indinitialValue).Value);
    elseif fig.Children(indoutputRadio).Children(1).Value==1
        % #.#.#. Type Position + Velocity -> Time
        T0=eval(fig.Children(indinitialValue).Value);
    end
end

% #. Plot
if fig.Children(indoutputRadio).Children(3).Value==1
    % #. Time + Position -> Velocity
    % #.#. Integration
    [tPlot,pPlot,vPlot,v0Plot]=PositionDerivation(input1Vect,input2Vect,V0,100);
    % #.#. Plot
    hold(fig.Children(indinputAxes),'on');
    hold(fig.Children(indoutputAxes),'on');
    plot(fig.Children(indoutputAxes),input1Vect,v0Plot,'bx');
    plot(fig.Children(indinputAxes),tPlot,pPlot,'-r');
    plot(fig.Children(indoutputAxes),tPlot,vPlot,'-r');
    xlabel(fig.Children(indoutputAxes),'Time');
    ylabel(fig.Children(indoutputAxes),'Velocity');
    hold(fig.Children(indinputAxes),'off');
    hold(fig.Children(indoutputAxes),'off');
    % #.#. Output
    % #.#.#. Output only
    fig.Children(indoutputOnly).Value=...
        arrayfun(@(x) num2str(x,15),v0Plot, 'UniformOutput', 0);
    % #.#.#. Output with format
    fig.Children(indoutputWithFormat).Value=...
        [num2str(size(input1Vect,2))...
        strcat(arrayfun(@(x) num2str(x,15), input1Vect, 'UniformOutput', 0)...
        ,{' '},...
        arrayfun(@(x) num2str(x,15),v0Plot, 'UniformOutput', 0))];
elseif fig.Children(indoutputRadio).Children(2).Value==1
    % #. Type Time + Velocity -> Position
    % #.#. Derivative
    [tPlot,vPlot,pPlot,p0Plot]=VelocityIntegration(input1Vect,input2Vect,P0,100);
    % #.#. Plot
    hold(fig.Children(indinputAxes),'on');
    hold(fig.Children(indoutputAxes),'on');
    plot(fig.Children(indoutputAxes),input1Vect,p0Plot,'bx');
    plot(fig.Children(indinputAxes),tPlot,vPlot,'-r');
    plot(fig.Children(indoutputAxes),tPlot,pPlot,'-r');
    xlabel(fig.Children(indoutputAxes),'Time');
    ylabel(fig.Children(indoutputAxes),'Position');
    hold(fig.Children(indinputAxes),'off');
    hold(fig.Children(indoutputAxes),'off');
    % #.#. Output
    % #.#.#. Output only
    fig.Children(indoutputOnly).Value=...
        arrayfun(@(x) num2str(x,15),p0Plot, 'UniformOutput', 0);
    % #.#.#. Output with format
    fig.Children(indoutputWithFormat).Value=...
        [num2str(size(input1Vect,2))...
        strcat(arrayfun(@(x) num2str(x,15), input1Vect, 'UniformOutput', 0)...
        ,{' '},...
        arrayfun(@(x) num2str(x,15),input2Vect, 'UniformOutput', 0))];
elseif fig.Children(indoutputRadio).Children(1).Value==1
    % #. Type Position + Velocity -> Time
    % #.#. Time calculation
    dtVect=(input1Vect(1,2:end)-input1Vect(1,1:end-1))./((input2Vect(1,2:end)+input2Vect(1,1:end-1))/2);
    if any(dtVect<0) || any(dtVect==Inf)
        % If the sign of the displacement does not correspond to the sign
        % of the velocity (e.g. an increase in position is requested
        % with a negative velocity)
        msgbox('Displacement cannot be reach with the indicated velocity (e.g. positive displacement with negative velocity).','Information','help');
    end
    tVect=[T0 cumsum(dtVect)+T0];
    % #.#. Continuous position calculation
    [tPlot,vPlot,pPlot,~]=VelocityIntegration(tVect,input2Vect,input1Vect(1,1),100);
    % #.#. Plot
    % #.#.#. Velocity(Position)
    hold(fig.Children(indinputAxes),'on');
    plot(fig.Children(indinputAxes),input1Vect,input2Vect,'--r');
    hold(fig.Children(indinputAxes),'off');
    % #.#.#. Position(time)
    yyaxis(fig.Children(indoutputAxes),'left')
    hold(fig.Children(indoutputAxes),'on');
    plot(fig.Children(indoutputAxes),tVect,input1Vect,'x');
    plot(fig.Children(indoutputAxes),tPlot,pPlot,'-');
    hold(fig.Children(indoutputAxes),'off');
    xlabel(fig.Children(indoutputAxes),'Time');
    ylabel(fig.Children(indoutputAxes),'Position');
    % #.#.#. Velocity(time)
    yyaxis(fig.Children(indoutputAxes),'right')
    hold(fig.Children(indoutputAxes),'on');
    plot(fig.Children(indoutputAxes),tVect,input2Vect,'x');
    plot(fig.Children(indoutputAxes),tPlot,vPlot,'-');
    hold(fig.Children(indoutputAxes),'off');
    ylabel(fig.Children(indoutputAxes),'Velocity');
    % #.#. Output
    % #.#.#. Output only
    fig.Children(indoutputOnly).Value=...
        arrayfun(@(x) num2str(x,15),tVect, 'UniformOutput', 0);
    % #.#.#. Output with format
    fig.Children(indoutputWithFormat).Value=...
        [num2str(size(input1Vect,2))...
        strcat(arrayfun(@(x) num2str(x,15), tVect, 'UniformOutput', 0)...
        ,{' '},...
        arrayfun(@(x) num2str(x,15),input2Vect, 'UniformOutput', 0))];
end
end