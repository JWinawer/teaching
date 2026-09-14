function Spins = rotateB0(Spins, params, offsetStep)
% Larmor precession about B0.
%
%   Spins = rotateB0(Spins, params, offsetStep)
%
% Every spin advances in azimuth by params.larmorStep. If offsetStep is
% given, it is added on: it is the extra phase per time step for each spin
% arising from its own static B0 offset, and it is what produces T2* decay.
% Setting params.larmor to 0 puts you in the rotating reference frame, where
% the offsets are all that is left.

[azimuth, elevation, r] = cart2sph(Spins(:,1), Spins(:,2), Spins(:,3));

azimuth = azimuth + params.larmorStep;

if exist('offsetStep', 'var') && ~isempty(offsetStep)
    azimuth = azimuth + offsetStep;
end

[x, y, z] = sph2cart(azimuth, elevation, r);
Spins = [x y z];

end
