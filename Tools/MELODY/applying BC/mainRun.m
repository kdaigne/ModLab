%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                                Applying BC                            %%
%%                         Last update: July 29, 2024                    %%
%%                               Kévin Daigne                            %%
%%                         kevin.daigne@hotmail.fr                       %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Creates a GUI to apply conditions on several bodies
%% - Examples -
% The format is as follows:
% SECTION NAME (the new one if boundary conditions)
% New content
%
% To keep a part of the old content, you can use the '~'
% character, placing it after the name of the section or at
% the very end.
%
% The number of boundary conditions is calculated automatically
%
% #. e.g.
% Before:
% Y Dirichlet Driven
% 2
% 0 0
% 1000000 0
% Changes:
% Y Neumann Following
% 2
% 0 0
% 1000000 0
% After:
% Y Neumann Following
% 2
% 0 0
% 1000000 0
%
% #. e.g.
% Before
% Y Dirichlet Driven
% 2
% 0 0
% 10 0
% Changes:
% Y Neumann Following
% ~
% 1000000 0
% After:
% Y Neumann Following
% 3
% 0 0
% 10 0
% 1000000 0
%
% #. e.g.
% Before
% Y Dirichlet Driven
% 2
% 10 0
% 1000000 0
% Changes:
% Y Neumann Following
% 0 0
% ~
% After:
% Y Neumann Following
% 3
% 0 0
% 10 0
% 10000000 0
%
%% -

% #. tabNumber
tabNumber=findTab(app);

% #. Figure
fig=uifigure('Name','Bodies changes','Units','Normalized','Position',[0.2 0.2 0.6 0.6],'Color',[.98 .98 .98]);
set(fig,'Units','Pixels');
pos=get(fig,'Position');

% #. Bodies
pathSimu=app.TabGroup.Children(tabNumber).Children(app.id.gridTabNumber).Children(app.id.gridProcessingNumber).Children(app.id.SAVEPanelNumber).Children(app.id.gridSaveNumber).Children(app.id.displayPathNumber).Value;
[materialsList,bodiesNumber]=MelodyMaterialPerBody(pathSimu);
bodiesList=strcat('Body',{' '},cellfun(@num2str,num2cell(0:bodiesNumber-1),'UniformOutput',false),{' '},'-',{' '},materialsList);
uilabel(fig,'Position',[0 0.95*pos(4) 0.2*pos(3) 0.05*pos(4)],'Text','Bodies:','HorizontalAlignment','center','fontweight','bold','fontsize',16);
uilistbox(fig,'Position',[0 0.1*pos(4) 0.2*pos(3) 0.85*pos(4)],'Items',bodiesList,'Multiselect','on','Value',{},'Tag','bodiesList');
uieditfield(fig,'Position',[0 0.05*pos(4) 0.2*pos(3) 0.05*pos(4)],'Tag','bodiesValue','ToolTip','Bodies can be entered in matrix form (e.g. [0:2:10 20])');

% #. Changes
uilabel(fig,'Position',[0.2*pos(3) 0.95*pos(4) 0.8/3*pos(3) 0.05*pos(4)],'Text','Changes:','HorizontalAlignment','center','fontweight','bold','fontsize',16);
uitextarea(fig,'Position',[0.2*pos(3) 0.05*pos(4) 0.8/3*pos(3) 0.9*pos(4)],'Tag','bodiesModif');

% #. Old
uilabel(fig,'Position',[(0.20+0.8/3)*pos(3) 0.95*pos(4) 0.8/3*pos(3) 0.05*pos(4)],'Text','Before save:','HorizontalAlignment','center','fontweight','bold','fontsize',16);
uitextarea(fig,'Position',[(0.20+0.8/3)*pos(3) 0.05*pos(4) 0.8/3*pos(3) 0.9*pos(4)],'Editable','off','Tag','oldStatic');

