%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                            ObjectPosition                             %%
%%                    Last update: January 02, 2022                     %%
%%                             Kévin Daigne                              %%
%%                        kevin.daigne@hotmail.fr                        %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Gives or assigns the position in a certain unit, independently of the
% object unit, and without unit conversion. Avoids rounding errors, which
% can be significant and require a forced object refresh. Note that if the
% unit is not recognized, a conversion will be performed.
%% - Input -
% object : Object to be processed (figure, axes, colorbar, etc.)
%% - Options -
% 'Units' :
%   - Desired unit ('Pixels' by default)
% 'Type' :
%   - Position type such as InnerPositon, OuterPosition, etc. ('Position' by default)
%   - If the type is not recognized, 'Position' will automatically be taken as the type
% 'Set' :
%   - Assigns the position according to the unit indicated by 'Units' and the type indicated by 'Type'
%   - If all indices are to be modified, indicate this with a matrix 1*N double (N=4 most often; see examples)
%   - If only certain indices are to be modified, indicate this with a cell of 1*N double (N=4 most often; see examples)
%% - Output -
% - pos : Object position in the indicated unit
%% - Examples -
% e.g. n°1 :
% ObjectPosition(object)
% pos=object.Position in pixel units
% e.g. n°2 :
% ObjectPosition(object,'Units','Pixels','Type','InnerPosition')
% pos=object.InnerPosition in pixel units
% e.g. n°3 :
% ObjectPosition(object,'Units','Normalized','Type','Position','Set',[0 0 1 1])
% pos=object.Position in normalized units
% object.Position=[0 0 1 1] in normalized units
% e.g. n°4 :
% ObjectPosition(object,'Units','Normalized','Type','Position','Set',{[] [] 1 []})
% pos=object.Position in normalized units
% object.Position(3)=1 in normalized units
%% -

function pos=ObjectPosition(object,varargin)

