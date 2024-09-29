%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                               manageBodies                            %%
%%                         Last update: July 31, 2024                    %%
%%                               Kévin Daigne                            %%
%%                         kevin.daigne@hotmail.fr                       %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Imports/deletes bodies from an other simulation
%% -

% #. Initialization
pathSimuExport=[];
stepExport=[];
bodiesBefore=[];
bodiesExport=[];
bodiesNumberExport=[];
xShift=[];
yShift=[];
assignInput=[];

% #. Inputs
tabNumberImport=findTab(app);
refreshSteps(app,tabNumberImport,0);
stepVal=find(strcmp(app.TabGroup.Children(tabNumberImport).Children(app.id.gridTabNumber).Children(app.id.gridProcessingNumber).Children(app.id.STEPSPanelNumber).Children(app.id.gridStepsNumber).Children(app.id.stepsListNumber).Items,...
    app.TabGroup.Children(tabNumberImport).Children(app.id.gridTabNumber).Children(app.id.gridProcessingNumber).Children(app.id.STEPSPanelNumber).Children(app.id.gridStepsNumber).Children(app.id.stepsListNumber).Value),1,'first');
stepImport=app.TabGroup.Children(tabNumberImport).Children(app.id.gridTabNumber).Children(app.id.gridProcessingNumber).Children(app.id.STEPSPanelNumber).Children(app.id.gridStepsNumber).Children(app.id.stepsListNumber).Value;
pathSimuImport=app.TabGroup.Children(tabNumberImport).Children(app.id.gridTabNumber).Children(app.id.gridProcessingNumber).Children(app.id.SAVEPanelNumber).Children(app.id.gridSaveNumber).Children(app.id.displayPathNumber).Value;

% #. Body number
generalData=MelodyGeneralData(pathSimuImport);
ind=find(strcmpi(strtrim(generalData),'NUMBER_BODIES'),1,'first');
if isempty(ind); return; end
bodiesNumberImport=str2double(generalData{ind+1});

% #. Warning
if stepVal~=1
    stepLast=app.TabGroup.Children(tabNumber).Children(app.id.gridTabNumber).Children(app.id.gridProcessingNumber).Children(app.id.STEPSPanelNumber).Children(app.id.gridStepsNumber).Children(app.id.stepsListNumber).Items{1};
    answer = questdlg(['Warning: changes will be applied to step ' stepImport ' and not to step ' stepLast '.'],'Warning','Continue','Cancel','Cancel');
    figure(app.mainUIFigure);
    if isempty(answer) || strcmpi(answer,'Cancel')
        busyOff(app); return;
    end
end

% #. Mode
mode=questdlg('What type of change is requested concerning the bodies?','Type','Import','Delete','Cancel','Cancel');
figure(app.mainUIFigure);
if isempty(mode) || strcmpi(mode,'Cancel')
    return;
end

