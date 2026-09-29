# KspaceDemo code review (September 2026)

A review of the demo for accuracy, readability, and speed. Each finding was
checked by running the simulation core in MATLAB R2026a without the GUI, using
the default settings (FOV 180 mm, 2 mm pixels, so a 90 x 90 image; 125 kHz
bandwidth; axial brain image).

## Status (updated September 2026)

Fixed since this review was written. Each fix was checked by a test in MATLAB.

| Item | What changed | Check |
|---|---|---|
| A1, A2 | Spiral weighting is now \|k\| with no post-compensation; gradient sign fixed; spiral k-space rescaled to match EPI | Spiral correlation 0.71 → 0.95 |
| A3 | Multi-shot option removed. It had been added to improve the spiral image, and fix A1 made it unnecessary. | Tests pass without it |
| A4 | `echoTime` is now the true TE: the readout is placed so the center of k-space is sampled at TE. Too short a TE gives an error stating the minimum. Default TE is now 40 ms, because 30 ms is below the EPI minimum (33 ms). | Center sampled at 40.000 ms for EPI and spiral |
| A5 | New `t2star` parameter (scalar or map) | Center sample shrinks by 0.4493; exp(-40/50) = 0.4493 |
| A6 | All labels fixed; plots rebuilt (see README) | Figures inspected |
| Readability | New `kspaceDefaultParams` and `kspaceSimulate` (no dialog); unit conversion moved to `kspaceDerivedParams`; the dialog no longer converts values twice; loop instead of recursion; new figure instead of figures 1 and 2; help text throughout; Code Analyzer clean | Dialog round trip test |
| Speed | EPI reconstruction places samples directly (no `griddata`). The progress display redraws once per EPI line and updates existing plots instead of adding new ones. | Progress mode: about 2 s for EPI (was an estimated 11+ minutes) |

Still open: the spiral image keeps a faint circular shading near the edges,
and the separable speed-up for spiral steps (see Speed) is not done.

### Names changed later in September 2026

A later cleanup made this demo match the spin demo in style, so some names in
the review below no longer exist. Helper functions moved from
`kspaceFunctions/` to `subroutines/`, and the images moved to `data/`.

| Old name | New name |
|---|---|
| `noiseType`, `noiseScale` (settings) | `fieldErrorType`, `fieldErrorPpm` |
| `imfile`, `res`, `imSize`, `imRes`, `loop` (settings) | `imageFile`, `pixelSize`, `objectSize`, `objectPixelSize`, `keepDialogOpen` |
| `kspaceParamsGUI` | `kspaceParamsDialog` |
| `kspaceGetImage`, `kspaceGrid` | `kspaceLoadObject`, `kspacePixelPositions` |
| `kspaceGetB0Noise` | `kspaceFieldErrorMap` |
| `kspaceInitializeMatrices`, `kspacePreCompute` | `kspaceInitializeData`, `kspaceInitializeSpins` |
| `kspaceComputeOnePoint`, `kspaceGetCurrentSignal` | `kspaceStepFactor`, `kspaceMeasureSample` |
| `kspaceGetCurrentBasisFunctions` | one line in `kspaceSimulate` |
| `grid_kb`, `kaiser_bessel_kern` | `kspaceGridKaiserBessel` (one file) |

The borrowed gridding code passed its inputs with `'`, which in MATLAB is the
conjugate transpose. So it quietly conjugated both the data and the
trajectory. The new version does the same mapping directly: rows along ky,
columns along kx, and the signal as measured. The spiral images are unchanged.

`tests/testKspace.m` now holds the checks listed in the table above.

The dialog is now built with MATLAB's own `uifigure` controls, inside
`kspaceParamsDialog`, so the borrowed `mrVistaUtilities/` folder (about 590
lines) is gone. A movie option was also added (`SaveMovie=true`).

The rest of this document is the review as first written.

## Summary

- **The EPI simulation is correct.** With no field errors, the reconstructed
  image matches the original (correlation 0.986). A uniform 0.5 ppm field
  offset (64 Hz at 3 T) should shift the image 4.1 pixels along the
  phase-encode direction and not at all along the readout. The simulation
  shifts it 4 pixels and 0 pixels. So the core physics, "k-space position is
  the time integral of the gradient", is implemented correctly.
- **The spiral reconstruction is poor, for a fixable reason.** The spiral image
  has a large ring artifact and uneven shading (correlation 0.71). The main
  cause is the density weighting. Two smaller errors add to it.
