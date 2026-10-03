% s_makeSchematicFigures
%
% Make Figures 1-5 of docs/nmr_relaxation_summary.md. These are schematic
% drawings, not simulations (Figures 6-8 come from s_makeRelaxationFigures):
%
%   1. Three ways to draw spins at equilibrium: alignment, 2-cone, uniform
%   2. A spinning top drooping as friction drains its energy
%   3. Symmetric collisions plus an uneven population give a net flow
%   4. Detailed balance: the spin's two levels and the bath's many levels
%   5. The shape of T1 recovery
%
% The figures are written to docs/figures, replacing the existing ones. The
% random seed is fixed, so a rerun gives the same figures.
%
% See also s_makeRelaxationFigures, spinsBoltzmannDistribution

scriptDir = fileparts(mfilename("fullpath"));
codeDir = fileparts(scriptDir);
addpath(codeDir);

figureDir = fullfile(codeDir, "docs", "figures");
if ~isfolder(figureDir)
    mkdir(figureDir);
end

figureResolution = 200;   % dots per inch
fontSize = 12;
labelFontSize = 11;
rng(1);

% Same palette as s_makeRelaxationFigures
upColor = "#1f3a5f";      % aligned with B0, or low energy
downColor = "#b23a1f";    % opposed to B0, or high energy
accentColor = "#c98a1f";
guideColor = "#888888";
textColor = "#555555";

%% 1. Three ways to draw spins at equilibrium
% The cones are drawn in 3D and projected onto the page, viewed from slightly
% above, so that their rims show as ellipses. The uniform model is viewed
% exactly side-on, so that every spin drawn above the equator really does
% point upward.
viewElevation = deg2rad(15);
project = @(v) [v(:,1), v(:,3)*cos(viewElevation) + v(:,2)*sin(viewElevation)];
projectSideOn = @(v) [v(:,1), v(:,3)];

fig = figure(Position=[100 100 1300 560]);
layout = tiledlayout(1, 3, TileSpacing="compact");

% Alignment model: every spin exactly up or exactly down, one more up than down
nexttile
hold on
drawFieldAxis(guideColor)
nUp = 5;
nDown = 4;
arrowSpacing = 0.16;
for xPosition = arrowSpacing*((1:nUp) - (nUp + 1)/2)
    drawArrow([xPosition 0.05], [xPosition 1], upColor, 2.5, 0.12);
end
for xPosition = arrowSpacing*((1:nDown) - (nDown + 1)/2)
    drawArrow([xPosition -0.05], [xPosition -1], downColor, 2.5, 0.12);
end
formatSchematicAxes([-1.3 1.3], [-1.45 1.75])
title(["Alignment model", "only up or only down"], FontWeight="normal", FontSize=fontSize)

% 2-cone model: spins on two cones at the magic angle, 54.7 degrees from z
nexttile
hold on
drawFieldAxis(guideColor)
magicAngle = acos(1/sqrt(3));
rimAngle = linspace(0, 2*pi, 200)';
for coneSign = [1 -1]
    rim = [sin(magicAngle)*cos(rimAngle), sin(magicAngle)*sin(rimAngle), ...
        coneSign*cos(magicAngle)*ones(size(rimAngle))];
    rim2d = project(rim);
    plot(rim2d(:,1), rim2d(:,2), "--", Color=guideColor, LineWidth=1.5);
end
coneCounts = [nUp nDown];
coneSigns = [1 -1];
coneColors = [upColor downColor];
for iCone = 1:2
    azimuth = 2*pi*rand(coneCounts(iCone), 1);
    spinVectors = [sin(magicAngle)*cos(azimuth), sin(magicAngle)*sin(azimuth), ...
        coneSigns(iCone)*cos(magicAngle)*ones(size(azimuth))];
    drawSpinArrows(project(spinVectors), coneColors(iCone));
end
formatSchematicAxes([-1.3 1.3], [-1.45 1.75])
title(["2-cone model", "two cones, 54.7° from B_0"], FontWeight="normal", FontSize=fontSize)

