%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                             FindObjects                               %%
%%                    Last update: January 02, 2022                      %%
%%                             Kévin Daigne                              %%
%%                        kevin.daigne@hotmail.fr                        %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Finds the object(s) associated with an axis, regardless of their 
% handle visibility
%% - Input -
% ax = axes : axes on which the search is performed
%% - Options -
% 'Type' = chars ('colorbar' by default) : Type of object to find
%% - Outputs -
% objets = cells : objects found
% indObjects = doubles : indices of objects in axes childrens (with showhiddenhandles='on')
% indAxes = double : axes index in its parent (with showhiddenhandles='on')
%% -

function [objects,indObjects,indAxes]=FindObjects(ax,varargin)

% #. Inputs
p=inputParser;
addOptional(p,'Type','colorbar');
parse(p,varargin{:});
opts=p.Results;

% #. Initialization
set(0,'showhiddenhandles','on'); % e.g. colorbars are not displayed in handles

% #. Find the axis
indAxes=find(ax.Parent.Children==ax,1,'first');

% #. Find the colorbar(s)
% Objects can be located before or after the axis (e.g. copyobj reverses
% the order). We therefore need to test the 2 possibilities. We use
% objectTemp to make sure we're looking in the right direction. Note that
% you can't use the ancestor function directly to find all the objects,
% as it can only find one.
objectTemp=get(ancestor(ax,'axes'),opts.Type);
if ~isempty(indAxes)
    if ~isempty(objectTemp)
        objectsNumber=numel(ax.Parent.Children);
        for tryNum=1:2
            objects=gobjects(1,objectsNumber); indObjects=zeros(1,objectsNumber);
            % #.#. Direction
            if tryNum==1
                delta=1;
            else
                delta=-1;
            end
            % #.#. Find the object(s)
            ind=indAxes+delta;
            while ind>0 && ind<=objectsNumber
                if ~strcmpi(ax.Parent.Children(ind).Type,opts.Type)
                    break;
                else
                    objects(ind)=ax.Parent.Children(ind);
                    indObjects(ind)=1;
                end
                ind=ind+delta;
            end
            % #.#. Stop condition
            indObjects=find(indObjects);
            if any(objects(indObjects)==objectTemp)
                break;
            end
        end
        objects(~ismember(1:objectsNumber,indObjects))=[];
    else
        objects=[];
        indObjects=[];
    end
else
    objects=[];
    indObjects=[];
end
set(0,'showhiddenhandles','off');