%% #. Inputs
pos=[];
p=inputParser;
addOptional(p,'Units','Pixels');
addOptional(p,'Type','Position');
addOptional(p,'Set',[]);
parse(p,varargin{:});
opts=p.Results;
if ~isprop(object,opts.Type)
    if isprop(object,'Position')
        opts.Type='Position';
    else
        if strcmpi(opts.Type,'position')
            msgbox('Cannot find ''Position'' property inside the object.','Information','help');
        else
            msgbox(['Cannot find ''' opts.Type ''' and ''Position'' properties inside the object.'],'Information','help');
        end
        return;
    end
end
if ~isprop(object,'Units')
    % Object with position but without units (e.g. ContextMenu)
    pos=object.(opts.Type); return;
end

%% #. Parent position in pixels
if ~strcmpi(object.Units,opts.Units) && (~strcmpi(object.Units,'normalized') || ~strcmpi(opts.Units,'normalized'))
    if strcmpi(object.Parent.Type,'root')
        parentPosPixels=object.Parent.ScreenSize;
    else
        parentPosPixels=getpixelposition(object.Parent);
    end
end

%% #. Object units -> Normalized
% Of the following form: PosNormalized=corr1_0+(PosUnitsOld+corr2_0)*corr3_0
unknownUnits=false; % If the unit is not recognized
if strcmpi(object.Units,opts.Units) || strcmpi(object.Units,'normalized')
    
    % #.#. Identical or Normalized units
    corr1_0=[0 0 0 0];
    corr2_0=[0 0 0 0];
    corr3_0=[1 1 1 1];
    
else
    
    if strcmpi(object.Units,'pixels') ...
            || strcmpi(object.Units,'inches') ...
            || strcmpi(object.Units,'points') ...
            || strcmpi(object.Units,'centimeters')
        
        % #.#. Pixels
        corr1_0=[0 0 0 0];
        corr2_0=[0 0 0 0];
        corr3_0=1./parentPosPixels([3 4 3 4]);
        
        if ~strcmpi(object.Units,'pixels')
            % #.#. Inches
            screenSize=get(0,'ScreenPixelsPerInch');
            corr3_0=corr3_0.*screenSize;
            if strcmpi(object.Units,'points')
                % #.#. Points
                corr3_0=corr3_0./72;
            elseif strcmpi(object.Units,'centimeters')
                % #.#. Centimeters
                corr3_0=corr3_0./2.54;
            end
        end
        
    elseif strcmpi(object.Units,'data')
        
        % #.#. Data
        if strcmpi(object.Parent.Type,'colorbar')
            % Colorbar parent
            if object.Parent.Label.Rotation==0
                limX=object.Parent.Limits;
                limY=[0 1];
            else
                limX=[0 1];
                limY=object.Parent.Limits;
            end
        else
            % Axes parent
            v=axis(object.Parent);
            limX=v(1:2);
            limY=v(3:4);
        end
        corr1_0=repmat([0 0],1,2);
        corr2_0=[-limX(1) -limY(1) 0 0];
        corr3_0=repmat([1./(limX(2)-limX(1)) 1./(limY(2)-limY(1))],1,2);
        
    else
        
        % #.#. Unknown units
        unknownUnits=1;
        corr1_0=[0 0 0 0];
        corr2_0=[0 0 0 0];
        corr3_0=[1 1 1 1];
    end
end

%% #. Normalized -> Desired units
% Of the following form: PosUnitsNew=corr1_1+(PosNormalized+corr2_1)*corr3_1
if strcmpi(object.Units,opts.Units) || strcmpi(opts.Units,'normalized')
    
    % #.#. Identical or Normalized units
    corr1_1=[0 0 0 0];
    corr2_1=[0 0 0 0];
    corr3_1=[1 1 1 1];
    
else
    
    if strcmpi(opts.Units,'pixels')...
            || strcmpi(opts.Units,'inches') ...
            || strcmpi(opts.Units,'points') ...
            || strcmpi(opts.Units,'centimeters')
        
        % #.#. Pixels
        corr1_1=[0 0 0 0];
        corr2_1=[0 0 0 0];
        corr3_1=parentPosPixels([3 4 3 4]);
        
        if ~strcmpi(opts.Units,'pixels')
            % #.#. Inches
            screenSize=get(0,'ScreenPixelsPerInch');
            corr3_1=corr3_1./screenSize;
            if strcmpi(opts.Units,'points')
                % #.#. Points
                corr3_1=corr3_1.*72;
            elseif strcmpi(opts.Units,'centimeters')
                % #.#. Centimeters
                corr3_1=corr3_1.*2.54;
            end
        end
        
    elseif strcmpi(opts.Units,'data')
        
        % #.#. Data
        if strcmpi(object.Parent.Type,'colorbar')
            % Colorbar parent
            if object.Parent.Label.Rotation==0
                limX=object.Parent.Limits;
                limY=[0 1];
            else
                limX=[0 1];
                limY=object.Parent.Limits;
            end
        else
            % Axes parent
            v=axis(object.Parent);
            limX=v(1:2);
            limY=v(3:4);
        end
        corr1_1=[limX(1) limY(1) 0 0];
        corr2_1=[0 0 0 0];
        corr3_1=repmat([limX(2)-limX(1) limY(2)-limY(1)],1,2);
        
    else
        
        % #.#. Requested units unknown
        msgbox(['Cannot recognize ' opts.Units],'Information','help');
        return;
    end
end

%% #. Object units -> Desired units
% In the following form: PosUnitsNew=corr1+(PosUnitsOld+corr2)*corr3
% PosNormalized=corr1_0+(PosUnitsOld+corr2_0)*corr3_0
% PosUnitsNew=corr1_1+(PosNormalized+corr2_1)*corr3_1
% Solving the system gives:
corr1=corr1_1+(corr1_0+corr2_1).*corr3_1;
corr2=corr2_0;
corr3=corr3_0.*corr3_1;

%% #. If the requested position does not have 4 elements
if numel(get(object,opts.Type))~=4 % e.g. Unit in x0 y0 z0 for colorbar labels
    corr1=[corr1(1:2) zeros(1,numel(get(object,opts.Type))-2)];
    corr2=[corr2(1:2) zeros(1,numel(get(object,opts.Type))-2)];
    corr3=[corr3(1:2) zeros(1,numel(get(object,opts.Type))-2)];
end

%% #. Trouve la position
% Of the following form: PosUnitsNew=corr1+(PosUnitsOld+corr2)*corr3
if ~unknownUnits
    % #.#. Known units
    pos=corr1+(get(object,opts.Type)+corr2).*corr3;
else
    % #.#. Unknown units
    unitsSave=object.Units;
    drawnow; set(object,'Units',opts.Type); drawnow;
    pos=object.(opts.Type);
end

%% #. Assigns position
% In the following form: PosUnitsOld=(PosUnitsNew-corr1)/corr3-corr2
if ~isempty(opts.Set)
    if iscell(opts.Set)
        % Modification of certain indexes
        ind=find(~cellfun(@isempty,opts.Set));
        opts.Set=cell2mat(opts.Set);
    else
        % Modification of all indices
        ind=1:numel(opts.Set);
    end
    try % Some properties can be recognized but are read-only
        object.(opts.Type)(ind)=(opts.Set-corr1(ind))./corr3(ind)-corr2(ind);
    catch
        object.Position(ind)=(opts.Set-corr1(ind))./corr3(ind)-corr2(ind);
    end
end

%% #. Reassignment of old units
if unknownUnits
    drawnow; set(object,'Units',unitsSave); drawnow;
end