- **Several labels and plot annotations are wrong.** The most important for
  teaching: the "Echo time" setting is not the echo time.
- **Speed is fine in the default mode (about 2 s for EPI, 5 s for spiral).**
  The "show recon point by point" mode is very slow, for reasons that are easy
  to fix.
- **The biggest limitation for teaching is not a bug.** The code can only be
  run through the pop-up dialog, so students cannot script a parameter sweep.

## Accuracy

### A1. Spiral density weighting is wrong (main cause of the spiral artifact)

`kspaceRecon.m` weights each spiral sample by `r.^0.5`, the square root of its
distance from the k-space center. The comment says this was copied from test
data and is not understood.

For an Archimedean spiral traced at a constant angular rate, samples bunch up
near the center. The number of samples per unit area falls off as 1/|k|. So
each sample should be weighted in proportion to |k|, which evens out the
density. (Hoge et al., 1997, compare weighting functions for spirals. I cite
this from memory. The PubMed tool was not working during this review, so I
could not check the details.)

The code also turns on "post-compensation" (`postcompensate = 'y'`). This
divides the gridded data by the gridded weights. That largely undoes the
density weighting, so the result is closer to a local average than a
density-corrected sum.

Measured effect (correlation with the true image):

| Weighting | Post-compensation | Correlation |
|---|---|---|
| sqrt(r) (current) | on (current) | 0.708 |
| r | on | 0.766 |
| sqrt(r) | off | 0.867 |
| **r** | **off** | **0.943** |

**Fix:** `w = r;` and `postcompensate = 'n'`.

### A2. Sign error in the spiral gradient formula

`kspaceSpiral.m` wants the trajectory `kx = c*theta*sin(theta)`,
`ky = c*theta*cos(theta)`. The gradient is the time derivative of k. The
derivative of `theta*cos(theta)` is `cos(theta) - theta*sin(theta)`. The code
has a plus sign. The trajectory it actually traces is a mirror-image spiral,
bent near the center by up to about one-third of the ring spacing during the
first two turns. Fixing the sign improves the reconstruction a little (0.943
to 0.952 with fix A1 in place). The same sign error is in the header comment.

### A3. Multi-shot spiral is treated as one long readout

`oversample` is labeled "n shots". Each extra shot is a full spiral, so the
setting doubles the sampling density rather than splitting the spiral into
interleaves. Also, the step that returns to the k-space center between shots
lasts as long as all previous shots. So field-error phase keeps building up
from shot to shot, as if there were no new excitation. In a real multi-shot
scan, the phase restarts at each excitation. As a result, field-error
artifacts for `oversample > 1` are wrong.

### A4. "Echo time" is the delay before the readout, not TE

TE is normally defined as the time from excitation to the center of k-space
(Bernstein, King & Zhou, *Handbook of MRI Pulse Sequences*, 2004, cited from
memory). In the code, `echoTime` is a delay before the readout begins. For the
default EPI, the center of k-space is reached 33 ms after that. So a setting of
30 ms gives a true TE of **63 ms**. For spiral, the center is sampled first, so
there the setting is close to the true TE.

This matters for teaching because students will compare dropout at different
TEs. Either relabel the setting ("Delay before readout"), or better, place the
readout so that the k-space center lands at the requested TE.

### A5. No T2* decay

The signal from each spin has a constant magnitude. The only effect of TE is
the phase that builds up from field errors. That phase does produce realistic
intravoxel dephasing: the object is simulated at 1 mm and reconstructed at
2 mm, so the sub-voxel phases cancel. But there is no T2 or T2* decay, so there
is no blurring from signal decay during a long readout. The author's note at
the top of `kspaceDemo.m` already lists this as a planned improvement. For an
fMRI course it is the most valuable physics to add. The spin demo already has
this physics, which is a natural link between the two demos.

### A6. Wrong labels and annotations

- **B0 map title:** both ends of the range use the minimum, `rg(1)`
  (`kspaceShowPlots.m:155-156`). The maximum shown is wrong.
- **Image axes:** `imsize = [0 params.imSize*100]` converts meters to
  centimeters, but the axes say mm (`kspaceShowPlots.m:66`). The scale is off
  by a factor of 10.
- **"kspace computed from image" axes:** this panel shows the FFT of the 1 mm
  original, which reaches twice as far in k-space as the acquired data, but it
  is labeled with the axes of the acquired data. The acquired k-space is only
  the central quarter of this panel. That is a useful teaching point, and at
  the moment the figure hides it.
