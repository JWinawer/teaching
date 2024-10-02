function Spins = rotateB1(Spins, params, stepnum)

if params.RFpulse(stepnum)


    theta = stepnum * params.larmor * 2*pi * params.dt ;        
    
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