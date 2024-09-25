%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                               ReadVTKFiles                            %%
%%                     Last update: January 17, 2022                     %%
%%                               Kévin Daigne                            %%
%%                         kevin.daigne@hotmail.fr                       %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Function reading .vtk files. Based on Alberto Gomez's “Medical Image
% Processing Toolbox”, removing unnecessary elements and optimizing the
% function. Reading time was initially high (e.g. several hours for 1000
% bodies on 50 files, which has been reduced here to a few minutes). The
% ability to read files of different types has been added.
%% - Input -
% filename = chars : vtk file path
%% - Output
% info = struct : file content
%% -

function [info]=ReadVTKFiles(filename)

% #. Initialization
info=[]; % Structure containing all the information

% #. Open
fileID=fopen(filename,'rb');

% #. Header
% #.#. Size
headerNumber=0;
line='';
while ~(contains(line,'float') || contains(line,'double'))
    headerNumber=headerNumber+1;
    line=lower(fgetl(fileID));
    if feof(fileID)
        fclose(fileID); return;
    end
end
headerNumber=headerNumber-1;
frewind(fileID);
% #.#. Processing
header=cell(1,headerNumber);
for line=1:headerNumber
    header{line}=fgetl(fileID);
end

% #. Pixels
ind=contains(lower(header),'window'); % The window term is followed by [xmin xmax ymin ymax]
if any(ind)
    lineSplit=strsplit(header{ind},' ');
    lineSplit(cellfun(@isempty,lineSplit))=[];
    ind=find(contains(lineSplit,'Window')==1);
    if ~isempty(ind) && numel(lineSplit)>=ind+4
        info.X=[str2double(lineSplit{ind+1}) str2double(lineSplit{ind+2})];
        info.Y=[str2double(lineSplit{ind+3}) str2double(lineSplit{ind+4})];
    end
end

