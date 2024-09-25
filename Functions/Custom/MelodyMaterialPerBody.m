%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                            MaterialPerBody                            %%
%%                      Last update: October 16, 2024                    %%
%%                             Kévin Daigne                              %%
%%                        kevin.daigne@hotmail.fr                        %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% 
%% - Abstract -
% MELODY: list of materials per body
%% -

function [materialsList,bodiesNumber]=MelodyMaterialPerBody(pathSimu)

% #. Path
fileToRead=[pathSimu filesep 'CODE' filesep 'STATIC_CONTROL.asc'];

% #. Options
opts=struct();
opts.TypeOpen={{'Contains' 'Empty' 'Empty' 'Shift'}};
opts.CriterionOpen={{{'BODY' '%%%'} '' '' 2}};
opts.TrueOpen={{1 1 0 1}};
opts.TypeClose={{'Shift'}};
opts.CriterionClose={{0}};
opts.PeriodOpen=inf;
opts.Format='Horizontal';

% #. Reading
sections=TextEditor(fileToRead,opts);

% #. Outputs
materialsList=[sections{:}];
bodiesNumber=numel(sections);