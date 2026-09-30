function kspaceShowPlots(f, result, options)
% Plot the object, its k-space, the measured k-space, and the reconstruction.
%
%   kspaceShowPlots(f, result)
%   kspaceShowPlots(f, result, DrawEveryUpdate=true)
%
% f is a figure handle and result is the output of kspaceSimulate. The first
% call for a new set of parameters builds the plots. Later calls (while
% k-space fills) only update the data, which is much faster.
%
% By default the screen is redrawn at most about 20 times a second, and
% updates in between are skipped, which keeps a long run fast. With
% DrawEveryUpdate=true every update is drawn, so that no step is skipped.
%
% Panels
%   Top row:    the object, its full k-space, and the B0 field error map
%   Middle row: the reconstructed image, the k-space measured so far, and the
%               spin pattern at the current sample
%   Bottom row: the gradient waveforms against time since excitation
%
% See also kspaceSimulate

arguments
    f (1,1) matlab.ui.Figure
    result (1,1) struct
    options.DrawEveryUpdate (1,1) logical = false
end

sim       = result.sim;
kspace    = result.kspace;
gradients = result.gradients;
t         = max(result.t, 1);

handles = getappdata(f, "kspaceHandles");
if isempty(handles) || ~isvalid(handles.recon) || ~isequal(handles.sim, sim)
    handles = initializePlots(f, result);
end

% Measured k-space, on the same log scale as the object's k-space
measured = fftshift(kspace.grid.signal);
handles.kspace.CData  = log10(abs(measured) + handles.floor);
handles.kmarker.XData = kspace.samples.kx(t);
handles.kmarker.YData = kspace.samples.ky(t);

% Reconstruction
handles.recon.CData = result.recon;

% Spin pattern
handles.spins.CData = real(result.spins.state);
handles.spinsSubtitle.String = sprintf("k = (%.0f, %.0f) cycles/m", ...
    kspace.samples.kx(t), kspace.samples.ky(t));

% Current time on the gradient plot, shown only while k-space fills
msPerS = 1e3;
handles.now.Value = (gradients.delayDwells + sum(gradients.nDwells(1:t)))*sim.dt*msPerS;
handles.now.Visible = result.t < numel(gradients.nDwells);

if options.DrawEveryUpdate
    drawnow
else
    drawnow limitrate
end

end

function handles = initializePlots(f, result)
% Build all the panels and return handles to the parts that change

sim       = result.sim;
object    = result.object;
gradients = result.gradients;
mmPerM    = 1e3;
msPerS    = 1e3;
mTPerT    = 1e3;

clf(f);
layout = tiledlayout(f, 3, 3, TileSpacing="compact", Padding="compact");

% Log scale shared by both k-space panels. The measured samples are sums of
% (image x pixel area), so the object's k-space is scaled the same way.
objectK = abs(fftshift(object.fft))*sim.objectPixelSize^2;
kPeak   = max(objectK(:));
handles.floor = kPeak*1e-4;
kCLim   = log10([handles.floor kPeak]);

% --- Object
ax = nexttile(layout, 1);
objectExtent = [0 sim.objectSize*mmPerM];
imagesc(ax, objectExtent, objectExtent, object.image);
axis(ax, "image");
colormap(ax, gray);
title(ax, "Object");
subtitle(ax, sprintf("%g mm pixels", sim.objectPixelSize*mmPerM));
xlabel(ax, "x (mm)");
ylabel(ax, "y (mm)");

% --- Object k-space, with the region the scan measures outlined
ax = nexttile(layout, 2);
kObject = (-sim.nObjectPixels/2:sim.nObjectPixels/2-1)/sim.objectSize;
imagesc(ax, kObject, kObject, log10(objectK + handles.floor), kCLim);
axis(ax, "image");
colormap(ax, gray);
hold(ax, "on");
kmax = sim.nPixels/(2*sim.FOV);
if sim.sequenceType == "spiral"
    angles = linspace(0, 2*pi, 200);
    plot(ax, kmax*cos(angles), kmax*sin(angles), "r-", LineWidth=1.5);
else
    plot(ax, kmax*[-1 1 1 -1 -1], kmax*[-1 -1 1 1 -1], "r-", LineWidth=1.5);
end
title(ax, "k-space of object");
subtitle(ax, "Red: region measured");
xlabel(ax, "k_x (cycles/m)");
ylabel(ax, "k_y (cycles/m)");