% #. New
uilabel(fig,'Position',[(0.20+2*0.8/3)*pos(3) 0.95*pos(4) 0.8/3*pos(3) 0.05*pos(4)],'Text','After save:','HorizontalAlignment','center','fontweight','bold','fontsize',16);
uitextarea(fig,'Position',[(0.20+2*0.8/3)*pos(3) 0.05*pos(4) 0.8/3*pos(3) 0.9*pos(4)],'Editable','off','Tag','newStatic');

% #. Preview
uibutton(fig,'Position',[0 0 (0.20+0.8/3)*pos(3) 0.05*pos(4)],'Text','Preview','fontweight','bold','fontsize',12,'ButtonPushedFcn',@(bShow,event) bodiesBoundariesMainFunction(app,tabNumber,fig,'display'));

% #. Save
uibutton(fig,'Position',[(0.20+0.8/3)*pos(3) 0 0.8/3*2*pos(3) 0.05*pos(4)],'Text','Save','fontweight','bold','fontsize',12,'ButtonPushedFcn',@(bSave,event) bodiesBoundariesMainFunction(app,tabNumber,fig,'save'));

function bodiesBoundariesMainFunction(app,tabNumber,figBoundaries,mode)
% Abstract: saves changes made to a body in the CONTROL file
% Mode:
% 'save': saves changes
% 'display': displays changes without saving

% #. Paths
pathSimu=app.TabGroup.Children(tabNumber).Children(app.id.gridTabNumber).Children(app.id.gridProcessingNumber).Children(app.id.SAVEPanelNumber).Children(app.id.gridSaveNumber).Children(app.id.displayPathNumber).Value;
pathControl=[pathSimu filesep 'CODE' filesep 'STATIC_CONTROL.asc'];

% #. Changes
[controlNew,controlOld,lineSave]=bodiesBoundariesGUIUpdate(figBoundaries,pathSimu);
if ~strcmpi(mode,'save'); return; end

% #. Writing
fileID=fopen(pathControl,'w');
for lineNum=1:size(lineSave,2)
    fwrite(fileID,lineSave{lineNum});
    fwrite(fileID,newline);
end
fclose(fileID);

% #. Log
logMsg=[controlNew {'#. Old entry:'} controlOld];
logMsg(strcmp(logMsg,''))=[]; % Remove empty lines
if exist([pathSimu filesep 'SAVE'],'dir')==0
    mkdir([pathSimu filesep 'SAVE']);
end
[~,~]=LogSave(logMsg,{''},'CONTROL - BODIES CHANGES',[pathSimu filesep 'SAVE' filesep 'LOG_save.log']);

% #. Update GUI
processingEditedText(app,tabNumber,0);

end

function [controlNew,controlOld,lineSave]=bodiesBoundariesGUIUpdate(fig,pathSimu)

% #. Initialization
controlOld={}; controlNew={}; lineSave={};

% #. Indices
for ind=1:numel(fig.Children)
    if strcmp(fig.Children(ind).Tag,'bodiesList')
        indBodiesList=ind;
    elseif strcmp(fig.Children(ind).Tag,'bodiesValue')
        indBodiesValue=ind;
    elseif strcmp(fig.Children(ind).Tag,'bodiesModif')
        indBodiesModif=ind;
    elseif strcmp(fig.Children(ind).Tag,'oldStatic')
        indOldStatic=ind;
    elseif strcmp(fig.Children(ind).Tag,'newStatic')
        indNewStatic=ind;
    end
end

% #. Path
pathControl=[pathSimu filesep 'CODE' filesep 'STATIC_CONTROL.asc'];

% #. Processing bodies to be modified
if ~isempty(fig.Children(indBodiesList).Value)
    bodiesSplit=cellfun(@(x)strsplit(x,' '),fig.Children(indBodiesList).Value,'UniformOutput',false);
    bodiesVectList=zeros(1,size(bodiesSplit,2));
    for bodiesNum=1:size(bodiesSplit,2)
        bodiesVectList(bodiesNum)=str2double(bodiesSplit{bodiesNum}{2});
    end