if strcmpi(mode,'Import')

    % #. Tab selection
    % #.#. Pre-processing
    tabList=cell(1,numel(app.TabGroup.Children)-2);
    for tabNumberVar=3:numel(app.TabGroup.Children)
        tabList{tabNumberVar-2}=app.TabGroup.Children(tabNumberVar).Title;
    end
    % #.#. DLG
    [indTab,~]=listdlg('Name','Tab','PromptString',{'Select the tab that contains' 'the bodies to be imported:'},'listString',tabList,'SelectionMode','single','InitialValue',tabNumberImport-2);
    figure(app.mainUIFigure);
    if isempty(indTab)
        return;
    end
    % #.#. Output
    tabNumberExport=indTab+2; % Tab index where the data are exported

    % #. Step selection
    % #.#. Pre-processing
    stepListExport=loadListStep(app,tabNumberExport);
    if isempty(stepListExport)
        msgbox('No steps can be found in this tab.','Information','help'); return;
    end
    % #.#. DLG
    [indStep,~] = listdlg('Name','Step','PromptString',{'Select the step that contains' 'the data to be imported:'},'listString',stepListExport,'SelectionMode','single','InitialValue',1);
    figure(app.mainUIFigure);
    if isempty(indStep)
        return;
    end
    % #.#. Output
    stepExport=stepListExport{indStep}; % Step for which the data are exported

    % #. Body selection
    % #.#. BodyIndex
    mainLoading(app,{pathSimu},{{'GRAINS_'}},{{{stepExport}}},'.vtk',0);
    dataTemp=load([pathSimu filesep 'SAVE' filesep 'GRAINS_' stepExport '.mat'],'body_index');
    bodyIndexExport=dataTemp.body_index; % Must be loaded because deactivated bodies do not appear in the mesh (i.e. cannot be found from the latter)
    % #.#. DLG
    bodiesExport=bodiesSelection(app,tabNumberExport,[],stepExport,bodyIndexExport);
    if isempty(bodiesExport)
        return;
    end
    % #.#. Outputs
    bodiesExport=cellfun(@num2str, num2cell(bodiesExport),'UniformOutput',0); % List of the bodies to be exported
    bodiesNumberExport=numel(bodiesExport); % Number of bodies to be exported

    % #. Location selection
    % #.#. Location to copy
    pathSimuExport=app.TabGroup.Children(tabNumberExport).Children(app.id.gridTabNumber).Children(app.id.gridProcessingNumber).Children(app.id.SAVEPanelNumber).Children(app.id.gridSaveNumber).Children(app.id.displayPathNumber).Value;
    [materialsList,bodiesNumber]=MelodyMaterialPerBody(pathSimuExport);
    bodiesList=strcat('Body',{' '},cellfun(@num2str,num2cell(0:bodiesNumber-1),'UniformOutput',false),{' '},'-',{' '},materialsList);
    locationListToCopy=['At the beginning' bodiesList];
    % #.#. DLG
    [indBody,~] = listdlg('Name','Location','PromptString',{'Bodies will be added just after' 'the selected body:'},'listString',locationListToCopy,'SelectionMode','single','InitialValue',1);
    figure(app.mainUIFigure);
    if isempty(indBody)
        return;
    end
    % #.#. Outputs
    bodiesBefore=indBody-2; % -1 because the body indexation starts from 0 and -1 because the bodies start from the 2nd proposal
    if indBody==1
        assignInput='addBefore'; % Will be added before the first body
    else
        assignInput='addAfter'; % Will be added after the selected body
    end

    % #. Shift
    % #.#. DLG
    prompt={'X shift (x desired - x current):','Y shift (y desired - y current):'}; dlgtitle='Shift'; dims=[1 35]; definput={'0','0'};
    answer=inputdlg(prompt,dlgtitle,dims,definput);
    figure(app.mainUIFigure);
    if isempty(answer)
        return;
    end
    % #.#. Outputs
    xShift=str2double(answer{1}); yShift=str2double(answer{2});
    if isnan(xShift) || isnan(yShift)
        msgbox('Unknown format.','Information','help'); return;
    end

elseif strcmpi(mode,'Delete')

    % #. Body selection
    % #.#. BodyIndex
    mainLoading(app,{pathSimu},{{'GRAINS_'}},{{{stepImport}}},'.vtk',0);
    dataTemp=load([pathSimu filesep 'SAVE' filesep 'GRAINS_' stepImport '.mat'],'body_index');
    bodyIndexImport=dataTemp.body_index; % Must be loaded because deactivated bodies do not appear in the mesh (i.e. cannot be found from the latter)
    % #.#. DLG
    bodiesExport=bodiesSelection(app,tabNumberImport,[],stepImport,bodyIndexImport);
    if isempty(bodiesExport)
        return;
    end
    % #.#. Outputs
    bodiesExport=cellfun(@num2str, num2cell(bodiesExport),'UniformOutput',0);
    bodiesNumberExport=numel(bodiesExport);

    % #. Location selection
    assignInput='delete';

end

% #. Change
errorVerif=manageBodiesFunction(pathSimuImport,pathSimuExport,stepImport,stepExport,bodiesBefore,bodiesExport,bodiesNumberImport,bodiesNumberExport,xShift,yShift,mode,assignInput);

