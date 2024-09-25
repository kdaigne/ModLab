%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                            Packing2D processing                       %%
%%                         Last update: July 30, 2024                    %%
%%                               Kévin Daigne                            %%
%%                         kevin.daigne@hotmail.fr                       %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Runs Packing2D and transfers files to the simulation directory
%% -

% #. Paths
% #.#. Main
pathMain=mfilename('fullpath');
% #.#. Program
pathProgram=[fileparts(pathMain) filesep 'Packing2D'];
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
% #.#. Preprocessing path
% Outputs are saved in a preprocessing folder inside the simulation path
pathPrepro=[pathSimu filesep 'PREPROCESSING'];
% #.#. Validation
answer=questdlg(['Current simulation path:' newline pathSimu newline 'Warning: duplicate files will be deleted'], ...
                    'Simulation path','Yes','No','No');
if isempty(answer) || strcmpi(answer,'No'); return; end

% #. Directory old
% Detects new and modified files for subsequent copying
dirOld=dir([pathProgram filesep '**' filesep '*.*']);
dirOld(ismember({dirOld.name},{'.' '..' '.DS_Store' 'Thumbs.db'}))=[];

% #. Run
run([pathProgram filesep 'Packing2D_Main_Program.m']);

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
            || strcmpi(T_old.name(idxOld(fileNum)),'Packing2D_Main_Program.m') % copies the main program in all cases
        indUpdated(fileNum)=true;
    end
end
pathsUpdated=pathsCommon(indUpdated);
% #.#. Created files
pathsCreated=setdiff(pathsNew,pathsOld);

% #. Transfer
if ~exist(pathPrepro,'dir')
    mkdir(pathPrepro);
end
for fileNum=1:numel(pathsUpdated)
    copyfile(pathsUpdated{fileNum},pathPrepro);
end
for fileNum=1:numel(pathsCreated)
    movefile(pathsCreated{fileNum},pathPrepro);
end

% #. End
msgbox('Packing2D has ended normaly.', 'Icon','help');