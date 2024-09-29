%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                              optionsOnStep                            %%
%%                         Last update: July 29, 2024                    %%
%%                               Kévin Daigne                            %%
%%                         kevin.daigne@hotmail.fr                       %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Adds or deletes an option to the header of the DYNAMIC file
%% -

% #.#. Old options state
tabNumber=findTab(app);
refreshSteps(app,tabNumber,0);
stepVal=find(strcmp(app.TabGroup.Children(tabNumber).Children(app.id.gridTabNumber).Children(app.id.gridProcessingNumber).Children(app.id.STEPSPanelNumber).Children(app.id.gridStepsNumber).Children(app.id.stepsListNumber).Items,...
    app.TabGroup.Children(tabNumber).Children(app.id.gridTabNumber).Children(app.id.gridProcessingNumber).Children(app.id.STEPSPanelNumber).Children(app.id.gridStepsNumber).Children(app.id.stepsListNumber).Value),1,'first');
step=app.TabGroup.Children(tabNumber).Children(app.id.gridTabNumber).Children(app.id.gridProcessingNumber).Children(app.id.STEPSPanelNumber).Children(app.id.gridStepsNumber).Children(app.id.stepsListNumber).Value;
opts=optionsOnStep(app,tabNumber,'read',[]);

% #. Warning
if stepVal~=1
    stepLast=app.TabGroup.Children(tabNumber).Children(app.id.gridTabNumber).Children(app.id.gridProcessingNumber).Children(app.id.STEPSPanelNumber).Children(app.id.gridStepsNumber).Children(app.id.stepsListNumber).Items{1};
    answer = questdlg(['Warning: changes will be applied to step ' step ' and not to step ' stepLast '.'],'Warning','Continue','Cancel','Cancel');
    figure(app.mainUIFigure);
    if isempty(answer) || strcmpi(answer,'Cancel')
        busyOff(app); return;
    end
end

% #. Options selection
optsList={'INITIALIZE_CZM' 'KILL_AT_EACH_SAVE' 'KILL_VELOCITY' 'MONITOR_BOUNDARIES' ...
    'MONITOR_ENERGY' 'NO_LOG' 'NO_MONITORING' 'NO_SELF_CONTACT' ...
    'RESET_WORK' 'UPDATE_DAMPING_MATRIX' 'UPDATE_INITIAL_DAMAGE' 'UPDATE_MASS_MATRIX' ...
    'UPDATE_STIFFNESS_MATRIX'}; % list of options
activeList=repmat({'(inactive)'},1,numel(optsList));
indActiveOld=find(ismember(optsList,opts));
activeList(indActiveOld)=repmat({'(active)'},1,numel(indActiveOld));
displayedList=strcat(optsList,{' '},activeList); % shows current state
[indActiveNew,tf]=listdlg('Name','Option','PromptString',{'Which options do you want to be active?'},'ListSize',[200 300],'listString',displayedList,'InitialValue',indActiveOld);
figure(app.mainUIFigure);
if ~tf; return; end

% #. Processing
for optNum=1:numel(optsList)
    
    % #.#. Mode
    if all(indActiveOld~=optNum) && any(indActiveNew==optNum)
        % #.#.#. Add
        mode='add';
    elseif any(indActiveOld==optNum) && all(indActiveNew~=optNum)
        % #.#.#. Remove
        mode='remove';
    else
        % #.#.#. Nothing
        continue;
    end

    % #.#. Assignment
    optToProcess=optsList{optNum};
    opts=optionsOnStep(app,tabNumber,mode,optToProcess);

end

function opts=optionsOnStep(app,tabNumber,mode,optToProcess)

