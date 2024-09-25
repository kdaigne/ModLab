%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                              TextEditor                               %%
%%                     Last update: November 06, 2022                    %%
%%                             Kévin Daigne                              %%
%%                        kevin.daigne@hotmail.fr                        %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Extract and modify certain sections of a text or directly from a file.
% Particularly useful if periodic patterns are present.
%% - Main features -
% A section is a part of the text that meets several criteria
% It is possible to manage repeated sections with the period option
% It is opened if all the 'criterionOpen' are checked successively
% It is closed if all the 'criterionClose' are checked successively
%% - Input -
% file:
%   - If chars : relative or absolute path of the text file
%   - If cells = {1*NLines} : text that will be analyzed
%% - Options -
%
% Options to open or close a section:
%   - 'TypeOpen' / 'TypeClose' (default = 'strcmp') :
%       . 'Strcmp' : the line must be exactly equal to the criterion
%       . 'Contains' : the line must contain the criterion
%       . 'Empty' : the line must contain only ' ' or be empty
%       . 'Numeric' : the line must contain only numerical data
%       . 'Shift' : will skip N lines according to the value of the Criterion (positive=down,negative=up)
%   - 'CriterionOpen' / 'CriterionClose' (default = '') :
%       . Argument of the 'Type' option
%       . For 'Strcmp' and 'Contains' = [chars] or {[chars1],[chars2],etc.} :
%         Characters that will be checked. Note that in the case of multiple 
%         characters groups, all the groups will be checked for the same line 
%         according to the rule defined in the Logical option (see option below)
%       . For 'Shift' = [double] : defines the number of lines to skip
%       . For 'Empty' and 'Numeric', this option is ignored
%   - 'PeriodOpen' / 'PeriodClose' (default = 1) :
%       . double : number of times an argument must be checked
%       . If all the sections are found, the search can be stopped (period=1) or repeated N times (period=N)
%       . Useful in the case of repeated sections
%       . Value can be adjusted for all the arguments. It allows for example to skip headings or preambles
%   - 'TrueOpen' / 'TrueClose' (default = 1) :
%       . 1 : argument must be true
%       . 0 : argument must be false
%   - 'LogicalOpen' / 'LogicalClose' (default = 'And') :
%       . 'And' : all the arguments of THE criterion must be checked
%       . 'Or' : at least one argument of THE criterion must be checked
%       . e.g. Criterion{section_i}{argument_j} : argument_j is checked regardless of the value of this option
%       . e.g. Criterion{section_i}{argument_j}{subArgument_k}) argument_j is true if all the {subArgument_k} are true ('And') or if at least one is true ('Or')
%   - 'CaseSensitiveOpen' / 'CaseSensitiveClose' (default = 'On') :
%       . 'On' : case sensitivity is active
%       . 'Off' : case sensitivity is inactive
%   - 'StepOpen' / 'StepClose' (default = 1) :
%       . double : number of lines to skip at each iteration
%       . A positive value reads the text from top to bottom and a negative value from bottom to top
%       . For a negative step for the first section and argument, the reading starts at the end of the text
%
% 'Update': changes applied to a section
%     - /!\ If the input is a file, it will be permanently modified /!\
%     - Update{section_i}: 
%       . Several arguments (i.e. changes) can be defined to modify a section
%       . Changes are applied only on the unmodified text and the modified 
%       text can be modified by the next argument. For example, if you add 
%       several 'example' lines before all the lines that contain 'am', the
%       'example' lines will not be consider as lines that contain 'am' for
%       this argument.
%     - Section type:
%       . Changes are made on the whole section
%       . Update{section_i}{argument_i} = {Location,Changes}
%     - Line type:
%       . Changes are made on one or several lines of the section
%       . Update{section_i}{argument_i} = {Location,Lines,Changes}
%     - Word type:
%       . Changes are made on one or several lines and one or several words of the section
%       . Update{section_i}{argument_i} = {Location,Lines,Words,Changes}
%     - Location:
%       . 'assign': replaces the text found by the Changes_input
%           -> Section type: Section=[Changes_input]
%           -> Line type: Section=[Lines_before_line_found,Changes_input,Lines_after_line_found]
%           -> Word type: Section{line_found}=[Words_before_word_found,Changes_input,Words_after_word_found]
%       . 'assignBefore': replaces all the text before the text found by the Changes_input
%           -> Section type: Section=[Changes_input,Section]
%           -> Line type: Section=[Changes_input,Line_found,Lines_after_line_found]
%           -> Word type: Section{line_found}=[Changes_input,Word_found,Words_after_word_found]
%       . 'assignAfter': replaces all the text after the text found by the Changes_input
%           -> Section type: Section=[Section,Changes_input]
%           -> Line type: Section=[Lines_before_line_found,Line_found,Changes_input]
%           -> Word type: Section{Line_found}=[Words_before_word_found,Word_found,Changes_input]
%       . 'addBefore': adds just before the text found the Changes_input
%           -> Section type: Section=[Changes_input,Section]
%           -> Line type: Section=[Lines_before_line_found,Changes_input,Line_found,Lines_after_line_found]
%           -> Word type: Section{Line_found}=[Words_before_word_found,Changes_input,Word_found,Words_after_word_found]
%       . 'addAfter': adds right after the text found the Changes_input
%           -> Section type: Section=[Section,Changes_input]
%           -> Line type: Section=[Lines_before_line_found,Line_found,Changes_input,Lines_after_line_found]
%           -> Word type: Section{Line_found}=[Words_before_word_found,Word_found,Changes_input,Words_after_word_found]
%       . 'delete': deletes the text found
%           -> Note that Changes_input = '' is different from delete (e.g. delete a line instead of define an empty line)
%           -> Section type: Section=[]
%           -> Line type: Section=[Lines_before_line_found,Lines_after_line_found]
%           -> Word type: Section{Line_found}=[Words_before_word_found,Words_after_word_found]
%     - Lines:
%       . If [chars]: changes are made on all the lines containing these characters
%       . If [doubles]: changes are made on these line indices (line numbers)
%          -> Note that if the indices are greater than the number of lines, they will be ignored
%          -> If you want to change all the lines: indices=1:number_greater_than_the_number_of_lines or use the input 'all'
%          -> If you want to change the lines according to the last line: use the input 'end' (e.g. '1:end', 'end-1', etc.)
%     - Words:
%       . If [chars]: changes are made on all the patterns containing these characters
%       . If [doubles]: changes are made on these word indices (word numbers according to the beginning of each line)
%          -> Note that if the indices are greater than the number of words, they will be ignored
%          -> If you want to change all the words: indices=1:number_greater_than_the_number_of_words or use the input 'all'
%          -> If you want to change the words according to the last word: use the input 'end' (e.g. '1:end', 'end-1', etc.)
%     - Changes:
%       . If [chars]: characters will be added according to the Location_input
%       . If {[chars1],[chars2],etc.}: these lines will be added according to the Location_input
%       . If [double]: this value will be added to all the numbers found in the text found
%          -> Note that it only works for individual numbers (e.g. works for 'example 1' but not for 'example_1')
%          -> Location value is ignored
%
% 'Save' = 'On' (default) or 'Off': if the changes are saved in the file
%
% 'Format' (default = 'Vertical') : 
%       . 'Vertical': lines are stored in vertical cells (size(linesOld) = [NLines,1]), which is convenient for reading
%       . 'Horizontal': lines are stored in horizontal cells  (size(linesOld) = [1,NLines]), which is convenient for concatenation (e.g. [sectionsNew{:}])
%
%% - Format -
% Applicable to 'Type', 'Criterion', 'Period', 'True', 'Logical', 'CaseSensitive' and 'Step' :
%     - If only a char/double is specified, this value will be applied to all the sections and arguments
%     - If only a {char/double} is specified, this value will be applied to all the arguments of the corresponding section
%     - Type = {1*NSections}
%     - Type{section_i} = {1*NArguments}
%     - Type{section_i}{argument_i} = {'subArgument1'} {'subArgument2'} ... {'subArgumentN'}
%% - Outputs -
% sectionsNew = {NSections*1} : sections after changes
% linesNew = {num.linesNumber*1}  : full text after changes
% sectionsOld = {NSections*1} : sections before changes
% linesOld = {num.linesNumber*1}  : full text before changes
%% - Examples -
% - Text :
% =============
% %%% Title %%%
% Subtitle
% 1+1=2
% 2/2=2
%
% %%% Title %%%
% Subtitle
% Hello world
% Hello world !
% =============
%
% - Function used for the example:
% [sectionsNew,linesNew,sectionsOld,linesOld]=TextEditor(filename,opts);
%
% Without option:
% opts=struct();
% -> sectionsNew={'%%% Title %%%';'Subtitle';'1+1=2';'2/2=2'}
%
% By adding:
% opts.CriterionOpen={...
%     {'Title'} ... % section 1
%     };
% -> sectionsNew={}
%
% By adding:
% opts.TypeOpen={...
%     {'Contains'} ... % section 1
%     };
% -> sectionsNew={'%%% Title %%%';'Subtitle';'1+1=2';'2/2=2'}
%
% By adding:
% opts.PeriodOpen=inf;
% -> sectionsNew{1,1}={'%%% Title %%%';'Subtitle';'1+1=2';'2/2=2'}
% -> sectionsNew{2,1}={'%%% Title %%%';'Subtitle';'Hello world';'Hello world !'}
%
% By modifying:
% opts.CriterionOpen={...
%     {'Title'} ... % section 1
%     {'Title' 'Title'} ... % section 2
%     };
% opts.TypeOpen={...
%     {'Contains'} ... % section 1
%     {'Contains' 'Contains'} ... % section 2
%     };
% -> sectionsNew={'%%% Title %%%';'Subtitle';'1+1=2';'2/2=2'}
%
% By adding:
% opts.CaseSensitiveOpen='off';
% -> sectionsNew{1,1}={'%%% Title %%%';'Subtitle';'1+1=2';'2/2=2'}
% -> sectionsNew{2,1}={'Subtitle';'Hello world';'Hello world !'}
%
% By adding:
% opts.CriterionClose={...
%     {'1'} ... % section 1
%     {} ... % section 2
%     };
% -> sectionsNew={'%%% Title %%%';'Subtitle';'1+1=2';'2/2=2';'';'%%% Title %%%';'Subtitle';'Hello world';'Hello world !'}
%
% By adding:
% opts.TypeClose={...
%     {'Contains'} ... % section 1
%     {} ... % section 2
%     };
% -> sectionsNew{1,1}={'%%% Title %%%';'Subtitle';'1+1=2'}
% -> sectionsNew{2,1}={'Subtitle';'Hello world';'Hello world !'}
%
% By adding:
% opts.TrueOpen={...
%     {0} ... % section 1
%     {} ... % section 2
%     };
% -> sectionsNew={'1+1=2';'2/2=2';'';'%%% Title %%%';'Subtitle';'Hello world';'Hello world !'}
%
% - More advanced inputs are possible:
%
% Checks several conditions for 1 line:
% opts.CriterionOpen={...
%     {'Title'} ... % section 1
%     {{'Title' '%%%'} 'Title'} ... % section 2
%     };
%
% Edits the text file:
% opts.Update={...
%     {{'replace' '%' '#'} {'addBeforeSection' 'test1'} {'addAfterSection' {'test1' 'test2'}} {'addAfterSection' {'test1' 'test2'} 'test3'} ... % section 1
%     {{'assign' 'new section!'}} ... % section 2
%     };
%% -

function [sectionsNew,linesNew,sectionsOld,linesOld]=TextEditor(file,varargin)
%Abstract: main function

% #. Loading options
opts=loadingOptions(varargin{:});
% #. Load text
linesOld=loadingText(file);
% #. Finds the sections
[sectionsOld,indSections,kSectionLocal]=findsSections(linesOld,opts);
% #. Updates the sections
[sectionsNew,linesNew]=updatesSections(sectionsOld,indSections,kSectionLocal,linesOld,opts);
% #. Updates the text file
updatesFile(file,linesOld,linesNew,opts);
% #. Outputs format
if ~strcmpi(opts.Format,'vertical')
    sectionsOld=cellfun(@(x)reshape(x,1,[]),sectionsOld,'UniformOutput',false);
    sectionsNew=cellfun(@(x)reshape(x,1,[]),sectionsNew,'UniformOutput',false);
    linesOld=linesOld';
    linesNew=linesNew';
end

end

function opts=loadingOptions(varargin)
% Abstract: loads the options according to several formats. Indeed, some
% options can be specified or split according to the inputs.

% #. Default
optsList=["Type" "Criterion" "Period" "True" "Logical" "CaseSensitive" "Step"]; % Options that are associated to the boundaries of a section
optsDefault={'strcmp' '' 1 1 'and' 'on' 1}; % Allows to define empty cells as default values and fix the other cells

% #. Imports options
p=inputParser;
for mode=["Open" "Close"]; for optNum=1:numel(optsList); addOptional(p,strcat(optsList(optNum),mode),optsDefault{optNum}); end; end
addOptional(p,'Update',''); addOptional(p,'Save','on'); addOptional(p,'Format','vertical');
parse(p,varargin{:});
opts=p.Results;

% #. Number of sections
fns=fieldnames(opts);
sectionWithoutCell=~cell2mat(struct2cell(structfun(@iscell,opts,'UniformOutput',false))); % Otherwise for char input ('example'), each letter will be counted as a section
sectionNumberTemp=cell2mat(struct2cell(structfun(@numel,opts,'UniformOutput',false))); sectionNumberTemp(sectionWithoutCell)=1;
opts.number.sections=max(sectionNumberTemp(contains(fns,optsList))); % Only some options have a section format

% #. Number of arguments per section
% Each opening and ending option must have the same number of arguments.
% Therefore, the maximum number of arguments is found and a correction
% is applied for the sections with a lower number of arguments. It
% allows to defined an argument one time and apply its value to all the
% sections, or ignored an argument if the default is wanted.
opts.number.arguments.Open=zeros(1,opts.number.sections); opts.number.arguments.Close=zeros(1,opts.number.sections); % Number of arguments can be different for the opening and the closing of a section
for mode=["Open" "Close"]
    argMatrix=zeros(numel(optsList),opts.number.sections); % [option number, section number]
    for optNum=1:numel(optsList)
        if ~iscell(opts.(strcat(optsList(optNum),mode)))
            % #.#. One value for all the sections
            argMatrix(optNum,:)=1;
        else
            for sectionNum=1:opts.number.sections
                if sectionNum>numel(opts.(strcat(optsList(optNum),mode)))
                    % #.#. Unspecified value
                    argMatrix(optNum,sectionNum:end)=1; break;
                elseif ~iscell(opts.(strcat(optsList(optNum),mode)){sectionNum})
                    % #.#. One value per section
                    argMatrix(optNum,:)=1; break;
                else
                    % #.#. One value per argument
                    argMatrix(optNum,sectionNum)=numel(opts.(strcat(optsList(optNum),mode)){sectionNum});
                end
            end
        end
    end
    opts.number.arguments.(mode)=max(argMatrix,[],1);
end

% #. Format (opening/closing options)
% Some options can be defined for all the sections, for all the section, or
% for each argument. Therefore, some processing may be necessary to
% extend certain options or to apply the default value according to the case.
for mode=["Open" "Close"]
    for optNum=1:numel(optsList)
        optName=optsList{optNum};
        if ~iscell(opts.(strcat(optName,mode)))
            % #.#. One value for all the sections
            % #.#.#. Value to apply
            if isempty(opts.(strcat(optName,mode))) && ~ischar(opts.(strcat(optName,mode))) % '' is allowable
                valueSave=optsDefault{optNum};
            else
                valueSave=opts.(strcat(optName,mode));
            end
            % #.#.#. Processing
            opts.(strcat(optName,mode))=cell(1,opts.number.sections);
            for sectionNum=1:opts.number.sections
                opts.(strcat(optName,mode)){sectionNum}=repmat({valueSave},1,opts.number.arguments.(mode)(sectionNum));
            end
        else
            for sectionNum=1:opts.number.sections
                if sectionNum>numel(opts.(strcat(optsList(optNum),mode)))
                    % #.#. Unspecified value
                    % #.#.#. Value to apply
                    valueSave=optsDefault{optNum};
                    % #.#.#. Processing
                    opts.(strcat(optName,mode)){sectionNum}=repmat({valueSave},1,opts.number.arguments.(mode)(sectionNum));
                elseif ~iscell(opts.(strcat(optName,mode)){sectionNum})
                    % #.#. One value per section
                    % #.#.#. Value to apply
                    if isempty(opts.(strcat(optName,mode)){sectionNum}) && ~ischar(opts.(strcat(optName,mode)){sectionNum}) % '' is allowable
                        valueSave=optsDefault{optNum};
                    else
                        valueSave=opts.(strcat(optName,mode)){sectionNum};
                    end
                    % #.#.#. Processing
                    opts.(strcat(optName,mode)){sectionNum}=cell(1,opts.number.arguments.(mode)(sectionNum));
                    opts.(strcat(optName,mode)){sectionNum}=repmat({valueSave},1,opts.number.arguments.(mode)(sectionNum));
                else
                    for argNum=1:opts.number.arguments.(mode)(sectionNum)
                        % #.#. One value per argument
                        if argNum>numel(opts.(strcat(optName,mode)){sectionNum}) ...
                                || (isempty(opts.(strcat(optName,mode)){sectionNum}{argNum}) && ~ischar(opts.(strcat(optName,mode)){sectionNum}{argNum})) % '' is allowable
                            opts.(strcat(optName,mode)){sectionNum}{argNum}=optsDefault{optNum};
                        end
                    end
                end
            end
        end
    end
end

% #. Format (update option)
if ~iscell(opts.Update)
    % #.#. One value for all the sections
    opts.Update=repmat({{''}},1,opts.number.sections);
else
    for sectionNum=1:opts.number.sections
        if ~iscell(opts.Update{sectionNum})
            opts.Update{sectionNum}={''};
        else
            for argNum=1:numel(opts.Update{sectionNum})
                % #.#. One value per argument
                if (isempty(opts.Update{sectionNum}{argNum}) && ~ischar(opts.Update{sectionNum}{argNum})) % '' is allowable
                    opts.Update{sectionNum}{argNum}='';
                end
            end
        end
    end
end

% #. Period values
% The maximum period value for the opening option must match the
% maximum period value for the closing option
for sectionNum=1:opts.number.sections
    periodOpen=[opts.PeriodOpen{sectionNum}{:}]; periodOpenMax=max(periodOpen);
    periodClose=[opts.PeriodClose{sectionNum}{:}]; periodCloseMax=max(periodClose);
    delta=periodCloseMax-periodOpenMax;
    if delta>0
        % Periods of the opening arguments are lower
        opts.PeriodOpen{sectionNum}=num2cell(periodOpen+delta);
    elseif delta<0
        % Periods of the closing arguments are lower
        opts.PeriodClose{sectionNum}=num2cell(periodClose-delta);
    end
end

end

function linesOld=loadingText(file)
% Abstract: loads the text to analyse
if iscell(file)
    % #. Imported text
    linesOld=reshape(file,1,[]);
else
    % #. File to read
    % Determine the number of lines is mandatory for a good memory allocation.
    % However, there is no efficient way to know this number without import
    % all the file or without loop. Therefore, the file is fully imported,
    % even if in some specific cases it is not necessary and expensive.
    fileID=fopen(file); % Open the file
    %fseek(fileID, 0, 'eof'); % Go to the end of the file
    %fileSize = ftell(fileID); % Get file size.
    %frewind(fileID); % Renitialize the current line
    linesOld=splitlines(fread(fileID,inf, '*char')'); % Import each line of the file
    fclose(fileID); % Close the file
end
end

function [sectionsOld,indSections,kSectionLocal]=findsSections(linesOld,opts)
% Abstract: finds the sections in the text according to the options
% #. Initialization
linesNumber=numel(linesOld);
indSections=zeros(2,linesNumber); % Line number of the begining (1,:) and the end (2,:) of each section
mode='Open'; % Defines if the option concerns the opening or the closing of the section
kSectionGlobal=1; % takes into account the period (can be superior to the number of sections in the inputs)
kSectionLocal=[1 zeros(1,linesNumber-1)]; % does not take into account the period (less or equal to the number of sections in the inputs)
kArg=1;
if opts.StepOpen{1}{1}>0
    kLine=1-opts.StepOpen{1}{1}; % Index of the current line, starts from the first line
else
    kLine=linesNumber-opts.StepOpen{1}{1};  % Index of the current line, for a negative step for the first section and first argument, starts from the last line
end

% #. Processing
% Depending on how the conditions are implemented, the complexity of the code 
% according to the size of the text can be significant. Therefore, several
% while loop have been defined to minimize the number of conditions to
% check for a given argument. There is however still a sort of loop for
% certain conditions that requires several itterations (use of a cellfun for
% contains function because a better solution could not be found in terms 
% of computation time).
try
    while 1
        
        % #.#. Initial line step
        kLine=kLine+opts.(['Step' mode]){kSectionLocal(kSectionGlobal)}{kArg}; % i.e. if an argument is checked, the next line is read
        
        if strcmpi(opts.(['Type' mode]){kSectionLocal(kSectionGlobal)}{kArg},'strcmp')
            
            % #.#. strcmp
            if strcmpi(opts.(['CaseSensitive' mode]){kSectionLocal(kSectionGlobal)}{kArg},'on')
                % #.#.#. Case sensitive
                if strcmpi(opts.(['Logical' mode]){kSectionLocal(kSectionGlobal)}{kArg},'and')
                    % #.#.#.#. And
                    while ~all(strcmp(linesOld{kLine},opts.(['Criterion' mode]){kSectionLocal(kSectionGlobal)}{kArg}))==opts.(['True' mode]){kSectionLocal(kSectionGlobal)}{kArg}
                        kLine=kLine+opts.(['Step' mode]){kSectionLocal(kSectionGlobal)}{kArg};
                    end
                else
                    % #.#.#.#. Or
                    while ~any(strcmp(linesOld{kLine},opts.(['Criterion' mode]){kSectionLocal(kSectionGlobal)}{kArg}))==opts.(['True' mode]){kSectionLocal(kSectionGlobal)}{kArg}
                        kLine=kLine+opts.(['Step' mode]){kSectionLocal(kSectionGlobal)}{kArg};
                    end
                end
            else
                % #.#.#. Case unsensitive
                if strcmpi(opts.(['Logical' mode]){kSectionLocal(kSectionGlobal)}{kArg},'and')
                    % #.#.#.#. And
                    while ~all(strcmpi(linesOld{kLine},opts.(['Criterion' mode]){kSectionLocal(kSectionGlobal)}{kArg}))==opts.(['True' mode]){kSectionLocal(kSectionGlobal)}{kArg}
                        kLine=kLine+opts.(['Step' mode]){kSectionLocal(kSectionGlobal)}{kArg};
                    end
                else
                    % #.#.#.#. Or
                    while ~any(strcmpi(linesOld{kLine},opts.(['Criterion' mode]){kSectionLocal(kSectionGlobal)}{kArg}))==opts.(['True' mode]){kSectionLocal(kSectionGlobal)}{kArg}
                        kLine=kLine+opts.(['Step' mode]){kSectionLocal(kSectionGlobal)}{kArg};
                    end
                end
            end
            
        elseif strcmpi(opts.(['Type' mode]){kSectionLocal(kSectionGlobal)}{kArg},'contains')
            
            % #.#. contains
            if strcmpi(opts.(['CaseSensitive' mode]){kSectionLocal(kSectionGlobal)}{kArg},'on')
                % #.#.#. Case sensitive
                if strcmpi(opts.(['Logical' mode]){kSectionLocal(kSectionGlobal)}{kArg},'and')
                    % #.#.#.#. And
                    if iscell(opts.(['Criterion' mode]){kSectionLocal(kSectionGlobal)}{kArg})
                        while ~all(cellfun(@(x)contains(linesOld{kLine},x),opts.(['Criterion' mode]){kSectionLocal(kSectionGlobal)}{kArg}))==opts.(['True' mode]){kSectionLocal(kSectionGlobal)}{kArg}
                            kLine=kLine+opts.(['Step' mode]){kSectionLocal(kSectionGlobal)}{kArg};
                        end
                    else
                        while ~all(contains(linesOld{kLine},opts.(['Criterion' mode]){kSectionLocal(kSectionGlobal)}{kArg}))==opts.(['True' mode]){kSectionLocal(kSectionGlobal)}{kArg}
                            kLine=kLine+opts.(['Step' mode]){kSectionLocal(kSectionGlobal)}{kArg};
                        end
                    end
                else
                    % #.#.#.#. Or
                    if iscell(opts.(['Criterion' mode]){kSectionLocal(kSectionGlobal)}{kArg}) % Several conditions to check
                        while ~any(cellfun(@(x)contains(linesOld{kLine},x),opts.(['Criterion' mode]){kSectionLocal(kSectionGlobal)}{kArg}))==opts.(['True' mode]){kSectionLocal(kSectionGlobal)}{kArg}
                            kLine=kLine+opts.(['Step' mode]){kSectionLocal(kSectionGlobal)}{kArg};
                        end
                    else % 1 condition to check
                        while ~any(contains(linesOld{kLine},opts.(['Criterion' mode]){kSectionLocal(kSectionGlobal)}{kArg}))==opts.(['True' mode]){kSectionLocal(kSectionGlobal)}{kArg}
                            kLine=kLine+opts.(['Step' mode]){kSectionLocal(kSectionGlobal)}{kArg};
                        end
                    end
                end
            else
                % #.#.#. Case unsensitive
                if strcmpi(opts.(['Logical' mode]){kSectionLocal(kSectionGlobal)}{kArg},'and')
                    % #.#.#.#. And
                    if iscell(opts.(['Criterion' mode]){kSectionLocal(kSectionGlobal)}{kArg})
                        while ~all(cellfun(@(x)contains(lower(linesOld{kLine}),x),lower(opts.(['Criterion' mode]){kSectionLocal(kSectionGlobal)}{kArg})))==opts.(['True' mode]){kSectionLocal(kSectionGlobal)}{kArg}
                            kLine=kLine+opts.(['Step' mode]){kSectionLocal(kSectionGlobal)}{kArg};
                        end
                    else
                        while ~all(contains(lower(linesOld{kLine}),lower(opts.(['Criterion' mode]){kSectionLocal(kSectionGlobal)}{kArg})))==opts.(['True' mode]){kSectionLocal(kSectionGlobal)}{kArg}
                            kLine=kLine+opts.(['Step' mode]){kSectionLocal(kSectionGlobal)}{kArg};
                        end
                    end
                else
                    % #.#.#.#. Or
                    if iscell(opts.(['Criterion' mode]){kSectionLocal(kSectionGlobal)}{kArg}) % Several conditions to check
                        while ~any(cellfun(@(x)contains(lower(linesOld{kLine}),x),lower(opts.(['Criterion' mode]){kSectionLocal(kSectionGlobal)}{kArg})))==opts.(['True' mode]){kSectionLocal(kSectionGlobal)}{kArg}
                            kLine=kLine+opts.(['Step' mode]){kSectionLocal(kSectionGlobal)}{kArg};
                        end
                    else % 1 condition to check
                        while ~any(contains(lower(linesOld{kLine}),lower(opts.(['Criterion' mode]){kSectionLocal(kSectionGlobal)}{kArg})))==opts.(['True' mode]){kSectionLocal(kSectionGlobal)}{kArg}
                            kLine=kLine+opts.(['Step' mode]){kSectionLocal(kSectionGlobal)}{kArg};
                        end
                    end
                end
            end
            
        elseif strcmpi(opts.(['Type' mode]){kSectionLocal(kSectionGlobal)}{kArg},'empty')
            
            % #.#. empty
            while ~isempty(erase(linesOld{kLine},' '))==opts.(['True' mode]){kSectionLocal(kSectionGlobal)}{kArg}
                kLine=kLine+opts.(['Step' mode]){kSectionLocal(kSectionGlobal)}{kArg};
            end
            
        elseif strcmpi(opts.(['Type' mode]){kSectionLocal(kSectionGlobal)}{kArg},'numeric')
            
            % #.#. numeric
            while any(isnan(str2double(split(linesOld{kLine}))))==opts.(['True' mode]){kSectionLocal(kSectionGlobal)}{kArg}
                kLine=kLine+opts.(['Step' mode]){kSectionLocal(kSectionGlobal)}{kArg};
            end
            
        elseif strcmpi(opts.(['Type' mode]){kSectionLocal(kSectionGlobal)}{kArg},'shift')
            
            % #.#. shift
            kLine=kLine+opts.(['Criterion' mode]){kSectionLocal(kSectionGlobal)}{kArg}-opts.(['Step' mode]){kSectionLocal(kSectionGlobal)}{kArg}; % For the shift option, initial line step is ignored
            
        end
        
        % #.#. Period
        opts.(strcat('Period',mode)){kSectionLocal(kSectionGlobal)}{kArg}=opts.(strcat('Period',mode)){kSectionLocal(kSectionGlobal)}{kArg}-1;
        
        % #.#. Next step
        while 1
            kArg=kArg+1;
            % #.#.#. Section processing
            if kArg>opts.number.arguments.(mode)(kSectionLocal(kSectionGlobal))
                kArg=1;
                if strcmp(mode,'Open')
                    % #.#.#.#. A section is opened
                    indSections(1,kSectionGlobal)=kLine;
                    mode='Close';
                else
                    % #.#.#.#. A section is closed
                    indSections(2,kSectionGlobal)=kLine;
                    mode='Open';
                    while 1
                        % #.#.#.#.#. New section
                        kSectionGlobal=kSectionGlobal+1;
                        if kSectionLocal(kSectionGlobal-1)==opts.number.sections
                            kSectionLocal(kSectionGlobal)=1;
                        else
                            kSectionLocal(kSectionGlobal)=kSectionLocal(kSectionGlobal-1)+1;
                        end
                        % #.#.#.#.#. Active section
                        % Otherwise, inactive sections (period=0) will save the current line
                        if any([opts.PeriodOpen{kSectionLocal(kSectionGlobal)}{:}]>0) ... % If the opening is active, the closing is necessarily active
                                || all(cellfun(@(x)all(x==0),[opts.PeriodClose{:}])) % If no section is active
                           break;
                        end
                    end
                end
            end
            % #.#.#. Active step
            if opts.(strcat('Period',mode)){kSectionLocal(kSectionGlobal)}{kArg}>0 % Argument is still active
                break;
            elseif all(cellfun(@(x)all(x==0),[opts.PeriodClose{:}])) % All the sections are found
                plus; % Create an error to leave the upper loop
            end
            
        end
        
    end
    
catch
    
    % #. All the sections are found or exceed the boundaries of the text
    if strcmpi(mode,'close')
        % If the section could not be closed, the last readed
        % line is considered as the end of the current section
        indSections(2,kSectionGlobal)=kLine-opts.(['Step' mode]){kSectionLocal(kSectionGlobal)}{kArg};
    end
    
end

% #. Export the sections
% #.#. Indices
indToDelete=indSections(1,:)==0 | indSections(2,:)==0;
indSections(:,indToDelete)=[];
kSectionLocal(indToDelete)=[];
% #.#. Sort
indSections=sort(indSections); % According to the sign of the step, the lower limit can be in 1st or 2nd row
% #.#. Extract lines
sectionsOld=cell(size(indSections,2),1);
for sectionNum=1:size(indSections,2)
    sectionsOld{sectionNum}=linesOld(indSections(1,sectionNum):indSections(2,sectionNum));
end

end

function [sectionsNew,linesNew]=updatesSections(sectionsOld,indSections,kSectionLocal,linesOld,opts)
% Abstract: updates the sections according to the options
% #. Initialization
sectionsNew=sectionsOld;

% #. No change to apply
if all(cellfun(@isempty,[opts.Update{:}])) || isempty(sectionsOld)
    linesNew=linesOld; return;
end

% #. Processing
for kSectionGlobal=1:numel(kSectionLocal)
    
    for argNum=1:numel(opts.Update{kSectionLocal(kSectionGlobal)})
        
        update=opts.Update{kSectionLocal(kSectionGlobal)}{argNum};
        
        % #.#. No change to apply
        if isempty(update)
            continue;
        end
        
        % #.#. Mode
        switch numel(update)+strcmpi(update{1},'delete') % Delete option does not have a change cell
            case 2
                mode=1; % section change
            case 3
                mode=2; % lines change
            case 4
                mode=3; % words change
        end
        
        % #.#. Numeric change
        % An increment is performed and therefore each word must be readed
        if ~strcmpi(update{1},'delete') && isnumeric(update{end})
            if mode==1 % Every word in every line must be checked
                update{4}=update{2}; update{3}='all'; update{2}='all';
            elseif mode==2 % Every word in the selected lines must be checked
                update{4}=update{3}; update{3}='all';
            end
            mode=3;
        end
        
        % #.#. Lines to change
        if mode>=2
            % #.#.#. Char index
            if ~isnumeric(update{2})
                if strcmpi(update{2},'all') % 'all' lines
                    update{2}=1:numel(sectionsNew{kSectionGlobal});
                elseif contains(update{2},'end') % 'end' line
                    update{2}=eval(replace(update{2},num2str(numel(sectionsNew{kSectionGlobal}))));
                end
            end
            % #.#.#. linesToChange
            if isnumeric(update{2}) % Line index
                linesToChange=update{2};
                linesToChange(linesToChange>numel(sectionsNew{kSectionGlobal}))=[]; % Boundaries
            else % Char input
                linesToChange=find(contains(sectionsNew{kSectionGlobal},update{2}));
            end
            linesToChange=sort(unique(linesToChange));
        else
            linesToChange=1:numel(sectionsNew{kSectionGlobal});
        end
        if isempty(linesToChange)
            continue;
        end
        
        % #.#. Format of the change
        % Avoid some concatenation issues
        if iscell(update{end})
            if mode==3
                if ~isnumeric(update{end}{1})
                    update{end}=strjoin(update{end}); % {'an' 'example'} -> 'an example'
                else
                    update{end}=update{end}{1};
                end
            end
        else
            if mode<3
                update{end}=update(end);
            end
        end
        
        % #.#. Apply changes
        
        if mode==1 % Change sections
            
            if strcmpi(update{1},'assign')
                sectionsNew{kSectionGlobal}=update{end};
            elseif strcmpi(update{1},'assignBefore') ...
                    || strcmpi(update{1},'addBefore')
                sectionsNew{kSectionGlobal}=[update{end} ; sectionsNew{kSectionGlobal}];
            elseif strcmpi(update{1},'assignAfter') ...
                    || strcmpi(update{1},'addAfter')
                sectionsNew{kSectionGlobal}=[sectionsNew{kSectionGlobal} ; update{end}];
            elseif strcmpi(update{1},'delete')
                sectionsNew{kSectionGlobal}={};
            end
            
        elseif mode==2 % Change lines
            
            sizeNew=numel(sectionsNew{kSectionGlobal}); % Initialization
            for kLine=1:numel(linesToChange)
                lineNum=linesToChange(kLine);
                sizeOld=sizeNew;
                if strcmpi(update{1},'assign')
                    sectionsNew{kSectionGlobal}=[sectionsNew{kSectionGlobal}(1:lineNum-1) ; update{end} ; sectionsNew{kSectionGlobal}(lineNum+1:end)];
                elseif strcmpi(update{1},'assignBefore')
                    sectionsNew{kSectionGlobal}=[update{end} ; sectionsNew{kSectionGlobal}(lineNum:end)];
                elseif strcmpi(update{1},'assignAfter')
                    sectionsNew{kSectionGlobal}=[sectionsNew{kSectionGlobal}(1:lineNum) ; update{end}];
                elseif strcmpi(update{1},'addBefore')
                    sectionsNew{kSectionGlobal}=[sectionsNew{kSectionGlobal}(1:lineNum-1) ; update{end} ; sectionsNew{kSectionGlobal}(lineNum:end)];
                elseif strcmpi(update{1},'addAfter')
                    sectionsNew{kSectionGlobal}=[sectionsNew{kSectionGlobal}(1:lineNum) ; update{end} ; sectionsNew{kSectionGlobal}(lineNum+1:end)];
                elseif strcmpi(update{1},'delete')
                    sectionsNew{kSectionGlobal}=[sectionsNew{kSectionGlobal}(1:lineNum-1) ; sectionsNew{kSectionGlobal}(lineNum+1:end)];
                end
                sizeNew=numel(sectionsNew{kSectionGlobal});
                linesToChange=linesToChange+sizeNew-sizeOld; % Indices are changing
            end
            
        elseif mode==3 % Change words
            
            for lineNum=linesToChange
                
                % #.#.#. Empty line
                if isempty(sectionsNew{kSectionGlobal}{lineNum})
                    continue; % Do nothing
                end
                    
                % #.#.#. Words to change  
                if isnumeric(update{3}) || contains(update{3},'end') || strcmpi(update{3},'all') % Word index
                    % #.#.#.#. Words available  
                    % indSpaces=~isstrprop(sectionsNew{sectionRealNum}{lineNum},'digit'); Disable because it does not work well with exponential notation
                    indSpaces=sectionsNew{kSectionGlobal}{lineNum}==sprintf('\t') | sectionsNew{kSectionGlobal}{lineNum}==sprintf(' '); % Indexes of each tab and space
                    indSpacesOpenTemp=find([indSpaces(1:end-1)~=indSpaces(2:end) false] & indSpaces); % For several spaces in a row, the word starts right after the last space
                    indSpacesCloseTemp=find([false indSpaces(2:end)~=indSpaces(1:end-1)] & indSpaces); % For several spaces in a row, the word ends just before the first space
                    if indSpaces(1)==0
                        indSpacesOpen=[0 indSpacesOpenTemp]; % The first word is not positioned after a space e.g. 'abc d '
                    else
                        indSpacesOpen=indSpacesOpenTemp; % The first word is positioned after a space e.g. ' abc d '
                    end
                    if indSpaces(end)==0
                        indSpacesClose=[indSpacesCloseTemp numel(sectionsNew{kSectionGlobal}{lineNum})+1]; % The last word is not positioned before a space e.g. ' abc d'
                    else
                        indSpacesClose=indSpacesCloseTemp; % The last word is positioned before a space e.g. ' abc d '
                    end
                    wordsAvailable=[indSpacesOpen+1 ; indSpacesClose-1]; % Index of the words and not the spaces (->+1)
                    % #.#.#.#. Char index
                    if ~isnumeric(update{3})
                        if strcmpi(update{3},'all') % 'all' words
                            update{3}=wordsAvailable;
                        elseif contains(update{3},'end') % 'end' word
                            update{3}=eval(replace(update{3},num2str(wordsAvailable(end))));
                        end
                    end
                    % #.#.#.#. Processing
                    wordsToChange=update{3};
                    wordsToChange(wordsToChange>size(wordsAvailable,2))=[]; % To avoid input greater than words number
                    wordsToChange=wordsAvailable(:,wordsToChange);
                else % Char input
                    wordsToChangeTemp=strfind(sectionsNew{kSectionGlobal}{lineNum},update{3});
                    wordsToChange=[wordsToChangeTemp ; wordsToChangeTemp+numel(update{3})-1]; % strfind gives the index of the first char
                end
                
                % #.#.#. Intersection removal
                % Avoid conflicts (e.g. if '%%' is search and the line is '%%%', 
                % it will be find twice but only one can be change without change the other)
                if size(wordsToChange,2)>1
                    wordsToChange(:,[false wordsToChange(1,2:end)<=wordsToChange(2,1:end-1)])=[]; 
                    wordsToChange=sortrows(wordsToChange')'; % ascending order
                end
                if isempty(wordsToChange)
                    continue;
                end
                
                % #.#.#. Processing
                sizeNew=numel(sectionsNew{kSectionGlobal}{lineNum}); % Initialization
                for wordNum=1:size(wordsToChange,2)
                    sizeOld=sizeNew;
                    if isnumeric(update{end}) % Numeric change
                        oldValue=str2double(sectionsNew{kSectionGlobal}{lineNum}(wordsToChange(1,wordNum):wordsToChange(2,wordNum)));
                        if ~isnan(oldValue)
                            % Update
                            newValue=num2str(oldValue+update{end});
                            sectionsNew{kSectionGlobal}{lineNum}=[sectionsNew{kSectionGlobal}{lineNum}(1:wordsToChange(1,wordNum)-1)  newValue  sectionsNew{kSectionGlobal}{lineNum}(wordsToChange(2,wordNum)+1:end)];
                            % Indices
                            wordsToChange=wordsToChange-(wordsToChange(2,wordNum)-wordsToChange(1,wordNum)+1)+numel(newValue);
                        end
                    else % Char change
                        if strcmpi(update{1},'assign')
                            sectionsNew{kSectionGlobal}{lineNum}=[sectionsNew{kSectionGlobal}{lineNum}(1:wordsToChange(1,wordNum)-1) update{end} sectionsNew{kSectionGlobal}{lineNum}(wordsToChange(2,wordNum)+1:end)];
                        elseif strcmpi(update{1},'assignBefore')
                            sectionsNew{kSectionGlobal}{lineNum}=[update{end} sectionsNew{kSectionGlobal}{lineNum}(wordsToChange(1,wordNum):end)];
                        elseif strcmpi(update{1},'assignAfter')
                            sectionsNew{kSectionGlobal}{lineNum}=[sectionsNew{kSectionGlobal}{lineNum}(1:wordsToChange(2,wordNum)) update{end}];
                        elseif strcmpi(update{1},'addBefore')
                            sectionsNew{kSectionGlobal}{lineNum}=[sectionsNew{kSectionGlobal}{lineNum}(1:wordsToChange(1,wordNum)-1) update{end} sectionsNew{kSectionGlobal}{lineNum}(wordsToChange(1,wordNum):end)];
                        elseif strcmpi(update{1},'addAfter')
                            sectionsNew{kSectionGlobal}{lineNum}=[sectionsNew{kSectionGlobal}{lineNum}(1:wordsToChange(2,wordNum)) update{end} sectionsNew{kSectionGlobal}{lineNum}(wordsToChange(2,wordNum)+1:end)];
                        elseif strcmpi(update{1},'delete')
                            % A specific correction is applied to remove multiple spaces
                            % e.g. 'Hello world !', if world is removed it gives 'Hello  !' instead of 'Hello !'
                            if wordsToChange(2,wordNum)==sizeOld
                                % If it is the last word, the spaces before the word need to be removed
                                % e.g. 'Hello world !' -> 'Hello world' instead of 'Hello world '
                                shift=-1*[find(flip(~(sectionsNew{kSectionGlobal}{lineNum}(1:wordsToChange(1,wordNum)-1)==sprintf('\t') | sectionsNew{kSectionGlobal}{lineNum}(1:wordsToChange(1,wordNum)-1)==sprintf(' '))),1,'first')-1 0]; % Find the first non empty char before the word
                            else
                                % Arbitrary choice: the spaces after the word are removed
                                shift=[0 find(~(sectionsNew{kSectionGlobal}{lineNum}(wordsToChange(2,wordNum)+1:end)==sprintf('\t') | sectionsNew{kSectionGlobal}{lineNum}(wordsToChange(2,wordNum)+1:end)==sprintf(' ')),1,'first')-1]; % Find the first non empty char after the word
                            end
                            if numel(shift)~=2
                                shift=[0 0];
                            end
                            sectionsNew{kSectionGlobal}{lineNum}=[sectionsNew{kSectionGlobal}{lineNum}(1:wordsToChange(1,wordNum)-1+shift(1)) sectionsNew{kSectionGlobal}{lineNum}(wordsToChange(2,wordNum)+1+shift(2):end)];
                        end
                    end
                    sizeNew=numel(sectionsNew{kSectionGlobal}{lineNum});
                    wordsToChange=wordsToChange+sizeNew-sizeOld; % Indices are changing as the section has changed
                end
                
            end
        end
        
    end
end

% #. Lines new
% #.#. Initialization
linesModified=cell(1,numel(sectionsNew));
linesUnmodified=cell(1,numel(sectionsNew)+1);
% #.#. Modified lines
for kSectionGlobal=1:numel(sectionsNew)
    linesModified{kSectionGlobal}=sectionsNew{kSectionGlobal}';
end
% #.#. Unmodified lines
linesUnmodified{1}=linesOld(1:indSections(1,1)-1)';
for i=2:numel(sectionsNew)
    linesUnmodified{i}=linesOld(indSections(2,i-1)+1:indSections(1,i)-1)';
end
linesUnmodified{end}=linesOld(indSections(2,end)+1:end)';
% #.#. Concat
linesNew=[linesUnmodified(1) reshape([linesModified ; linesUnmodified(2:end)],1,[])];
linesNew=[linesNew{:}]';

end

function updatesFile(file,linesOld,linesNew,opts)
% Abstract: applies the changes to the file
% #. No change to apply
if ~strcmpi(opts.Save,'on') ...
        || iscell(file) ... % Input is not a file
        || all(cellfun(@isempty,[opts.Update{:}])) ...
        || isequal(linesOld,linesNew)
    return;
end

% #. Writting
fileID=fopen(file,'w');
fwrite(fileID,strjoin(linesNew,'\n'));
fclose(fileID);

end