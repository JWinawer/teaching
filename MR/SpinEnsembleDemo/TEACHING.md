# Using the spin animations in the fMRI course

Notes on how to get the `SpinEnsembleDemo` animations in front of students and into
lecture material. Written September 2026, for an fMRI course aimed at early
stage PhD students in cognitive neuroscience with limited physics background.

Everything under "Proposed additions" is not built yet. Everything else works
with the code as it stands.

**Update, September 2026.** Section 2 (field inhomogeneity, T2*, spin echo,
BOLD) is now built. See `params.b0spread`, the vector `flipangle` / `fliptime` /
`flipphase` fields, and the last three cells of `s_NMRWorkedExamples.m`. A first
worked tutorial, `tutorials/tutorial1_equilibrium.m`, covers the Boltzmann
distribution and equilibrium.

---

## 1. Getting students running

This is the biggest obstacle, and it is not a content problem. "Install MATLAB,
clone a repo, addpath, run a script" will lose a real fraction of a cognitive
neuroscience cohort in the first week. Three options, in order of effort:

**MATLAB Online.** The NYU license almost certainly includes it. Put the folder
in MATLAB Drive and share a link. Students click and run in a browser with no
install. Highest payoff for the least work.

**A Live Script with sliders.** Live Editor controls on `k`, `flipangle`, `t1`,
`t2`, and `nspins` let students drag a control and immediately re-run the
section. The animation now runs at about 36 fps, so this feels responsive
rather than sluggish.

Combined, these two are probably the right answer: a Live Script, opened in
MATLAB Online from a shared link.

**A browser version.** Zero install, works on a phone, no license needed. But
it is a real project, and it would need maintaining separately from the MATLAB
code.

---

## 2. The content gap that matters most: T2\*

The simulation originally had no static field inhomogeneity, so it could not
show T2\*, the spin echo, or BOLD contrast. For an fMRI course that was the
important gap, because **BOLD contrast is T2\***.

**This is now implemented.** Each spin gets a fixed frequency offset drawn from
a Lorentzian distribution, set by `params.b0spread` and added to the phase
advance in `rotateB0`. The Lorentzian is what makes the decay exponential, so
the familiar `1/T2* = 1/T2 + 1/T2'` holds, and it is reproduced to within about
1%. One extra array buys three things:

**T2\* falls out automatically.** Transverse magnetization decays faster than
T2 because spins at different offsets fan out in phase, on top of the random
walk that produces true T2.

**The spin echo.** This is where the uniform model earns its keep. Students can
watch the spins fan out from the static offsets, see a 180 degree pulse flip
the fan over, and watch it re-converge into an echo, while the random T2 walk
visibly does *not* come back. The difference between reversible and
irreversible dephasing is hard to convey with the two-cone picture and close to
self-evident here.

**BOLD in one slider.** Widen the offset distribution to represent
deoxygenated blood, narrow it for oxygenated. Transverse magnetization then
decays at different rates, so at a fixed TE you read out a different signal.
That is the entire basis of the experiment the students will spend the rest of
the semester analyzing, in one control.

---

## 3. Frame the lecture as myth-busting, not illustration

Both source papers are explicitly corrective. Hanson is arguing against the
two-cone picture; Williamson is comparing three models and arguing the uniform
one is best. Students will already have seen the two-cone picture in every
textbook they have opened.

So do not present the animation as another picture to memorize. Present it as
the resolution of a puzzle:

1. Show the textbook two-cone figure.
2. Ask what it predicts for a 90 degree pulse.
3. Let them notice that spins pinned to two cones cannot produce transverse
   magnetization.
4. Then run the animation.

Williamson's line that the alignment model "cannot comment on transverse
relaxation, because there is no xy component to magnetization in this model" is
the hinge of the whole argument, and it is worth putting on a slide.

---

## 4. Make the elevation histogram the centerpiece

The bottom right panel of the animation *is* the Boltzmann distribution. Its
tilt toward +90 degrees is the entire source of the MR signal. Everything else
on the screen is bookkeeping.

Worth saying out loud: the real bias is about 1 part in 10^5, far too small to
draw, so what they are seeing is exaggerated by roughly that factor. Then ask
how many spins you would need before the excess becomes visible, and point out
that a voxel holds something like 10^19. That is why it works at all.

This also explains why `k` is a display parameter with no physical units, which
otherwise looks like a fudge.

