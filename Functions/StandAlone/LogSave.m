%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                                 LogSave                               %%
%%                     Last update: September 23, 2022                   %%
%%                               Kévin Daigne                            %%
%%                         kevin.daigne@hotmail.fr                       %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Function for paragraph-by-paragraph comparison bertween two entries.
% This allows for example to check changes made in a file (and create a
% log file). Moreover, paragraphs provide context when looking at the log
% file.
%% - Inputs -
% new = 1*lineNumber cell : plain text (after modification)
% old = 1*lineNumber cell : plain text (before modification)
% header = chars : header display in log file
% pathLog = chars : 
%   - Path of the log file where changes will be saved (not mandatory)
%   - If non-empty and the file does not exist, create it and add a custom header
%% - Outputs -
% new = 1*N cell : formated modified paragraph (after modification)
% old = 1*N cell : formated modified paragraph (before modification)
%% - Log file format -
% e.g. several paragraphs have been modified
% Gives:
% header - date and time of modification
% #. New entry:
% #.#. 1
% paragraph 1 after modification
% #.#. 2
% paragraph 2 after modification
% #. Old entry:
% #.#. 1
% paragraph 1 before modification
% #.#. 2
% paragraph 2 before modification
%
% e.g. write in log file without text comparison
% new = {'Information I would like to insert'}
% old = {''}
% Gives:
% header - date and time of modification
% #. New entry:
% 'Information I would like to insert'
%% -

function [new,old]=LogSave(new,old,header,pathLog)

% #. Initialization
if ~isempty(pathLog)
    if ~isfile(pathLog)
        fileID=fopen(pathLog, 'w');
        fwrite(fileID,'##############################################'); fwrite(fileID,newline);
        fwrite(fileID,'#                  LOG FILE                  #'); fwrite(fileID,newline);
        fwrite(fileID,'##############################################'); fwrite(fileID,newline);
        fwrite(fileID,newline);
        fwrite(fileID,newline);
        fwrite(fileID,'O=================== Notes ==================O'); fwrite(fileID,newline);
        fwrite(fileID,newline);
        fwrite(fileID,'O============================================O'); fwrite(fileID,newline);
        fwrite(fileID,newline);
        fwrite(fileID,'______________');
        fwrite(fileID,newline);
        fclose(fileID);
    end
end

% #. Format
% To have a horizontal cell instead of a vertical one in all cases
% #.#. New
if size(new,2)>size(new,1)
    new=new';
end
% #.#. Old
if size(old,2)>size(old,1)
    old=old';
end

% #. Size
if size(new,2)>1 || size(old,2)>1
    new=''; old='';
    msgbox('Cannot save log file','Information','help');
    return;
end

% #. Change detection
if size(new,1)==size(old,1) % If different sizes, there is necessarily a change
    idTemp=find(cellfun(@isequal,new,old)==0,1); % Empty if identical line by line
    if isempty(idTemp)
        new=''; old='';
        return;
    end
end

% #. Initialization
newTemp=cell(size(new,1)*2,1); oldTemp=cell(size(new,1)*2,1); % Initialization with a much larger size