% #. Paths
pathSimu=app.TabGroup.Children(tabNumber).Children(app.id.gridTabNumber).Children(app.id.gridProcessingNumber).Children(app.id.SAVEPanelNumber).Children(app.id.gridSaveNumber).Children(app.id.displayPathNumber).Value;
step=app.TabGroup.Children(tabNumber).Children(app.id.gridTabNumber).Children(app.id.gridProcessingNumber).Children(app.id.STEPSPanelNumber).Children(app.id.gridStepsNumber).Children(app.id.stepsListNumber).Value;
pathStep=[pathSimu filesep 'CODE' filesep 'DYNAMIC_' step '.asc']; opts={};
if isempty(step) || ~isfile(pathStep)
    return;
end

% #. Find the end of the header
fileID=fopen(pathStep); headerLineNumber=0; kSection=0;
while 1
    % #.#. Reading
    headerLineNumber=headerLineNumber+1;
    lineTemp=fgetl(fileID);
    if contains(lineTemp,'%%%%')
        kSection=kSection+1;
    end
    % #.#. Count
    if kSection>=4 % the end of the header corresponds to the 4th line containing %%%
        buffer=fread(fileID,Inf);
        fclose(fileID);
        break;
    end
    % #.#. Error
    if feof(fileID)
        stepListValueChangedFunction(app,tabNumber);
        msgbox('Could not find end of header','Warning','warn');
        fclose(fileID);
        return;
    end
end

% #. Saves the header
fileID=fopen(pathStep);
headerSave=cell(1,headerLineNumber);
for lineNum=1:headerLineNumber
    headerSave{lineNum}=fgetl(fileID);
end
fclose(fileID);

% #. Section processing
% #.#. Paragraph index
indSpace=find(strcmp(headerSave,'') | strcmp(headerSave,' ') | cellfun(@isempty,headerSave));
% #.#. Remove double line breaks
headerSave(indSpace(indSpace(2:end)-indSpace(1:end-1)==1))=[];
indSpace=find(strcmp(headerSave,'') | strcmp(headerSave,' ') | cellfun(@isempty,headerSave));
% #.#. Options
if all(~isnan(str2double(strsplit(headerSave{indSpace(end)-1},' '))))
    % If no options (the line before the options is entirely numeric)
    beforeOpts=headerSave(1:indSpace(end));
    opts={''};
    afterOpts=headerSave(end);
else
    % Options
    beforeOpts=headerSave(1:indSpace(end-1));
    opts=headerSave(indSpace(end-1)+1:indSpace(end));
    afterOpts=headerSave(end);
end
if strcmpi(mode,'read')
    return;
end

% #. Modifying options
indOptsToChange=find(strcmpi(strtrim(opts),optToProcess));
if strcmpi(mode,'remove')
    % Remove an option
    opts(indOptsToChange)=[];
elseif strcmpi(mode,'add') && isempty(indOptsToChange)
    % Adds an option
    opts(strcmp(opts,'') | strcmp(opts,' ') | cellfun(@isempty,opts))=[]; % Remove empty lines
    opts=[opts optToProcess {''}];
end

% #. Modification
fileID=fopen(pathStep, 'w');
% #.#. Before
for lineNum=1:numel(beforeOpts)
    fwrite(fileID,beforeOpts{lineNum});
    fwrite(fileID,newline);
end
% #.#. Options
for lineNum=1:numel(opts)
    fwrite(fileID,opts{lineNum});
    fwrite(fileID,newline);
end
% #.#. After
for lineNum=1:numel(afterOpts)
    fwrite(fileID,afterOpts{lineNum});
    fwrite(fileID,newline);
end
fwrite(fileID,buffer);
fclose(fileID);

% #. Display
stepListValueChangedFunction(app,tabNumber);

% #. Log
if ~exist([pathSimu filesep 'SAVE'],'dir')
    mkdir([pathSimu filesep 'SAVE']);
end
if strcmpi(mode,'add')
    [~,~]=LogSave({['Added on DYNAMIC ' step]},{''},optToProcess,[pathSimu filesep 'SAVE' filesep 'LOG_save.log']);
elseif strcmpi(mode,'remove')
    [~,~]=LogSave({['Removed from DYNAMIC ' step]},{''},optToProcess,[pathSimu filesep 'SAVE' filesep 'LOG_save.log']);
end

end