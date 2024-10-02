function plotHistogram(Spins, whichdimension)

[azimuth, elevation] = cart2sph(Spins(:,1), Spins(:,2), Spins(:,3));

switch lower(whichdimension)
    case 'azimuth'
        angleData = rad2deg(azimuth);
        angleRange = [-180 180];
        color = 'g';
    case 'elevation'
        angleData = rad2deg(elevation);
        angleRange = [-90 90];
        color = 'r';
end

nSpins = length(angleData);
bins = linspace(angleRange(1), angleRange(2), 100);
n = histcounts(angleData, bins);
plot(bins(1:end-1), n, color, 'DisplayName',whichdimension, 'LineWidth',3);

title(whichdimension)
set(gca, 'YLim', [0 nSpins/100*10], 'XLim', angleRange); axis square

end