if ~all(cellfun(@isempty,old)) && ~all(strcmpi(old,'')) % If only one new entry without old, then the entry is already formatted
    
    % #. Indices paragraph new
    if ~isempty(new)
        % #.#. Indices of empty lines
        indParaNewTemp=unique([find(strcmpi(new,' '));find(strcmpi(new,''))]); % Indices '' and ' ' to delimit paragraphs
        if isempty(indParaNewTemp)
            % If one single paragraph with no delimited end
            indParaNewTemp(end+1,1)=size(new,1)+1;
        elseif indParaNewTemp(end,1)~=size(new,1)
            % If the last paragraph does not end with an empty line
            indParaNewTemp(end+1,1)=size(new,1)+1;
        end
        % #.#. Add first line
        indParaNewTemp=[0;indParaNewTemp]; % No blank line to mark the beginning
        % #.#. Indices of paragraphs
        % A paragraph is delimited by two blank lines
        indParaNew=[indParaNewTemp(1:end-1)+1 indParaNewTemp(2:end)-1];
        % #.#. Two consecutive empty lines are not considered a paragraph
        indParaNew(abs(indParaNewTemp(2:end)-indParaNewTemp(1:end-1))<=1,:)=[];
    end
    
    % #. Indices paragraph old
    if ~isempty(new)
        % #.#. Indices of empty lines
        indParaOldTemp=unique([find(strcmpi(old,' '));find(strcmpi(old,''))]); % Indices '' and ' ' to delimit paragraphs
        if isempty(indParaOldTemp)
            % If one single paragraph with no delimited end
            indParaOldTemp(end+1,1)=size(old,1)+1;
        elseif indParaOldTemp(end,1)~=size(old,1)
            % If the last paragraph does not end with an empty line
            indParaOldTemp(end+1,1)=size(old,1)+1;
        end
        % #.#. Add first line
        indParaOldTemp=[0;indParaOldTemp]; % No blank line to mark the beginning
        % #.#. Indices of paragraphs
        % A paragraph is delimited by two blank lines
        indParaOld=[indParaOldTemp(1:end-1)+1 indParaOldTemp(2:end)-1];
        % #.#. Two consecutive empty lines are not considered a paragraph
        indParaOld(abs(indParaOldTemp(2:end)-indParaOldTemp(1:end-1))<=1,:)=[];
    end
    
    % #. Difference detection
    kglob=0; lineNew=1; lineOld=1;
    if size(indParaNew,1)==size(indParaOld,1)
        % #.#. Same number of parapraphs
        % Go through each paragraph
        for paraNum=1:size(indParaNew,1)
            if (indParaNew(paraNum,2)-indParaNew(paraNum,1))~=(indParaOld(paraNum,2)-indParaOld(paraNum,1))
                % #.#.#. Different sizes
                % There is necessarily a change, so this paragraph is added
                kglob=kglob+1;
                newTemp{lineNew}=['# ' num2str(kglob) ' #'];
                lineNew=lineNew+1;
                newTemp(lineNew:lineNew+indParaNew(paraNum,2)-indParaNew(paraNum,1))=new(indParaNew(paraNum,1):indParaNew(paraNum,2));
                lineNew=lineNew+indParaNew(paraNum,2)-indParaNew(paraNum,1)+1;
                oldTemp{lineOld}=['# ' num2str(kglob) ' #'];
                lineOld=lineOld+1;
                oldTemp(lineOld:lineOld+indParaOld(paraNum,2)-indParaOld(paraNum,1))=old(indParaOld(paraNum,1):indParaOld(paraNum,2));
                lineOld=lineOld+indParaOld(paraNum,2)-indParaOld(paraNum,1)+1;
            elseif ~isempty(find(cellfun(@isequal, new(indParaNew(paraNum,1):indParaNew(paraNum,2)), old(indParaOld(paraNum,1):indParaOld(paraNum,2)))==0,1))
                % #.#.#. Identical sizes
                % We compared line by line and add this paragraph if we
                % detect differences
                kglob=kglob+1;
                newTemp{lineNew}=['# ' num2str(kglob) ' #'];
                lineNew=lineNew+1;
                newTemp(lineNew:lineNew+indParaNew(paraNum,2)-indParaNew(paraNum,1))=new(indParaNew(paraNum,1):indParaNew(paraNum,2));
                lineNew=lineNew+indParaNew(paraNum,2)-indParaNew(paraNum,1)+1;
                oldTemp{lineOld}=['# ' num2str(kglob) ' #'];
                lineOld=lineOld+1;
                oldTemp(lineOld:lineOld+indParaOld(paraNum,2)-indParaOld(paraNum,1))=old(indParaOld(paraNum,1):indParaOld(paraNum,2));
                lineOld=lineOld+indParaOld(paraNum,2)-indParaOld(paraNum,1)+1;
            end
        end
        if kglob==1
            newTemp(1)=[]; % Remove number if there is only one entry
            oldTemp(1)=[]; % Remove number if there is only one entry
            lineNew=lineNew-1;
            lineOld=lineOld-1;
        end
    else
        % #.#. Different number of paragraphs
        % We cannot detect which paragraph has been modified because we
        % do not know which paragraph in the new version corresponds to the
        % one in the old version. We therefore display the paragraphs in
        % the old file that are not found in the new file and vice versa,
        % so as not to lose any information. We then return to the case
        % with the same number of paragraphs but without the
        % correspondences.
        % #.#.#. Added paragraphs
        % i.e. Comparing new with old
        kglobNew=0;
        for paraNumGlob=1:size(indParaNew,1)
            paraNumVar=0; flag=0;
            while paraNumVar<size(indParaOld,1)
                paraNumVar=paraNumVar+1;
                % #.#.#.#. We are looking to see if there is a difference
                if (indParaNew(paraNumGlob,2)-indParaNew(paraNumGlob,1))==(indParaOld(paraNumVar,2)-indParaOld(paraNumVar,1))
                    % #.#.#.#.#. Identical if and only if they have the same size
                    % Compare line by line only if necessary
                    if isempty(find(cellfun(@isequal, new(indParaNew(paraNumGlob,1):indParaNew(paraNumGlob,2)), old(indParaOld(paraNumVar,1):indParaOld(paraNumVar,2)))==0,1))
                        % #.#.#.#.#. Line-by-line comparison
                        flag=1; % If identical
                        break;
                    end
                end
            end
            if flag==1
                continue;
            end
            % #.#.#.#. If there is a difference
            kglobNew=kglobNew+1;
            if kglobNew==1
                newTemp{lineNew}='Elements that have been modified or added:';
                lineNew=lineNew+1;
            end
            newTemp{lineNew}=['# ' num2str(kglobNew) ' #'];
            lineNew=lineNew+1;
            newTemp(lineNew:lineNew+indParaNew(paraNumGlob,2)-indParaNew(paraNumGlob,1))=new(indParaNew(paraNumGlob,1):indParaNew(paraNumGlob,2));
            lineNew=lineNew+indParaNew(paraNumGlob,2)-indParaNew(paraNumGlob,1)+1;
        end
        if kglobNew==1
            newTemp(2)=[]; % Remove number if there is only one entry
            lineNew=lineNew-1;
        end
        % #.#.#. Deleted paragraphs
        % i.e. Comparing old with new
        kglobOld=0;
        for paraNumGlob=1:size(indParaOld,1)
            paraNumVar=0; flag=0;
            while paraNumVar<size(indParaNew,1)
                paraNumVar=paraNumVar+1;
                % #.#.#.#. We are looking to see if there is a difference
                if (indParaOld(paraNumGlob,2)-indParaOld(paraNumGlob,1))==(indParaNew(paraNumVar,2)-indParaNew(paraNumVar,1))
                    % #.#.#.#.#. Identical if and only if they have the same size
                    % Compare line by line only if necessary
                    if isempty(find(cellfun(@isequal, old(indParaOld(paraNumGlob,1):indParaOld(paraNumGlob,2)), new(indParaNew(paraNumVar,1):indParaNew(paraNumVar,2)))==0,1))
                        % #.#.#.#.#. Line-by-line comparison
                        flag=1; % If identical
                        break;
                    end
                end
            end
            if flag==1
                continue;
            end
            % #.#.#.#. If there is a difference
            kglobOld=kglobOld+1;
            if kglobOld==1
                oldTemp{lineOld}='Elements that have been modified or deleted:';
                lineOld=lineOld+1;
            end
            oldTemp{lineOld}=['# ' num2str(kglobOld) ' #'];
            lineOld=lineOld+1;
            oldTemp(lineOld:lineOld+indParaOld(paraNumGlob,2)-indParaOld(paraNumGlob,1))=old(indParaOld(paraNumGlob,1):indParaOld(paraNumGlob,2));
            lineOld=lineOld+indParaOld(paraNumGlob,2)-indParaOld(paraNumGlob,1)+1;
        end
        if kglobOld==1
            oldTemp(2)=[]; % Remove number if there is only one entry
            lineOld=lineOld-1;
        end
        if isempty(oldTemp)
            newTemp(1)=[]; % Remove the 'elements...' from new if there are no elements in old
            lineNew=lineNew-1;
        end
    end
    if ~all(cellfun(@isempty,newTemp)) && ~all(strcmpi(newTemp,''))
        new=newTemp(1:lineNew-1);
    end
    if ~all(cellfun(@isempty,oldTemp)) && ~all(strcmpi(oldTemp,''))
        old=oldTemp(1:lineOld-1);
    end
