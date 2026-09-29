function spins = spinsPrecess(spins, params, offsetStep)
% Larmor precession about B0.
%
%   spins = spinsPrecess(spins, params, offsetStep)
%
% Every spin advances in azimuth by params.larmorStep, plus offsetStep: the
% extra phase per time step for each spin from its own static B0 offset,
% which is what produces T2* decay. Setting params.larmor to 0 puts you in
% the rotating reference frame, where the offsets are all that is left.
%
% See also spinsInitialize, spinsTimeStep

[azimuth, elevation, radius] = cart2sph(spins(:,1), spins(:,2), spins(:,3));

azimuth = azimuth + params.larmorStep + offsetStep;

[x, y, z] = sph2cart(azimuth, elevation, radius);
spins = [x y z];

end
