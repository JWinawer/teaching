function spinsPlotHistogram(spins, dimensionName)
% Plot the distribution of spin angles in one dimension.
%
%   spinsPlotHistogram(spins, dimensionName)
%
% Draws in the current axes. dimensionName is "Azimuth" (phase around B0,
% which shows coherence after an RF pulse) or "Elevation" (angle from the
% transverse plane, which shows the Boltzmann bias toward B0).
%
% See also spinsAnimate

arguments
    spins (:,3) double
    dimensionName (1,1) string {mustBeMember(dimensionName, ["Azimuth", "Elevation"])}
end

ax = gca;
[azimuth, elevation] = cart2sph(spins(:,1), spins(:,2), spins(:,3));

switch dimensionName
    case "Azimuth"
        angleData  = rad2deg(azimuth);
        angleRange = [-180 180];
        color = "r";
    case "Elevation"
        angleData  = rad2deg(elevation);
        angleRange = [-90 90];
        color = "g";
    otherwise
        % Cannot happen: the arguments block allows only the two cases above
end

nBins      = 29;
binEdges   = linspace(angleRange(1), angleRange(2), nBins + 1);
binCenters = (binEdges(1:end-1) + binEdges(2:end))/2;

counts = histcounts(angleData, binEdges);

% Correct for the shrinking circumference of the sphere near the poles, so
% that a uniform distribution over the sphere's surface plots as flat.
if dimensionName == "Elevation"
    counts = counts./abs(cosd(binCenters));
end

fraction = counts/sum(counts);

handles = ax.UserData;

if isstruct(handles) && isfield(handles, "hist") && isvalid(handles.hist)

    set(handles.hist, YData=fraction);

else

    handles = struct();
    handles.hist = plot(ax, binCenters, fraction, color, DisplayName=dimensionName, LineWidth=3);

    title(ax, dimensionName);
    set(ax, YLim=[0 0.2], XLim=angleRange, XTick=-180:45:180);
    axis(ax, "square");

    ax.UserData = handles;

end

end
