% Set up the figure
fH = figure;

%% Thermal equilibrium

[params, units] = spinsDefaultParams();
params.fliptime  = inf;  %   (no flip)      

clf;
set(gcf, 'Name', 'Thermal equilibrium', 'NumberTitle', 'off');
animateSpins(params);

%% 90º flip, t2 relaxation, laboratory reference 
% (set t1 to very long)
params = spinsDefaultParams();

params.dt        = 0.002; % seconds
params.t1        = 20;    % seconds 

clf; 
set(gcf, 'Name', 'T2 relaxation, laboratory reference frame', 'NumberTitle', 'off');
animateSpins(params);

%% same, but in rotating reference frame
params = spinsDefaultParams();

params.dt        = 0.002; % seconds
params.t1        = 20;    % seconds 
params.larmor    = 0;
params.B1carrier = params.larmor;

clf;
set(gcf, 'Name', 'T2 relaxation, rotating reference frame', 'NumberTitle', 'off');

animateSpins(params);


%% watch a slow 90º flip in rotating reference frame
params = spinsDefaultParams();

params.dt        = 0.0001;   % seconds
params.nsteps    = 150; % count
params.flipangle = pi/2;   % flip angle in radians
params.fliptime  = 0.001;  % when to initiate flip (seconds)
params.larmor    = 0;
params.B1carrier = params.larmor;

clf
set(gcf, 'Name', 'Slow 90º flip', 'NumberTitle', 'off');

animateSpins(params);

%% continuous flipping. increase t2 and t1 
params = spinsDefaultParams();

params.dt        = 0.002;   
params.nsteps    = 200; 
params.flipangle = pi*2*50;   % flip angle in radians
params.fliptime  = 0.003;  % when to initiate flip (seconds)
params.t2        = .2;
params.t1        = 20;
params.larmor    = 0;
params.B1carrier = params.larmor;

clf;
set(gcf, 'Name', 'Continuous flipping', 'NumberTitle', 'off');

animateSpins(params);

%% t1 recovery from 180º flip
params = spinsDefaultParams();

params.dt        = 0.01;% longer dt because we need a longer demo for T1 reovery   
params.nsteps    = 150;     
params.flipangle = pi;

clf;
set(gcf, 'Name', 'T1 relaxation from 180º flip', 'NumberTitle', 'off');

animateSpins(params);

