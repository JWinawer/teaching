# Up/down spins vs. the uniform model: reconciling Callaghan with Hanson and Williamson

A discussion between Jonathan Winawer and Claude (Claude Code, Opus 5), 16 September 2026.
The replies are lightly edited from the original conversation. Offers to do follow-up work and
the tool output have been removed.

**Sources**

- Paul Callaghan, Magritek NMR/MRI video series: <https://www.youtube.com/watch?v=jUKdVBpCLHM>
- Hanson LG. Is quantum mechanics necessary for understanding magnetic resonance?
  *Concepts Magn. Reson.* 2008;32A:329-340. <https://doi.org/10.1002/cmr.a.20123>
  (in `../literature/`)
- Williamson MP. Drawing Single NMR Spins and Understanding Relaxation.
  *Natural Product Communications*. 2019;14(5). <https://doi.org/10.1177/1934578X19849790>
  (in `../literature/`)

---

## Question 1: Can Callaghan's description be reconciled with Hanson and Williamson?

> In this video, the physicist Paul Callaghan describes hydrogen nuclei in a magnetic field as
> being in either a high energy state (spin up) or a low energy state (spin down), with each
> proton definitely in either the up or down state. This is a typical depiction of NMR. However,
> the Hanson and the Williamson articles seem to argue against this description, and against this
> type of diagram to represent nuclear spins in a magnetic field. For example, see Hanson's
> section "Myth 1: According to QM, Protons Align Either Parallel or Antiparallel to the Magnetic
> Field". Presumably Callaghan is completely knowledgeable about NMR physics and is speaking
> correctly. Can you reconcile these? The code repository for this project makes visualizations
> of the type described in Hanson and Williamson premised on the belief that they are a more
> useful, and possibly more accurate, representation of NMR phenomena.

*(The question came with a screenshot from the video. It shows a slide with B₀ = 2.35 T
(100 MHz) and T = 300 K. On the slide, one energy level splits into two. Four nuclei with arrows
pointing down sit on the upper level, and five with arrows pointing up sit on the lower level.
The caption reads "States each nucleus is definitely in either up or down States".)*

### Answer

Short answer: the two descriptions are not rivals. At the level of what any NMR or MRI experiment
can measure, they are exactly the same. They are two ways to split the same thing into parts.
Neither one says what a single proton in a warm sample is "really" doing. They differ in how well
each works as a picture, and on that point Hanson and Williamson are right.

#### 1. What quantum mechanics says about a sample of spins

A large sample of non-interacting spin-½ nuclei is described by one object, the **density
matrix**. It holds everything you could ever measure about the group. For spin-½ it has a very
simple form:

$$\rho = \tfrac{1}{2}\left(I + \mathbf{P}\cdot\boldsymbol{\sigma}\right)$$

Here **P** is just the **average** Bloch vector of the group. Nothing else about the group enters.
At thermal equilibrium, **P** points along B₀ and is tiny: about 10⁻⁵ at 2.35 T and 300 K.

This means that **any** way of building a group with that same average direction gives the same
density matrix. So it gives the same result for every measurement you can make on the group. Some
examples:

- **Callaghan's picture:** 50.0004% of spins exactly up, 49.9996% exactly down.
- **Hanson and Williamson's picture:** spins point every which way, with a very slight lean toward
  +z.
- **A strange third picture:** 50.0004% along +x and 49.9996% along −x, then rotated. Or any other
  split you like.

Physicists know this result well. The same mixed state can be built from pure states in many ways,
and no measurement on the group can tell those ways apart. So the diagram with 5 spins up and 4
down is a correct **bookkeeping** of the equilibrium state. The populations in it are the diagonal
entries of ρ, and they are exact.

#### 2. Where "definitely up or down" goes too far

One version of Callaghan's sentence is true: **if** you measured the z-spin of any single nucleus,
you would always get up or down, never anything in between. The odds would match the populations.

The problem comes when "would be found up or down" becomes "is up or down." This is the core of
Hanson's Myth 1. Collapse into an eigenstate only happens if you measure each nucleus on its own,
as in a Stern–Gerlach setup. An NMR machine only ever measures the total magnetization. That
measurement is far too gentle to push single nuclei into eigenstates (Hanson, appendix,
proposition 1).

To be fair to both sides, one more point matters. A proton in a warm sample is constantly
interacting with its surroundings. So it usually has no pure state of its own at all. That means
"each spin points in some definite direction" is **also** a way of splitting ρ into parts, not a
literal fact. Williamson says this openly in his abstract: there is "no single 'correct' vector
representation." So the uniform model is not the one true picture either.

#### 3. Why the pictures still differ: what happens next

For a sample sitting still at equilibrium, the two pictures cannot be told apart. They separate
once you apply a pulse, let spins precess, or watch them relax. Each picture then implies
something about how **individual** spins move.

