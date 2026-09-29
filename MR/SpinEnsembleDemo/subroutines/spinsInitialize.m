function [spins, boltzmann, offsetStep, magnetizationScale] = spinsInitialize(params)
% Create a population of spins at thermal equilibrium.
%
%   [spins, boltzmann, offsetStep, magnetizationScale] = spinsInitialize(params)
%
% Outputs
%   spins      - nSpins x 3, one unit vector per row
%   boltzmann  - the equilibrium elevation distribution
%                (spinsBoltzmannDistribution)
%   offsetStep - nSpins x 1, the extra phase per time step, in radians, that
%                each spin picks up from its own static B0 offset
%   magnetizationScale - the sum of all spins at equilibrium. Dividing the
%                sum of the spins by this gives M in units of the equilibrium
%                magnetization.
%
% The offsets are drawn from a Lorentzian distribution, which is what makes
% the resulting dephasing exponential in time, so that the observed decay
% constant combines with T2 as 1/t2star = 1/t2 + 1/t2prime. Each offset is
% fixed for the whole run, which is why a 180 degree pulse can undo the
% dephasing it causes.
%
% See also spinsBoltzmannDistribution, spinsDerivedParams

msPerS = 1000;

boltzmann = spinsBoltzmannDistribution(params.k);

% Elevation is biased toward B0 (Z+); azimuth is uniform. If the field is
% still off at the first step (see params.fieldOnTime), there is nothing to
% bias the spins yet, so they start spread evenly over the sphere instead.
% boltzmann still describes the equilibrium they relax toward once it comes on.
if params.fieldOn(1)
    elevation = boltzmann.sample(params.nSpins);
else
    elevation = spinsBoltzmannDistribution(0).sample(params.nSpins);
end
azimuth = rand(size(elevation))*2*pi;

% Spherical to Cartesian, on the unit sphere
radius = ones(size(azimuth));
[x, y, z] = sph2cart(azimuth, elevation, radius);
spins = [x; y; z]';

% Static B0 offsets, in Hz, drawn from a Lorentzian with half width at half
% maximum params.b0Spread, then converted to radians per time step.
if params.b0Spread > 0
    offsetHz   = params.b0Spread*tan(pi*(rand(params.nSpins, 1) - 0.5));
    offsetStep = 2*pi*offsetHz*params.dt/msPerS;
else
    offsetStep = zeros(params.nSpins, 1);
end

% Use the expected equilibrium magnetization rather than the realized one,
% so that any wobble away from Mz = 1 is the honest sampling noise of
% simulating only nSpins spins instead of the ~10^19 in a real voxel. With
% k = 0 there is no field and no equilibrium magnetization, so use nSpins;
% the bulk vector then correctly shows up as a tiny residual near the origin.
if boltzmann.Mz > 0
    magnetizationScale = params.nSpins*boltzmann.Mz;
else
    magnetizationScale = params.nSpins;
end

end
