%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                            MELODY preprocessing                       %%
%%                         Last update: July 30, 2024                    %%
%%                               Kévin Daigne                            %%
%%                         kevin.daigne@hotmail.fr                       %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Runs MELODY preprocessor and transfers files to the simulation directory
% IMPORTANT: run the pre-processor from this file
%% -
clearvars; 

% #. Paths
% #.#. Main
pathMain=mfilename('fullpath');
% #.#. Program
pathProgram=[fileparts(pathMain) filesep 'Preprocessor'];
% #.#. GUI
ind=strfind(lower(pathMain),'tools');
if isempty(ind); return; end
pathGUI=pathMain(1:ind(end)-2);
% #.#. Simulation save
% Current simulation path is saved in a .mat
if ~isfile([pathGUI filesep 'Save' filesep 'path_save.mat'])
    return;
else
    load([pathGUI filesep 'Save' filesep 'path_save.mat']); % pathSimu
end
% #.#. Paths
pathCode=[pathSimu filesep 'CODE'];
pathSave=[pathSimu filesep 'SAVE'];
pathPrepro=[pathSimu filesep 'PREPROCESSING']; % Outputs are saved in a preprocessing folder inside the simulation path
% #.#. Dir
if exist(pathCode,'dir')==0
    mkdir(pathCode);
end
if exist(pathSave,'dir')==0
    mkdir(pathSave);
end
if exist(pathPrepro,'dir')==0
    mkdir(pathPrepro);
end
% #.#. Validation
answer=questdlg(['Current simulation path:' newline pathSimu newline 'Warning: duplicate files will be deleted'], ...
                    'Simulation path','Yes','No','No');
if isempty(answer) || strcmpi(answer,'No'); return; end

% #. Directory old
% Detects new and modified files for subsequent copying
dirOld=dir([pathProgram filesep '**' filesep '*.*']);
dirOld(ismember({dirOld.name},{'.' '..' '.DS_Store' 'Thumbs.db'}))=[];

% #. Run
% Several processing mainly because clearvars inside MELODY;
% Variables are saved in a .mat which avoids having to modify the
% preprocessor (i.e. remove clearvars) every time it's updated
% #.#. Pre-processing
subDirs=genpath(pathProgram); % Adds subdirectories such as distmesh
addpath(subDirs);
save([pathPrepro filesep 'MELODYPreprocessingData.mat']);
% #.#. Processing
run([pathProgram filesep 'MELODY.m']);
% #.#. Post-processing
pathMain=mfilename('fullpath');
ind=strfind(lower(pathMain),'tools');
if isempty(ind); return; end
pathGUI=pathMain(1:ind(end)-2);
load([pathGUI filesep 'Save' filesep 'path_save.mat']); % pathSimu
pathPrepro=[pathSimu filesep 'PREPROCESSING'];
load([pathPrepro filesep 'MELODYPreprocessingData.mat']); % Retrieves variables before run
delete([pathPrepro filesep 'MELODYPreprocessingData.mat']);

% #. Directory new
dirNew=dir([pathProgram filesep '**' filesep '*.*']);
dirNew(ismember({dirNew.name},{'.' '..' '.DS_Store' 'Thumbs.db'}))=[];

% #. Comparison
% #.#. Conversion
T_old=struct2table(dirOld);
T_new=struct2table(dirNew);
pathsOld=strcat(T_old.folder,filesep,T_old.name);
pathsNew=strcat(T_new.folder,filesep,T_new.name);
% #.#. Common files
% #.#.#. Initialization
[pathsCommon,idxOld,idxNew]=intersect(pathsOld,pathsNew);
indUpdated=false(1,numel(pathsCommon));
% #.#.#. Check for updated files
for fileNum=1:numel(pathsCommon)
    if T_old.datenum(idxOld(fileNum))~=T_new.datenum(idxNew(fileNum)) ...
            || strcmpi(T_old.name(idxOld(fileNum)),'MELODYLoadData_Example.m') % copies the main program in all cases
        indUpdated(fileNum)=true;
    end
end
pathsUpdated=pathsCommon(indUpdated);
% #.#. Created files
pathsCreated=setdiff(pathsNew,pathsOld);
% #.#. Concat
pathsConcat=[reshape(pathsUpdated,1,[]) reshape(pathsCreated,1,[])];

% #. Transfer CODE
indToCopy=find(contains(pathsConcat,{'STATIC_CONTROL' 'STATIC_DATA' 'DYNAMIC_'}));
for fileNum=1:numel(indToCopy)
    copyfile(pathsConcat{indToCopy(fileNum)},pathCode);
end

% #. Transfer PREPRO
for fileNum=1:numel(pathsUpdated)
    copyfile(pathsUpdated{fileNum},pathPrepro);
end
for fileNum=1:numel(pathsCreated)
    movefile(pathsCreated{fileNum},pathPrepro); % Must be the last one
end

% #. Log
[~,copyMsg]=fileparts(pathsUpdated);
[~,moveMsg]=fileparts(pathsCreated);
logMsg=['Files copied after computation:' reshape(copyMsg,1,[]) reshape(moveMsg,1,[])];
[~,~]=LogSave(logMsg,{''},'MELODY preprocessing has ended normaly',[pathSimu filesep 'SAVE' filesep 'LOG_save.log']);

% #. End
msgbox('MELODY preprocessing has ended normaly.', 'Icon','help');