function MOV = animateSpins(parameters, figureHandle, titleString)

if ~exist('parameters', 'var'),   parameters   = spinsDefaultParams(); end
if ~exist('figureHandle', 'var'), figureHandle = figure(); end
if ~exist('titleString', 'var'),  titleString  = []; end
if nargout>0, MOV(parameters.nsteps) = struct('cdata',[],'colormap',[]); end

% Derived parameters
parameters = spinsAddDerivedParameters(parameters);

% Set up figure
figureHandle = spinsSetUpFigure(figureHandle, titleString);

% Initialize spins at thermal equilibrium
[Spins, B_dist, M0] = initializeSpins(parameters);

% Dynamics
for stepnum = 1:parameters.nsteps
    
    % Larmor precession
    Spins = rotateB0(Spins, parameters);

    % B1 flip
    Spins = rotateB1(Spins, parameters, stepnum);

    % T2 relaxation
    Spins = relaxationTransverse(Spins, parameters);

    % T1 relaxation
    Spins = relaxationLongitudinal(Spins, parameters, B_dist);

    % Bulk magnetization
    M(stepnum,:) = sum(Spins)/norm(M0);    

    % Plot instantaneous spins
    nexttile(1, [3 3]);
    plotSpins(Spins, M0, stepnum);

    % Plot Bulk magnetization 
    nexttile(4);
    plotBulk(parameters.t, M)

    % Plot Spin Angle Histograms
    nexttile(8);    
    plotHistogram(Spins,'Azimuth');

    nexttile(12);
    plotHistogram(Spins, 'Elevation');
    
    pause(0.005);
    
    if nargout == 1, MOV(stepnum) = getframe(figureHandle); end
end

end























