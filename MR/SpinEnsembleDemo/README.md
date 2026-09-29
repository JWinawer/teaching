# SpinEnsembleDemo

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

Add this folder to the MATLAB path, then:

```matlab
params = spinsDefaultParams();
spinsAnimate(params);
```

`spinsAnimate` returns the bulk magnetization over time, so you can analyze a
run after it finishes:

```matlab
[M, params] = spinsAnimate(params, Title="my title");
plot(params.t, M(:,3));   % Mz against time, in ms
```

For more examples, run the cells in `tutorials/s_NMRWorkedExamples.m`.

For a run with no graphics, which is much faster and useful when you want a
curve rather than an animation, use `spinsSimulate`:

```matlab
[M, params] = spinsSimulate(params);
plot(params.t, vecnorm(M(:,1:2), 2, 2));   % Mxy against time
```

## Units

Times are in **ms**, frequencies in **Hz** and angles in **degrees**, the units
a scanner console uses. The k-space demo uses the same units. For example:

```matlab
params.t2        = 50;         % ms
params.flipAngle = [90 180];   % degrees
params.flipTime  = [1 21];     % ms
```

Settings you leave out take their defaults. A setting name that does not exist
is an error rather than being silently ignored. This also catches the names used
before September 2026 (for example `flipangle`, now `flipAngle`), when times
were in seconds and angles in radians. A time or angle that looks like it is in
the old units gives a warning.

## Playback speed and movies

`params.frameRate` sets how fast the animation plays, both on screen and in a
saved movie. It is playback speed, not simulation speed: the run covers
`nSteps*dt` ms of simulated time either way, so lowering it shows the same
physics in slower motion.

On screen the frames are paced to that rate. This matters: a single step takes
only a few milliseconds of computer time, so without pacing the animation races
past unevenly and is impossible to follow.

To save a movie, set `SaveMovie=true`. The path comes back as the third output,
so you can play it straight away:

```matlab
[~, ~, movieFile] = spinsAnimate(params, Title="my title", SaveMovie=true);
implay(movieFile);          % needs Image Processing Toolbox
```

Movies go in `movies/`, which is gitignored. Note that saving is much slower
than watching, because capturing each frame costs far more than drawing it, so
leave `SaveMovie` off unless you actually want the file.

For a movie that loops seamlessly, make the run an exact whole number of
revolutions. One revolution takes `1000/larmor` ms, so:

```matlab
params.nSteps = round(1000/(params.larmor*params.dt));
```

## Tutorials

`tutorials/` holds worked tutorials that use these animations to build up the
underlying ideas. Each mixes explanation, formulas and runnable code, and is a
plain-text MATLAB Live Script: open it in MATLAB and it renders as a document.

- `tutorial1_equilibrium.m`: where the MR signal comes from, the Boltzmann
  distribution, and why the real effect is a hundred thousand times smaller
  than the animations show.

It also holds two ordinary scripts:

- `s_NMRWorkedExamples.m`: worked cells for precession, pulses, T1, T2, T2*,
  the spin echo and BOLD. Run one cell at a time.
- `s_makeRelaxationFigures.m`: short runs of `spinsSimulate` with no
  animation. It makes Figures 6-8 of `docs/nmr_relaxation_summary.md` and
  prints the numbers quoted in their captions.

## Tests

`tests/testSpins.m` checks the physics: it measures T2, T2*, T1 and the spin
echo from simulated runs and compares them with the nominal values. Run it from
this folder with:

```matlab
runtests("tests")
```

## Docs

`docs/` holds background write-ups. Their figures are in `docs/figures/`.

- `TEACHING.md`: notes on using the animations in an fMRI course: getting
  students running, lecture ideas, exercises, and planned tutorials.
- `nmr_relaxation_summary.md`: why spins relax: which parts of NMR the
  classical vector picture gets right (precession, pulses, equilibrium
  magnetization), and why T1 relaxation needs quantum mechanics. Built from
  Williamson (2019) and Hanson (2008), with figures from this code.
- `alignment_vs_uniform_model.md`: how the common "spins are either up or
  down" picture relates to the uniform model used here, and whether an
  introductory MRI text needs the up/down picture at all.

Some [movies](https://drive.google.com/drive/folders/1Ni6xqJajgEw1TNGQrfSQUiMYROcS5pJj)
made by the code.

## Files

- Top level: the functions you call. `spinsAnimate`, `spinsSimulate`,
  `spinsDefaultParams`, `spinsB0SpreadForT2star` and
  `spinsBoltzmannDistribution`.
- `subroutines/`: the pieces they are built from. `spinsTimeStep` is one time
  step, and calls `spinsPrecess`, `spinsApplyRF`, `spinsRelaxT2` and
  `spinsRelaxT1` in turn. The top-level functions add this folder to the path
  themselves.
- `tests/`, `tutorials/`, `docs/`, `literature/` and `movies/`, described
  above.

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

See `spinsDefaultParams` for the full list and units. The ones that most affect
what you see:

- `k` sets how strongly spins prefer to point along B0. In a real magnet the
  bias is about 1 part in 10^5, far too small to draw, so `k` is deliberately
  exaggerated. 1 is subtle, 4 is obvious, 2-3 is a good compromise. `k = 0`
  means no field at all, and the bulk magnetization correctly collapses to
  zero.
- `larmor` is the precession frequency, in Hz. Setting it to 0 puts you in the
  rotating reference frame, which is a compact way to show students that the
  rotating frame is a change of viewpoint and not a change of physics. The
  transverse axes are then labeled X' and Y', the usual names in the rotating
  frame. (With `k = 0` as well there is no field, so no rotating frame, and
  the axes keep their ordinary names.)
- `fieldOnTime` switches the field on partway through a run, in ms. Before
  that moment the spins are spread evenly and sit still. From then on they
  precess and relax toward equilibrium, so Mz climbs from 0 with time constant
  T1. This is how a sample becomes magnetized when it enters the scanner. The
  default, 0, means the field is on from the start.
- `b0Spread` is the spread of static B0 offsets across spins, in Hz. It is what
  separates T2* from T2. 0 means a perfectly uniform field. Use
  `spinsB0SpreadForT2star` if you would rather specify the T2* you want to see:

  ```matlab
  params.b0Spread = spinsB0SpreadForT2star(40, params.t2);   % T2* of 40 ms
  ```

## Pulse sequences

`flipAngle`, `flipTime` and `flipPhase` may each be a vector, so you can apply a
train of pulses. A spin echo is two pulses:

```matlab
params.flipAngle = [90 180];   % degrees
params.flipTime  = [1 21];     % ms; the echo lands near 42 ms
params.flipPhase = [0 90];     % 90 about x, 180 about y
params.b1Freq    = 500;        % Hz, short pulses
params.dt        = 0.1;        % ms, small enough to resolve them
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
the comments in `subroutines/spinsRelaxT1.m`. `tests/testSpins.m` checks all of
these.

## Requirements

MATLAB R2021a or newer (for `Name=Value` syntax). No toolboxes, except the
Image Processing Toolbox for `implay`.

Updated Sep 2026