- **The uniform model is correct for single spins, not just for the group.** Feynman, Vernon, and
  Hellwarth showed that a spin-½ state's Bloch vector moves exactly like a classical magnetic
  dipole. So every arrow in the animation can follow the Bloch equations by itself. Precession, RF
  rotation, dephasing, and echoes all work spin by spin. Adding up the arrows gives the right bulk
  result at every moment.
- **The up/down picture breaks as soon as anything happens.** After a 90° pulse, a spin that
  started "up" is along x. That is an equal mix of up and down, and the picture has no way to draw
  it. Textbooks then add fixes that are actually wrong:
  - "The pulse brings the spins into phase" (Hanson's Myth 3, Fig. 4). A uniform RF field can
    never change the angles between spins. It can only rotate the whole group.
  - "Relaxation is spins flipping between up and down." Williamson shows this is an unsatisfying
    story, and that relaxation reads more naturally in the uniform model.

So the static diagram is not false. What is false is the story people build on it about how spins
move.

#### 4. Why an expert like Callaghan uses it

The energy-level picture is the natural language of **spectroscopy**. It is the best tool for:

- explaining why the signal is so weak (the Boltzmann population difference);
- explaining why the resonance frequency is ΔE/h;
- thinking about spin temperature, hyperpolarization, and transitions in coupled-spin systems.

Experts use it as shorthand for "populations of energy levels," and they know what it leaves out.
The confusion comes when a beginner takes it literally.

#### What this means for SpinEnsembleDemo

A slightly different framing from "more accurate" is stronger. The most defensible claim is this:

> The uniform model and the up/down model predict the same equilibrium magnetization. But only the
> uniform model lets each drawn spin obey the correct equation of motion. That is why it can show
> pulses, precession, dephasing, echoes, and relaxation spin by spin without contradicting itself.

This matches what the code does. `initializeSpins.m` spreads the spins over the sphere with a
biased elevation. `spinsTimeStep.m` then moves each spin separately.

---

## Question 2: Is there a way to get the transcript of the Callaghan video?

### Answer

Yes. There are two easy ways.

**Option 1: in the browser (no install).** Open the video on youtube.com. Under the video, click
**...more** to expand the description, scroll down, and click **Show transcript**. A panel opens
with the text and timestamps. You can turn the timestamps off from the ⋮ menu, then copy the text.
The captions for this video are auto-generated, so expect some errors with physics terms.

**Option 2: download the caption file with `yt-dlp`.** This free command-line tool can save just
the captions, without the video.

```bash
brew install yt-dlp
```

```bash
yt-dlp --skip-download --write-subs --write-auto-subs --sub-langs "en.*" --sub-format vtt -o "$HOME/Documents/callaghan_nmr.%(ext)s" "https://www.youtube.com/watch?v=jUKdVBpCLHM"
```

This saves a `.vtt` caption file. It is plain text, but full of timestamps, and auto-captions
repeat each line several times. A short Python script turned it into clean text, grouped into
30-second paragraphs. The result is in `~/Documents/callaghan_nmr_transcript.txt` (not in this
repository). The captions contain errors such as "lour" for "Larmor" and "procession" for
"precession."

---

## Question 3: What does Callaghan actually say about up and down?

*(Follow-up after reading the transcript.)*

### Answer

Callaghan does not add a caveat later in the talk. He states the up/down view firmly. Here is what
he says, in order (times are approximate):

- **0:37:** A proton in a field has two quantum states, spin up (low energy) and spin down (high
  energy).
- **1:12:** A single nucleus can be in a coherent superposition of up and down. He says this is the
  situation while protons are precessing in an MR experiment. He then says he won't discuss
  superpositions again in the series.
- **2:16:** This is the key passage. He says, of the spins at equilibrium, "these thermal
  equilibrium states are not superposition States." Then he says each nucleus is definitely up or
  down, with slightly more up. So the slide caption was an intentional claim, not a loose phrase.
- **2:48:** Only the "spin excess" can be seen. All the other spins cancel in pairs and are
  invisible to NMR.

#### How this fits with the answer to Question 1

His claim has a precise, correct version and a literal version that goes further.

- **The correct version:** At thermal equilibrium, the density matrix of the sample has no
  coherences between up and down. In that sense the *ensemble* is "not in a superposition." That is
  standard and true. After an RF pulse, those coherences appear, which matches his statement that
  superpositions show up once spins precess.
- **The literal version:** "Each nucleus is definitely up or down" is one way to split that density
  matrix into single spins. It is the exact point that Hanson's Myth 1 disputes. A sample with every
  spin pointing in a random direction, leaning slightly toward +z, has the very same density matrix.
  No NMR measurement can tell the two apart.

The "spin excess" story is the same kind of choice. In the up/down picture, most spins cancel in
pairs, and only the excess does anything visible. In the uniform model, which SpinEnsembleDemo
uses, every spin contributes a little, and the small net lean produces the magnetization. Both give
the same bulk vector. But only the uniform model lets each drawn spin follow the Bloch equation on
its own through pulses and relaxation.

So Callaghan is not making an error you could catch in an experiment. He is presenting one valid
bookkeeping as if it were the literal state of each nucleus. That is the habit Hanson and
Williamson argue against.

---

## Question 4: Does the up/down bookkeeping have any advantage for teaching?

> As a student, I found diagrams and language like that presented by Callaghan to be confusing in
> the non-equilibrium state, as I found it hard to translate it into flips, particularly a
> continuous flip that keeps going past 180º. Is there any advantage to the bookkeeping choice he
> makes? For example, would an introductory text on MRI be disadvantaged by *not* including any
> diagrams showing all nuclei in either an exact up or down state, without ever referring to or
> depicting the "alignment model" or the "two-cone model" described in the two papers?

### Answer

Short answer: an introductory MRI text would lose very little by never drawing the alignment or
two-cone model. It could gain a lot. The up/down view has a few real strengths, but you can get
each of them without drawing nuclei as arrows pointing only up or down. The main cost of leaving it
out entirely is that students will run into it elsewhere and won't know how it relates. A short
side note can fix that.

#### This difficulty is a real flaw, not a student error

The up/down view only gives a clear picture at two flip angles. At 0° nothing has changed. At 180°
the populations are swapped. Every other angle needs superpositions, which the diagram can't show.
A flip that keeps going past 180° is even harder, because "swapped populations" has no obvious next
step.

The clearest example is comparing a 90° pulse with **saturation**:

- After a 90° pulse, the up and down populations are equal. The signal is as large as it can be.
- After saturation (for example, many rapid pulses with spoiling), the up and down populations are
  also equal. There is no signal.

A population diagram draws these two states the same way. The difference lies entirely in the
coherences, the off-diagonal part of the density matrix, which the diagram leaves out. In the
uniform model the difference is obvious. After the 90° pulse, the whole cloud leans sideways. After
saturation, it doesn't lean in any direction. A flip angle of 270° or 400° is just the cloud
rotating further.

#### What the up/down view really does well

| Strength | Do you need nuclei drawn as up or down? |
|---|---|
| **Two energy levels, ΔE = γħB₀.** Links the Larmor frequency to energy and to the Boltzmann factor. | No. You can draw two energy levels as a statement about **energies**, without drawing spins pointing up or down. |
| **Size of the signal.** "About 1 in 100,000 extra spins" gives a feel for why MRI is weak, and why a higher field or lower temperature helps. | No. "The cloud leans toward +z by about 1 part in 100,000" says the same thing. |
| **The exact formula for M₀.** The spin-½ result (Curie's law) falls out of a two-level sum. | Partly. The uniform model gets the same answer, but only if you use the full spin magnitude, √(I(I+1)). Using ½ gives an answer off by a factor of 3. An intro text can simply state the formula. |
| **Inversion and "negative spin temperature."** | No. After a 180° pulse, the cloud leans toward −z and relaxes back. |
| **Relaxation theory** (transition rates W₀, W₁, W₂, spectral density at ω₀ and 2ω₀, NOE, magnetization transfer) is written in terms of transitions between energy levels. | This is the strongest case. But it is advanced material, beyond most intro MRI courses. At an intro level, "fluctuating fields near the Larmor frequency cause T₁ relaxation" works fine with the uniform model. |
| **Spectroscopy** (J-coupling multiplets, hyperpolarization, DNP). Energy-level diagrams are the standard tool. | Yes, energy levels are needed. But coupled spins can't be drawn as single vectors in **any** of the three models. This is MRS or NMR chemistry, not intro MRI. |

So what really helps is the **energy-level diagram** and **population counting**. Neither one needs
a picture of each nucleus pointing exactly up or down.

#### Costs of the up/down view in an MRI course

Beyond the flip-angle problem:

- It invites "the RF pulse brings spins into phase" (Hanson's Myth 3) and "T₂ is spins falling out
  of the phase the pulse gave them."
- It suggests most spins are "invisible" and only the excess matters. That makes dephasing and
  echoes harder to picture spin by spin.
- It tells students on day one that spins behave strangely. Then nearly everything in MRI (pulses,
  gradients, echoes, k-space) is taught with classical rotations anyway.

#### One caution about the uniform model

It is not free of risk. Students may treat each arrow as a tiny classical magnet whose z-component
you could read directly. For MRI this almost never matters. One sentence can head it off: the arrows
are a faithful way to track the group, and a measurement on a single nucleus would still give only
up or down.

#### Recommendation for an intro MRI text

1. Use the uniform model for every picture of individual spins, as SpinEnsembleDemo does.
2. Include one **energy-level diagram** with **no spins drawn on it**. Use it for ΔE = γħB₀ and the
   Boltzmann ratio.
3. Add a short box, something like "You will often see spins drawn as only up or only down." In it,
   explain that this is a way of counting populations. It gives the same bulk magnetization, but it
   can't show what happens during a pulse. Point out that the 90°-versus-saturation example shows
   what it leaves out.

With that box, students lose nothing they need for MRI. They will also be able to read
Callaghan-style explanations without confusion. Williamson points to Keeler's and Levitt's textbooks
as examples that already avoid the alignment picture.