---

## 5. Predict-then-watch exercises

Each is one parameter change. The point is that students commit to an answer
before running.

| Change | Question | What they should see |
|---|---|---|
| `k = 0` | What happens to the bulk vector? | It collapses to zero. No field, no signal. |
| `larmor = 0` | What changed physically? | Nothing. The rotating frame is a change of viewpoint, not of physics. |
| `flipangle = pi` | Where does M go? Is there a signal right away? | Straight to −z, no transverse component, so no signal. This is why inversion recovery needs a second pulse. |
| `nspins = 30` | What happens to the Mz and Mxy traces? | They get visibly noisy. |

The `larmor = 0` one is close to free and does a lot of work. The rotating
frame is a concept students usually find slippery, and here it is literally one
parameter.

The `nspins` one is the cleanest bridge from NMR physics to the rest of the
course: it is the same reason fMRI has noise, and the same reason voxel size
trades against SNR.

---

## 6. Lecture material mechanics

**Pre-render the movies and embed the mp4 files in slides.** Keynote and
PowerPoint both play them natively. Do not run the animation live in front of
40 people. Movie export works now (`saveMovieFlag = true`); it writes to
`movies/`, which is gitignored.

**Add a still-frame export.** Worth building a small "figure mode" that writes a
four panel still: equilibrium, just after the flip, mid-relaxation, and
recovered. Useful for handouts, for annotating on printouts, and for the day the
projector misbehaves.

**Consider thickening the bulk magnetization vector.** In the current rendering
it can be hard to pick out against the cloud of spins, especially when it is
short. For projection it may need to be heavier, or drawn as an arrow.

---

## 7. An assessment idea

Hand students the code and ask them to **measure** T2 from the simulation
output and compare it to the nominal `t2` value.

It is a short exercise, it teaches that a simulation has to be validated
against what it claims, and it is exactly the check that caught a real 5%
miscalibration in this code in September 2026. There is something useful in
students learning that published-looking code can be quietly wrong, and that
the way you find out is by measuring.

A harder version: ask them to measure T1 and explain why the answer depends
slightly on how the magnetization was prepared. The answer is in the comments
in `relaxationLongitudinal.m` — exaggerating `k` makes the relaxation slightly
non-exponential.

---

## Proposed additions, in priority order

1. ~~**Field inhomogeneity, spin echo, and BOLD**~~ — done, September 2026.
2. **The rest of the tutorial series** (see below). Tutorial 1 is drafted.
3. **Live Script with sliders**, shared through MATLAB Online (section 1).
   Solves the access problem. The tutorials are already Live Scripts, so adding
   controls is a small step from here.
4. **Still-frame export mode** (section 6). Small.
5. **Two-tissue comparison.** Run two parameter sets side by side with different
   T1 values, gray versus white matter, and vary TR to show how T1-weighting
   arises. The physics is already in place; this is a wrapper and a second
   figure panel. `simulateSpins` makes this easy.

## Planned tutorial series

Each is a plain-text Live Script in `tutorials/`, mixing explanation, formulas
and runnable calls to the animations.

1. **Equilibrium and the Boltzmann distribution** — drafted. Where the signal
   comes from, why spins are not on two cones, and why the real effect is about
   10^5 times smaller than the picture.
2. **Precession and the rotating frame** — what Larmor precession is, and why
   setting `larmor = 0` is a change of viewpoint rather than of physics.
3. **B1 and resonance** — why a weak rotating field tips the magnetization when
   a strong static one does not, and what "resonance" actually means.
4. **T1 and T2 relaxation** — the two mechanisms as different random walks, one
   in elevation and one in azimuth.
5. **T2 versus T2\*, and the spin echo** — reversible versus irreversible
   dephasing. All the machinery for this exists now.
6. **From T2\* to BOLD** — why the fMRI signal changes with oxygenation, and why
   TE is set near T2\*.

---

## Source papers

Both are in `literature/`, and both are worth assigning. Williamson is the more
readable of the two for this audience.

- Williamson MP. Drawing Single NMR Spins and Understanding Relaxation.
  *Natural Product Communications*. 2019;14(5). Figure 3 is the uniform model.
- Hanson LG. Is quantum mechanics necessary for understanding magnetic
  resonance? *Concepts Magn. Reson.* 2008;32A:329-340. Figures 2 and 3.