% Uniform model: spins point anywhere, drawn from the Boltzmann distribution
% that the simulation itself uses, with k exaggerated so the bias is visible
nexttile
hold on
drawFieldAxis(guideColor)
sphereOutline = [cos(rimAngle), sin(rimAngle)];
plot(sphereOutline(:,1), sphereOutline(:,2), "--", Color=guideColor, LineWidth=1.5);
nUniform = 40;
kUniform = 1.5;
B = spinsBoltzmannDistribution(kUniform);
elevation = B.sample(nUniform)';
azimuth = 2*pi*rand(nUniform, 1);
spinVectors = [cos(elevation).*cos(azimuth), cos(elevation).*sin(azimuth), sin(elevation)];
isAboveEquator = spinVectors(:,3) > 0;
drawSpinArrows(projectSideOn(spinVectors(isAboveEquator,:)), upColor);
drawSpinArrows(projectSideOn(spinVectors(~isAboveEquator,:)), downColor);
formatSchematicAxes([-1.3 1.3], [-1.45 1.75])
title(["Uniform model", "any direction, excess toward B_0"], FontWeight="normal", FontSize=fontSize)

title(layout, "Three ways to draw spins at equilibrium (the excess along B_0 is exaggerated)", FontSize=fontSize + 1)
exportgraphics(fig, fullfile(figureDir, "relaxation_fig1_three_spin_models.png"), ...
    Resolution=figureResolution);

%% 2. A spinning top droops as friction drains its energy
topElevations = [80 55 30];   % degrees above the table
panelTitles = {["Fast spin:", "axis nearly upright"], ["Friction slows the spin:", "axis tilts further"], ...
    ["Slower still:", "axis close to the table"]};

fig = figure(Position=[100 100 1300 430]);
layout = tiledlayout(1, 4, TileSpacing="compact");
for iPanel = 1:numel(topElevations)
    nexttile
    hold on
    drawTop(topElevations(iPanel), upColor, accentColor, guideColor)
    formatSchematicAxes([-1.7 1.9], [-0.35 1.9])
    title(panelTitles{iPanel}, FontWeight="normal", FontSize=labelFontSize)
end

nexttile
timeAxis = linspace(0, 6, 200);
schematicTimeConstant = 2.2;
plot(timeAxis, 80*exp(-timeAxis/schematicTimeConstant), LineWidth=3, Color=downColor);
xlabel("time")
ylabel("axis elevation (degrees)")
ylim([0 90])
title(["Elevation keeps falling", "(schematic)"], FontWeight="normal", FontSize=labelFontSize)
set(gca, FontSize=labelFontSize)
box off

title(layout, "Friction always removes energy, so the top's axis droops in one direction only", ...
    FontSize=fontSize + 1)
exportgraphics(fig, fullfile(figureDir, "relaxation_fig2_spinning_top.png"), ...
    Resolution=figureResolution);

%% 3. Symmetric collisions plus an uneven population give a net flow
% A box split in two. Each molecule is as likely to cross in either
% direction, but the left side holds more molecules, so more cross left to
% right: four crossings to the right are drawn for every two to the left.
nDense = 60;
nSparse = 15;
boxWidth = 2;
boxHeight = 1;
margin = 0.05;
densePoints = [margin + (1 - 2*margin)*rand(nDense, 1), margin + (boxHeight - 2*margin)*rand(nDense, 1)];
sparsePoints = [1 + margin + (1 - 2*margin)*rand(nSparse, 1), margin + (boxHeight - 2*margin)*rand(nSparse, 1)];

fig = figure(Position=[100 100 1100 500]);
hold on
rectangle(Position=[0 0 boxWidth boxHeight], LineWidth=2);
plot([1 1], [0 boxHeight], "--", Color=guideColor, LineWidth=2);
plot(densePoints(:,1), densePoints(:,2), "o", MarkerSize=6, MarkerFaceColor=upColor, MarkerEdgeColor="none");
plot(sparsePoints(:,1), sparsePoints(:,2), "o", MarkerSize=6, MarkerFaceColor=upColor, MarkerEdgeColor="none");
crossingHalfLength = 0.13;
for yPosition = [0.15 0.4 0.62 0.86]
    drawArrow([1 - crossingHalfLength yPosition], [1 + crossingHalfLength yPosition], downColor, 2, 0.04);
