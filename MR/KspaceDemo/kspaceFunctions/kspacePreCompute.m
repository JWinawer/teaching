function spins = kspacePreCompute(sim, gradients, xygrid, b0noise)
% Set the spins to their state at the start of the readout, and precompute
% the steps if the sequence repeats itself.
%
%   spins = kspacePreCompute(sim, gradients, xygrid, b0noise)
%
% Outputs
%   spins.total      - spin state after the wait before the readout
%   spins.afterDelay - a copy of that state, used to restart each new shot
%   spins.precompute, spins.precomputeIndex - the distinct steps, and which
%                      one each sample uses. Only set if there are 20 or fewer
%                      distinct steps (true for EPI), since otherwise
%                      precomputing saves little and uses a lot of memory.
%
% Winawer, Vistasoft, 2009

% Effect of the wait between excitation and the start of the readout
spins = kspaceComputeOnePoint(sim, gradients, xygrid, b0noise, [], 0);
spins.total      = spins.step;
spins.afterDelay = spins.step;

% Find the distinct steps. For EPI there are only a handful.
[b, m, n] = unique([gradients.y' gradients.x' gradients.T'], "rows");
maxPrecompute = 20;
if size(b, 1) > maxPrecompute
    return
end

precompute = zeros([size(xygrid.x) size(b, 1)]);
for ii = 1:size(b, 1)
    tmpspins = kspaceComputeOnePoint(sim, gradients, xygrid, b0noise, [], m(ii));
    precompute(:,:,ii) = tmpspins.step;
end
spins.precompute      = precompute;
spins.precomputeIndex = n;

end
