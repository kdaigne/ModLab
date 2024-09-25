%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                            PositionDerivation                         %%
%%                      Last update: December 03, 2021                   %%
%%                               Kévin Daigne                            %%
%%                         kevin.daigne@hotmail.fr                       %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
% This function should be replaced by spline built-in function
%
%% - Abstract -
% Function integrating position to obtain velocity under the following
% conditions:
% The position is of the form p(t)=at^2+bt+c, as only 2 points on an
% interval are defined, a tangency constraint must be added to obtain a
% unique solution (i.e. 3 equations to identify a b and c).
% tPlot,pPlot,vPlot and v0Plot are vectors containing the results for all
% sections in a single vector, with N discretization points per section. 
% This method is used because one plot per section means a long calculation time.
%% -

function [tPlot,pPlot,vPlot,v0Plot]=PositionDerivation(timeVect,positionVect,V0,N)
% #. Coefficients
% Solving the system of equations analytically gives the following equations:
a=@(t0,t1,p0,p1,V0) -1.*((p0-p1-V0.*(t0-t1))./((t0-t1).*(t0-t1))); % Coefficient
b=@(t0,V0,a) V0-2.*a.*t0; % Coefficient
c=@(t0,t1,p0,p1,V0,a) 0.5.*(p0+p1-a.*(t1.*t1-t0.*t0-2.*t0.*t1)-V0.*(t0+t1)); % Coefficient
p=@(t,a,b,c) a.*t.*t+b.*t+c; % Position
v=@(t,a,b) 2.*a.*t+b; % Velocity
% #. Initialization
tPlot=cell(1,size(timeVect,2));
pPlot=cell(1,size(timeVect,2));
vPlot=cell(1,size(timeVect,2));
v0Plot=cell(1,size(timeVect,2));
v0Plot{1}=V0;
% #. Calculation for each section
for piecewiseNum=2:1:size(timeVect,2)
    % #.#. Initialization
    t0=timeVect(1,piecewiseNum-1); t1=timeVect(1,piecewiseNum);
    p0=positionVect(1,piecewiseNum-1); p1=positionVect(1,piecewiseNum);
    pFonc= @(t) p(t,a(t0,t1,p0,p1,V0),b(t0,V0,a(t0,t1,p0,p1,V0)),c(t0,t1,p0,p1,V0,a(t0,t1,p0,p1,V0)));
    vFonc= @(t) v(t,a(t0,t1,p0,p1,V0),b(t0,V0,a(t0,t1,p0,p1,V0)));
    % #.#. Calculation
    V0=vFonc(t1);
    tVect=t0:(t1-t0)/(N-1):t1;
    tPlot{piecewiseNum}=tVect;
    pPlot{piecewiseNum}=pFonc(tVect);
    vPlot{piecewiseNum}=vFonc(tVect);
    v0Plot{piecewiseNum}=V0;
end
% #.#. Conversion
tPlot=cell2mat(tPlot);
pPlot=cell2mat(pPlot);
vPlot=cell2mat(vPlot);
v0Plot=cell2mat(v0Plot);