% --- B0 field error, in Hz
ax = nexttile(layout, 3);
errorHz = result.fieldError*sim.gamma/(2*pi);
range = [min(errorHz(:)) max(errorHz(:))];
cLimits = [-1 1]*max([abs(range) eps]);
imagesc(ax, objectExtent, objectExtent, errorHz, cLimits);
axis(ax, "image");
colormap(ax, parula);
colorbar(ax);
title(ax, "B0 field error (Hz)");
subtitle(ax, sprintf("Range %.1f to %.1f Hz", range));
xlabel(ax, "x (mm)");
ylabel(ax, "y (mm)");

% --- Reconstruction
ax = nexttile(layout, 4);
reconExtent = [0 sim.FOV*mmPerM];
handles.recon = imagesc(ax, reconExtent, reconExtent, zeros(sim.nPixels));
axis(ax, "image");
colormap(ax, gray);
title(ax, "Reconstructed image");
if sim.sequenceType == "epi"
    subtitle(ax, [sprintf("%g mm pixels", sim.pixelSize*mmPerM); "Readout vertical, phase encode horizontal"]);
else
    subtitle(ax, sprintf("%g mm pixels", sim.pixelSize*mmPerM));
end
xlabel(ax, "x (mm)");
ylabel(ax, "y (mm)");

% --- Measured k-space
ax = nexttile(layout, 5);
kGrid = (-sim.nPixels/2:sim.nPixels/2-1)/sim.FOV;
handles.kspace = imagesc(ax, kGrid, kGrid, kCLim(1)*ones(sim.nPixels), kCLim);
axis(ax, "image");
colormap(ax, gray);
hold(ax, "on");
handles.kmarker = plot(ax, 0, 0, "r+", MarkerSize=10, LineWidth=1.5);
title(ax, "k-space measured");
subtitle(ax, sprintf("TE = %g ms", sim.echoTime*msPerS));
xlabel(ax, "k_x (cycles/m)");
ylabel(ax, "k_y (cycles/m)");

% --- Spin pattern
ax = nexttile(layout, 6);
handles.spins = imagesc(ax, objectExtent, objectExtent, zeros(sim.nObjectPixels), [-1 1]);
axis(ax, "image");
colormap(ax, gray);
title(ax, "Spins now (real part)");
handles.spinsSubtitle = subtitle(ax, "k = (0, 0) cycles/m");
xlabel(ax, "x (mm)");
ylabel(ax, "y (mm)");

% --- Gradients against time since excitation, in mT/m
ax = nexttile(layout, 7, [1 3]);
tEdges   = (gradients.delayDwells + [0 cumsum(gradients.nDwells)])*sim.dt*msPerS;
gxmT     = gradients.dkx*sim.gradientPerStep*mTPerT;
gymT     = gradients.dky*sim.gradientPerStep*mTPerT;
% The readout is drawn first, so that the brief phase encode blips (one
% sample each in EPI) are drawn on top of it rather than hidden behind it
stairs(ax, tEdges, [gymT gymT(end)], "b-", DisplayName="G_y (readout)");
hold(ax, "on");
stairs(ax, tEdges, [gxmT gxmT(end)], "r-", LineWidth=1.5, DisplayName="G_x (phase encode)");
if sim.sequenceType == "spiral"
    legend(ax, ["G_y", "G_x"], Location="eastoutside");
else
    legend(ax, Location="eastoutside");
end
xline(ax, sim.echoTime*msPerS, "k--", "TE", HandleVisibility="off");
% The current time, while k-space fills. Hidden once the scan is done.
handles.now = xline(ax, tEdges(1), "g-", "now", LineWidth=1.5, HandleVisibility="off", ...
    LabelVerticalAlignment="bottom");
% Show only the readout, plus a small margin on each side. TE is included so
% that its marker is never cut off.
paddingFraction = 0.05;
tRange   = [min(tEdges(1), sim.echoTime*msPerS) max(tEdges(end), sim.echoTime*msPerS)];
tPadding = paddingFraction*diff(tRange);
xlim(ax, tRange + [-tPadding tPadding]);
title(ax, "Gradients");
subtitle(ax, "Time since excitation");
xlabel(ax, "time (ms)");
ylabel(ax, "gradient (mT/m)");

handles.sim = sim;
setappdata(f, "kspaceHandles", handles);

end
