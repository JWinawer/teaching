function animateSpins(P)

% derived parameters
t              = (1:P.nsteps) * P.dt; % seconds
P.larmorStep   = P.larmor * P.dt * 2 * pi; % radians
P.t2stepsize   = sqrt(1.9/P.t2*P.dt); % sd of radians per step for random walk causing t2 decay
flipduration   = P.flipangle / (2*pi) / P.B1freq;
P.RFpulse      = t > P.fliptime & t < P.fliptime + flipduration;

% Initialize spins at thermal equilibrium
[Spins, B_dist, M0] = initializeSpins(P);

% Dynamics
for ii = 1:P.nsteps
    
    P.stepnum = ii;

    % Larmor precession
    Spins = rotateB0(Spins, P);

    % B1 flip
    Spins = rotateB1(Spins, P);

    % T2 relaxation
    Spins = t2relaxation(Spins, P);

    % T1 relaxation
    Spins = t1relaxation(Spins, P, B_dist);

    % Bulk magnetization
    M(ii,:) = sum(Spins)/norm(M0);    

    % Plot instantaeous spins
    subplot(121)
    plotSpins(Spins, M0);     

    % Plot Bulk magnetization 
    subplot(122)
    plotBulk(t, M)

    drawnow(); 
end

end

% --------------------------------------------------------------
% ************************ SUBROUTINES *************************
% --------------------------------------------------------------
function B_dist = boltzmannDistribution(k)

% x the elevation of the spin axis
x = linspace(-pi/2,pi/2, 10000);
dx = x(2)-x(1);

% Probability of spin axis elevation:
%   Boltzmann distribution
%       p ~ exp(-E/(kT));
%   The energy, E, is minimal at 90º elevation, ie the B0+ direction, and
%   declines with a cosine dependence for other elevations. But the
%   circumference of a sphere at a particular elevation is proportional to
%   abs(cosine) of that elevation, and we need to scale the probability by
%   this factor to achieve uniform distribution when k is 0. 

Energy      = @(X) -cos(X-pi/2);
Probability = @(X) exp(-k*Energy(X));
P           = @(X) Probability(X).*abs(cos(X));
PDF         = @(X) P(X) ./ sum(P(X)) / dx;

% Convert to a probability density function
fx = PDF(x);   

% convert to a cumulative probability distribution 
Fx = cumsum(fx); Fx = Fx/Fx(end);
Fx(1) = 0;  Fx(end)=1; % ensure the CDF starts at 0 and ends at 1
B_dist = makedist('PiecewiseLinear', 'x', x, 'Fx', Fx);

end

function [Spins, B_dist, M0] = initializeSpins(params)

B_dist = boltzmannDistribution(params.k);

% sample the CDF to determine spin elevations
elevation = random(B_dist, 1, params.nspins);

% now randomly generate azimuth
azimuth = rand(size(elevation))*2*pi;

% spherical to cartesian 
r = ones(size(azimuth));
[x,y,z] = sph2cart(azimuth,elevation,r);
Spins = [x; y; z]';

M0 = sum(Spins);

end


function Spins = t1relaxation(Spins, params, B)

[azimuth, elevation, r] = cart2sph(Spins(:,1), Spins(:,2), Spins(:,3));

dx   =  sqrt(params.dt) / params.t1 / sqrt(params.k) / sqrt(2);

p_up   = B.pdf(elevation+dx);
p_down = B.pdf(elevation-dx);

p_up = p_up./(p_up + p_down);

up = p_up > rand(size(elevation)); 

deltaE = dx*(up*2-1)*2;

elevation = elevation + deltaE;

[x, y, z] = sph2cart(azimuth, elevation, r);
Spins = [x y z];

end


function Spins = rotateB0(Spins, params)

[azimuth, elevation, r] = cart2sph(Spins(:,1), Spins(:,2), Spins(:,3));
azimuth = azimuth + params.larmorStep;
[x, y, z] = sph2cart(azimuth, elevation, r);
Spins = [x y z];

end

function Spins = t2relaxation(Spins, params)

[azimuth, elevation, r] = cart2sph(Spins(:,1), Spins(:,2), Spins(:,3));
azimuth = azimuth + randn(size(azimuth))*params.t2stepsize;
[x, y, z] = sph2cart(azimuth, elevation, r);
Spins = [x y z];

end

function Spins = rotateB1(Spins, params)

stepnum = params.stepnum;

if params.RFpulse(stepnum)


    theta = stepnum * params.B1carrier * 2*pi * params.dt ;        
    
    % We can compute the effect of B1 either by assuming a rotation of the
    %  spin axis or by computing the cross product of the spin axes with
    %  the B1 axis. The latter is not as good becuase it results in
    %  discrete, straigt line displacement of the spin axis, rather than a
    %  rotation, thereby taking the spin vectors off the unit sphere. 

    % % Cross product calculation
    % B = params.B1freq * 2*pi;
    % B1 = [B*cos(theta); -B*sin(theta); 0] * ones(1,params.nspins);
    % dM = params.dt * cross(Spins', B1)';
    % Spins = Spins - dM;

    % % Rotation calculation
    deltaE = params.B1freq * 2 * pi * params.dt;
    axang = [cos(theta) sin(theta) 0 -deltaE];
    rotm = axang2rotm(axang);
    Spins = Spins*rotm;
    
end

end

function plotSpins(Spins, M0)

% Individual spin vectors
scatter3(Spins(:,1), Spins(:,2), Spins(:,3), 10,  ...
    '.', 'MarkerFaceColor', .8*[1 1 1], 'MarkerFaceAlpha', .3, ...
    'MarkerEdgeColor',.8*[1 1 1], 'MarkerEdgeAlpha', .3);
axis([-1 1 -1 1 -1 1]); axis square

hold on; 
plotAxes();

% Bulk magnetization
M = sum(Spins)/norm(M0);
quiver3(0, 0, 0, M(1), M(2), M(3), 'k-', 'AutoScale', 'off', 'LineWidth', 4); 
quiver3(0, 0, 0, M(1), M(2), 0, 'r-', 'AutoScale', 'off', 'LineWidth', 4); 
quiver3(0, 0, 0, 0, 0, M(3), 'g-', 'AutoScale', 'off', 'LineWidth', 4); 
    
hold off;

end

function plotAxes

plot3([-1 1], [0 0], [0 0], 'k-');
plot3([0 0], [1 -1], [0 0], 'k-');
plot3([0 0], [0 0], [-1 1], 'k-');

end

function plotBulk(t, M)

idx = size(M,1);
if idx >= 2, idx = [-1 0] + idx; end
Mz  = M(idx,3);
Mxy = vecnorm(M(idx, 1:2), 2, 2);
plot(t(idx), Mz, 'g.-', t(idx), Mxy,  'r.-');

hold on; 
if size(M,1) == 1
    axis([0 max(t) -1 1.1]); 
    axis square
    xlabel('Time (s)')
    ylabel('Magnetization')

    legend({'Mz', 'Mxy'},'AutoUpdate','off', 'Location','southwest');
end

end