if ~errorVerif

    if ~exist([pathSimuImport filesep 'SAVE'],'dir')
        mkdir([pathSimuImport filesep 'SAVE']);
    end

    % #. Log
    if strcmpi(mode,'Import')

        % #.#. Import

        logMsg={['Step ' stepImport];...
            ['Bodies (old indexing): ' strjoin(bodiesExport)];...
            ['Bodies (new indexing): ' strjoin(cellfun(@num2str,num2cell(bodiesBefore+1:bodiesBefore+numel(bodiesExport)),'UniformOutput',false))];...
            ['Shift (X,Y): [' num2str(xShift) ',' num2str(yShift) ']']};
        LogSave(logMsg,{''},'Bodies import',[pathSimuImport filesep 'SAVE' filesep 'LOG_save.log']);

    elseif strcmpi(mode,'Delete')

        % #.#. Delete

        logMsg={['Step: ' stepImport]; ...
            ['Bodies: ' strjoin(bodiesExport)]};
        LogSave(logMsg,{''},'Bodies deletion',[pathSimuImport filesep 'SAVE' filesep 'LOG_save.log']);

    end

    % #. Load
    loadPathFunction(app,tabNumberImport); % To refresh the GUI

end

function errorVerif=manageBodiesFunction(pathSimuImport,pathSimuExport,stepImport,stepExport,bodiesBefore,bodiesExport,bodiesNumberImport,bodiesNumberExport,xShift,yShift,mode,assignInput)
% Abstract: manage bodies processing

% #. Paths
errorVerif=0;
pathControlImport=[pathSimuImport filesep 'CODE' filesep 'STATIC_CONTROL.asc'];
pathDataImport=[pathSimuImport filesep 'CODE' filesep 'STATIC_DATA.asc'];
pathDynImport=[pathSimuImport filesep 'CODE' filesep 'DYNAMIC_' stepImport '.asc'];
if strcmp(mode,'Import')
    pathControlExport=[pathSimuExport filesep 'CODE' filesep 'STATIC_CONTROL.asc'];
    pathDataExport=[pathSimuExport filesep 'CODE' filesep 'STATIC_DATA.asc'];
    pathDynExport=[pathSimuExport filesep 'CODE' filesep 'DYNAMIC_' stepExport '.asc'];
elseif strcmp(mode,'Delete')
    pathControlExport=pathControlImport;
    pathDataExport=pathDataImport;
    pathDynExport=pathDynImport;
end

% #. msg
answer = questdlg('The operation can be quite long and cannot be stopped without affecting the files, do you want to continue?', ...
    'Preview', ...
    'Yes (with backup)','Yes (without backup)','No','No');
if strcmp(answer,'No')==1 || isempty(answer)
    errorVerif=1;
    return;
