%[text] # Tutorial 1. Spins at equilibrium in a magnetic field
%[text] This is the first of a series of tutorials that use the Spins2Bulk animations to build up the ideas behind MR imaging. It should take about 30 minutes.
%[text] By the end you should be able to say, in your own words, where the MR signal actually comes from, and why it is so small.
%[text] Run each section in turn with **Run Section**, read the text, and answer the questions as you go. You do not need any physics background beyond the idea that a magnetic field can push on a magnet.
%[text] ## Setup
codeDir = fileparts(fileparts(mfilename('fullpath')));
addpath(codeDir);
addpath(fullfile(codeDir, 'subroutines'));
%%
%[text] ## 1. A proton is a tiny magnet
%[text] Every hydrogen nucleus, which is a single proton, behaves like a very small bar magnet. It has a magnetic moment, written $\mu$, which is a vector: it points in some direction in space.
%[text] Water is full of hydrogen, and you are full of water. So your head contains an enormous number of these tiny magnets. The question that MR physics answers is: what do they do when you put them in a strong magnetic field, and how does that produce a signal we can measure?
%[text] Let us start with the situation *before* the field is turned on.
params = spinsDefaultParams();
params.k      = 0;      % k = 0 means no magnetic field
params.t1     = inf;    % no relaxation, so nothing changes over time
params.t2     = inf;
params.nsteps = 60;
params.fliptime = inf;  % no RF pulse

figure;
animateSpins(params, gcf, 'No magnetic field');
%[text] Look at the sphere on the left. Each dot is one spin, drawn as a point on the unit sphere showing which way it points. They point in every direction, with no preference.
%[text] Now look at the black vector at the centre. That is the **bulk magnetization**, the vector sum of all the individual spins. It is essentially zero, because for every spin pointing one way there is another pointing the opposite way, and they cancel.
%[text] **Question 1.** The bulk magnetization is not exactly zero. Why not? What would make it smaller?
%%
%[text] ## 2. Turning the field on
%[text] Now put the spins in a strong magnetic field $B_0$, pointing along the $z$ axis.
%[text] A magnet in a field has an energy that depends on its orientation. It is lowest when the magnet is lined up with the field and highest when it is opposed to it:
%[text] $E = -\mu \cdot B_0 = -\mu B_0 \sin(\phi)$
%[text] where $\phi$ is the elevation of the spin, the angle up from the transverse plane, so $\phi = 90^\circ$ means pointing straight along the field.
%[text] Here is the crucial part. The spins are also being knocked around by thermal motion, and at body temperature that jostling is *far* stronger than the magnetic energy. So the spins do not line up. They keep pointing in all directions. All that happens is that the directions closer to $B_0$ become very slightly more likely than the directions away from it.
%[text] Statistical mechanics gives the probability of each orientation as the Boltzmann distribution:
%[text] $p(\phi) \propto e^{-E/k_BT} = e^{(\mu B_0 / k_B T)\sin\phi}$
%[text] In the code, the whole exponent prefactor $\mu B_0 / k_B T$ is collapsed into a single parameter, `params.k`. Larger `k` means a stronger preference for pointing along the field.
%[text] We will use `k = 3`. Be warned now that this is a **large** exaggeration, far bigger than any real magnet produces. Section 5 works out how big, and why we have to cheat this way. For the moment just note that the picture is honest about the *shape* of what happens and dishonest about the *size*.
params.k = 3;

figure;
animateSpins(params, gcf, 'In a magnetic field, B0 along z');
%[text] Compare this with the previous animation. The spins still point in every direction, and no spin is neatly lined up with the field. But now look at the **Elevation** histogram at the bottom right: it slopes upward toward $+90^\circ$. More spins point along the field than against it.
%[text] That excess is the entire source of the MR signal. The green vector, the bulk magnetization along $z$, is no longer zero.
%%
%[text] ## 3. What the elevation distribution looks like
%[text] Let us plot the distribution directly for several values of `k`, rather than reading it off a histogram.
phi = linspace(-pi/2, pi/2, 200);

figure; hold on
for kk = [0 1 2 3 6]
    B = boltzmannDistribution(kk);
    plot(rad2deg(phi), B.pdf(phi), 'LineWidth', 2, 'DisplayName', sprintf('k = %g', kk));
