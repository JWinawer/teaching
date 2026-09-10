# Spins2Bulk

Animations that show individual nuclear spins and the bulk magnetization vector
at the same time, so you can watch the bulk vector emerge as the sum of the
spins.

The visualizations use the **uniform model** of spin distributions rather than
the much more common *alignment* or *two-cone* models. In the uniform model,
individual spins point in any direction in 3D space, with only a slight
statistical preference toward the applied field. See:

- Williamson MP. Drawing Single NMR Spins and Understanding Relaxation.
  *Natural Product Communications*. 2019;14(5).
  https://doi.org/10.1177/1934578X19849790
- Hanson LG. Is quantum mechanics necessary for understanding magnetic
  resonance? *Concepts Magn. Reson.* 2008;32A:329-340.
  https://doi.org/10.1002/cmr.a.20123

The relevant figures are 2 and 3 in Hanson and figure 3 in Williamson.

## Quick start

```matlab
addpath('subroutines');
fH = figure();
params = spinsDefaultParams();
animateSpins(params, fH);
```

`animateSpins` optionally returns the bulk magnetization over time, so you can
analyze a run after it finishes:

```matlab
[M, params] = animateSpins(params, fH, 'my title');
plot(params.t, M(:,3));   % Mz vs time
```

For more examples, run the cells in `s_SpinsToBulkM.m`.

For a run with no graphics, which is much faster and useful when you want a
curve rather than an animation, use `simulateSpins`:

```matlab
[M, params] = simulateSpins(params);
plot(params.t, vecnorm(M(:,1:2), 2, 2));   % Mxy vs time
```

## Playback speed and movies

`params.frameRate` sets how fast the animation plays, both on screen and in a
saved movie. It is playback speed, not simulation speed: the run covers
`nsteps*dt` seconds of simulated time either way, so lowering it shows the same
physics in slower motion.

On screen the frames are paced to that rate. This matters: a single step takes
only a few milliseconds, so without pacing the animation races past unevenly
and is impossible to follow.

To save a movie, pass `true` as the fourth argument. The path comes back as the
third output, so you can play it straight away:

```matlab
[~, ~, movieFile] = animateSpins(params, figure, 'my title', true);
implay(movieFile);          % needs Image Processing Toolbox
```

Movies go in `movies/`, which is gitignored. Note that saving is much slower
than watching, because capturing each frame costs far more than drawing it, so
leave `saveMovieFlag` off unless you actually want the file.

For a movie that loops seamlessly, make the run an exact whole number of
revolutions. One revolution takes `1/larmor` seconds, so:

```matlab
params.nsteps = round(1 / (params.larmor * params.dt));
```

## Tutorials

`tutorials/` holds worked tutorials that use these animations to build up the
underlying ideas. Each mixes explanation, formulas and runnable code, and is a
plain-text MATLAB Live Script: open it in MATLAB and it renders as a document.

- `tutorial1_equilibrium.m` — where the MR signal comes from, the Boltzmann
  distribution, and why the real effect is a hundred thousand times smaller
  than the animations show.

Some [movies](https://drive.google.com/drive/folders/1Ni6xqJajgEw1TNGQrfSQUiMYROcS5pJj)
made by the code.

## What the panels show

- **Left**: every simulated spin as a dot on the unit sphere, plus the bulk
  magnetization vector (black), its transverse component (red) and its
  longitudinal component (green).
- **Top right**: Mz and Mxy against time.
- **Middle right**: distribution of azimuth, the phase around B0. A bump here
  means the spins are in phase, which is what an RF pulse creates and what T2
  destroys.
- **Bottom right**: distribution of elevation, the angle away from the
  transverse plane. The tilt toward +90 degrees *is* the Boltzmann bias, and it
  is the entire source of the MR signal.

## Parameters

See `spinsDefaultParams` for the full list and units. The two that most affect
what you see:

- `k` sets how strongly spins prefer to point along B0. In a real magnet the
  bias is about 1 part in 10^5, far too small to draw, so `k` is deliberately
  exaggerated. 1 is subtle, 4 is obvious, 2-3 is a good compromise. `k = 0`
  means no field at all, and the bulk magnetization correctly collapses to
  zero.
- `larmor` is the precession frequency. Setting it to 0 puts you in the
  rotating reference frame, which is a compact way to show students that the
  rotating frame is a change of viewpoint and not a change of physics.
- `b0spread` is the spread of static B0 offsets across spins, in Hz. It is what
  separates T2* from T2. 0 means a perfectly uniform field. Use
  `b0spreadForT2star` if you would rather specify the T2* you want to see:

  ```matlab
  params.b0spread = b0spreadForT2star(0.040, params.t2);   % T2* of 40 ms
  ```

## Pulse sequences

`flipangle`, `fliptime` and `flipphase` may each be a vector, so you can apply a
train of pulses. A spin echo is two pulses:

```matlab
params.flipangle = [pi/2 pi];        % 90 then 180
params.fliptime  = [0.001 0.021];    % the echo lands near t = 0.042 s
params.flipphase = [0 pi/2];         % 90 about x, 180 about y
```

The 180 degree pulse reverses the dephasing caused by the static field spread,
which is why the signal comes back, but it cannot reverse the random walk that
causes T2. So the echo peaks at `exp(-TE/t2)`, not `exp(-TE/t2star)`. That
difference is the whole point of the spin echo, and it is visible in the
animation as a fan of spins that spreads out, flips over, and re-converges.

## A note on accuracy

The T2 step size is derived analytically and reproduces the nominal `t2` to
within about 1%. The same is true of T2*: the simulated decay matches
`1/t2star = 1/t2 + 1/t2prime` to within about 1% over a wide range of field
spreads. The T1 step size is calibrated so that the nominal `t1` is
also reproduced, but with a caveat: exaggerating `k` so the bias is visible
also makes longitudinal relaxation slightly non-exponential, so the observed
time constant depends a little on how the magnetization was prepared. The
calibration targets the case these demos use, a 90 degree pulse applied to the
equilibrium distribution, which lands within about 2% over `k` = 1 to 5. See
the comments in `relaxationLongitudinal.m`.

Requires base MATLAB only; no toolboxes.

Updated Sep 2026
