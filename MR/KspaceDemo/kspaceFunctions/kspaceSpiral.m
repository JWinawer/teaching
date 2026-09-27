function [gx, gy, T, shotStart] = kspaceSpiral(sim)
% Generate a spiral-out gradient sequence
%
%   [gx, gy, T, shotStart] = kspaceSpiral(sim)
%
% See McRobbie et al (MRI from picture to proton), 2nd edition, p 370, box.
%
% This is an Archimedean spiral, meaning
%   A = c*theta
% where A is the distance from the centre of k-space, theta is the angle
% (which keeps increasing beyond 2*pi as the spiral wraps around), and c is
% a constant. In kx,ky space:
%
%   kx = 1/(2*pi*FOV) * theta * sin(theta)
%   ky = 1/(2*pi*FOV) * theta * cos(theta)
%
% With c = 1/(2*pi*FOV), successive turns are 1/FOV apart, which is the
% spacing needed to avoid wraparound. The gradients are the derivatives of the
% k-space position with respect to theta (times dtheta per sample):
%
%   Gx = 1/(2*pi*FOV) * dtheta * (sin(theta) + theta*cos(theta))
%   Gy = 1/(2*pi*FOV) * dtheta * (cos(theta) - theta*sin(theta))
%
% Theta increases at a constant rate, so the spiral is traced at a constant
% angular speed. Samples are therefore dense near the centre of k-space and
% sparse at the edge. kspaceRecon corrects for this.
%
% Outputs are k-space steps per sample (cycles per metre) and the duration of
% each step (in dwell times). shotStart is true for the first sample of each
% shot after the first. See kspaceMakePulseSequence.
%
% The number of samples per shot is the number of reconstructed pixels. Each
% extra shot (sim.oversample > 1) is another full spiral, rotated, so extra
% shots add sampling density. They do not split the spiral into interleaves.
% Each shot is a new excitation: kspaceSimulate resets the spins to their
% state at the start of the first shot, so field-error phase and T2* decay
% start again from the same point.

nsamples    = sim.freq^2;
noversample = sim.oversample;
c           = 1/(2*pi*sim.FOV);

T  = ones(1, nsamples*noversample);
gx = zeros(1, nsamples*noversample);
gy = zeros(1, nsamples*noversample);
shotStart = false(1, nsamples*noversample);

theta  = linspace(0, sim.freq*pi, nsamples);
dtheta = theta(2) - theta(1);

for ii = 0:noversample-1
    inds   = (1:nsamples) + ii*nsamples;
    offset = ii/noversample*2*pi; % angular offset for each shot
    gx(inds) = c*dtheta*(sin(theta+offset) + theta.*cos(theta+offset));
    gy(inds) = c*dtheta*(cos(theta+offset) - theta.*sin(theta+offset));

    % Return to the centre of k-space before each extra shot. This step sets
    % the k-space positions. The spins themselves are reset by kspaceSimulate.
    if ii > 0
        previousInds = 1:inds(1)-1;
        xpos = gx(previousInds)*T(previousInds)';
        ypos = gy(previousInds)*T(previousInds)';
        gx(inds(1)) = -xpos/length(previousInds);
        gy(inds(1)) = -ypos/length(previousInds);
        T(inds(1))  = length(previousInds);
        shotStart(inds(1)) = true;
    end
end

end
