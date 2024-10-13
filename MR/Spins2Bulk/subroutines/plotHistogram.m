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

bins = linspace(angleRange(1), angleRange(2), 30);
bincenters = (bins(1:end-1)+bins(2:end))/2;

n = histcounts(angleData, bins);

if strcmpi(whichdimension, 'elevation')
    n = n ./ abs(cosd(bincenters));
end

n = n/sum(n);

plot(bincenters, n, color, 'DisplayName',whichdimension, 'LineWidth',3);

title(sprintf('Spin density (%s)', whichdimension))
set(gca, 'YLim', [0 .2], 'XLim', angleRange, 'XTick', -180:45:180); axis square

end