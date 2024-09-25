%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                            ColorConverter                             %%
%%                    Last update: December 09, 2021                     %%
%%                             Kévin Daigne                              %%
%%                        kevin.daigne@hotmail.fr                        %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Gives color in normalized RGB from various inputs
%% - Input -
% color = RGB (not normalized), matlab ('r', 'b', etc.) or hexadecimal
%% - Option -
% 'Default' : Color given if format is not recognized (black by default)
%% - Output -
% color = 1*3 double : Normalized and numerical RGB color
%% -

function [color]=ColorConverter(color,varargin)

% #. Default color
p=inputParser;
addOptional(p,'Default',[0 0 0]);
parse(p,varargin{:});

if strcmpi(color,'none')
    % #. None
    return;
elseif numel(color)==3 && all(~isletter(color))
    % #. Numeric RGB
elseif isscalar(color) && all(isletter(color))
    % #. Color with letter (e.g. 'r')
    color=bitget(find('krgybmcw'==color)-1,1:3); % Converts the letter to RGB
elseif contains(char(color),'[') && contains(char(color),']')
    % #. Numeric RGB but with char format
    color=eval(color);
    if any(color>=1)
        % Normalization if necessary
        color=color./255;
    end
elseif contains(char(color),'#')
    % #. Hexadecimal
    color = sscanf(color(2:end),'%2x%2x%2x',[1 3])/255;
else
    % #. Format not recognized
    color=p.Results.Default;
    if ~isequal(color,[0 0 0])
        [color]=ColorConverter(color); % Allows a default value with any format
    end
end