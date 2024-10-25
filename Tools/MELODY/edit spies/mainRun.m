%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                            SPIES selection tool                       %%
%%                         Last update: July 31, 2024                    %%
%%                               Kévin Daigne                            %%
%%                         kevin.daigne@hotmail.fr                       %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract - 
% Adds a potentially large number of spies from a graphical selection
%% -

% #. Inputs
tabNumber=findTab(app);
pathSimu=app.TabGroup.Children(tabNumber).Children(app.id.gridTabNumber).Children(app.id.gridProcessingNumber).Children(app.id.SAVEPanelNumber).Children(app.id.gridSaveNumber).Children(app.id.displayPathNumber).Value;

% #. Node selection
[body,nodeGlob,nodeLoc]=graphSelection(app,tabNumber,[],[],[],1);
if isempty(body) || isempty(nodeGlob) || isempty(nodeLoc)
    busyOff(app); return;
else
    nodeGlob=nodeGlob-1; nodeLoc=nodeLoc-1; % First index is 0 and not 1
end

% #. Changes
spiesSections=spiesEditor(pathSimu,body,nodeGlob,nodeLoc);
if isempty(spiesSections)
    return;
end

% #. Log
% #.#. MSG
if isscalar(spiesSections)
    spiesLog=[spiesSections{:}];
else
    spiesLog=reshape([strcat('#.#.',{' '},cellfun(@num2str,num2cell(1:numel(spiesSections)),'UniformOutput',false)) ; spiesSections],1,[]); % For several sections, the section number is specified
    spiesLog=[spiesLog{:}];
end
% #.#. Processing
if ~exist([pathSimu filesep 'SAVE'],'dir')
    mkdir([pathSimu filesep 'SAVE']);
end
[~,~]=LogSave(spiesLog,{''},'One or several spies have been added:',[pathSimu filesep 'SAVE' filesep 'LOG_save.log']);

% #. Update GUI
processingEditedText(app,tabNumber,0);

function spiesSections=spiesEditor(pathSimu,body,nodeGlob,nodeLoc)
% Abstract: processing of spies creation

spiesSections={};

% #. Input
% #.#. List of SPIES types
listSpies={'Position' 'Displacement' 'Velocity' 'Acceleration' 'Force' 'Jacobian body node' 'Stress' 'Contact' 'Damage' 'Energy' 'Work' 'Error' 'MassScaling' 'Polar' 'Property'};
% #.#. List of associated arguments
listArgument{1}={'X' 'Y' 'R' 'AllX' 'AllY'};
listArgument{2}={'X' 'Y' 'R' 'Mag'};
listArgument{3}={'X' 'Y' 'R' 'Mag'};
listArgument{4}={'X' 'Y' 'R' 'Mag'};
listArgument{5}={'X' 'Y' 'R' 'Mag'};
listArgument{6}={''};
listArgument{7}={'XX' 'YY' 'XY' 'ZZ' 'Tresca' 'VM' 'Major' 'Intermediate' 'Minor' 'Spherical'};
listArgument{8}={'Gapn' 'Gapt' 'Xsi' 'Xnorm' 'Ynorm' 'Damage' 'Fx' 'Fy' 'Length' 'Master' 'Px' 'Py' 'Slave' 'Xslave' 'Yslave'};
listArgument{9}={'Initial' 'Current' 'Relative'};
listArgument{10}={'Kinetic' 'Deformation'};
listArgument{11}={'Internal' 'Contact' 'Body' 'Dirichlet' 'Neumann' 'Damping' 'Alid'};
listArgument{12}={'X' 'Y' 'Mag' 'Norm' 'Max'};
listArgument{13}={'X' 'Y' 'Moy' 'dX' 'dY' 'dMoy' 'Xmass' 'Ymass' 'Mass'};
listArgument{14}={'Contact_Normal' 'Force_Direction' 'Compressive_Contact_Normal' 'Compressive_Force_Direction' 'Tensile_Contact_Normal' 'Tensile_Force_Direction'};
listArgument{15}={'Status' 'Type' 'Active_Contacts' 'Contacting_Bodies' 'Length' 'LengthInContact' 'Area' 'Temperature'};
% #.#. Information on existing spies
arrayInfo=MelodyArrayInfo(pathSimu);

% #. Initialization
nameNewSpies{1}='';