end
if strcmp(answer,'Yes (with backup)')
    filename=[pathSimuImport filesep 'Backup_' replace(char(datetime('now')),{'[',' ','!','"','#','$','%','&','(',')','*','+',',','-','.','/',':',';','<','=','>','?','@','\','^','_','`','''','{','|','}','~',']'},'_')];
    if exist(filename,'dir')
        msgbox('Cannot save the backup because the name already exists.','Information','help');
        errorVerif=1;
        return;
    end
    mkdir(filename);
    copyfile(pathControlImport,filename);
    copyfile(pathDynImport,filename);
    copyfile(pathDataImport,filename);
    [~,control1,control2]=fileparts(pathControlImport);
    [~,dyn1,dyn2]=fileparts(pathDynImport);
    [~,data1,data2]=fileparts(pathDataImport);
    if ~isfile([filename filesep control1 control2]) || ~isfile([filename filesep dyn1 dyn2]) || ~isfile([filename filesep data1 data2])
        msgbox('Cannot save the backup files for an unknown reason.','Information','help');
        errorVerif=1;
        return;
    end
end

% #. Options pour la lecture
if strcmp(mode,'Import')

    % #.#. STATIC CONTOL + DYNAMIC
    optsControl=struct();
    optsControl.TypeOpen=cell(1,2*bodiesNumberExport); optsControl.CriterionOpen=cell(1,2*bodiesNumberExport);
    optsControl.TypeClose=cell(1,2*bodiesNumberExport); optsControl.CriterionClose=cell(1,2*bodiesNumberExport); optsControl.TrueClose=cell(1,2*bodiesNumberExport);
    optsControl.Update=cell(1,2*bodiesNumberExport); optsControl.Format='Horizontal';
    for bodyNum=1:bodiesNumberExport
        % #.#. Title
        optsControl.TypeOpen{2*bodyNum-1}={'Contains' 'Shift'};
        optsControl.CriterionOpen{2*bodyNum-1}={{'BODY' '%%%' bodiesExport{bodyNum}} -1};
        optsControl.TypeClose{2*bodyNum-1}={'Empty' 'Empty' 'Numeric' 'Shift'};
        optsControl.CriterionClose{2*bodyNum-1}={'' '' '' -1};
        optsControl.TrueClose{2*bodyNum-1}={1 0 1 1};
        % #.#. Number
        optsControl.TypeOpen{2*bodyNum}={'Numeric'};
        optsControl.CriterionOpen{2*bodyNum}={''};
        optsControl.TypeClose{2*bodyNum}={'Contains' 'Shift'};
        optsControl.CriterionClose{2*bodyNum}={'%%%' -1};
        optsControl.TrueClose{2*bodyNum}={1 1};
        optsControl.Update{2*bodyNum-1}={{'Assign' 2 3 num2str(bodiesBefore+bodyNum)}};
        optsControl.Update{2*bodyNum}={{'Assign' 1 1 num2str(bodiesBefore+bodyNum)}};
    end
    optsControl.Save='off';
    optsDyn=optsControl;
    % #.#. STATIC DATA
    optsData=struct();
    optsData.TypeOpen=cell(1,4*bodiesNumberExport); optsData.CriterionOpen=cell(1,4*bodiesNumberExport);
    optsData.TypeClose=cell(1,4*bodiesNumberExport); optsData.CriterionClose=cell(1,4*bodiesNumberExport); optsData.TrueClose=cell(1,4*bodiesNumberExport);
    optsData.Update=cell(1,4*bodiesNumberExport); optsData.Format='Horizontal';
    for bodyNum=1:bodiesNumberExport
        % #.#. Title
        optsData.TypeOpen{4*bodyNum-3}={'Contains' 'Shift'};
        optsData.CriterionOpen{4*bodyNum-3}={{'BODY' '%%%' bodiesExport{bodyNum}} -1};
        optsData.TypeClose{4*bodyNum-3}={'Empty' 'Empty' 'Numeric' 'Shift'};
        optsData.CriterionClose{4*bodyNum-3}={'' '' '' -1};
        optsData.TrueClose{4*bodyNum-3}={1 0 1 1};
        % #.#. Number
        optsData.TypeOpen{4*bodyNum-2}={'Shift'};
        optsData.CriterionOpen{4*bodyNum-2}={1};
        optsData.TypeClose{4*bodyNum-2}={'Contains' 'Empty' 'Empty' 'Shift'};
        optsData.CriterionClose{4*bodyNum-2}={'NODES' '' '' -1};
        optsData.TrueClose{4*bodyNum-2}={1 1 0 1};
        optsData.Update{4*bodyNum-3}={{'Assign' 2 3 num2str(bodiesBefore+bodyNum)}};
        optsData.Update{4*bodyNum-2}={{'Assign' 1 1 num2str(bodiesBefore+bodyNum)}};
        % #.#. Nodes
        optsData.TypeOpen{4*bodyNum-1}={'Shift'};
        optsData.CriterionOpen{4*bodyNum-1}={1};
        optsData.TypeClose{4*bodyNum-1}={'Empty' 'Shift'};
        optsData.CriterionClose{4*bodyNum-1}={'' -1};
        if xShift~=0 || yShift~=0
            optsData.Update{4*bodyNum-1}={{'Assign' 'all' 2 xShift} {'Assign' 'all' 3 yShift}};
        end
        % #.#. Remain
        optsData.TypeOpen{4*bodyNum}={'Shift'};
        optsData.CriterionOpen{4*bodyNum}={1};
        optsData.TypeClose{4*bodyNum}={'Contains' 'Shift'};
        optsData.CriterionClose{4*bodyNum}={'%%%' -1};
    end
    optsData.Save='off';

elseif strcmp(mode,'Delete')

    % #.#. STATIC CONTOL + DYNAMIC + STATIC DATA
    optsControl=struct();
    optsControl.TypeOpen=cell(1,bodiesNumberExport); optsControl.CriterionOpen=cell(1,bodiesNumberExport);
    optsControl.TypeClose=cell(1,bodiesNumberExport); optsControl.CriterionClose=cell(1,bodiesNumberExport);
    optsControl.Update=cell(1,bodiesNumberExport); optsControl.Format='Horizontal';
    for bodyNum=1:bodiesNumberExport
        optsControl.TypeOpen{bodyNum}={'Contains' 'Shift'};
        optsControl.CriterionOpen{bodyNum}={{'BODY' '%%%' bodiesExport{bodyNum}} -1};
        optsControl.TypeClose{bodyNum}={'Contains' 'Contains' 'Contains' 'Shift'};
        optsControl.CriterionClose{bodyNum}={'%%%' '%%%' '%%%' -1};
        optsControl.Update{bodyNum}={{'delete'}};
    end
    optsDyn=optsControl;
    optsData=optsControl;

end

% #. Static_Control (reading)
%             tStart=tic; % Duration guess is not not very good because the computing speed is not linear at the beggining and the convergence occurs when STATIC_DATA is already being read (Duration is driven by it)
msg=waitbar(0,'[1/2] Pre-processing 1/3','Name','Progress');
sectionsNew=TextEditor(pathControlExport,optsControl); controlToImport=[sectionsNew{:}]';

% #. Dynamic (reading)
if ishandle(msg)
    waitbar(1/6,msg,'[1/2] Pre-processing 2/3');
end
sectionsNew=TextEditor(pathDynExport,optsDyn); dynToImport=[sectionsNew{:}]';

% #. Static_Data (reading)
if ishandle(msg)
    waitbar(2/6,msg,'[1/2] Pre-processing 3/3');
end
sectionsNew=TextEditor(pathDataExport,optsData); dataToImport=[sectionsNew{:}]';

% #. Options pour l'importation

if strcmp(mode,'Import')

    % #.#. Initialisation
    optsControl=struct();
    optsControl.TypeOpen=cell(1,4); optsControl.CriterionOpen=cell(1,4); optsControl.TrueOpen=cell(1,4);
    optsControl.TypeClose=cell(1,4); optsControl.CriterionClose=cell(1,4);
    optsControl.PeriodOpen=cell(1,4); optsControl.Update=cell(1,4);
    % #.#. NUMBER_BODIES
    optsControl.TypeOpen{1}={'Contains' 'Shift'};
    optsControl.CriterionOpen{1}={'NUMBER_BODIES' 1};
    optsControl.PeriodOpen{1}={1 1};
    optsControl.TypeClose{1}={'Shift'};
    optsControl.CriterionClose{1}={0};
    optsControl.Update{1}={{'Assign' bodiesNumberExport}};
    % #.#. BODIES TO ADD
    if strcmpi(assignInput,'addBefore')
        optsControl.TypeOpen{end-2}={'Contains' 'Shift'};
        optsControl.CriterionOpen{end-2}={{'BODY' '%%%' num2str(bodiesBefore+1)} -1};
        optsControl.PeriodOpen{end-2}={1 1};
        optsControl.TypeClose{end-2}={'Shift'};
        optsControl.CriterionClose{end-2}={0};
        optsControl.Update{end-2}={{'addBefore' controlToImport}};
    elseif strcmpi(assignInput,'addAfter')
        optsControl.TypeOpen{end-2}={'Contains' 'Contains' 'Contains' 'Shift'};
        optsControl.CriterionOpen{end-2}={{'BODY' '%%%' num2str(bodiesBefore)} '%%%' '%%%' -1};
        optsControl.PeriodOpen{end-2}={1 1 1 1};
        optsControl.TypeClose{end-2}={'Shift'};
        optsControl.CriterionClose{end-2}={0};
        optsControl.Update{end-2}={{'addAfter' controlToImport}};
    end
    % #.#. Title
    optsControl.TypeOpen{end-1}={'Contains'};
    optsControl.CriterionOpen{end-1}={{'BODY' '%%%'}};
    optsControl.PeriodOpen{end-1}={inf};
    optsControl.TypeClose{end-1}={'Shift'};
    optsControl.CriterionClose{end-1}={0};
    optsControl.Update{end-1}={{'Assign' 1 3 bodiesNumberExport}};
    % #.#. Body number
    optsControl.TypeOpen{end}={'Empty' 'Empty' 'Numeric'};
    optsControl.CriterionOpen{end}={'' '' ''};
    optsControl.PeriodOpen{end}={inf inf inf};
    optsControl.TrueOpen{end}={1 0 1};
    optsControl.TypeClose{end}={'Shift'};
    optsControl.CriterionClose{end}={0};
    optsControl.Update{end}={{'Assign' 1 1 bodiesNumberExport}};
    %% #.#. Dyn
    optsDyn=optsControl;
    optsDyn.TypeOpen(1)=[]; optsDyn.CriterionOpen(1)=[]; optsDyn.PeriodOpen(1)=[];  optsDyn.TrueOpen(1)=[]; optsDyn.TypeClose(1)=[]; optsDyn.CriterionClose(1)=[]; optsDyn.Update(1)=[]; % No 'NUMBER_BODIES'
    optsDyn.Update{1}{1}{2}=dynToImport;
    % #.#. STATIC DATA
    optsData=optsControl; optsData.Update{2}{1}{2}=dataToImport;

elseif strcmp(mode,'Delete')

    % #.#. Initialisation
    bodyNumber=bodiesNumberImport-bodiesNumberExport;
    optsControl=struct();
    optsControl.TypeOpen=cell(1,2*bodyNumber+1); optsControl.CriterionOpen=cell(1,2*bodyNumber+1); optsControl.TrueOpen=cell(1,2*bodyNumber+1);
    optsControl.TypeClose=cell(1,2*bodyNumber+1); optsControl.CriterionClose=cell(1,2*bodyNumber+1);
    optsControl.Update=cell(1,2*bodyNumber+1);
    % #.#. NUMBER_BODIES
    optsControl.TypeOpen{1}={'Contains' 'Shift'};
    optsControl.CriterionOpen{1}={'NUMBER_BODIES' 1};
    optsControl.TypeClose{1}={'Shift'};
    optsControl.CriterionClose{1}={0};
    optsControl.Update{1}={{'Assign' 1 1 num2str(bodyNumber)}};
    k=1;
    for bodyNum=0:bodyNumber-1
        % #.#. Title
        k=k+1;
        optsControl.TypeOpen{k}={'Contains'};
        optsControl.CriterionOpen{k}={{'BODY' '%%%'}};
        optsControl.TypeClose{k}={'Shift'};
        optsControl.CriterionClose{k}={0};
        optsControl.Update{k}={{'Assign' 1 3 num2str(bodyNum)}};
        % #.#. Body number
        k=k+1;
        optsControl.TypeOpen{k}={'Empty' 'Empty' 'Numeric'};
        optsControl.CriterionOpen{k}={'' '' ''};
        optsControl.TrueOpen{k}={1 0 1};
        optsControl.TypeClose{k}={'Shift'};
        optsControl.CriterionClose{k}={0};
        optsControl.Update{k}={{'Assign' 1 1 num2str(bodyNum)}};
    end
    optsDyn=optsControl; optsDyn.TypeOpen(1)=[]; optsDyn.CriterionOpen(1)=[];  optsDyn.TrueOpen(1)=[]; optsDyn.TypeClose(1)=[]; optsDyn.CriterionClose(1)=[]; optsDyn.Update(1)=[]; % No 'NUMBER_BODIES'
    optsData=optsControl;
end

% #. Static_Control (importing)
% #.#. BODIES
if ishandle(msg)
    waitbar(3/6,msg,'[2/2] Updating 1/3');
end
TextEditor(pathControlImport,optsControl);

% #. Dynamic (importing)
if ishandle(msg)
    waitbar(4/6,msg,'[2/2] Updating 2/3');
end
TextEditor(pathDynImport,optsDyn);

% #. Static_Data (importing)
if ishandle(msg)
    waitbar(5/6,msg,'[2/2] Updating 3/3');
end
TextEditor(pathDataImport,optsData);

% #. Close
if ishandle(msg)
    waitbar(6/6,msg,'[2/2] Updating 3/3');
    delete(msg);
end
msgbox('Loading is complete (remember to update the body numbers in the spies section if necessary).','Success','help');
end