end
for yPosition = [0.28 0.74]
    drawArrow([1 + crossingHalfLength yPosition], [1 - crossingHalfLength yPosition], downColor, 2, 0.04);
end
drawArrow([0.6 -0.17], [1.4 -0.17], accentColor, 4, 0.07);
text(1, -0.27, "net flow", Color=accentColor, FontSize=fontSize, FontWeight="bold", ...
    HorizontalAlignment="center", VerticalAlignment="top");
text(0.5, boxHeight + 0.05, "dense side", FontSize=fontSize, HorizontalAlignment="center", ...
    VerticalAlignment="bottom");
text(1.5, boxHeight + 0.05, "sparse side", FontSize=fontSize, HorizontalAlignment="center", ...
    VerticalAlignment="bottom");
text(1, -0.43, ["Each crossing is equally likely in either direction.", ...
    "The net flow comes only from having more molecules on the left."], ...
    Color=textColor, FontSize=labelFontSize, HorizontalAlignment="center", VerticalAlignment="top");
formatSchematicAxes([-0.05 2.05], [-0.68 1.2])
title("Symmetric collisions, uneven population, net flow", FontSize=fontSize + 1)
exportgraphics(fig, fullfile(figureDir, "relaxation_fig3_gas_diffusion.png"), ...
    Resolution=figureResolution);

%% 4. Detailed balance: the spin's two levels and the bath's many levels
% Energies are in units of the spin's energy gap, h-bar times omega0. The
% bath (the tumbling molecules) has many levels spaced by the same amount
% here, and it occupies the low ones more often (Boltzmann weighting). Each
% transition of the spin is paired with an opposite transition of the bath,
% so energy is conserved. The coupling is the same in both directions; only
% the bath's occupancy differs.
spinLevelHeights = [0 1];   % alpha (aligned with B0) below beta, level with the bath's lowest pair
spinLevelX = [0 1.6];
bathLevelHeights = 0:4;
bathLevelX = [5.8 7.6];
bathOccupancy = [10 6 4 2 1];   % dots per bath level, exaggerated Boltzmann falloff

fig = figure(Position=[100 100 1150 650]);
hold on

% The spin
plot(spinLevelX, spinLevelHeights(1)*[1 1], Color=upColor, LineWidth=4);
plot(spinLevelX, spinLevelHeights(2)*[1 1], Color=downColor, LineWidth=4);
text(spinLevelX(1) - 0.15, spinLevelHeights(1), ["\alpha: aligned with B_0", "(lower energy)"], ...
    Color=upColor, FontSize=labelFontSize, HorizontalAlignment="right");
text(spinLevelX(1) - 0.15, spinLevelHeights(2), ["\beta: opposed to B_0", "(higher energy)"], ...
    Color=downColor, FontSize=labelFontSize, HorizontalAlignment="right");
plot([spinLevelX(2) bathLevelX(1)], spinLevelHeights(1)*[1 1], ":", Color=guideColor, LineWidth=1);
plot([spinLevelX(2) bathLevelX(1)], spinLevelHeights(2)*[1 1], ":", Color=guideColor, LineWidth=1);
text(spinLevelX(2) + 0.1, mean(spinLevelHeights), "$\hbar\omega_0$", Interpreter="latex", FontSize=labelFontSize + 4);
text(mean(spinLevelX), 4.6, ["The spin", "(two levels)"], FontSize=fontSize, FontWeight="bold", ...
    HorizontalAlignment="center");

