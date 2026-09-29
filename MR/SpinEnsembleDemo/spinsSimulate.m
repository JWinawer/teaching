function [M, params, spins] = spinsSimulate(params)
% Run the spin simulation without drawing anything.
%
%   [M, params, spins] = spinsSimulate()
%   [M, params, spins] = spinsSimulate(params)
%
% This is the same physics as spinsAnimate but with no graphics, so it runs
% in a few milliseconds instead of a few seconds. Use it when you want a
% curve to plot or a number to compare rather than an animation to watch,
% for instance to put two tissue types side by side.
%
% Inputs
%   params - settings (default: spinsDefaultParams()). Missing fields take
%            their defaults.
%
% Outputs
%   M      - bulk magnetization, nSteps x 3 (Mx, My, Mz), in units of the
%            equilibrium magnetization
%   params - the settings, with derived fields added (spinsDerivedParams).
%            params.t is the time of each step, in ms.
%   spins  - the final state of the spins, nSpins x 3
%
% Example: Mxy against time
%   [M, params] = spinsSimulate();
%   plot(params.t, vecnorm(M(:,1:2), 2, 2)); xlabel("Time (ms)")
%
% See also spinsAnimate, spinsDefaultParams

arguments
    params (1,1) struct = spinsDefaultParams()
end

spinsCheckPaths();
params = spinsDerivedParams(params);

[spins, boltzmann, offsetStep, magnetizationScale] = spinsInitialize(params);

M = zeros(params.nSteps, 3);
for stepIndex = 1:params.nSteps
    spins = spinsTimeStep(spins, params, stepIndex, boltzmann, offsetStep);
    M(stepIndex,:) = sum(spins)/magnetizationScale;
end

end
