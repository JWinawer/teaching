# MR

MATLAB demos for teaching the physics of MRI, written for an fMRI course for
graduate students.

- `SpinEnsembleDemo/`: where the MR signal comes from. It animates thousands
  of individual spins and the bulk magnetization they add up to, covering
  equilibrium, precession, RF pulses, T1, T2, T2*, the spin echo and BOLD.
- `KspaceDemo/`: how the signal becomes an image. It simulates a scanner
  measuring k-space one sample at a time, with EPI and spiral readouts, and
  shows where distortion, wraparound and signal dropout come from.

Each demo has its own README with a quick start.

## Shared conventions

The two demos are written to work the same way, so that students who learn
one can use the other.

- **Units:** the ones a scanner console uses. Times in ms, frequencies in Hz,
  angles in degrees, distances in mm, bandwidth in kHz, field errors in ppm.
- **Settings:** a struct from `...DefaultParams()`, whose help lists every
  setting with its unit. Settings you leave out take their defaults. A name
  that does not exist is an error, and a value that looks like it is in the
  old units (seconds, radians) gives a warning.
- **Entry points:** at the top level of each demo, and prefixed with the demo
  name: `spinsAnimate`, `spinsSimulate`, `kspaceDemo`, `kspaceSimulate`.
  Optional inputs use `Name=Value`, for example `Figure=f`.
- **Folders:** `subroutines/` for the helper functions (added to the path
  automatically), `tests/` for tests, `docs/` for write-ups. Run the tests
  with `runtests("tests")` from the demo folder.
- **Code style:** the MathWorks MATLAB coding guidelines: lowerCamelCase
  names, double-quoted strings, an `arguments` block for inputs, and help text
  that starts with a one-line summary, then the syntax, inputs, outputs and a
  "See also" line.
- **Requirements:** MATLAB R2021a or newer. KspaceDemo also needs the Image
  Processing Toolbox.