else
    bodiesVectList=[];
end
if ~isempty(fig.Children(indBodiesValue).Value)
    bodiesVectEval=str2double(fig.Children(indBodiesValue).Value);
    if isnan(bodiesVectEval)
        bodiesVectEval=eval(fig.Children(indBodiesValue).Value);
    end
else
    bodiesVectEval=[];
end
bodiesVect=sort(unique([bodiesVectList bodiesVectEval]));
if isempty(bodiesVect)
    return;
end

% #. Processing the change to be made
newContent=fig.Children(indBodiesModif).Value;
newContentLineNumber=numel(newContent);
if isscalar(newContent) && strcmp(newContent{1},'')
    newContent=repmat([{'X None'};{'Y None'};{''}],10000,1); % More than 10000 borders seems unlikely
    newContentLineNumber=numel(newContent);
    previewMode=true; % User can display current conditions even without modification
else
    previewMode=false;
    indToSupr=false(1,newContentLineNumber); lineNum=0;

    while 1

        % #.#. Iteration
        lineNum=lineNum+1;
        if lineNum>size(newContent,1)
            break;
        end

        % #.#. Add number of conditions if missing
        % Value not important as it will be reprocessed later
        if (contains(newContent{lineNum},'X ') || contains(newContent{lineNum},'Y ')) && ~contains(newContent{lineNum},'None')
            if lineNum<size(newContent,1)
                if ~strcmp(newContent{lineNum+1},'~') && ~strcmp(newContent{lineNum+1},'')
                    lineSplit=strsplit(newContent{lineNum+1},' ');
                    if size(lineSplit,2)~=1
                        newContent=[newContent(1:lineNum);{'0'};newContent(lineNum+1:end)];
                    end
                end
            end
        end

        % #.#. Add a line break between X and Y
        if (contains(newContent{lineNum},'X ') || contains(newContent{lineNum},'Y ')) ...
                && lineNum~=1
            if ~strcmp(newContent{lineNum-1},'')
                newContent=[newContent(1:lineNum-1) ; {''} ; newContent(lineNum:end)];
                lineNum=lineNum+1;
            end
        end

        % #.#. Cannot have 2 line breaks or ~ in a row
        if lineNum~=1 && lineNum<=size(newContent,1)
            if strcmp(newContent{lineNum-1},'') && strcmp(newContent{lineNum},'')
                indToSupr(lineNum)=1;
            end
            if strcmp(newContent{lineNum-1},'~') && strcmp(newContent{lineNum},'~')
                indToSupr(lineNum)=1;
            end
        end

    end

    newContent(indToSupr)=[];

end

% #.#. Cannot have an empty 1st or last line
if strcmp(newContent{1},'') || strcmp(newContent{1},'~')
    newContent(1)=[];
end
if strcmp(newContent{end},'')
    newContent(end)=[];
end

% #.#. Separation of sections
partNum=1; lineNum=0; bodiesModifCell=cell(1,newContentLineNumber);
while lineNum<size(newContent,1)
    lineNum=lineNum+1;
    if strcmp(newContent{lineNum},'')
        partNum=partNum+1;
        lineNum=lineNum+1;
        bodiesModifCell{partNum}=[];
    end
    bodiesModifCell{partNum}{end+1}=newContent{lineNum};
end
bodiesModifCell(partNum+1:end)=[];

% #. Reading
msg=[];
fileID=fopen(pathControl);
bodyNum=1; % Body index in bodiesVect

