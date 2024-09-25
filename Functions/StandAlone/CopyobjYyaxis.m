%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                             copyobjYyaxis                             %%
%%                      Last update: April 02, 2022                      %%
%%                             Kévin Daigne                              %%
%%                        kevin.daigne@hotmail.fr                        %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract -
% Built-in copyobj function does not work well for axes containing several
% y-axes (e.g. using yyaxis left). A custom function has therefore been
% created.
%% - Input -
% axInput = axes : object to copy
% parentInput = object : object where axes is copied
%% - Output -
% ax = axes : copied axes
%% -

function ax=CopyobjYyaxis(axInput,parentInput)

%% #. Initialization
ax=uiaxes(parentInput); hold(ax,'on'); % If axes and not uiaxes, positioning does not take axis size into account, which causes problems later on
propList=["Color" "Colormap" "FontAngle" "FontName" "FontWeight" "GridLineStyle" "LineWidth" "View" "XGrid" "YGrid" "ZGrid"];
propPlotList=["Color" "LineStyle" "LineWidth" "Marker" "MarkerEdgeColor" "MarkerFaceColor" "MarkerSize"];
propAxisList=["Color" "FontAngle" "FontName" "FontWeight" "LineWidth"];
propLabelList=["Interpreter" "String" "BackgroundColor" "Color" "EdgeColor" "FontAngle" "FontName" "FontWeight" "LineStyle" "LineWidth"];

%% #. Graph
for side=["left" "right"]
    yyaxis(ax,side);
    yyaxis(axInput,side);
    for childNum=numel(axInput.Children):-1:1
        plot(ax,axInput.Children(childNum).XData,axInput.Children(childNum).YData)
    end
end
ax.Tag=axInput.Tag;

%% #. Axis formatting
for var=['X' 'Y']
    for axisNum=1:numel(axInput.([var 'Axis']))
        for propName=propAxisList
            ax.([var 'Axis'])(axisNum).(propName)=axInput.([var 'Axis'])(axisNum).(propName);
        end
        for propName=propLabelList
            ax.([var 'Axis'])(axisNum).Label.(propName)=axInput.([var 'Axis'])(axisNum).Label.(propName);
        end
    end
end

%% #. General formatting
for side=["left" "right"]
    yyaxis(ax,side);
    yyaxis(axInput,side);
    for childNum=numel(axInput.Children):-1:1
        for propName=propPlotList
            ax.Children(childNum).(propName)=axInput.Children(childNum).(propName);
        end
    end
end
for propName=propList
    ax.(propName)=axInput.(propName);
end