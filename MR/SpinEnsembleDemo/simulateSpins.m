function [M, params, Spins] = simulateSpins(params)
% Run the spin simulation without drawing anything.
%
%   [M, params, Spins] = simulateSpins(params)
%
% Returns the bulk magnetization M as nsteps x 3, in units of the
% equilibrium magnetization, along with params with its derived fields added
% and the final state of the spins.
%
% This is the same physics as animateSpins but with no graphics, so it runs
% in a few milliseconds instead of a few seconds. Use it when you want a
% curve to plot or a number to compare rather than an animation to watch,
% for instance to put two tissue types side by side.
%
% See also ANIMATESPINS, SPINSDEFAULTPARAMS

if ~exist('params', 'var') || isempty(params), params = spinsDefaultParams(); end

params = spinsAddDerivedParameters(params);

[Spins, B_dist, ~, offsetStep] = initializeSpins(params);

if B_dist.Mz > 0
    Mscale = params.nspins * B_dist.Mz;
else
    Mscale = params.nspins;
end

M = zeros(params.nsteps, 3);

for stepnum = 1:params.nsteps
    Spins = spinsTimeStep(Spins, params, stepnum, B_dist, offsetStep);
    M(stepnum,:) = sum(Spins)/Mscale;
end

end