end
xlabel('Elevation (degrees)'); ylabel('Probability density');
title('Distribution of spin elevations'); legend('Location','northwest');
set(gca,'FontSize',12,'XTick',-90:45:90); box off
%[text] Two things are worth noticing.
%[text] First, at `k = 0` the curve is not flat: it is a cosine, peaking at $0^\circ$. That is not a preference for the transverse plane. It is geometry. There is simply much more *surface area* on a sphere near the equator than near the poles, so more directions have an elevation near $0^\circ$. This is why `boltzmannDistribution` multiplies by $|\cos\phi|$, and it is an easy thing to get wrong.
%[text] Second, as `k` rises the whole curve tilts toward $+90^\circ$. Even at `k = 6`, which is a much stronger bias than anything real, the spins are still spread over the whole sphere.
%[text] **Question 2.** At `k = 3`, what fraction of spins have a positive elevation, that is, point at all toward $B_0$? Write down a guess before you run the next line.
B = boltzmannDistribution(3);
fractionUp = integral(@(x) B.pdf(x), 0, pi/2);
fprintf('Fraction pointing toward B0 at k = 3: %.3f\n', fractionUp);
%[text] If you guessed a few percent above half, you were thinking about a real magnet. At `k = 3` it is about 95%, which is nothing like a real sample. Hold on to that number: in section 5 we compute the true figure and it is almost exactly one half.
%[text] This is the single most important caveat about these animations. They get the *mechanism* right, and they get the *magnitude* wrong on purpose, because the true magnitude cannot be drawn.
%%
%[text] ## 4. Why this is not the two-cone picture
%[text] Almost every textbook draws this differently. In the usual picture, spins are either "spin up" or "spin down", sitting on one of two cones, with slightly more on the up cone than the down cone.
%[text] That picture is misleading, and both papers in the `literature` folder are written to argue against it. Hanson (2008) calls it a myth; Williamson (2019) compares it with the uniform model used here and concludes the uniform model is better.
%[text] The cleanest way to see the problem is to ask a question the two-cone picture cannot answer:
%[text] ***If every spin is pinned to one of two cones about the $z$ axis, where does transverse magnetization come from after a $90^\circ$ pulse?***
%[text] In the two-cone picture there is no $xy$ component of an individual spin to rotate into the transverse plane. Williamson puts it bluntly: the alignment model "cannot comment on transverse relaxation, because there is no xy component to magnetization in this model."
%[text] In the uniform model there is no such difficulty. Spins already point in all directions. A pulse rotates all of them together, and the sum follows.
%[text] **Question 3.** In the animation above, is any individual spin "aligned with" $B_0$? Is the *bulk* magnetization aligned with $B_0$? Why is there no contradiction?
%%
%[text] ## 5. How big is the real effect?
%[text] The value `k = 3` was chosen to make the bias visible on screen. The real bias is very much smaller. Let us work out how much smaller.
%[text] The energy gap between a proton pointing along the field and one pointing against it is $\Delta E = \gamma \hbar B_0$, and the relevant comparison is with the thermal energy $k_B T$.
gamma = 2.675e8;      % gyromagnetic ratio of a proton, rad/s/T
hbar  = 1.055e-34;    % reduced Planck constant, J s
kB    = 1.381e-23;    % Boltzmann constant, J/K
B0    = 3;            % field strength, tesla
Temp  = 310;          % body temperature, kelvin

deltaE = gamma * hbar * B0;
thermal = kB * Temp;
polarization = deltaE / (2*thermal);

fprintf('Magnetic energy gap : %.3e J\n', deltaE);
fprintf('Thermal energy      : %.3e J\n', thermal);
fprintf('Ratio               : %.3e\n', deltaE/thermal);
fprintf('Net polarization    : %.2e, about 1 spin in %.0f\n', ...
    polarization, 1/polarization);
%[text] So at 3 tesla, roughly one proton in a hundred thousand contributes to the signal. Everything else cancels out.
%[text] That sounds hopeless until you count how many protons there are in a single voxel.
voxel_mm3   = 3*3*3;                       % a typical fMRI voxel, cubic mm
grams       = voxel_mm3 * 1e-3;            % water is about 1 g per cubic cm
molesWater  = grams / 18;
protons     = molesWater * 6.022e23 * 2;   % 2 hydrogens per water molecule
netSpins    = protons * polarization;

