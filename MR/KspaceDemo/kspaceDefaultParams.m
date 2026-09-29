function params = kspaceDefaultParams()
% Default parameters for the k-space demo.
%
%   params = kspaceDefaultParams()
%
% Edit the fields and pass the struct to kspaceSimulate (no graphics) or
% kspaceDemo (with the dialog and plots). Values are in the units a scanner
% console uses: mm, ms, kHz and ppm. Fields you leave out take these
% defaults, and a field name that is not listed here is an error, so that a
% typo cannot be silently ignored.
%
% The object
%   imageFile       - Image to scan: a file in data/ (e.g. "face.jpg"),
%                     "other" to pick a file, or a numeric matrix (scripts
%                     only).
%   objectSize      - Width of the object, mm.
%   objectPixelSize - Pixel size of the simulated object, mm. Should be finer
%                     than pixelSize, so that each reconstructed pixel holds
%                     several simulated spins. Otherwise there can be no
%                     dephasing within a pixel.
%   t2star          - T2* decay of the tissue, ms, from causes smaller than
%                     one simulated pixel. Inf means no decay. May be a matrix
%                     the size of the image (scripts only). Field errors (see
%                     fieldErrorType) are simulated separately and add further
%                     dephasing on top.
%
% The scan
%   sequenceType    - "epi" or "spiral".
%   FOV             - Field of view, mm. Smaller than objectSize gives
%                     wraparound (aliasing).
%   pixelSize       - Pixel size of the reconstructed image, mm.
%   bandwidth       - Total receiver bandwidth, kHz. Sets the time between
%                     samples (dwell time = 1/bandwidth).
%   echoTime        - Echo time (TE), ms: the time from excitation to the
%                     center of k-space. Must be long enough for the readout
%                     to reach the center; kspaceSimulate reports the minimum
%                     if it is not.
%   B0              - Main field strength, tesla.
%
% Errors in the main field
%   fieldErrorType  - Spatial pattern of the error in B0: "none",
%                     "local offset", "random offset", "random lowpass",
%                     "x gradient", "y gradient", "dc offset", or "map" (a
%                     measured field map).
%   fieldErrorPpm   - Size of the error, in parts per million of B0. Ignored
%                     for "map", which is already in real units.
%
% Display
%   progressDisplay - How often to redraw the plots while k-space fills:
%                     "final" (only the end result), "line" (once per EPI
%                     line, a few seconds) or "point" (after every sample,
%                     so every step is shown; this takes minutes). With a
%                     spiral, "point" updates the image once per turn of the
%                     spiral.
%   keepDialogOpen  - kspaceDemo only: true to reopen the dialog after each
%                     run.
%
% Example
%   params = kspaceDefaultParams();
%   params.fieldErrorType = "dc offset";
%   result = kspaceSimulate(params);
%   imagesc(result.recon); axis image; colormap gray
%
% See also kspaceSimulate, kspaceDemo, kspaceDerivedParams

params.imageFile       = "axialBrain.jpg";
params.objectSize      = 180;    % mm
params.objectPixelSize = 1;      % mm
params.t2star          = Inf;    % ms
params.sequenceType    = "epi";
params.FOV             = 180;    % mm
params.pixelSize       = 2;      % mm
params.bandwidth       = 125;    % kHz
params.echoTime        = 40;     % ms
params.B0              = 3;      % tesla
params.fieldErrorType  = "local offset";
params.fieldErrorPpm   = 0.5;    % ppm
params.progressDisplay = "final";
params.keepDialogOpen  = true;

end
