function MOV = animateSpins(params, fH, titlestr)

if ~exist('P', 'var'), params = spinsDefaultParams(); end
if ~exist('fH', 'var'), fH = figure(); end
if ~exist('titlestring', 'var'), titlestr = []; end
if nargout > 0, MOV(params.nsteps) = struct('cdata',[],'colormap',[]); end

% Derived parameters
params = spinsAddDerivedParameters(params);

% Set up figure
fH = spinsSetUpFigure(fH, titlestr);

% Initialize spins at thermal equilibrium
[Spins, B_dist, M0] = initializeSpins(params);

% Dynamics
for stepnum = 1:params.nsteps
    
    % Larmor precession
    Spins = rotateB0(Spins, params);

    % B1 flip
    Spins = rotateB1(Spins, params, stepnum);

    % T2 relaxation
    Spins = relaxationTransverse(Spins, params);

    % T1 relaxation
    Spins = relaxationLongitudinal(Spins, params, B_dist);

    % Bulk magnetization
    M(stepnum,:) = sum(Spins)/norm(M0);    

    % Plot instantaneous spins
    nexttile(1, [3 3]);
    plotSpins(Spins, M0, stepnum);

    % Plot Bulk magnetization 
    nexttile(4);
    plotBulk(params.t, M)

    % Plot Spin Angle Histograms
    nexttile(8);    
    plotHistogram(Spins,'Azimuth');

    nexttile(12);
    plotHistogram(Spins, 'Elevation');
    
    pause(0.005);
    
    if nargout == 1, MOV(stepnum) = getframe(fH); end
end

end























