%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                            deactivatingBodies                         %%
%%                         Last update: July 31, 2024                    %%
%%                               Kévin Daigne                            %%
%%                         kevin.daigne@hotmail.fr                       %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Activates or deactivates selected bodies
%% -

% #. Inputs
tabNumber=findTab(app);
refreshSteps(app,tabNumber,0);
pathSimu=app.TabGroup.Children(tabNumber).Children(app.id.gridTabNumber).Children(app.id.gridProcessingNumber).Children(app.id.SAVEPanelNumber).Children(app.id.gridSaveNumber).Children(app.id.displayPathNumber).Value;
stepVal=find(strcmp(app.TabGroup.Children(tabNumber).Children(app.id.gridTabNumber).Children(app.id.gridProcessingNumber).Children(app.id.STEPSPanelNumber).Children(app.id.gridStepsNumber).Children(app.id.stepsListNumber).Items,...
    app.TabGroup.Children(tabNumber).Children(app.id.gridTabNumber).Children(app.id.gridProcessingNumber).Children(app.id.STEPSPanelNumber).Children(app.id.gridStepsNumber).Children(app.id.stepsListNumber).Value),1,'first');
step=app.TabGroup.Children(tabNumber).Children(app.id.gridTabNumber).Children(app.id.gridProcessingNumber).Children(app.id.STEPSPanelNumber).Children(app.id.gridStepsNumber).Children(app.id.stepsListNumber).Value;

% #. Warning
if stepVal~=1
    stepLast=app.TabGroup.Children(tabNumber).Children(app.id.gridTabNumber).Children(app.id.gridProcessingNumber).Children(app.id.STEPSPanelNumber).Children(app.id.gridStepsNumber).Children(app.id.stepsListNumber).Items{1};
    answer = questdlg(['Warning: changes will be applied to step ' step ' and not to step ' stepLast '.'],'Warning','Continue','Cancel','Cancel');
    figure(app.mainUIFigure);
    if isempty(answer) || strcmpi(answer,'Cancel')
        busyOff(app); return;
    end
end

% #. Finds the activated bodies
activatedBodiesLogicalOld=activatedBodiesFunction(pathSimu,step,[],[]); % Old activated bodies (logical)
inactivatedBodiesLogicalOld=~activatedBodiesLogicalOld; % Old inactivated bodies (logical)
inactivatedBodiesIndexOld=find(inactivatedBodiesLogicalOld)-1; % Old inactivated bodies (index)

% #. Body index
mainLoading(app,{pathSimu},{{'GRAINS_'}},{{{step}}},'.vtk',0);
dataTemp=load([pathSimu filesep 'SAVE' filesep 'GRAINS_' step '.mat'],'body_index');
bodyIndex=dataTemp.body_index; % Must be loaded because deactivated bodies do not appear in the mesh (i.e. cannot be found from the latter)

% #. Selection of the bodies
inactivatedBodiesIndexNew=bodiesSelection(app,tabNumber,inactivatedBodiesIndexOld,step,bodyIndex); % New inactivated bodies (index)
if isequal(inactivatedBodiesIndexNew,inactivatedBodiesIndexOld)
    % If no changes are found or if the selection is empty for
    % some cases (depending on the selection method)
    return;
end
inactivatedBodiesLogicalNew=zeros(1,numel(activatedBodiesLogicalOld));
inactivatedBodiesLogicalNew(inactivatedBodiesIndexNew+1)=1; % Indexing starts from 0
inactivatedBodiesLogicalNew=logical(inactivatedBodiesLogicalNew);  % New inactivated bodies (logical)

% #. Changes
% #.#. Pre-processing
activationCellNew=repmat({'active'},1,numel(activatedBodiesLogicalOld));
activationCellNew(inactivatedBodiesLogicalNew)={'inactive'}; % Cell that contains the activation keyword
bodyNum=find(inactivatedBodiesLogicalNew~=inactivatedBodiesLogicalOld)-1; % Bodies that need to be modified
update=activationCellNew(bodyNum+1); % Indexing starts from 0
% #.#. Editing
activatedBodiesFunction(pathSimu,step,bodyNum,update);

% #. Log
% #.#. MSG
activationLog=[{['Applied to step ' step]} ...
    strcat('BODY',{' '},strsplit(num2str(bodyNum),' '),{' '},'is now',{' '},activationCellNew(bodyNum+1))];
% #.#. SAVE
if ~exist([pathSimu filesep 'SAVE'],'dir')
    mkdir([pathSimu filesep 'SAVE']);
end
[~,~]=LogSave(activationLog, {''},'Activation or deactivation of bodies', [pathSimu filesep 'SAVE' filesep 'LOG_save.log']);

function indActivatedBodies=activatedBodiesFunction(pathSimu,step,bodyIndex,bodyUpdate)

% #. Inputs
fileName=[pathSimu filesep 'CODE' filesep 'DYNAMIC_' step '.asc'];
if isempty(bodyIndex)
    bodyIndex={''};
elseif isnumeric(bodyIndex)
    bodyIndex=cellfun(@num2str,num2cell(bodyIndex),'UniformOutput',false);
elseif ~iscell(bodyIndex)
    bodyIndex={bodyIndex};
end
if isempty(bodyUpdate)
    bodyUpdate={''};
elseif isnumeric(bodyUpdate)
    bodyUpdate=cellfun(@num2str,num2cell(bodyUpdate),'UniformOutput',false);
elseif ~iscell(bodyUpdate)
    bodyUpdate={bodyUpdate};
end
bodiesNumber=numel(bodyIndex);

% #. Options
opts=struct();
opts.TypeOpen=cell(1,bodiesNumber); opts.CriterionOpen=cell(1,bodiesNumber); opts.TrueOpen=cell(1,bodiesNumber);
opts.TypeClose=cell(1,bodiesNumber); opts.CriterionClose=cell(1,bodiesNumber);
opts.PeriodOpen=cell(1,bodiesNumber);
for bodyNum=1:bodiesNumber
    opts.TypeOpen{bodyNum}={'Contains' 'Empty' 'Empty' 'Shift'};
    opts.CriterionOpen{bodyNum}={{'BODY' '%%%' bodyIndex{bodyNum}} '' '' 1};
    opts.TrueOpen{bodyNum}={1 1 0 1};
    opts.TypeClose{bodyNum}={'Shift'};
    opts.CriterionClose{bodyNum}={0};
    if isempty(bodyIndex{bodyNum})
        opts.PeriodOpen{bodyNum}=inf;
    end
    if ~isempty(bodyUpdate{bodyNum})
        opts.Update{bodyNum}={{'assign' bodyUpdate{bodyNum}}};
    end
end

% #. Reading
[~,~,text,~]=TextEditor(fileName,opts);

% #. Processing
indActivatedBodies=reshape(cellfun(@(x)strcmpi(strtrim(x),'active'),text),1,[]);

end