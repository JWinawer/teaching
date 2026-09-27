function [gx, gy, T, shotStart] = kspaceEPI(sim)
% Generate an EPI gradient sequence
%
%   [gx, gy, T, shotStart] = kspaceEPI(sim)
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
% Outputs are k-space steps per sample (cycles per metre) and the duration of
% each step (in dwell times). shotStart is all false, because this is a
% single-shot sequence. See kspaceMakePulseSequence.

freq     = sim.freq;
nsamples = freq^2;   % one sample per reconstructed pixel
dk       = 1/sim.FOV; % k-space step between samples, cycles per metre

T  = ones(1, nsamples);
gx = zeros(1, nsamples);   % phase encode
gy = zeros(1, nsamples);   % readout
shotStart = false(1, nsamples);

% Readout (y gradient): + on odd rows, - on even rows
for row = 1:2:freq
    inds = (1:freq) + (row-1)*freq;
    gy(inds)      = dk;
    gy(inds+freq) = -dk;
end

% Phase encode (x gradient): one blip at the start of each new row, with the
% readout gradient off during the blip
blips     = freq+1:freq:nsamples-freq+1;
gx(blips) = dk;
gy(blips) = 0;

% First step moves to the corner of k-space. It takes half a row.
gx(1) = -dk;
gy(1) = -dk;
T(1)  = freq/2;

end
