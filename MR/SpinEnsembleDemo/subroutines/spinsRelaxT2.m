function spins = spinsRelaxT2(spins, params)
% T2 relaxation: a random walk of each spin's azimuth.
%
%   spins = spinsRelaxT2(spins, params)
%
% Each spin's phase around B0 takes an independent random step, so the
% population gradually loses the phase coherence created by the RF pulse.
% Elevation is untouched, so this affects only the transverse magnetization.
% See spinsDerivedParams for how the step size is set.
%
% See also spinsRelaxT1, spinsTimeStep

% t2 = Inf means no transverse relaxation, so there is nothing to do
if params.t2StepSize == 0
    return
end

[azimuth, elevation, radius] = cart2sph(spins(:,1), spins(:,2), spins(:,3));
azimuth = azimuth + randn(size(azimuth))*params.t2StepSize;
[x, y, z] = sph2cart(azimuth, elevation, radius);
spins = [x y z];

end