end
% #. Writing results
if ~isempty(pathLog)  
    % #.#. Reading existing text
    fileID = fopen(pathLog);
    buffer = fread(fileID, Inf) ;
    fclose(fileID);
    % #.#. Open the file for writing
    fileID = fopen(pathLog, 'w');
    % #.#.#. Rewriting the previous text
    fwrite(fileID,buffer);
    fwrite(fileID,newline);
    % #.#.#. Header
    if ~isempty(header)
        fwrite(fileID,[header ' - ' char(datetime("now"))]);
        fwrite(fileID,newline);
        fwrite(fileID,newline);
    end
    % #.#.#. New
    if ~all(cellfun(@isempty,oldTemp)) && ~all(strcmpi(oldTemp,''))
        fwrite(fileID,'## New entry ##');
        fwrite(fileID,newline);
        fwrite(fileID,newline);
    end
    for lineNum=1:numel(new)
        fwrite(fileID,new{lineNum});
        fwrite(fileID,newline);
    end
    % #.#.#. Old
    if ~all(cellfun(@isempty,oldTemp)) && ~all(strcmpi(oldTemp,''))
        fwrite(fileID,newline);
        fwrite(fileID,'## Old entry ##');
        fwrite(fileID,newline);
        fwrite(fileID,newline);
        for lineNum=1:numel(old)
            fwrite(fileID,old{lineNum});
            fwrite(fileID,newline);
        end
    end
    fwrite(fileID,newline);
    fwrite(fileID,'______________');
    fwrite(fileID,newline);
    % #.#.#. Close
    fclose(fileID);
end
end