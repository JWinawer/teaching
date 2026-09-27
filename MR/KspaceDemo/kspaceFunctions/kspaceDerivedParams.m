function sim = kspaceDerivedParams(params)
% Convert demo parameters to SI units and add derived constants.
%
%   sim = kspaceDerivedParams(params)
%
% params is in everyday units (see kspaceDefaultParams). sim holds the same
% settings in SI units (m, s, Hz, T), plus the values derived from them. The
% simulation functions all use sim. params itself is never changed, so it can
% be passed back in to run again.
%
% See also kspaceDefaultParams, kspaceSimulate

mm = 1e-3;
ms = 1e-3;

% Gyromagnetic ratio of hydrogen, in radians per second per tesla
gamma = 42.58e6*2*pi;

% Field of view is rounded so that the number of reconstructed pixels is
% even. The number of pixels must be even for the EPI trajectory.
res  = params.res*mm;
FOV  = round(params.FOV*mm/res/2)*res*2;
freq = round(FOV/res);

imSize = params.imSize*mm;
imRes  = params.imRes*mm;
imFreq = round(imSize/imRes);

% T2* in seconds. A map is resized to the simulated image grid.
t2star = params.t2star*ms;
if ~isscalar(t2star)
    t2star = imresize(t2star, [imFreq imFreq], "nearest");
end

% Dwell time is the time between successive k-space samples
bandwidth = params.bandwidth*1e3;
dt        = 1/bandwidth;

% Gradient strength per unit step. The maths:
%   gx*gamma*dt = 2*pi
% So one dwell time at this gradient adds a 2*pi phase difference per metre.
% The pulse sequence functions then scale this by the k-space step they want
% per sample (in cycles per metre), which gives a gradient in tesla per metre.
gx = 2*pi/(gamma*dt);

sim.imfile       = params.imfile;
sim.sequenceType = string(params.sequenceType);
sim.noiseType    = string(params.noiseType);
sim.noiseScale   = params.noiseScale*1e-6;   % fraction of B0
sim.res          = res;
sim.FOV          = FOV;
sim.freq         = freq;                     % reconstructed pixels per side
sim.imSize       = imSize;
sim.imRes        = imRes;
sim.imFreq       = imFreq;                   % simulated pixels per side
sim.bandwidth    = bandwidth;
sim.dt           = dt;
sim.echoTime     = params.echoTime*ms;
sim.t2star       = t2star;
sim.B0           = params.B0;
sim.gamma        = gamma;
sim.gx           = gx;
sim.gy           = gx;
sim.showProgress = params.showProgress;

end
