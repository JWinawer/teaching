function params = kspaceDefaultParams()
% Default parameters for the k-space demo, in everyday scanner units.
%
%   params = kspaceDefaultParams()
%
% Edit the fields and pass the struct to kspaceSimulate (no graphics) or
% kspaceDemo (with the dialog and plots). Values are in the units a scanner
% console uses (mm, ms, kHz, ppm). kspaceDerivedParams converts them to SI
% units internally, so you never need to.
%
% Fields
%   imfile       - Image to scan. A file name (e.g. "face.jpg"), "other" to
%                  pick a file, or a numeric matrix (scripts only).
%   sequenceType - "epi" or "spiral".
%   noiseType    - Spatial pattern of B0 field error: "none", "local offset",
%                  "random offset", "random lowpass", "x gradient",
%                  "y gradient", "dc offset", or "map" (a measured field map).
%   noiseScale   - Size of the B0 field error, in parts per million of B0.
%                  Ignored for "map", which is already in real units.
%   FOV          - Field of view of the scan, mm. Smaller than imSize gives
%                  wraparound (aliasing).
%   res          - Pixel size of the reconstructed image, mm.
%   imSize       - Width of the simulated object, mm.
%   imRes        - Pixel size of the simulated object, mm. Should be finer than
%                  res, so that each reconstructed pixel holds several
%                  simulated spins. Otherwise there can be no dephasing within
%                  a pixel.
%   bandwidth    - Total receiver bandwidth, kHz. Sets the time between samples
%                  (dwell time = 1/bandwidth).
%   echoTime     - Echo time (TE), ms: the time from excitation to the centre
%                  of k-space. Must be long enough for the readout to reach the
%                  centre; kspaceSimulate reports the minimum if it is not.
%   t2star       - T2* decay of the tissue, ms, from causes smaller than one
%                  simulated pixel. Inf means no decay. May be a matrix the size
%                  of the image (scripts only). Field errors from noiseType are
%                  simulated separately and add further dephasing on top.
%   oversample   - Number of spiral shots (spiral only).
%   B0           - Main field strength, tesla.
%   showProgress - true to redraw the plots as k-space fills (slower).
%   loop         - kspaceDemo only: true to reopen the dialog after each run.
%
% Example
%   params = kspaceDefaultParams();
%   params.noiseType = "dc offset";
%   result = kspaceSimulate(params);
%   imagesc(result.recon); axis image; colormap gray
%
% See also kspaceSimulate, kspaceDemo, kspaceDerivedParams

params.imfile       = "axialBrain.jpg";
params.sequenceType = "epi";
params.noiseType    = "local offset";
params.noiseScale   = 0.5;   % ppm
params.FOV          = 180;   % mm
params.res          = 2;     % mm
params.imSize       = 180;   % mm
params.imRes        = 1;     % mm
params.bandwidth    = 125;   % kHz
params.echoTime     = 40;    % ms
params.t2star       = Inf;   % ms
params.oversample   = 1;     % spiral shots
params.B0           = 3;     % tesla
params.showProgress = false;
params.loop         = true;

end