% The bath
for iLevel = 1:numel(bathLevelHeights)
    plot(bathLevelX, bathLevelHeights(iLevel)*[1 1], Color=guideColor, LineWidth=2);
    dotX = linspace(bathLevelX(1) + 0.1, bathLevelX(2) - 0.1, max(bathOccupancy));
    plot(dotX(1:bathOccupancy(iLevel)), (bathLevelHeights(iLevel) + 0.14)*ones(1, bathOccupancy(iLevel)), ...
        "o", MarkerSize=6, MarkerFaceColor=textColor, MarkerEdgeColor="none");
end
text(mean(bathLevelX), 4.6, ["The bath (tumbling molecules)", "many levels, low ones fuller"], ...
    FontSize=fontSize, FontWeight="bold", HorizontalAlignment="center");

% Common process: the spin drops from beta to alpha and the bath climbs one
% level. The bath is usually in its low levels, so this happens often.
drawArrow([0.5 spinLevelHeights(2)], [0.5 spinLevelHeights(1)], accentColor, 4, 0.18);
drawArrow([bathLevelX(2) + 0.3 bathLevelHeights(1)], [bathLevelX(2) + 0.3 bathLevelHeights(2)], ...
    accentColor, 4, 0.18);
% Rare process: the spin climbs from alpha to beta and the bath drops one
% level. The bath must already be in a higher level, which is less likely.
drawArrow([1.1 spinLevelHeights(1)], [1.1 spinLevelHeights(2)], guideColor, 2, 0.15);
drawArrow([bathLevelX(2) + 0.7 bathLevelHeights(2)], [bathLevelX(2) + 0.7 bathLevelHeights(1)], ...
    guideColor, 2, 0.15);

text(3.7, 3.4, ["Common (gold): the spin drops and the", ...
    "bath climbs one level. The bath is usually", "in a low level, so it can take the energy."], ...
    Color=accentColor, FontSize=labelFontSize, FontWeight="bold", HorizontalAlignment="center");
text(3.7, 2.1, ["Rare (gray): the spin climbs and the", ...
    "bath drops one level. The bath must already", "be in a higher level to give energy up."], ...
    Color=textColor, FontSize=labelFontSize, HorizontalAlignment="center");

text(3.7, -0.85, "$\frac{W(\beta\to\alpha)}{W(\alpha\to\beta)} = e^{\hbar\omega_0/kT}$", ...
    Interpreter="latex", FontSize=fontSize + 6, HorizontalAlignment="center");
text(3.7, -1.5, ["Same coupling in both directions.", ...
    "The difference comes from how often the bath sits in each level."], ...
    Color=textColor, FontSize=labelFontSize, HorizontalAlignment="center");
formatSchematicAxes([-2.9 9.2], [-2.3 5.1])
title("Where the bias toward alignment comes from", FontSize=fontSize + 1)
exportgraphics(fig, fullfile(figureDir, "relaxation_fig4_detailed_balance.png"), ...
    Resolution=figureResolution);

%% 5. The shape of T1 recovery
% Mz recovering from zero, for example after a 90 degree pulse, in units of T1
timeInT1 = linspace(0, 5, 300);
mzRecovery = 1 - exp(-timeInT1);

fig = figure(Position=[100 100 900 480]);
hold on
plot(timeInT1, mzRecovery, LineWidth=3, Color=upColor);
plot([0 5], [1 1], "--", Color=guideColor, LineWidth=2);
plot([1 1], [0 1.1], ":", Color=accentColor, LineWidth=3);
plot(1, 1 - exp(-1), "o", MarkerSize=9, MarkerFaceColor=accentColor, MarkerEdgeColor="none");
text(1.12, 1 - exp(-1) - 0.06, "63% recovered at t = T_1", Color=accentColor, ...
    FontSize=labelFontSize, FontWeight="bold", VerticalAlignment="top");
text(3.3, 1.05, "equilibrium", Color=textColor, FontSize=labelFontSize);
xlabel("time after the disturbance (units of T_1)")
ylabel("M_z / M_0")
ylim([0 1.15])
title("T1 recovery: the drift back toward equilibrium", FontSize=fontSize + 1)
set(gca, FontSize=fontSize)
box off
exportgraphics(fig, fullfile(figureDir, "relaxation_fig5_t1_recovery_schematic.png"), ...
    Resolution=figureResolution);

