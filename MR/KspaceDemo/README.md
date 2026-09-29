# KspaceDemo

A simulation of how an MRI scanner measures k-space and turns it into an
image. The scanner is simulated one sample at a time: at each step, every spin
in the object is rotated by the gradients and by any error in the main field,
and the signal is the sum over all spins. You can watch k-space fill, and see
where artifacts such as EPI distortion, wraparound and signal dropout come
from.

Two readouts are included: EPI (a zigzag through k-space) and a spiral.

## Quick start

Add this folder to the MATLAB path. Then, with the dialog:

```matlab
kspaceDemo();
```

From a script, with no dialog and no graphics:

```matlab
params = kspaceDefaultParams();
params.fieldErrorType = "dc offset";   % a uniform error in B0
result = kspaceSimulate(params);
imagesc(result.recon); axis image; colormap gray
```

To plot a scripted run, pass a figure:

```matlab
result = kspaceSimulate(params, Figure=figure);
```

`kspaceSimulate` never changes `params`, so it is easy to sweep a setting:

```matlab
params = kspaceDefaultParams();
params.fieldErrorType = "local offset";
for te = [35 50 80]
    params.echoTime = te;
    result = kspaceSimulate(params);
    % ... compare result.recon across echo times
end
```

## Units

Values are in the units a scanner console uses: **mm**, **ms**, **kHz** and
**ppm**. The spin demo uses the same units. Settings you leave out take their
defaults. A setting name that does not exist is an error rather than being
silently ignored. This also catches the names used before September 2026 (for
example `noiseType`, now `fieldErrorType`). A time that looks like it is in
seconds gives a warning.

## Parameters

See `kspaceDefaultParams` for the full list and units. A few to know about:

- `echoTime` is the echo time, TE: the time from excitation to the center of
  k-space. The readout is placed so that the center is sampled at exactly this
  time. EPI reaches the center halfway through its readout, so it has a
  minimum TE. At the default settings that minimum is about 33 ms. A shorter
  TE gives an error that states the minimum.
- `t2star` is the T2* decay of the tissue, from causes smaller than one
  simulated pixel. The default, `Inf`, means no decay. Field errors from
  `fieldErrorType` add more dephasing on top of this, because they are
  simulated explicitly. In a script, `t2star` may also be a map the size of
  the image.
- `fieldErrorType` and `fieldErrorPpm` set the pattern and size of the error
  in the main field B0. This is a fixed error in the field, not random noise.
- `imageFile` names an image in `data/`. In a script it may also be a numeric
  matrix, so you can scan any object you like, such as a test pattern.
- `bandwidth` is the total receiver bandwidth. At the defaults (125 kHz,
  90 x 90 pixels) the bandwidth per pixel is 1389 Hz along the readout but only
  15.4 Hz along the phase encode direction. That is why field errors distort
  EPI images along the phase encode direction.
- In EPI, the readout runs vertically (along y) and phase encoding runs
  horizontally (along x).

## What the panels show

- **Top row:** the object; its full k-space, with the region the scan
  measures outlined in red; and the map of field error, in Hz.
- **Middle row:** the reconstructed image; the k-space measured so far; and
  the current spin pattern. That pattern is the cosine wave the object is
  being multiplied by to get the current sample.
- **Bottom row:** the gradient waveforms, in mT/m, against time since
  excitation. The dashed line marks TE.

Tick "Show recon as k-space fills" in the dialog, or set
`params.showProgress = true` with a figure, to watch k-space fill.

## Movies

To save a movie of k-space filling, set `SaveMovie=true`:

```matlab
result = kspaceSimulate(params, SaveMovie=true, Title="EPI with a local field error");
implay(result.movieFile);   % needs Image Processing Toolbox
```

This works with `kspaceDemo` too: `kspaceDemo(params, SaveMovie=true)` saves a
movie of each run. The movie has one frame per progress update (one EPI line by
default, so about 90 frames), plays at 6 frames per second (`MovieFrameRate`),
and holds the final image for 1 s. Without a `Title`, the file is named after
the sequence and field error type, so a later run with the same settings
replaces it. Movies go in `movies/`, which is gitignored. Saving is slower than
watching, because each frame has to be captured from the screen.

## Tests

`tests/testKspace.m` checks the simulation against results that can be worked
out by hand, such as the EPI shift from a uniform field offset and the signal
lost to T2* at TE. Run it from this folder with:

```matlab
runtests("tests")
```

## Files

- Top level: the functions you call. `kspaceDemo` (with the dialog),
  `kspaceSimulate` (for scripts) and `kspaceDefaultParams` (the settings and
  what each one means).
- `subroutines/`: the pieces. `kspaceMakePulseSequence` (with `kspaceEPI` and
  `kspaceSpiral`) makes the trajectory, `kspaceStepFactor` and
  `kspaceMeasureSample` do the physics of each step, `kspaceRecon` makes the
  image, and `kspaceShowPlots` draws it. The top-level functions add this
  folder to the path themselves.
- `data/`: the sample images and a measured field map.
- `movies/`: saved movies (not committed).
- `tests/`: see above.
- `docs/REVIEW.md`: a review of the code from September 2026, with what was
  fixed.

## Requirements

MATLAB R2021a or newer (for `Name=Value` syntax), and the Image Processing
Toolbox (`imresize`, `rgb2gray`, `fspecial`, `imfilter`).

## Credits

Written by Jonathan Winawer in 2009, as part of Vistasoft, with later edits by
Brian Wandell. Revised in September 2026. The spiral gridding code is adapted
from code credited to Atsushi in the original comments. The sample images were
downloaded from a Google image search. The field map in `data/b0Lucas.mat`
appears to be from the Lucas Center at Stanford.

Updated Sep 2026
