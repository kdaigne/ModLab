%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                            VelocityIntegration                        %%
%%                      Last update: December 03, 2021                   %%
%%                               Kévin Daigne                            %%
%%                         kevin.daigne@hotmail.fr                       %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%
%% - Abstract - 
% Function deriving velocity to obtain
% position according to the following conditions:
% Velocity of the form V(t)=at+b so P(t)=0.5*a*t^2+bt+c
% c taken in such a way that there is continuity in
% position between each section
% tPlot,vPlot,pPlot,p0Plot are vectors containing the
% results for all sections in a single vector, with N
% discretization points per section. This method is
% used, as one plot per section results in a significant time.
%% -

function [tPlot,vPlot,pPlot,p0Plot]=VelocityIntegration(timeVect,velocityVect,P0,N)
% #. Coefficients
a=@(t0,t1,v0,v1) (v1-v0)/(t1-t0); % Coefficient
b=@(t0,v0,a) v0-a*t0; % Coefficient
c=@(t0,P0,a,b) P0-0.5.*a.*t0.*t0-b.*t0; % Coefficient
% #. Initialization
tPlot=cell(1,numel(timeVect));
vPlot=cell(1,numel(timeVect));
pPlot=cell(1,numel(timeVect));
p0Plot=cell(1,numel(timeVect));
p0Plot{1}=P0;
% #. Calculation for each section
for piecewiseNum=2:1:numel(timeVect)
    % #.#. Initialization
    t0=timeVect(piecewiseNum-1); t1=timeVect(piecewiseNum);
    v0=velocityVect(piecewiseNum-1); v1=velocityVect(piecewiseNum);
    vFonc= @(t) a(t0,t1,v0,v1).*t+b(t0,v0,a(t0,t1,v0,v1));
    pFonc= @(t) 0.5.*a(t0,t1,v0,v1).*t.*t+b(t0,v0,a(t0,t1,v0,v1)).*t+c(t0,P0,a(t0,t1,v0,v1),b(t0,v0,a(t0,t1,v0,v1)));
    % #.#. Calculation
    P0=pFonc(t1);
    tVect=t0:(t1-t0)/(N-1):t1;
    tPlot{piecewiseNum}=tVect;
    vPlot{piecewiseNum}=vFonc(tVect);
    pPlot{piecewiseNum}=pFonc(tVect);
    p0Plot{piecewiseNum}=P0;
end
% #. Conversion
tPlot=cell2mat(tPlot);
vPlot=cell2mat(vPlot);
pPlot=cell2mat(pPlot);
p0Plot=cell2mat(p0Plot);