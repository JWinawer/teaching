# KspaceDemo

A simulation of how an MRI scanner measures k-space and turns it into an
image. The scanner is simulated one sample at a time: at each step, every spin
in the object is rotated by the gradients and by any error in the main field,
and the signal is the sum over all spins. You can watch k-space fill, and see
where artifacts such as EPI distortion, wraparound and signal dropout come
from.

Two readouts are included: EPI (a zigzag through k-space) and a spiral.

## Quick start

With the dialog:

```matlab
kspaceDemo();
```

From a script, with no dialog and no graphics:

```matlab
params = kspaceDefaultParams();
params.noiseType = "dc offset";   % a uniform field error
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
params.noiseType = "local offset";
for te = [35 50 80]
    params.echoTime = te;
    result = kspaceSimulate(params);
    % ... compare result.recon across echo times
end
```

## Parameters

See `kspaceDefaultParams` for the full list and units. All values are in the
units a scanner console uses: mm, ms, kHz and ppm. A few to know about:

- `echoTime` is the echo time, TE: the time from excitation to the centre of
  k-space. The readout is placed so that the centre is sampled at exactly this
  time. EPI reaches the centre halfway through its readout, so it has a
  minimum TE. At the default settings that minimum is about 33 ms. A shorter
  TE gives an error that states the minimum.
- `t2star` is the T2* decay of the tissue, from causes smaller than one
  simulated pixel. The default, `Inf`, means no decay. Field errors from
  `noiseType` add more dephasing on top of this, because they are simulated
  explicitly. In a script, `t2star` may also be a map the size of the image.
- `imfile` may also be a numeric matrix in a script, so you can scan any
  object you like, such as a test pattern.
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

## Files

- `kspaceDemo.m`: the dialog version.
- `kspaceSimulate.m`: the simulation, for scripts.
- `kspaceDefaultParams.m`: default settings and what each one means.
- `kspaceFunctions/`: the pieces: pulse sequences, the per-step physics,
  reconstruction and plotting.
- `mrVistaUtilities/`: the dialog code, from mrVista.
- `docs/REVIEW.md`: a review of the code from September 2026, with what was
  fixed.

## Requirements

MATLAB R2021a or newer (for `Name=Value` syntax), and the
Image Processing Toolbox (`imresize`, `rgb2gray`, `fspecial`, `imfilter`).

Updated Sep 2026
