% s_SpinsToBulkM
%
% Worked examples of the spin animations. Run one cell at a time.
% Each cell sets up a parameter struct and calls animateSpins.
%
% See also ANIMATESPINS, SPINSDEFAULTPARAMS

addpath(fullfile(fileparts(mfilename('fullpath')), 'subroutines'));
saveMovieFlag = false;

%% Noiseless Larmor precession
fH = figure;
params = spinsDefaultParams();
params.fliptime = inf;   % no flip
params.t1       = inf;
params.t2       = inf;

titlestr = 'Noiseless precession';
animateSpins(params, fH, titlestr, saveMovieFlag);

%% Noiseless Larmor precession with 90 degree flip
fH = figure;
params = spinsDefaultParams();
params.t1 = inf;
params.t2 = inf;

titlestr = 'Noiseless precession with flip';
animateSpins(params, fH, titlestr, saveMovieFlag);

%% T2 relaxation, laboratory reference frame
fH = figure;
params = spinsDefaultParams();

titlestr = 'T2 relaxation in laboratory reference frame';
animateSpins(params, fH, titlestr, saveMovieFlag);

%% T2 relaxation, rotating reference frame
fH = figure;
params = spinsDefaultParams();
params.larmor = 0;
params.dt     = 0.002;

titlestr = 'T2 relaxation in rotating reference frame';
animateSpins(params, fH, titlestr, saveMovieFlag);

%% T1 and T2 relaxation, rotating reference frame
fH = figure;
params = spinsDefaultParams();
params.larmor    = 0;
params.dt        = 0.001;
params.nsteps    = 500;   % many steps, because T1 recovery is slow
params.flipangle = pi/2;
params.fliptime  = 0.0100;

titlestr = 'T1 and T2 relaxation in rotating reference frame';
animateSpins(params, fH, titlestr, saveMovieFlag);

%% T1 and T2 relaxation, matched time scales
fH = figure;
params = spinsDefaultParams();
params.larmor    = 0;
params.t2        = params.t1;
params.dt        = 0.01;
params.nsteps    = 150;
params.flipangle = pi/2;
params.fliptime  = 0.100;

titlestr = 'T1 and T2 relaxation with matched time constants';
animateSpins(params, fH, titlestr, saveMovieFlag);

%% Slow 90 degree flip in rotating reference frame
fH = figure;
params = spinsDefaultParams();
params.dt       = 0.0001;
params.nsteps   = 150;
params.fliptime = 0.001;
params.larmor   = 0;

titlestr = 'Slow 90 degree flip';
animateSpins(params, fH, titlestr, saveMovieFlag);

%% Continuous flipping
fH = figure;
params = spinsDefaultParams();
params.dt        = 0.0001;
params.nsteps    = 150;
params.fliptime  = 0.001;
params.larmor    = 0;
params.flipangle = 50*pi;
params.B1freq    = 250;

titlestr = 'Continuous flipping';
animateSpins(params, fH, titlestr, saveMovieFlag);
