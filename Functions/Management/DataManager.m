%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                             DataManager                               %%
%%                    Last update: September 17, 2024                    %%
%%                             Kévin Daigne                              %%
%%                        kevin.daigne@hotmail.fr                        %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Manages custom data that can be used in the GUI. The main purpose is to
% define custom graphics from available data.
%% - Inputs -
% Corresponds only to data that might be useful for the user, but not relevant for the implementation
% app = obj : GUI
% mode = char : indicates the case to be processed (i.e. what appears in the sublist or the data value)
% selection = struct : multiple information about the current selection
%% - Outputs -
% customData = N*3 cells
%   > customData{i,1} = char : 
%       - Name of the data group that will appear in the main list
%       - A case corresponding to this name can be defined in 
%         PlotManager.m to create a custom graph which will use the loaded
%         data as defined below
%   > customData{i,2} = M*{char} : 
%       - Content of sub-list when group is selected
%       - A direct entry is entered as a char, a function as a char beginning with !
%       - 'example' : the word 'example' will appear in the list
%       - '!example' : the '!example' case defined above will be processed 
%         and the output (which can be X cells) will be displayed in the list
%   > customData{i,3} = L*{char} : 
%       - Name of data to be loaded or computed
%       - An existing data to load is entered as a char
%           o 'example' : the data 'example' will be loaded into the corresponding file
%       - A data to be computed is entered as a char beginning with !
%           o '!example' : a data called 'example' will be defined and its
%             value will be the output of the case '!example'
% output = any type :
%       - Value of the specified '!example'
%% -

function [customData,output]=DataManager(app,mode,selection)
output=[];

%% #. Custom data
customData={...
    'ISAAC - Contact pressure',{'!steps'},{'pres','shearx'};
    'MELODY - Velocity profile',{'!steps'},{'velocity_x'};
    'MELODY - Body index and velocity',{'!steps'},{'body_index' 'velocity_x' '!periodicBoundaries'};
    'MELODY - von Mises and velocity',{'!steps'},{'von_mises_stress' 'velocity_x' '!periodicBoundaries'};
    %'Peaks',{''},{''},{'!peaks'};
    };
if isempty(mode); return; end

%% #. Output

switch mode

    case '!steps'

        output=loadListStep(app,selection.other.pathSimu);

    case '!periodicBoundaries'

        output=MelodyPeriodicBoundaries(selection.other.pathSimu);

    case '!peaks'

        output=peaks(10);

end

end