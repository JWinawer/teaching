function [dkx, dky, nDwells] = kspaceSpiral(sim)
% Make a spiral-out trajectory through k-space.
%
%   [dkx, dky, nDwells] = kspaceSpiral(sim)
%
% See McRobbie et al (MRI from picture to proton), 2nd edition, p 370, box.
%
% This is an Archimedean spiral, meaning
%   A = c*theta
% where A is the distance from the center of k-space, theta is the angle
% (which keeps increasing beyond 2*pi as the spiral wraps around), and c is
% a constant. In kx, ky space:
%
%   kx = 1/(2*pi*FOV) * theta * sin(theta)
%   ky = 1/(2*pi*FOV) * theta * cos(theta)
%
% With c = 1/(2*pi*FOV), successive turns are 1/FOV apart, which is the
% spacing needed to avoid wraparound. The step per sample is the derivative
% of the k-space position with respect to theta, times dtheta per sample:
%
%   dkx = 1/(2*pi*FOV) * dtheta * (sin(theta) + theta*cos(theta))
%   dky = 1/(2*pi*FOV) * dtheta * (cos(theta) - theta*sin(theta))
%
% Theta increases at a constant rate, so the spiral is traced at a constant
% angular speed. Samples are therefore dense near the center of k-space and
% sparse at the edge. kspaceRecon corrects for this.
%
% The number of samples is the number of reconstructed pixels, in a single
% shot. Outputs are the k-space step per sample (cycles/m) and the duration
% of each step (in dwell times). See kspaceMakePulseSequence.
%
% See also kspaceEPI, kspaceMakePulseSequence

nSamples = sim.nPixels^2;
c        = 1/(2*pi*sim.FOV);

theta  = linspace(0, sim.nPixels*pi, nSamples);
dtheta = theta(2) - theta(1);

dkx     = c*dtheta*(sin(theta) + theta.*cos(theta));
dky     = c*dtheta*(cos(theta) - theta.*sin(theta));
nDwells = ones(1, nSamples);

end
