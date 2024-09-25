%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                            MelodyArrayInfo                            %%
%%                      Last update: October 16, 2024                    %%
%%                             Kévin Daigne                              %%
%%                        kevin.daigne@hotmail.fr                        %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%
%% - Abstract -
% MELODY: reads spies information
%% -

function output=MelodyArrayInfo(pathSimu)

% #. Path
pathStatic=[pathSimu filesep 'CODE' filesep 'STATIC_CONTROL.asc'];
if ~isfile(pathStatic)
    if ~isempty(pathSimu)
        msgbox('Can''t found STATIC_CONTROL.','Information','help');
    end
    return;
end
fileID=fopen(pathStatic);

% #. Beginning of SPIES section
while 1
    if strcmp(fgetl(fileID),'SPIES')==1
        break;
    end
    if feof(fileID)==1
        msgbox('Can''t found SPIES part in STATIC_CONTROL.','Warning','warn');
        fclose(fileID);
        return;
    end
end

% #. SPIES number
output=struct();
output.arrayNumber=str2double(fgetl(fileID));

% #. Initialization
output.DTArrayVect=zeros(1,output.arrayNumber);
output.nameArrayCell=cell(1,output.arrayNumber);
output.nameArgumentsCell=cell(1,output.arrayNumber);
output.argumentNumberVect=zeros(1,output.arrayNumber);

% #. Loop on SPIES
for spiesNum=1:output.arrayNumber
    % #.#. Header
    info='';
    while isempty(info)
        info=strip(fgetl(fileID)); % Space between each SPIES
    end
    infoSplit=strsplit(info,' ');
    output.nameArrayCell{spiesNum}=infoSplit{1};
    output.argumentNumberVect(spiesNum)=str2double(infoSplit{2});
    output.DTArrayVect(spiesNum)=str2double(infoSplit{3});
    % #.#. Loop on arguments
    for argumentNum=1:1:output.argumentNumberVect(spiesNum)
        output.nameArgumentsCell{spiesNum}{argumentNum}=fgetl(fileID);
        if feof(fileID)==1
            msgbox('Problem during SPIES reading.','Warning','warn');
            fclose(fileID);
            return;
        end
    end
end
fclose(fileID);