%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                        MelodyPeriodicBoundaries                       %%
%%                      Last update: October 16, 2024                    %%
%%                             Kévin Daigne                              %%
%%                        kevin.daigne@hotmail.fr                        %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% 
%% - Abstract -
% MELODY: gives the value of the periodic boundaries
%% -

function xCoordinates=MelodyPeriodicBoundaries(pathSimu)

% #. Path
fileToRead=[pathSimu filesep 'CODE' filesep 'STATIC_CONTROL.asc'];

% #. Options
opts=struct();
opts.TypeOpen={{'Contains' 'Empty' 'Shift'}};
opts.CriterionOpen={{'PERIODIC_BOUNDARIES' '' -1}};
opts.TypeClose={{'Shift'}};
opts.CriterionClose={{0}};

% #. Reading
sections=TextEditor(fileToRead,opts);

% #. Outputs
xCoordinates=str2double(strsplit(sections{1}{1}));