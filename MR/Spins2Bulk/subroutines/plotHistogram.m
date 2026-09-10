function plotHistogram(Spins, whichdimension)
% Plot the distribution of spin angles in one dimension.
%
%   plotHistogram(Spins, whichdimension)
%
% whichdimension is 'Azimuth' (phase around B0, which shows coherence after
% an RF pulse) or 'Elevation' (angle from the transverse plane, which shows
% the Boltzmann bias toward B0).

ax = gca;
[azimuth, elevation] = cart2sph(Spins(:,1), Spins(:,2), Spins(:,3));

switch lower(whichdimension)
    case 'azimuth'
        angleData  = rad2deg(azimuth);
        angleRange = [-180 180];
        color = 'r';
    case 'elevation'
        angleData  = rad2deg(elevation);
        angleRange = [-90 90];
        color = 'g';
    otherwise
        error('plotHistogram:dimension', ...
            'whichdimension must be ''Azimuth'' or ''Elevation''.');
end

bins       = linspace(angleRange(1), angleRange(2), 30);
bincenters = (bins(1:end-1) + bins(2:end))/2;

n = histcounts(angleData, bins);

% Correct for the shrinking circumference of the sphere near the poles, so
% that a uniform distribution over the sphere's surface plots as flat.
if strcmpi(whichdimension, 'elevation')
    n = n ./ abs(cosd(bincenters));
end

n = n/sum(n);

ud = ax.UserData;

if isstruct(ud) && isfield(ud, 'hist') && isvalid(ud.hist)

    set(ud.hist, 'YData', n);

else

    ud = struct();
    ud.hist = plot(ax, bincenters, n, color, ...
        'DisplayName', whichdimension, 'LineWidth', 3);

    title(ax, sprintf('%s', whichdimension));
    set(ax, 'YLim', [0 .2], 'XLim', angleRange, 'XTick', -180:45:180);
    axis(ax, 'square');

    ax.UserData = ud;

end

end
