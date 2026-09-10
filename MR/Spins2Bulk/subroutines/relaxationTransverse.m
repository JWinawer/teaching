function Spins = relaxationTransverse(Spins, params)
% T2 relaxation: a random walk of each spin's azimuth.
%
%   Spins = relaxationTransverse(Spins, params)
%
% Each spin's phase around B0 takes an independent random step, so the
% population gradually loses the phase coherence created by the RF pulse.
% Elevation is untouched, so this affects only the transverse magnetization.
% See spinsAddDerivedParameters for how the step size is set.

% t2 = inf means no transverse relaxation, so there is nothing to do
if params.t2stepsize == 0, return; end

[azimuth, elevation, r] = cart2sph(Spins(:,1), Spins(:,2), Spins(:,3));
azimuth = azimuth + randn(size(azimuth))*params.t2stepsize;
[x, y, z] = sph2cart(azimuth, elevation, r);
Spins = [x y z];

end
