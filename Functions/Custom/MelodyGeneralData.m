%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                            MelodyGeneralData                          %%
%%                      Last update: October 16, 2024                    %%
%%                             Kévin Daigne                              %%
%%                        kevin.daigne@hotmail.fr                        %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%
%% - Abstract -
% MELODY: reads general data
%% -

function generalData=MelodyGeneralData(pathSimu)

% #. Path
fileToRead=[pathSimu filesep 'CODE' filesep 'STATIC_CONTROL.asc'];

% #. Options
opts=struct();
opts.TypeOpen={'Contains'};
opts.CriterionOpen={'SIMULATION_NAME'};
opts.TypeClose={{'Contains' 'Empty'}};
opts.CriterionClose={{'%%%' ''}};
opts.StepClose={{1 -1}};
opts.TrueClose={{1 0}};

% #. Result
[~,~,generalData,~]=TextEditor(fileToRead,opts);
if isempty(generalData)
    msgbox('Cannot find the section GENERAL DATA in STATIC_CONTROL.','Warning','warn');
    return;
end
generalData=generalData{1};