fprintf('\nProtons in a %g mm^3 voxel : %.2e\n', voxel_mm3, protons);
fprintf('Net contributing spins      : %.2e\n', netSpins);
%[text] A vanishingly small fraction of an enormous number is still an enormous number. That is why MR works at all.
%[text] Now we can put a number on the exaggeration. For small `k` the magnetization per spin is close to $k/3$, so the value of `k` that would match a real 3 tesla magnet is:
kRealistic = 3 * polarization;
fprintf('Realistic k at 3 T   : %.2e\n', kRealistic);
fprintf('k used in the animations : %g\n', 3);
fprintf('Exaggeration factor      : %.0e\n', 3/kRealistic);

Breal = boltzmannDistribution(kRealistic);
fprintf('\nFraction pointing toward B0, realistic k : %.8f\n', ...
    integral(@(x) Breal.pdf(x), 0, pi/2));
fprintf('Fraction pointing toward B0, k = 3       : %.8f\n', fractionUp);
%[text] So the honest picture is a sphere of spins pointing in every direction, with an excess of about seven spins in a million on the $+z$ side. Drawing that would take about a million dots before the bias was visible at all.
%[text] That is why we raise `k`. The animation is a cartoon in this one specific respect, and in no other: the dynamics, the relaxation, and the response to pulses are all simulated properly.
%[text] **Question 4.** The simulation uses `params.nspins = 3000`. With a realistic polarization, the net magnetization of $N$ spins grows like $N \times 10^{-5}$, while the random cancellation left over grows like $\sqrt{N}$. Roughly how large would $N$ have to be for the signal to exceed that noise? Compare your answer with the number of protons in a voxel.
%%
%[text] ## 6. Equilibrium is dynamic, not static
%[text] One last idea. The equilibrium above is not a state in which nothing happens. Individual spins are constantly being knocked into new orientations. What is steady is the *distribution*, not any individual spin.
%[text] We can see this by starting the system away from equilibrium and watching it return. Here we tip the magnetization into the transverse plane with a $90^\circ$ pulse and then watch $M_z$ recover. The time constant of that recovery is $T_1$.
params = spinsDefaultParams();
params.larmor   = 0;        % rotating frame, so precession is hidden
params.t1       = 0.8;
params.t2       = 0.05;
params.dt       = 1e-3;
params.nsteps   = 400;
params.fliptime = 0.01;

figure;
animateSpins(params, gcf, 'Return to equilibrium after a 90 degree pulse');
%[text] Watch the elevation histogram. Right after the pulse it is symmetric, with no excess along $z$. Over the next few hundred milliseconds the tilt reappears, and the green $M_z$ trace climbs back up.
%[text] The equilibrium value it climbs back to is set entirely by `k`. In fact it has a closed form, the Langevin function:
%[text] $M_z / M_0 = \coth(k) - 1/k$
for kk = [1 2 3 6]
    B = boltzmannDistribution(kk);
    fprintf('k = %g : equilibrium Mz per spin = %.4f\n', kk, B.Mz);
end
%[text] **Question 5.** If you doubled `k`, would the bulk magnetization double? Check your answer against the numbers just printed, and explain the discrepancy.
%%
%[text] ## Summary
%[text] - A proton behaves like a tiny magnet, and in a field its energy depends on which way it points.
%[text] - Thermal jostling is far stronger than the magnetic energy, so spins point in **all** directions, not just two.
%[text] - The field creates only a very slight excess pointing along $B_0$, described by the Boltzmann distribution. The animations exaggerate that excess by a factor of about $10^5$ so that it can be seen.
%[text] - That excess is about 1 in $10^5$ at 3 tesla, but a voxel holds around $10^{19}$ protons, so the net magnetization is easily large enough to measure.
%[text] - Equilibrium is a steady distribution, not a frozen arrangement.
%[text] ## What next
%[text] Tutorial 2 introduces precession and the rotating reference frame, and shows what an RF pulse actually does to the spin population.
%[text] ## References
%[text] Hanson LG (2008). Is quantum mechanics necessary for understanding magnetic resonance? *Concepts Magn. Reson.* 32A:329-340. See figures 2 and 3.
%[text] Williamson MP (2019). Drawing Single NMR Spins and Understanding Relaxation. *Natural Product Communications* 14(5). See figure 3.

%[appendix]{"version":"1.0"}
%---
