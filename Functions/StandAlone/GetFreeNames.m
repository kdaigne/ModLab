%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                             GetFreeNames                              %%
%%                    Last update: December 30, 2021                     %%
%%                             Kévin Daigne                              %%
%%                        kevin.daigne@hotmail.fr                        %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Finds available names for files or folders in a given directory
%% - Options -
% 'Folder' = chars : Folder where the verification is performed
% 'DefaultNames' = [] or 1*namesNumber cell :
%   - Default names (not the final ones)
%   - Set number of names to be specified (1 if not specified)
%   - Possibility of specifying only a scalar to set the number of names
%   - A suffix will be added if these names are already taken
% 'Format' = [] or cell or 1*formatsNumber cell or 1*namesNumber cell containing 1*formatsNumber cell :
%   - All formats checked ('' if folder)
%   - If 1*formatsNumber cell, check these formats for each name
%   - If 1*namesNumber cell containing 1*formatsNumber cell, check corresponding formats for each name
% 'DefaultFolder': If 'Folder' is not specified, the folder selection window will start from this one (default = pwd)
% 'ImagesMode' = 'File' (default) or 'Folder'
%     If you have a large number of images (or .figs, etc.), it's better to save
%     them in a folder. However, you need to change the name, because if the
%     formats are multiple, you can't have several folders with the
%     same name. For each format, a folder with the name 'nameFORMAT' will be
%     checked if 'Folder' mode is enabled (see examples)
% 'ImagesFormat': Formats considered as images (contains by default
% a list of several formats, but can be modified if required)
%% - Outputs -
% namesList: List of available names without extension
% filesList: List of available names with extension (larger than namesList if more than one format checked per name)
% pathsList: Paths for files with available names with extension (larger than namesList if more than one format checked per name)
% Folder: Path of the folder where verification was performed
%% - Examples -
% e.g. n°1 :
% DefaultNames={'stress' 'velocity'}
% Format{1,1}={'avi' []}
% Format{1,2}={'txt'}
% -> Check if stress.avi, velocity.txt and a stress folder exist
%
% e.g. n°2 :
% DefaultNames={'stress.avi' 'velocity'} Format=[];
% -> Check if stress.avi and a velocity folder exist
%
% e.g. n°3 :
% DefaultNames={'stress' 'velocity'}
% Format={'avi' 'mp4'}
% -> Check if stress.avi, velocity.avi, stress.mp4 and velocity.mp4 exist
%
% e.g. n°4 :
% DefaultNames={'stress' 'velocity'}
% Format={'avi' 'png'}
% -> Check if stress.avi, velocity.avi, stress.png, velocity.png exist
%
% e.g. n°5 :
% DefaultNames={'stress' 'velocity'}
% Format={'avi' 'png'}
% ImagesMode='Folder'
% -> Check if stress.avi, velocity.avi and a stressPNG and velocityPNG folder exist
%% -

function [namesList,filesList,pathsList,folder]=GetFreeNames(varargin)

