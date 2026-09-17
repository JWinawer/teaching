function [Spins, B_dist, M0, offsetStep] = initializeSpins(params)
% Create a population of spins at thermal equilibrium.
%
%   [Spins, B_dist, M0, offsetStep] = initializeSpins(params)
%
% Spins      is nspins x 3, one unit vector per row
% B_dist     is the equilibrium elevation distribution (boltzmannDistribution)
% M0         is the bulk magnetization vector at the start, sum of Spins
% offsetStep is nspins x 1, the extra azimuthal phase per time step that
%            each spin picks up from its own static B0 offset
%
% The offsets are drawn from a Lorentzian distribution, which is what makes
% the resulting dephasing exponential in time, so that the observed decay
% constant combines with T2 as 1/t2star = 1/t2 + 1/t2prime. Each offset is
% fixed for the whole run, which is why a 180 degree pulse can undo the
% dephasing it causes.

B_dist = boltzmannDistribution(params.k);

% Elevation is biased toward B0 (Z+); azimuth is uniform. If the field is
% still off at the first step (see params.fieldOnTime), there is nothing to
% bias the spins yet, so they start spread evenly over the sphere instead.
% B_dist still describes the equilibrium they relax toward once it comes on.
startsInField = ~isfield(params, 'fieldOn') || params.fieldOn(1);
if startsInField
    elevation = B_dist.sample(params.nspins);
else
    elevation = boltzmannDistribution(0).sample(params.nspins);
end
azimuth   = rand(size(elevation)) * 2*pi;

% Spherical to cartesian, on the unit sphere
r = ones(size(azimuth));
[x, y, z] = sph2cart(azimuth, elevation, r);
Spins = [x; y; z]';

M0 = sum(Spins);

% Static B0 offsets, in Hz, drawn from a Lorentzian with half width at half
% maximum params.b0spread, then converted to radians per time step.
if params.b0spread > 0
    offsetHz = params.b0spread * tan(pi*(rand(params.nspins,1) - 0.5));
    offsetStep = 2*pi * offsetHz * params.dt;
else
    offsetStep = zeros(params.nspins, 1);
end

end