while ~feof(fileID)
    
    % Type
    str=lower(fgetl(fileID));
    
    if contains(str,'coordinates')

        % Coordinates --------------------------------
        if contains(str,'x')
            info.X=fscanf(fileID,'%f');
        elseif contains(str,'y')
            info.Y=fscanf(fileID,'%f');
        elseif contains(str,'z')
            info.Z=fscanf(fileID,'%f');
        end
        
    elseif contains(str,'points')

        % Point data --------------------------------
        % i.e. Nodal coordinates
        [data]=fscanf(fileID,'%f');
        info.X=data(1:3:end);
        info.Y=data(2:3:end);

    elseif contains(str,'polygons')

        % Triangle data --------------------------------
        % i.e. Connectivity
        elementsNumberSplit=strsplit(str,' ');
        elementsNumber = str2double(elementsNumberSplit{2});
        [data, ~]=fscanf(fileID,'%d');
        if unique(data(1:3:end))==2
            % Beam-type mesh
            % -> Matlab doesn't know how to interpret it, so we transform
            % each segment into 2 triangles
            info.CONNECTIVITY=[data(2:3:elementsNumber*3) data(2:3:elementsNumber*3) data(3:3:elementsNumber*3)]+1; % in matlab, first index is 1
        elseif unique(data(1:4:end))==3
            % Triangular mesh
            info.CONNECTIVITY=[data(2:4:elementsNumber*4) data(3:4:elementsNumber*4) data(4:4:elementsNumber*4)]+1; % in matlab, first index is 1
        elseif unique(data(1:5:end))==4
            % Quadrilateral mesh
            % -> Matlab doesn't know how to interpret it, so we transform
            % each segment into 2 triangles
            info.CONNECTIVITY=[[data(2:5:elementsNumber*5) data(3:5:elementsNumber*5) data(4:5:elementsNumber*5)]+1;...
                data(4:5:elementsNumber*5) data(5:5:elementsNumber*5) data(2:5:elementsNumber*5)]+1;
        else
            % Segments per element > 4
            % -> Matlab can't plot a polygon of order~=3, so we transform
            % it to have a minimum number of elements. We take a fixed
            % point on the contour, and scan the contour points to obtain
            % a succession of triangles, all of which have a common vertex
            % and do not overlap.
            info.CONNECTIVITY=[];
            shift=1;
            for elementNum=1:elementsNumber
                nodesNumber=data(shift);
                info.CONNECTIVITY=[info.CONNECTIVITY ; ones(size(data(shift+2:1:shift+nodesNumber-1)))*data(shift+1)+1 data(shift+2:1:shift+nodesNumber-1)+1 data(shift+3:1:shift+nodesNumber)+1]; % in matlab, first index is 1
                shift=shift+nodesNumber+1;
            end
        end
        
    elseif contains(str,'point_data')|| contains(str,'double')
        
        % Point data
        
        tmpSplit=strsplit(str,' ');
        elementsNumber = str2double(tmpSplit{2});
        
        while 1
            
            % Header
            str=lower(fgetl(fileID));   [attribute, temp] = strtok(str);
            
            if strcmpi(attribute,'scalars')

                % Inputs
                lineTemp=strsplit(temp); lineTemp(cellfun(@isempty,lineTemp))=[]; 
                attribute_name=lineTemp{1}; componentsNumber=lineTemp{end}; type=strcat(lineTemp{2:end-1});
                attribute_name=lower(replace(attribute_name ...
                    ,{'[',' ','!','"','#','$','%','&','(',')','*','+',',','-','.','/',':',';','<','=','>','?','@','\','^','_','`','''','{','|','}','~',']'},'_'));
                index = find(isletter(attribute_name), 1);
                attribute_name  = attribute_name(index:end); % Remove the potential digits in front of the name
                if numel(componentsNumber)==0
                    componentsNumber = 1; % default value
                else
                    componentsNumber = str2double(componentsNumber); % default value
                end
                fgetl(fileID);
                % DATA
                if strcmpi(type,'short')
                    [data,~]=fscanf(fileID,'%d');
                elseif (strcmpi(type,'float') || strcmpi(type,'double'))
                    [data,~]=fscanf(fileID,'%f');
                end
                % Outputs
                if componentsNumber==1
                    info.(attribute_name)=data(1:componentsNumber:elementsNumber*componentsNumber);
                elseif componentsNumber==2
                    info.([attribute_name '_x'])=data(1:componentsNumber:elementsNumber*componentsNumber);
                    info.([attribute_name '_y'])=data(2:componentsNumber:elementsNumber*componentsNumber);
                    info.([attribute_name '_norm'])=(info.([attribute_name '_x']).^2+info.([attribute_name '_y']).^2).^0.5;
                elseif componentsNumber==3
                    info.([attribute_name '_x'])=data(1:componentsNumber:elementsNumber*componentsNumber);
                    info.([attribute_name '_y'])=data(2:componentsNumber:elementsNumber*componentsNumber);
                    info.([attribute_name '_z'])=data(3:componentsNumber:elementsNumber*componentsNumber);
                    info.([attribute_name '_norm'])=(info.([attribute_name '_x']).^2+info.([attribute_name '_y']).^2+info.([attribute_name '_z']).^2).^0.5;
                else
                    for jj=1:componentsNumber
                        info.([attribute_name '_' num2str(jj)])=data(jj:componentsNumber:elementsNumber*componentsNumber);
                    end
                end

            elseif strcmpi(attribute,'color_scalars')

                % do nothing

            elseif strcmpi(attribute,'lookup_table')

                % do nothing

            elseif strcmpi(attribute,'vectors')

                % Inputs
                lineTemp=strsplit(temp); lineTemp(cellfun(@isempty,lineTemp))=[];
                attribute_name=lineTemp{1};
                attribute_name=lower(replace(attribute_name ...
                    ,{'[',' ','!','"','#','$','%','&','(',')','*','+',',','-','.','/',':',';','<','=','>','?','@','\','^','_','`','''','{','|','}','~',']'},'_'));
                index = find(isletter(attribute_name), 1);
                attribute_name  = attribute_name(index:end); % Remove the potential digits in front of the name
                type=lineTemp{end};
                % Reading
                if strcmpi(type,'short')
                    [data,~]=fscanf(fileID,'%d');
                elseif strcmpi(type,'float') || strcmpi(type,'double')
                    [data,~]=fscanf(fileID,'%f');
                end
                data=reshape(data,3,[])';
                % Format
                info.([attribute_name '_x'])=data(:,1);
                info.([attribute_name '_y'])=data(:,2);
                info.([attribute_name '_z'])=data(:,3);
                info.([attribute_name '_norm'])=vecnorm(data,2,2);

            elseif strcmpi(attribute,'normals')

                % do nothing

            elseif strcmpi(attribute,'tensors')

                % Inputs
                lineTemp=strsplit(temp); lineTemp(cellfun(@isempty,lineTemp))=[]; 
                attribute_name=lineTemp{1};
                attribute_name=lower(replace(attribute_name ...
                    ,{'[',' ','!','"','#','$','%','&','(',')','*','+',',','-','.','/',':',';','<','=','>','?','@','\','^','_','`','''','{','|','}','~',']'},'_'));
                index = find(isletter(attribute_name), 1);
                attribute_name  = attribute_name(index:end); % Remove the potential digits in front of the name
                type=lineTemp{end};
                % Reading
                if strcmpi(type,'short')
                    [data,~]=fscanf(fileID,'%d');
                elseif (strcmpi(type,'float') || strcmpi(type,'double'))
                    [data,~]=fscanf(fileID,'%f');
                end
                % Format
                data=reshape(data,9,[])';
                data=reshape(data,numel(info.X),numel(info.Y),numel(info.Z),9);
                data=permute(data,[2 1 3 4]);
                info.([attribute_name '_11'])=data(:,:,:,1);
                info.([attribute_name '_21'])=data(:,:,:,2);
                info.([attribute_name '_31'])=data(:,:,:,3);
                info.([attribute_name '_12'])=data(:,:,:,4);
                info.([attribute_name '_22'])=data(:,:,:,5);
                info.([attribute_name '_32'])=data(:,:,:,6);
                info.([attribute_name '_13'])=data(:,:,:,7);
                info.([attribute_name '_23'])=data(:,:,:,8);
                info.([attribute_name '_33'])=data(:,:,:,9);
                info.([attribute_name '_norm'])=vecnorm(data,2,4);

            elseif strcmpi(attribute,'texture_coordinates')

                % do nothing

            elseif strcmpi(attribute,'field')

                msgbox([attribute ' cannot actually be read by readVTK function.'],'Information','help');

            else

                break;

            end
        end
        
    elseif contains(str,'float')
        
        % Inputs
        [~, temp]=strtok(str); lineTemp=strsplit(temp); lineTemp(cellfun(@isempty,lineTemp))=[];
        attribute_name=lineTemp{1}; componentsNumber=lineTemp{end};
        attribute_name=lower(replace(attribute_name ...
                    ,{'[',' ','!','"','#','$','%','&','(',')','*','+',',','-','.','/',':',';','<','=','>','?','@','\','^','_','`','''','{','|','}','~',']'},'_'));
                index = find(isletter(attribute_name), 1);
                attribute_name  = attribute_name(index:end); % Remove the potential digits in front of the name
        ind=find(contains(header,'DIMENSIONS')==1);
        if ~isempty(ind)
            % Type Pixels
            lineSplit=strsplit(header{ind},' ');
            componentsNumber=str2double(lineSplit{2});
            elementsNumber=str2double(lineSplit{3});
        else
            % Other
            if numel(componentsNumber)==0
                componentsNumber = 1; % default value
            else
                componentsNumber = str2double(componentsNumber); % default value
            end
        end
        fgetl(fileID);
        % DATA
        [data,~]=fscanf(fileID,'%f');
        % Outputs
        if ~isempty(ind)
            if size(data,1)~=componentsNumber*elementsNumber % Incomplete data
                data(find(gcd(1:size(data,1),componentsNumber)==componentsNumber,1,'last')+1:end)=[];
            end
            info.(attribute_name)=reshape(data',componentsNumber,[])';
        else
            if componentsNumber==1
                info.(attribute_name)=data(1:componentsNumber:elementsNumber*componentsNumber);
            elseif componentsNumber==2
                info.([attribute_name '_x'])=data(1:componentsNumber:elementsNumber*componentsNumber);
                info.([attribute_name '_y'])=data(2:componentsNumber:elementsNumber*componentsNumber);
                info.([attribute_name '_norm'])=(info.([attribute_name '_x']).^2+info.([attribute_name '_y']).^2).^0.5;
            elseif componentsNumber==3
                info.([attribute_name '_x'])=data(1:componentsNumber:elementsNumber*componentsNumber);
                info.([attribute_name '_y'])=data(2:componentsNumber:elementsNumber*componentsNumber);
                info.([attribute_name '_z'])=data(3:componentsNumber:elementsNumber*componentsNumber);
                info.([attribute_name '_norm'])=(info.([attribute_name '_x']).^2+info.([attribute_name '_y']).^2+info.([attribute_name '_z']).^2).^0.5;
            else
                for jj=1:1:componentsNumber
                    info.([attribute_name '_' num2str(jj)])=data(jj:componentsNumber:elementsNumber*componentsNumber);
                end
            end
        end
        
    elseif contains(str,'triangle_strips')

        msgbox('triangle_strips cannot actually be read by readVTK function.','Information','help');
        
    elseif contains(str,'cell_data')
        
        % cell_data
        % Contains the number of elements
        
        tmpSplit=strsplit(str,' ');
        elementsNumber = str2double(tmpSplit{2});

    end
end

% #. Correction
% There may be one value for each element of the connectivity matrix, 
% which matlab cannot interpret.
if isfield(info,'CONNECTIVITY')
    maxNode=max(max(info.CONNECTIVITY));
    names=fieldnames(info); names(strcmpi(names,'CONNECTIVITY'))=[];
    for fieldNumber=1:numel(names)
        corr=round(maxNode/max(size(info.(names{fieldNumber}))));
        if corr~=1
            info.(names{fieldNumber})=repelem(info.(names{fieldNumber}),corr);
        end
    end
end

% #. Output
fclose(fileID);
info = orderfields(info);