- **Gradient panels:** both are titled "Gradients". The y-axis is k-space steps
  per sample (cycles/m), not tesla/m. The y-gradient panel's limits are taken
  from the x gradient.
- **Real and imaginary channels:** the comments in
  `kspaceGetCurrentSignal.m`, and the plot 5 comment in `kspaceShowPlots.m`,
  call the real part "sinusoidal" and the imaginary part "cosinusoidal". It is
  the other way round: the real part of `exp(-i*theta)` is `cos(theta)`.
- **"Bandwidth" comment:** the setting is the total receiver bandwidth
  (125 kHz), not the pixel bandwidth. The pixel bandwidth is 1389 Hz along the
  readout and 15.4 Hz along the phase-encode direction. The 15.4 Hz figure is
  the one that explains why EPI distorts along the phase-encode direction.
  Showing it would help students.
- **Local noise spot:** `(y-noiseCenter(1))` should be `noiseCenter(2)`
  (`kspaceGetB0Noise.m:59`). This does no harm at the moment, because both
  values are equal.

## Readability

- **No way to run without the GUI.** `kspaceDemo` always opens the dialog.
  Splitting it into `kspaceDefaultParams`, `kspaceSimulate` (no graphics) and a
  plotting function would match the spin demo (`spinsDefaultParams`,
  `simulateSpins`, `animateSpins`). It would also make assignments possible.
- **Unit conversion is hidden inside the GUI function.** `kspaceParamsGUI`
  both asks for values and converts mm to m, kHz to Hz, and so on. A
  parameter set passed back in is converted again unless the dialog runs.
- **Many functions have no help text** (for example `kspaceGetImage` and
  `kspacePreCompute`), and several give the wrong syntax (for example
  `kspaceComputeOnePoint`).
- **Readout direction.** The readout runs along `y` (image rows) and phase
  encoding runs along `x` (image columns). That is fine, but it is not stated
  anywhere a student would see it, and it decides which way the distortions go.
- **Recursion for "Keep GUI open".** `kspaceDemo` calls itself again, so each
  run adds a stack level. A `while` loop would be simpler.
- **Hard-coded figures 1 and 2** overwrite whatever the user has open.
- **Old style throughout:** single-quoted strings, `exist(...)` for optional
  arguments, `find` where a logical index would do, and dead code after
  `return` in `kspaceRecon.m`. `grid_kb.m` has no attribution. The comments
  mention "Atsushi", presumably its source.
- **Toolbox dependency:** `imresize`, `rgb2gray`, `fspecial` and `imfilter`
  need the Image Processing Toolbox. The README does not say so.
- **Cancelling "other" image selection loops forever** (`kspaceGetImage.m`).

## Speed

Default mode (reconstruct once at the end):

| Step | EPI | Spiral |
|---|---|---|
| Signal loop | 2.1 s | 5.5 s |
| Reconstruction | 0.08 s | 0.19 s |

This is fine for a demo. The point-by-point loop is also good for teaching,
because each step is literally "multiply every spin's phase by a small
rotation". I would not replace it with an FFT.

- **Spiral is slower** because the precompute step only works when there are
  20 or fewer distinct gradient values. Every spiral step recomputes two
  32,400-element complex exponentials. Both are separable in x and y
  (`exp(-i*2*pi*x*GX)` depends only on the column), so computing one row and
  one column vector and taking their outer product would be much cheaper.
- **"Show recon point by point" is very slow**, for two reasons that add up:
  1. The full reconstruction (`griddata` over all 8,100 points) runs at every
     one of the 8,100 time steps. That is about 11 minutes of reconstruction
     alone.
  2. Each update calls `imagesc` again and re-plots the whole gradient history,
     so graphics objects pile up and each frame gets slower. Updating `CData`
     and `XData`/`YData` on existing objects, and redrawing every Nth step with
     `drawnow limitrate`, would fix this.
- **EPI reconstruction uses `griddata`**, which triangulates the points even
  though they already lie on the grid. It is also the likely source of the NaN
  values that the code has to clean up. Placing each sample directly in its
  grid cell by index is exact and faster.

## Suggested order of fixes

1. A1 and A2 (spiral weighting and sign): small edits, big improvement.
2. A6 (labels): small edits that students will otherwise trip over.
3. Add a non-GUI API (`kspaceDefaultParams`, `kspaceSimulate`). Needed for
   any assignment.
4. A4 (true TE) and A5 (T2* decay).
5. Speed up the point-by-point display.
6. A3 (multi-shot spirals), if multi-shot is worth teaching. (Done: removed.)