% #. Inputs
% #.#. Options
p=inputParser;
addOptional(p,'Folder',[]);
addOptional(p,'DefaultFolder',pwd);
addOptional(p,'DefaultNames',[]);
addOptional(p,'Format',[]);
addOptional(p,'ImagesMode','File');
addOptional(p,'ImagesFormat',{'bmp' 'hdf' 'jpg' 'jp2' 'pbm' 'pcx' 'pgm' 'png' 'pnm' 'ppm' 'ras' 'tif' 'xwd' 'pdf' 'eps' 'fig'});
parse(p,varargin{:});
opts=p.Results;
% #.#. Input format
% #.#.#. DefaultNames just indicates the number of names
if ~isnan(str2double(opts.DefaultNames))
    opts.DefaultNames=strcat(repmat({'name'},opts.DefaultNames,1),arrayfun(@(x) num2str(x,'%02.f'),0:opts.DefaultNames-1, 'UniformOutput', 0)');
end
% #.#.#. Inputs into cells
if ~isempty(opts.DefaultNames)
    if ~iscell(opts.DefaultNames)
        opts.DefaultNames={opts.DefaultNames}; % If entered as char and not as cell
    end
end
if ~isempty(opts.Format)
    if ~iscell(opts.Format)
        opts.Format={{opts.Format}}; % If entered as char and not as cell of cell
    elseif ~iscell(opts.Format{1})
        opts.Format={opts.Format}; % If entered as char and not as cell of cell of cell
    end
end
% #.#.#. If cells are vertical, not horizontal
% #.#.#.#. DefaultNames
if ~isempty(opts.DefaultNames)
    if size(opts.DefaultNames,1)>1
        if size(opts.DefaultNames,2)>1
            % Unknown format
            msgbox('Cannot read the names (input must be {1,:} cell array).','Information','help');
            namesList=[]; filesList=[]; pathsList=[]; folder=[]; return;
        end
        opts.DefaultNames=opts.DefaultNames';
    end
end
% #.#.#.#. Format
if ~isempty(opts.Format)
    if size(opts.Format,1)>1
        if size(opts.Format,2)>1
            % Unknown format
            msgbox('Cannot read the formats (input must be {1,:} cell array and {1,:} for cells inside).','Information','help');
            namesList=[]; filesList=[]; pathsList=[]; folder=[]; return;
        end
        opts.opts.Format=opts.Format';
    end
    for formatNum=1:size(opts.Format,2)
        if size(opts.Format{formatNum},1)>1
            if size(opts.Format{formatNum},2)>1
                % Unknown format
                msgbox('Cannot read the formats (input must be {1,:} cell array and {1,:} for cells inside).','Information','help');
                namesList=[]; filesList=[]; pathsList=[]; folder=[]; return;
            end
            opts.Format{formatNum}=opts.Format{formatNum}';
        end
    end
end
% #.#.#. Remove points from formats if specified
if ~isempty(opts.Format)
    for formatNum=1:numel(opts.Format)
        opts.Format{formatNum}=erase(opts.Format{formatNum},'.');
    end
end
opts.ImagesFormat=erase(opts.ImagesFormat,'.');

% #. Initialization
if isempty(opts.DefaultNames)
    namesNumber=1;
    if isempty(opts.Format)
        % Empty names and formats
        opts.Format={{[]}};
    end
    opts.DefaultNames=strcat(repmat({'name'},namesNumber,1),arrayfun(@(x) num2str(x,'%02.f'),0:namesNumber-1, 'UniformOutput', 0)');
else
    namesNumber=numel(opts.DefaultNames);
    if isempty(opts.Format)
        % Indicated names and empty formats
        opts.Format=repmat({{[]}},1,namesNumber);
    elseif isequal(size(opts.Format),[1 1])
        % Formats is one cell
        % -> % Identical formats for each name
        opts.Format=repmat(opts.Format,1,namesNumber);
    else
        % Unknown format
        msgbox('Cannot read the formats.','Information','help');
        namesList=[]; filesList=[]; pathsList=[]; folder=[]; return;
    end
end

% #. Name processing
% Remove formats from names if indicated and modify 'Format' accordingly
for nameNum=1:namesNumber
    % #. Format processing
    ind=strfind(opts.DefaultNames{nameNum},'.');
    if ~isempty(ind)
        % #.#. Indicated format
        opts.Format{nameNum}={opts.DefaultNames{nameNum}(ind+1:end)}; % The indicated format potentially overrides the input format
        opts.DefaultNames{nameNum}(ind:end)=[]; % Format deletion
    else
        % #.#. Format not specified
        if isempty(opts.Format)
            % #.#.#. Folder type
            opts.Format{nameNum}={[]};
        end
    end
end

% #. Folder
if isempty(opts.Folder)
    opts.Folder=uigetdir(opts.DefaultFolder,'Select a folder');
    if isempty(opts.Folder) || isequal(opts.Folder,0)
        namesList=[]; filesList=[]; pathsList=[]; folder=[]; return;
    end
end

% #. Default names not taken
kName=-1; DefaultNamesTemp=opts.DefaultNames;
while 1
    filesList=namesListCreation(DefaultNamesTemp,opts.Format,opts.ImagesMode,opts.ImagesFormat);
    if ~iscell(opts.Folder)
        pathsList=strcat(opts.Folder,filesep,filesList);
    else
        pathsList=cell(1,numel(opts.Folder));
        for pathNum=1:numel(opts.Folder)
            pathsList{pathNum}=strcat(opts.Folder{pathNum},filesep,filesList);
        end
        pathsList=[pathsList{:}];
    end
    indFiles=contains(pathsList,'.'); indDir=~indFiles;
    if ~any(isfile(pathsList(indFiles))) && ~any(cellfun(@(x)exist(x,'dir'),pathsList(indDir)))
        opts.DefaultNames=DefaultNamesTemp;
        break;
    else
        kName=kName+1;
        DefaultNamesTemp=strcat(opts.DefaultNames,'_',num2str(kName,'%02.f'));
    end
end

% #. User-defined names
if namesNumber==1
    dlgtitle = 'Name';
    prompt={'Enter an available name:'};
else
    dlgtitle = 'Names';
    prompt=strcat(repmat({'Name '},namesNumber,1),arrayfun(@(x) num2str(x,'%01.f'),1:namesNumber, 'UniformOutput', 0)',':');
end
dims=[1 60];
while 1
    % #.#. DLG
    opts.DefaultNames=inputdlg(prompt,dlgtitle,dims,opts.DefaultNames)';
    if isempty(opts.DefaultNames)
        namesList=[]; filesList=[]; pathsList=[]; folder=[]; return;
    end
    filesList=namesListCreation(opts.DefaultNames,opts.Format,opts.ImagesMode,opts.ImagesFormat);
    if ~iscell(opts.Folder)
        pathsList=strcat(opts.Folder,filesep,filesList);
    else
        pathsList=cell(1,numel(opts.Folder));
        for pathNum=1:numel(opts.Folder)
            pathsList{pathNum}=strcat(opts.Folder{pathNum},filesep,filesList);
        end
        pathsList=[pathsList{:}];
    end
    indFiles=contains(pathsList,'.'); indDir=~indFiles;
    if any(isfile(pathsList(indFiles))) || any(cellfun(@(x)exist(x,'dir'),pathsList(indDir)))
        % #.#. Names already used
        waitfor(msgbox(['Some names are already used.' '- File names already used:' strcat(filesList(isfile(pathsList) & indFiles)) '- Folder names already used:' filesList(cellfun(@(x)exist(x,'dir'),pathsList) & indDir)],'Information','help'));
    elseif ~isequal(size(unique(filesList)),size(filesList))
        % #.#. Duplicated names
        [~,indDuplicate,~]=unique(filesList); % Unique name index
        [~,indDuplicate,~]=unique(filesList(~ismember(1:numel(filesList),indDuplicate))); % Index of duplicate names, keeping only one copy of each name
        waitfor(msgbox(['Some names are used several times which is not possible.' '- File names used several times:' strcat(filesList(indDuplicate & indFiles)) '- Folder names used several times:' filesList(indDuplicate & indDir)],'Information','help'));
    else
        % #.#. Free names
        namesList=opts.DefaultNames;
        folder=opts.Folder;
        break;
    end
end
end

function filesList=namesListCreation(namesInput,formatsInput,imagesMode,imagesFormat)
% Abstract: transforms the list of names and formats into a name.format list

% #. Initialization
kName=0;
if isempty(formatsInput)
    % Formats not fixed
    filesList=repmat({},1,numel(namesInput));
    formatsInput=repmat({{[]}},1,numel(namesInput));
else
    % Formats fixed
    if numel(formatsInput)==numel(namesInput)
        % Specific formats for each name
        filesList=cell(1,sum(cellfun(@(x) numel(x),formatsInput)));
    else
        % Identical formats for each name
        filesList=cell(1,numel(formatsInput)*numel(namesInput));
    end
end

for nameNum=1:numel(namesInput)
    % #. Format processing
    ind=strfind(namesInput{nameNum},'.');
    if ~isempty(ind)
        % #.#. Specified format
        filesList(end-numel(formatsInput{nameNum})+2:end)=[]; % Adjust output size as you change the number of formats
        formatsInput{nameNum}={namesInput{nameNum}(ind+1:end)}; % Indicated format has priority over input
        namesInput{nameNum}(ind:end)=[]; % Format deletion
    else
        % #.#. Format not specified
        if isempty(formatsInput)
            % #.#.#. Folder type
            formatsInput{nameNum}={[]};
        end
    end
    
    % #. Name list creation
    % #.#. imagesMode
    if strcmpi(imagesMode,'folder')
        % imagesMode='Folder'
        indImages=ismember(formatsInput{nameNum},imagesFormat);
    else
        % imagesMode='File'
        indImages=zeros(1,numel(formatsInput{nameNum}));
    end
    % #.#. Loop on formats
    for formatNum=1:numel(formatsInput{nameNum})
        kName=kName+1;
        if indImages(formatNum)==1
            % image
            filesList{kName}=[namesInput{nameNum} upper(formatsInput{nameNum}{formatNum})];
        elseif isempty(formatsInput{nameNum}{formatNum})
            % folder
            filesList{kName}=namesInput{nameNum};
        else
            % file
            filesList{kName}=strcat(namesInput{nameNum},'.',formatsInput{nameNum}{formatNum});
        end
    end
end
end