while 1

    lineSave{end+1}=fgetl(fileID);

    % #.#. Find the body
    if bodyNum<=size(bodiesVect,2)
        if contains(lineSave{end},['BODY ' num2str(bodiesVect(bodyNum))]) && contains(lineSave{end},'%%%%')

            partNum=1; % Section number to be modified
            contoursNumber=0; % Number of contours for a body
            lineTemp={''}; % Cell containing the CONTROL part to be processed
            lineSave{end+1}=fgetl(fileID); % Line %%%%
            lineSave{end+1}=fgetl(fileID); % Line empty
            controlOld=[controlOld ['#.#. BODY ' num2str(bodiesVect(bodyNum))] {''}];
            controlNew=[controlNew ['#.#. BODY ' num2str(bodiesVect(bodyNum))] {''}];

            while ~contains(lineSave{end},'%%%%') && ~feof(fileID) % End of a body, to avoid finding another section

                if ~contains(lineTemp{end},'Y ') % Because conditions X and Y are not separated by an empty line in CONTROL
                    lineSave{end+1}=fgetl(fileID);
                end
                lineTemp={''};

                if contains(lineSave{end},'X ')
                    contoursNumber=contoursNumber+1; % Number of contours for a body
                end

                if partNum<=size(bodiesModifCell,2)

                    % #.#.#. Find the section
                    if strcmp(lineSave{end},bodiesModifCell{partNum}{1}) ...
                            || (contains(lineSave{end},'X ') && contains(bodiesModifCell{partNum}{1},'X ')) ... % Allows you to change the condition type
                            || (contains(lineSave{end},'Y ') && contains(bodiesModifCell{partNum}{1},'Y ')) % Allows you to change the condition type
                        lineTemp={};
                        lineTemp{end+1}=fgetl(fileID);

                        % #.#.#. Finds the end of the condition in the CONTROL
                        while ~contains(lineTemp{end},'Y ') && ~strcmp(lineTemp{end},'') && ~strcmp(lineTemp{end},' ')
                            lineTemp{end+1}=fgetl(fileID);
                            if feof(fileID)
                                msgbox(['Can''t find the end of BODY ' num2str(bodiesVect(bodyNum)) ' in STATIC_CONTROL.'],'Information','help');
                                fclose(fileID);
                                return;
                            end
                        end

                        % #.#.#. Save controlOld/controlNew
                        if contains(lineSave{end},'X ') || contains(lineSave{end},'Y ')
                            % The contour number is displayed, and the total number is added later
                            controlOld=[controlOld {['(Border ' num2str(contoursNumber) '/']} lineSave(end) lineTemp(1:end-1) {''}];
                            controlNew=[controlNew {['(Border ' num2str(contoursNumber) '/']}];
                        else
                            controlOld=[controlOld   lineSave(end) lineTemp(1:end-1) {''}];
                        end
                        indSave=size(lineSave,2);
                        if ~contains(bodiesModifCell{partNum}{1},'None')
                            if strcmp(bodiesModifCell{partNum}{2},'~')
                                % Type :
                                % Section
                                % ~
                                % Add modification
                                if isscalar(lineTemp)
                                    if size(bodiesModifCell{partNum},2)>3
                                        % Type None
                                        % add the number of conditions
                                        lineSave=[lineSave(1:end-1) bodiesModifCell{partNum}(1) lineTemp(1:end-1) num2str(size(bodiesModifCell{partNum}(3:end),2)) bodiesModifCell{partNum}(3:end) lineTemp(end)];
                                    else
                                        % We cannot have just one
                                        % condition, so we do not
                                        % modify this section
                                        if isempty(ishandle(msg)) % To get the message only once
                                            msg=msgbox('One or more conditions have not been modified because at least 2 conditions are required for a body (probably due to the use of “~” for a None condition)','Information','help');
                                        end
                                        lineSave=[lineSave lineTemp];
                                    end
                                else
                                    % Other
                                    lineSave=[lineSave(1:end-1) bodiesModifCell{partNum}(1) lineTemp(1:end-1) bodiesModifCell{partNum}(3:end) lineTemp(end)];
                                end
                            elseif strcmp(bodiesModifCell{partNum}{end},'~')
                                % Type :
                                % Section
                                % Add modification
                                % ~
                                if isscalar(lineTemp)
                                    if size(bodiesModifCell{partNum},2)>4
                                        % Type None
                                        lineSave=[lineSave(1:end-1) bodiesModifCell{partNum}(1:end-1) lineTemp(end)];
                                    else
                                        % We cannot have just one
                                        % condition, so we do not
                                        % modify this section
                                        if isempty(ishandle(msg)) % To get the message only once
                                            msg=msgbox('One or more conditions have not been modified because at least 2 conditions are required for a body (probably due to the use of “~” for a None condition)','Information','help');
                                        end
                                        lineSave=[lineSave lineTemp];
                                    end
                                else
                                    % Other
                                    lineSave=[lineSave(1:end-1) bodiesModifCell{partNum}(1:end-1) lineTemp(2:end)];
                                end
                            else
                                % Type :
                                % Section
                                % Add modification
                                lineSave=[lineSave(1:end-1) bodiesModifCell{partNum}];
                                lineSave{end+1}=lineTemp{end};
                            end
                        else
                            % Type :
                            % X/Y None
                            lineSave=[lineSave(1:end-1) bodiesModifCell{partNum}];
                            lineSave{end+1}=lineTemp{end};
                        end

                        % #.#.#. Correction of the number of conditions
                        if ((contains(bodiesModifCell{partNum}{1},'X ')==1 || contains(bodiesModifCell{partNum}{1},'Y ')) && ~contains(bodiesModifCell{partNum}{1},'None')) && ~contains(lineSave{end-1},'None')
                            if strcmp(bodiesModifCell{partNum}{2},'~')
                                if size(lineTemp,2)>1
                                    condNumber=size(bodiesModifCell{partNum},2)+size(lineTemp,2)-4; % -4: Section name, Number of conditions, ~, End of paragraph
                                else
                                    % Type None -> Condition
                                    condNumber=size(bodiesModifCell{partNum},2)+size(lineTemp,2)-3; % -3: Section name, ~, End of paragraph
                                end
                            elseif strcmp(bodiesModifCell{partNum}{end},'~')
                                if size(lineTemp,2)>1
                                    condNumber=size(bodiesModifCell{partNum},2)+size(lineTemp,2)-5; % -4: Section name, Number of conditions*2, ~, End of paragraph
                                else
                                    % Type None -> Condition
                                    condNumber=size(bodiesModifCell{partNum},2)+size(lineTemp,2)-4; %-4: Section name, Number of conditions*1, ~, End of paragraph
                                end
                            else
                                condNumber=size(bodiesModifCell{partNum},2)-2;
                            end
                            lineSave(end-condNumber-1)={num2str(condNumber)};
                        end
                        controlNew=[controlNew lineSave(indSave:end-1) {''}];
                        partNum=partNum+1;
                    end
                end
            end
            % #.#.#. Modification controlOld/controlNew
            indStartOld=find(contains(controlOld,'#.#.'),1,'last');
            indStartNew=find(contains(controlNew,'#.#.'),1,'last');
            indBoundariesOld=find(contains(controlOld(indStartOld:end),'(Border '));
            indBoundariesNew=find(contains(controlNew(indStartNew:end),'(Border '));
            for boundariesNum=1:size(indBoundariesOld,2)
                controlOld(indStartOld+indBoundariesOld(boundariesNum)-1)={[controlOld{indStartOld+indBoundariesOld(boundariesNum)-1} num2str(contoursNumber) ')']};
                controlNew(indStartNew+indBoundariesNew(boundariesNum)-1)={[controlNew{indStartNew+indBoundariesNew(boundariesNum)-1} num2str(contoursNumber) ')']};
            end
            bodyNum=bodyNum+1;
        end
    end
    if feof(fileID)
        if bodyNum~=size(bodiesVect,2)+1
            msgbox(['Can''t find BODY ' num2str(bodiesNum) ' in STATIC_CONTROL.'],'Warning','warn');
            fclose(fileID);
            return;
        else
            break;
        end
    end
end
fclose(fileID);

% #. CONTROL
if previewMode
    controlNew=controlOld;
end
fig.Children(indOldStatic).Value=controlOld;
fig.Children(indNewStatic).Value=controlNew;
end