% #. Loop over each selected point
for spiesNum=1:numel(nodeLoc)

    waitfor(msgbox(['BODY ' num2str(body(spiesNum)) ' - Local node ' num2str(nodeLoc(spiesNum)) ' - Global node ' num2str(nodeGlob(spiesNum))],'Information','help'));

    % #.#. Name definition
    while 1
        % #.#.#. Find a free default number
        k=1;
        while 1
            nameDefault=['MELODYOutput' sprintf('%01d',k)];
            if isempty(find(ismember(arrayInfo.nameArrayCell,nameDefault),1)) && isempty(find(ismember(nameNewSpies, nameDefault),1))
                % #.#.#.#. If the name is not taken, it is kept
                % Must be compared with existing names and new ones to be created
                break;
            end
            k=k+1;
        end
        % #.#.#. The user enters a name
        nameNewSpiesTemp=inputdlg('Name of the spies:',' ',1,{nameDefault}); % Name selection
        % #.#.#. Checks if the name is not already taken
        if ~isempty(nameNewSpiesTemp)
            if isempty(find(ismember(arrayInfo.nameArrayCell,nameNewSpiesTemp{1}),1)) && isempty(find(ismember(nameNewSpies,nameNewSpiesTemp{1}),1))
                % #.#.#.#. If the name is not taken, it is kept
                % Must be compared with existing names and new ones to be created
                nameNewSpies{spiesNum}=nameNewSpiesTemp{1};
                break;
            else
                % #.#.#.#. If the name is taken, restart the loop.
                waitfor(msgbox('This name already exist.','Information','help'));
            end
        else
            % #.#.#.#. If the user cancels the selection
            return;
        end
    end

    % #.#. Time step definition
    if ~isempty(arrayInfo.DTArrayVect)
        dtDefault=num2str(arrayInfo.DTArrayVect(end));
    else
        dtDefault='1e0';
    end
    timeStepSpies=inputdlg('Time step:',' ',1,{dtDefault});
    if isempty(timeStepSpies)==1 || isnan(str2double(timeStepSpies))
        return;
    end

    % #.#. Type selection
    [indxSpies,~] = listdlg('PromptString',{'Select the output:'},'listString',listSpies,'SelectionMode','single');
    if isempty(indxSpies)
        return;
    end

    % #.#. Selection of arguments
    % Different arguments for different cases
    if indxSpies==1 || indxSpies || indxSpies==3 || indxSpies==4 || indxSpies==7
        % #.#.#. 1 Position 2 Displacement 3 Velocity 4 Acceleration 7 Stress
        ittNum=0; indxArgTemp=0;
        while ~isempty(indxArgTemp)
            if ittNum==0 % To change cancel to end after a selection because listdlg to infinity
                [indxArgTemp,~] = listdlg('PromptString',{'Select the argument (1/2):'},'listString',listArgument{indxSpies},'SelectionMode','single');
            else
                [indxArgTemp,~] = listdlg('PromptString',{'Select the argument (1/2):'},'listString',listArgument{indxSpies},'CancelString','End','SelectionMode','single');
            end
            if ~isempty(indxArgTemp)
                ittNum=ittNum+1;
                indxArg(ittNum)=indxArgTemp;
                [indxloc,~] = listdlg('PromptString',{'Select the argument (2/2):'},'listString',{'BODY' 'NODE'},'SelectionMode','single');
                if indxloc==1
                    spiesSections{spiesNum}{ittNum+1}=[listSpies{indxSpies} ' ' listArgument{indxSpies}{indxArg(ittNum)} ' ' '<body>' ' ' '-1'];
                elseif indxloc==2
                    spiesSections{spiesNum}{ittNum+1}=[listSpies{indxSpies} ' ' listArgument{indxSpies}{indxArg(ittNum)} ' ' '<body>' ' ' '<node>'];
                else
                    return;
                end
            elseif ittNum==0
                return;
            end
        end
        spiesSections{spiesNum}{1}=[nameNewSpies{spiesNum} ' ' num2str(numel(indxArg)) ' ' timeStepSpies{1}];
    elseif indxSpies==5
        % #.#.#. 5 Force
        ittNum=0; indxArgTemp=0;
        while ~isempty(indxArgTemp)
            if ittNum==0 % To change cancel to end after a selection because listdlg to infinity
                [indxArgTemp,~] = listdlg('PromptString',{'Select the argument (1/3):'},'listString',listArgument{indxSpies},'SelectionMode','single');
            else
                [indxArgTemp,~] = listdlg('PromptString',{'Select the argument (1/3):'},'listString',listArgument{indxSpies},'CancelString','End','SelectionMode','single');
            end
            if ~isempty(indxArgTemp)
                ittNum=ittNum+1;
                indxArg(ittNum)=indxArgTemp;
                listArg2={'Total' 'Internal' 'Contact' 'Body' 'Dirichlet' 'Neumann' 'Damping'};
                [indxarg2,~] = listdlg('PromptString',{'Select the argument (2/3):'},'listString',listArg2,'SelectionMode','single');
                if isempty(indxarg2)==1
                    return;
                end
                [indxloc,~] = listdlg('PromptString',{'Select the argument (3/3):'},'listString',{'BODY' 'NODE'},'SelectionMode','single');
                if indxloc==1
                    spiesSections{spiesNum}{ittNum+1}=[listSpies{indxSpies} ' ' listArgument{indxSpies}{indxArg(ittNum)} ' ' listArg2{indxarg2} ' ' '<body>' ' ' '-1'];
                elseif indxloc==2
                    spiesSections{spiesNum}{ittNum+1}=[listSpies{indxSpies} ' ' listArgument{indxSpies}{indxArg(ittNum)} ' ' '<body>' ' ' '<node>'];
                else
                    return;
                end
            elseif ittNum==0
                return;
            end
        end
        spiesSections{spiesNum}{1}=[nameNewSpies{spiesNum} ' ' num2str(numel(indxArg)) ' ' timeStepSpies{1}];
    elseif indxSpies==6
        % #.#.#. 6 Jacobian
        spiesSections{spiesNum}{1}=[nameNewSpies{spiesNum} ' ' num2str(numel(indxArg)) ' ' timeStepSpies{1}];
        spiesSections{spiesNum}{2}=[listSpies{indxSpies} ' ' '<body>' ' ' '<node>'];
    elseif indxSpies==10 || indxSpies==11
        %  #.#.#. 10 Energy   11 Work
        [indxArg,~] = listdlg('PromptString',{'Select the argument (1/2):'},'listString',listArgument{indxSpies},'SelectionMode','single');
        if isempty(indxArg)==1
            return;
        end
        [indxloc,~] = listdlg('PromptString',{'Select the argument (2/2):'},'listString',{'body' '-1'},'SelectionMode','single');
        if isempty(indxloc)==1
            return;
        end
        if indxloc==1
            spiesSections{spiesNum}{2}=[listSpies{indxSpies} ' ' listArgument{indxSpies}{indxArg} ' ' listArg2{indxarg2} ' ' '<body>'];
        else
            spiesSections{spiesNum}{2}=[listSpies{indxSpies} ' ' listArgument{indxSpies}{indxArg} ' ' '-1'];
        end
        spiesSections{spiesNum}{1}=[nameNewSpies{spiesNum} ' ' num2str(numel(indxArg)) ' ' timeStepSpies{1}];
    elseif indxSpies==11 || indxSpies==12
        % #.#.#. 11 error   12 MassScaling
        [indxArg,~] = listdlg('PromptString',{'Select the argument (1/1):'},'listString',listArgument{indxSpies},'SelectionMode','single');
        if isempty(indxArg)==1
            return;
        end
        spiesSections{spiesNum}{2}=[listSpies{indxSpies} ' ' listArgument{indxSpies}{indxArg} ' ' '<body>' '<node>'];
        spiesSections{spiesNum}{1}=[nameNewSpies{spiesNum} ' ' num2str(numel(indxArg)) ' ' timeStepSpies{1}];
    elseif indxSpies==9 || indxSpies==15
        % #.#.#. 9 Damage 15 Property
        [indxArg,~] = listdlg('PromptString',{'Select the argument (1/1):'},'listString',listArgument{indxSpies},'SelectionMode','single');
        if isempty(indxArg)==1
            return;
        end
        spiesSections{spiesNum}{2}=[listSpies{indxSpies} ' ' listArgument{indxSpies}{indxArg} ' ' '<body>'];
        spiesSections{spiesNum}{1}=[nameNewSpies{spiesNum} ' ' num2str(numel(indxArg)) ' ' timeStepSpies{1}];
    elseif or(indxSpies==8,indxSpies==14)==1
        % #.#.#. 8 Contact 14 Polar
        msgbox('not available','Information','help');
        return
    end

    % #.#.#. Proposed application of these parameters to all SPIES
    if spiesNum==1 && numel(nodeLoc)>1
        answer=questdlg('Do you want to apply these parameters for all the selected points?','Warning','Yes','No','No');
        if strcmp(answer,'Yes')
            % #.#.#.#. Duplicating results
            spiesSections=repmat(spiesSections,1,numel(nodeLoc));
            % #.#.#.#. Changing names
            k=0;
            for spiesNumTemp=2:numel(nodeLoc)
                if all(~contains(spiesSections{spiesNum}(2:end),'<node>')) && body(spiesNumTemp)==body(spiesNum)
                    spiesSections{spiesNumTemp}={''}; continue; % avoids duplicates (e.g. spies average on a body but several nodes were selected)
                end
                while 1
                    k=k+1;
                    nameDefault=['MELODYOutput' sprintf('%01d',k)];
                    if isempty(find(ismember(arrayInfo.nameArrayCell, nameDefault),1)) && isempty(find(ismember(nameNewSpies, nameDefault),1))
                        % #.#.#.#.#. If the name is not taken, it is kept
                        % Must be compared with existing names and new ones to be created
                        break;
                    end
                end
                lineSplit=strsplit(spiesSections{spiesNumTemp}{1,1},' ');
                spiesSections{spiesNumTemp}{1,1}=[nameDefault ' ' lineSplit{1,2} ' ' lineSplit{1,3}];
            end
            break;
        end
    end
