function kspaceShowPlots(f, result)
% Plot the object, its k-space, the measured k-space, and the reconstruction.
%
%   kspaceShowPlots(f, result)
%
% f is a figure handle and result is the output of kspaceSimulate. The first
% call for a new set of parameters builds the plots. Later calls (while
% k-space fills) only update the data, which is much faster.
%
% Panels
%   Top row:    the object, its full k-space, and the B0 field error map
%   Middle row: the reconstructed image, the k-space measured so far, and the
%               spin pattern at the current sample
%   Bottom row: the gradient waveforms against time since excitation

sim       = result.sim;
kspace    = result.kspace;
gradients = result.gradients;
t         = max(result.t, 1);

h = getappdata(f, "kspaceHandles");
if isempty(h) || ~isvalid(h.recon) || ~isequal(h.sim, sim)
    h = initializePlots(f, result);
end

% Measured k-space, on the same log scale as the object's k-space
K = fftshift(kspace.grid.real + 1i*kspace.grid.imag);
h.kspace.CData = log10(abs(K) + h.floor);
h.kmarker.XData = kspace.vector.x(t);
h.kmarker.YData = kspace.vector.y(t);

% Reconstruction
h.recon.CData = result.recon;

% Spin pattern
h.spins.CData = real(result.spins.total);
h.spinsTitle.String = sprintf("Spins now (real part), k = (%.0f, %.0f) cycles/m", ...
    kspace.vector.x(t), kspace.vector.y(t));

% Current time on the gradient plot
tNow = (gradients.delay + sum(gradients.T(1:t)))*sim.dt*1e3;
h.now.Value = tNow;

drawnow limitrate

end

function h = initializePlots(f, result)
% Build all the panels and return handles to the parts that change

sim       = result.sim;
im        = result.im;
gradients = result.gradients;
mmPerM    = 1e3;

clf(f);
layout = tiledlayout(f, 3, 3, TileSpacing="compact", Padding="compact");

% Log scale shared by both k-space panels. The measured samples are sums of
% (image x pixel area), so the object's k-space is scaled the same way.
objectK = abs(fftshift(im.fft))*sim.imRes^2;
kPeak   = max(objectK(:));
h.floor = kPeak*1e-4;
kCLim   = log10([h.floor kPeak]);

% --- Object
ax = nexttile(layout, 1);
objectExtent = [0 sim.imSize*mmPerM];
imagesc(ax, objectExtent, objectExtent, im.orig);
axis(ax, "image");
colormap(ax, gray);
title(ax, sprintf("Object (%g mm pixels)", sim.imRes*mmPerM));
xlabel(ax, "x (mm)");
ylabel(ax, "y (mm)");

% --- Object k-space, with the region the scan measures outlined
ax = nexttile(layout, 2);
kObject = (-sim.imFreq/2:sim.imFreq/2-1)/sim.imSize;
imagesc(ax, kObject, kObject, log10(objectK + h.floor), kCLim);
axis(ax, "image");
colormap(ax, gray);
hold(ax, "on");
kmax = sim.freq/(2*sim.FOV);
if sim.sequenceType == "spiral"
    angles = linspace(0, 2*pi, 200);
    plot(ax, kmax*cos(angles), kmax*sin(angles), "r-", LineWidth=1.5);
else
    plot(ax, kmax*[-1 1 1 -1 -1], kmax*[-1 -1 1 1 -1], "r-", LineWidth=1.5);
end
title(ax, "k-space of object (red: region measured)");
xlabel(ax, "k_x (cycles/m)");
ylabel(ax, "k_y (cycles/m)");

% --- B0 field error, in Hz
ax = nexttile(layout, 3);
b0Hz = result.b0noise*sim.gamma/(2*pi);
range = [min(b0Hz(:)) max(b0Hz(:))];
cLimits = [-1 1]*max([abs(range) eps]);
imagesc(ax, objectExtent, objectExtent, b0Hz, cLimits);
axis(ax, "image");
colormap(ax, parula);
colorbar(ax);
title(ax, sprintf("B0 field error (Hz), range [%.1f, %.1f]", range));
xlabel(ax, "x (mm)");
ylabel(ax, "y (mm)");

% --- Reconstruction
ax = nexttile(layout, 4);
reconExtent = [0 sim.FOV*mmPerM];
h.recon = imagesc(ax, reconExtent, reconExtent, zeros(sim.freq));
axis(ax, "image");
colormap(ax, gray);
title(ax, sprintf("Reconstructed image (%g mm pixels)", sim.res*mmPerM));
if sim.sequenceType == "epi"
    subtitle(ax, "Readout: vertical. Phase encode: horizontal.");
end
xlabel(ax, "x (mm)");
ylabel(ax, "y (mm)");

% --- Measured k-space
ax = nexttile(layout, 5);
kGrid = (-sim.freq/2:sim.freq/2-1)/sim.FOV;
h.kspace = imagesc(ax, kGrid, kGrid, kCLim(1)*ones(sim.freq), kCLim);
axis(ax, "image");
colormap(ax, gray);
hold(ax, "on");
h.kmarker = plot(ax, 0, 0, "r+", MarkerSize=10, LineWidth=1.5);
title(ax, sprintf("k-space measured (TE = %g ms)", sim.echoTime*1e3));
xlabel(ax, "k_x (cycles/m)");
ylabel(ax, "k_y (cycles/m)");

% --- Spin pattern
ax = nexttile(layout, 6);
h.spins = imagesc(ax, objectExtent, objectExtent, zeros(sim.imFreq), [-1 1]);
axis(ax, "image");
colormap(ax, gray);
h.spinsTitle = title(ax, "Spins now (real part)");
xlabel(ax, "x (mm)");
ylabel(ax, "y (mm)");

% --- Gradients against time since excitation, in mT/m
ax = nexttile(layout, 7, [1 3]);
msPerS   = 1e3;
tEdges   = (gradients.delay + [0 cumsum(gradients.T)])*sim.dt*msPerS;
gxmT     = gradients.x*sim.gx*mmPerM;
gymT     = gradients.y*sim.gy*mmPerM;
stairs(ax, tEdges, [gxmT gxmT(end)], "r-", DisplayName="G_x (phase encode)");
hold(ax, "on");
stairs(ax, tEdges, [gymT gymT(end)], "b-", DisplayName="G_y (readout)");
if sim.sequenceType == "spiral"
    legend(ax, ["G_x", "G_y"], Location="eastoutside");
else
    legend(ax, Location="eastoutside");
end
xline(ax, sim.echoTime*msPerS, "k--", "TE", HandleVisibility="off");
h.now = xline(ax, tEdges(1), "g-", LineWidth=1.5, HandleVisibility="off");
xlim(ax, [0 tEdges(end)]);
title(ax, "Gradients (excitation at time 0)");
xlabel(ax, "time (ms)");
ylabel(ax, "gradient (mT/m)");

h.sim = sim;
setappdata(f, "kspaceHandles", h);

end