%% Local functions

function drawArrow(startPoint, endPoint, color, lineWidth, headLength)
% Draw a 2D arrow from startPoint to endPoint with a filled triangular head.
% The axes must have equal data aspect ratio for the head to look right.
direction = endPoint - startPoint;
unitDirection = direction/norm(direction);
normal = [-unitDirection(2) unitDirection(1)];
headLength = min(headLength, 0.5*norm(direction));
headBase = endPoint - headLength*unitDirection;
plot([startPoint(1) headBase(1)], [startPoint(2) headBase(2)], Color=color, LineWidth=lineWidth);
headCorners = [endPoint; headBase + 0.45*headLength*normal; headBase - 0.45*headLength*normal];
patch(XData=headCorners(:,1), YData=headCorners(:,2), FaceColor=color, EdgeColor="none");
end

function drawSpinArrows(tips, color)
% Draw arrows from the origin to each row of tips (projected 2D points)
for iSpin = 1:size(tips, 1)
    drawArrow([0 0], tips(iSpin,:), color, 1.8, 0.09);
end
end

function drawFieldAxis(color)
% Draw the B0 axis as a vertical line with a label at the top
plot([0 0], [-1.35 1.35], Color=color, LineWidth=1.5);
text(0.06, 1.42, "B_0", FontSize=13, VerticalAlignment="bottom");
end

function drawTop(elevationDegrees, bodyColor, angleColor, guideColor)
% Draw a spinning top resting on a table, its axis at the given elevation
axisLength = 1.4;
elevation = deg2rad(elevationDegrees);
axisDirection = [cos(elevation) sin(elevation)];
axisNormal = [-axisDirection(2) axisDirection(1)];

% Table
patch(XData=[-1.7 1.9 1.9 -1.7], YData=[0 0 -0.3 -0.3], FaceColor=[0.93 0.93 0.93], EdgeColor="none");
plot([-1.7 1.9], [0 0], "k", LineWidth=1.5);

% Precession circle traced by the tip of the axis, seen in perspective
circleAngle = linspace(0, 2*pi, 200);
reach = axisLength*cos(elevation);
plot(reach*cos(circleAngle), axisLength*sin(elevation) + 0.12*reach*sin(circleAngle), "--", ...
    Color=guideColor, LineWidth=1.5);

% Body: a cone from the tip widening to a rim, capped by a shallow dome,
% drawn as a diamond in side view. The axis sticks out of the top as a handle.
rimCenter = 0.7*axisDirection;
rimHalfWidth = 0.38;
rimEnds = [rimCenter + rimHalfWidth*axisNormal; rimCenter - rimHalfWidth*axisNormal];
capPoint = 0.95*axisDirection;
bodyOutline = [0 0; rimEnds(1,:); capPoint; rimEnds(2,:)];
patch(XData=bodyOutline(:,1), YData=bodyOutline(:,2), FaceColor=bodyColor, ...
    FaceAlpha=0.6, EdgeColor=bodyColor, LineWidth=1.5);
plot([0 axisLength*axisDirection(1)], [0 axisLength*axisDirection(2)], Color=bodyColor, LineWidth=3.5);

% Elevation angle, measured up from the table
arcRadius = 1.15;   % outside the body, so the arc is not hidden
arcAngle = linspace(0, elevation, 50);
plot(arcRadius*cos(arcAngle), arcRadius*sin(arcAngle), Color=angleColor, LineWidth=2);
text(1.32*cos(elevation/2), 1.32*sin(elevation/2), "\theta", Color=angleColor, FontSize=13, ...
    HorizontalAlignment="center");
end

function formatSchematicAxes(xLimits, yLimits)
% Equal aspect ratio, fixed limits and no visible axes
axis equal
xlim(xLimits)
ylim(yLimits)
axis off
end