end

% #. Change <body> and <node> to values
% Not set directly, as easier to process if
% the same set of parameters is applied to all note
for spiesNum=1:numel(nodeLoc)
    spiesSections{spiesNum}=cellfun(@(x) replace(x,'<body>',num2str(body(spiesNum))),spiesSections{1,spiesNum},'UniformOutput',false);
    spiesSections{spiesNum}=cellfun(@(x) replace(x,'<node>',num2str(nodeLoc(spiesNum))),spiesSections{1,spiesNum},'UniformOutput',false);
    if spiesNum>1 && numel(spiesSections{spiesNum})>1
        ind=ismember(spiesSections{spiesNum},[spiesSections{1:spiesNum-1}]);
        spiesSections{spiesNum}(ind)=[]; % removes duplicates (e.g. spies average on a body but several nodes were selected); the criterion becore could not take in account -1 and <nodes> in the same spies
    end
end
indToRemove=cellfun(@numel,spiesSections)<=1;
spiesSections(indToRemove)=[]; % empty or only name

% #. Writing SPIES in STATIC_CONTROL
pathStatic=[pathSimu filesep 'CODE' filesep 'STATIC_CONTROL.asc'];

% #.#. Saving unmodified sections
fileID = fopen(pathStatic);
dataSave=[];
% #.#.#. Previous section
while 1
    dataSave{end+1}=fgetl(fileID);
    % We find the location of the SPIES section and save the correct
    % number of lines according to the different numbers entered
    if strcmp(dataSave{end},'SPIES')
        dataSave{end+1}=num2str(str2double(fgetl(fileID))+numel(spiesSections)); % Number of SPIES to be modified
        dataSave{end+1}=fgetl(fileID);
        while isempty(strip(dataSave{end}))
            dataSave{end+1}=fgetl(fileID); % Find next step
            if feof(fileID)==1
                msgbox('Cannot found SPIES part in STATIC_CONTROL.','Warning','warn');
                fclose(fileID);
                return;
            end
        end
        for i=1:arrayInfo.arrayNumber % Number of SPIES
            while ~isempty(strip(dataSave{end}))
                dataSave{end+1}=fgetl(fileID); % Space between each SPIES
                if feof(fileID)==1
                    msgbox('Cannot found SPIES part in STATIC_CONTROL.','Warning','warn');
                    fclose(fileID);
                    return;
                end
            end
            if i~=arrayInfo.arrayNumber
                while isempty(strip(dataSave{end}))
                    dataSave{end+1}=fgetl(fileID); % Find next step
                    if feof(fileID)==1
                        msgbox('Cannot found SPIES part in STATIC_CONTROL.','Warning','warn');
                        fclose(fileID);
                        return;
                    end
                end
            end
        end
        break;
    end
    if feof(fileID)==1
        msgbox('Cannot found SPIES part in STATIC_CONTROL.','Warning','warn');
        fclose(fileID);
        return;
    end
end
% #.#.#. Next section
buffer = fread(fileID, Inf) ;
fclose(fileID);

% #.#. Writting
fileID = fopen(pathStatic,'w');
% #.#.#.#. Previous section
for lineNum=1:numel(dataSave)-1
    fwrite(fileID,dataSave{lineNum});
    fwrite(fileID,newline);
end
% #.#.#.#. Modified section
fwrite(fileID,newline);
for spiesNum=1:numel(spiesSections)
    for argumentNum=1:numel(spiesSections{spiesNum})
        fwrite(fileID,spiesSections{spiesNum}{argumentNum});
        fwrite(fileID,newline);
    end
    fwrite(fileID,newline);
end
fwrite(fileID,newline);
% #.#.#.#. Next section
fwrite(fileID, buffer) ;
fclose(fileID);

end