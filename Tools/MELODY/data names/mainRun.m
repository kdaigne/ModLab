%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                                dataNames                              %%
%%                      Last update: September 16, 2024                  %%
%%                               Kévin Daigne                            %%
%%                         kevin.daigne@hotmail.fr                       %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Loads data names
%% -

% #. Path
tabNumber=findTab(app);
pathSimu=app.TabGroup.Children(tabNumber).Children(app.id.gridTabNumber).Children(app.id.gridProcessingNumber).Children(app.id.SAVEPanelNumber).Children(app.id.gridSaveNumber).Children(app.id.displayPathNumber).Value;
pathHeaders=[pathSimu filesep 'SAVE' filesep 'headers_save.mat'];

% #. Array info
spiesInfo=MelodyArrayInfo(pathSimu);

% #. Initialization
if isfile(pathHeaders)
    headersSave=load(pathHeaders);
    indToRemove=ismember(headersSave.headersFile,[{'FIELDS_' 'GRAINS_' 'CONTOURS_' 'CHAINS_'} reshape([spiesInfo.nameArrayCell{:}],1,[])]);
    headersSave.headersClass(indToRemove)=[];
    headersSave.headersColumn(indToRemove)=[];
    headersSave.headersExt(indToRemove)=[];
    headersSave.headersFile(indToRemove)=[];
    headersSave.headersName(indToRemove)=[];
    headersSave.headersType(indToRemove)=[];
else
    headersSave=struct();
    headersSave.headersClass={};
    headersSave.headersColumn={};
    headersSave.headersExt={};
    headersSave.headersFile={};
    headersSave.headersFileExclude={};
    headersSave.headersName={};
    headersSave.headersType={};
end

% #. SPIES
digitsNumber=num2str(numel(num2str(max([10 spiesInfo.arrayNumber])))); % at least 2 digits
for spiesNum=1:spiesInfo.arrayNumber
    headersSave.headersClass=[headersSave.headersClass repmat({'MATRIX'},1,spiesInfo.argumentNumberVect(spiesNum)+2)];
    headersSave.headersColumn=[headersSave.headersColumn num2cell(1:spiesInfo.argumentNumberVect(spiesNum)+2)];
    headersSave.headersExt=[headersSave.headersExt repmat({'.asc'},1,spiesInfo.argumentNumberVect(spiesNum)+2)];
    headersSave.headersFile=[headersSave.headersFile repmat(spiesInfo.nameArrayCell(spiesNum),1,spiesInfo.argumentNumberVect(spiesNum)+2)];
    if spiesInfo.arrayNumber>1
        headersSave.headersName=[headersSave.headersName [{['Iteration ' num2str(spiesNum,['%0' digitsNumber '.f'])]} {['Time ' num2str(spiesNum,['%0' digitsNumber '.f'])]} spiesInfo.nameArgumentsCell{spiesNum}]]; % number must be add after ite and time to obtain a unique name
    else
        headersSave.headersName=[headersSave.headersName ['Iteration' 'Time' spiesInfo.nameArgumentsCell{spiesNum}]];
    end
    headersSave.headersType=[headersSave.headersType repmat({'UNIQUE'},1,spiesInfo.argumentNumberVect(spiesNum)+2)];
end

% #. Sort
[~,indSort]=sort(lower(strcat(headersSave.headersFile,headersSave.headersName)));
headersSave.headersName=headersSave.headersName(indSort);
headersSave.headersType=headersSave.headersType(indSort);
headersSave.headersFile=headersSave.headersFile(indSort);
headersSave.headersExt=headersSave.headersExt(indSort);
headersSave.headersClass=headersSave.headersClass(indSort);
headersSave.headersColumn=headersSave.headersColumn(indSort);

% #. Save
save(pathHeaders,'-struct','headersSave');

% #. Other
dataDisplayList(app,tabNumber,'Reset',1,[]);