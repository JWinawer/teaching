function spins = spinsApplyRF(spins, params, stepIndex)
% Rotate the spins by the RF field B1, if a pulse is on at this step.
%
%   spins = spinsApplyRF(spins, params, stepIndex)
%
% B1 lies in the transverse plane and rotates with the spins at the Larmor
% frequency, which is what makes the pulse resonant: a small push repeated
% in step with the precession accumulates instead of averaging away.
%
% We rotate the spins rather than adding the cross product of each spin with
% the B1 axis. The cross product moves each spin along a straight line,
% which takes it off the unit sphere; a rotation does not.
%
% See also spinsDerivedParams, spinsTimeStep

pulse = params.rfPulse(stepIndex);
if pulse == 0
    return
end

% Direction of the B1 axis in the transverse plane. It tracks the precession
% phase the spins have built up so far, plus the fixed phase this pulse was
% given: 0 is along +x and pi/2 is along +y.
theta = params.larmorPhase(stepIndex) + params.flipPhaseRad(pulse);
b1Axis = [cos(theta) sin(theta) 0];

% Rotation about that axis in one time step. spinsDerivedParams sets this so
% that the steps of a pulse add up to exactly the requested flip angle.
angle = params.flipStep(pulse);

% The spins are row vectors, so multiplying on the right by the rotation
% matrix for -angle rotates them by +angle about the axis.
spins = spins*rotationMatrix(b1Axis, -angle);

end

function R = rotationMatrix(u, angle)
% Rotation matrix about the unit axis u, by Rodrigues' formula:
%   R = I + sin(angle)*S + (1 - cos(angle))*S^2
% where S is the cross-product (skew-symmetric) matrix of u. The elements are
% written out, which is faster than forming S.
c = cos(angle);
s = sin(angle);
v = 1 - c;
R = [u(1)*u(1)*v + c,      u(1)*u(2)*v - u(3)*s, u(1)*u(3)*v + u(2)*s
     u(1)*u(2)*v + u(3)*s, u(2)*u(2)*v + c,      u(2)*u(3)*v - u(1)*s
     u(1)*u(3)*v - u(2)*s, u(2)*u(3)*v + u(1)*s, u(3)*u(3)*v + c];
end
