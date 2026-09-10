function Spins = rotateB1(Spins, params, stepnum)
% Rotation of the spins by the RF field B1.
%
%   Spins = rotateB1(Spins, params, stepnum)
%
% Does nothing unless an RF pulse is on at this time step. B1 lies in the
% transverse plane and rotates with the spins at the Larmor frequency, which
% is what makes the pulse resonant: a small push repeated in step with the
% precession accumulates instead of averaging away.
%
% We rotate the spin axes rather than adding the cross product of the spin
% axes with the B1 axis. The cross product displaces each spin along a
% straight line, which takes it off the unit sphere; a rotation does not.

pulse = params.RFpulse(stepnum);

if pulse == 0, return; end

% Direction of the B1 axis in the transverse plane. It tracks the Larmor
% phase, plus whatever fixed phase this pulse was given: 0 is along +x and
% pi/2 is along +y.
theta = stepnum * params.larmor * 2*pi * params.dt + params.flipphase(pulse);

% Radians of rotation about that axis in one time step. This is set in
% spinsAddDerivedParameters so that the steps this pulse lands on sum to
% exactly the requested flip angle.
deltaE = params.flipstep(pulse);

axang = [cos(theta) sin(theta) 0 -deltaE];
rotm  = axang2rotm(axang);

Spins = Spins*rotm;

end
