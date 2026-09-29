function [dkx, dky, nDwells] = kspaceEPI(sim)
% Make an EPI trajectory through k-space.
%
%   [dkx, dky, nDwells] = kspaceEPI(sim)
%
% EPI works in a kind of zigzag. We start at one corner of k-space, move
% across a row in the readout (frequency encode) direction, step to the next
% row in the phase encode direction, move back across in the opposite
% direction, and so on. So the phase encode gradient blips once per row, and
% the readout gradient alternates + / - one row at a time.
%
% Here the readout runs along y (image rows, vertical in the plots) and phase
% encoding runs along x (image columns, horizontal). Field errors therefore
% shift and stretch the image mostly horizontally, because the phase encode
% direction has a far lower bandwidth per pixel.
%
% Outputs are the k-space step per sample (cycles/m) and the duration of
% each step (in dwell times). See kspaceMakePulseSequence.
%
% See also kspaceSpiral, kspaceMakePulseSequence

n        = sim.nPixels;
nSamples = n^2;          % one sample per reconstructed pixel
dk       = 1/sim.FOV;    % k-space step between samples, cycles/m

nDwells = ones(1, nSamples);
dkx     = zeros(1, nSamples);   % phase encode
dky     = zeros(1, nSamples);   % readout

% Readout (y): + on odd rows, - on even rows
for row = 1:2:n
    inds = (1:n) + (row-1)*n;
    dky(inds)   = dk;
    dky(inds+n) = -dk;
end

% Phase encode (x): one blip at the start of each new row, with the readout
% gradient off during the blip
blips      = n+1:n:nSamples-n+1;
dkx(blips) = dk;
dky(blips) = 0;

% The first step moves to the corner of k-space. It takes half a row.
dkx(1)     = -dk;
dky(1)     = -dk;
nDwells(1) = n/2;

end
