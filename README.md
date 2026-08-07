# Saint Vincent — Beamer theme and lecture notes

A clean Beamer theme and a matching lecture-notes class for economics, built on
a shared core so slides and notes look like the same document family.

Companion to the
[Economics Problem Set template](https://github.com/gianluca-tisci/Latex_Template_Economics_ProblemSet),
which uses the same `almacore.sty`. A definition, a call-out or a boxed result
renders identically in all three.

📄 **[Slides](Demo-beamer.pdf)** · **[Lecture notes](Demo-notes.pdf)**

---

## Quick start

Each directory under `templates/` is self-contained — zip it, upload to
Overleaf, recompile. Nothing needs installing.

```bash
git clone https://github.com/gianluca-tisci/Saint-Vincent-Beamer-Theme.git
cd Saint-Vincent-Beamer-Theme/templates/beamer && latexmk -pdf Main.tex
cd ../notes && latexmk -pdf main.tex
```

Requires `tcolorbox`, `pgfplots`, `titlesec` and the `augie` font — all in
full TeX Live, MacTeX and Overleaf. Annotation arrows need two passes;
`latexmk` handles that.

---

## Slides

```latex
\documentclass[aspectratio=169]{beamer}
\usetheme{SaintVincent}
```

| Option | Effect |
|---|---|
| `night` | dark colour scheme |
| `nosectionslides` | no divider slide at each `\section` |
| `hidememo` | suppress `\memo` and `\NB` annotations |
| `wiggle=<n>` | pencil amplitude in pt (default `0.2`) |
| `nographs` | skip pgfplots for faster compiles |

The theme is **standalone**. Earlier versions of this repository called
`\usetheme{SimplePlus}` without shipping that theme, so a fresh clone did not
build; nothing outside Beamer and `almacore` is needed now.

## Lecture notes

```latex
\documentclass[11pt,a4paper]{article}
\usepackage{svnotes}
```

| Command | Effect |
|---|---|
| `\para` | auto-numbered, `\ref`-able paragraph |
| `\tocheading{...}` | unnumbered heading that still reaches the TOC |
| `\backmatter` | switch `\section` numbering to letters for appendices |
| `\listofboxes` | list of every numbered `\boxentry` call-out |
| `\course`, `\lecturer`, `\academicyear`, `\shorttitle` | metadata driving the title and headers |

Theorem environments — `definition`, `proposition`, `theorem`, `lemma`,
`corollary`, `assumption`, `remark`, `example` — share one counter and are
numbered within sections, so "Proposition 3.2" tells you where to look.

---

## Shared core

`almacore.sty` provides everything both templates have in common:

| Item | Effect |
|---|---|
| `\lapis[c]{text}` | hand-drawn underline |
| `\lapisbox[c]{text}` | hand-drawn box around inline text |
| `\lapisboxeq[c]{math}` | hand-drawn box around display math |
| `\result{...}` | prominent boxed result |
| `\hl[c]{text}` | marker-pen highlight behind the text |
| `{\hand ...}`, `\handbold[stroke]{text}` | handwriting, scoped to the group |
| `\marker{name}{content}` + `\handnote[colour]{name}{dx}{dy}{text}` | handwritten comment with an arrow back to the target |
| `\handarrowup` / `down` / `left` / `right` | short inline arrows; take TikZ options |
| `almaoverlay` (env) + `almaarrow` style | draw your own annotation arrows |
| `notebox` + `\boxentry{title}` | breakable shaded call-out, numbered |
| `\memo{...}`, `\NB{...}` | draft annotations, hidden by `hidememo` |
| `code`, `\mc{...}`, `\mci\|...\|` | code block and inline chips |
| `econaxis` | pgfplots style for economics figures |
| `Y` column, `\tablenote`, `\sym` | table helpers, estout-compatible |
| `\E`, `\Ex[t]`, `\Var`, `\Cov` | moment operators |

Annotating a **table**: `\marker` names a cell, and the `\handnote` follows
the closed tabular (the overlay is in page coordinates, so a `\draw` inside a
cell would be clipped). Annotating a **figure**: skip `\marker` entirely and
draw inside the axis in `axis cs:` data coordinates — one pass, and the arrow
tracks the data if the limits change. Both are shown in the demo templates.

It loads **only packages that are safe under Beamer** — `xcolor`, `tikz`,
`tcolorbox`, `etoolbox`, `amsmath`, `fancyvrb`. Everything page-based lives in
the wrappers (`svnotes.sty`) or the theme. That constraint is what lets one
core serve a slide theme and an article class without either drifting.

### Notation modules

```latex
\input{macros/alma-micro}     % preferences, utility, demand, MRS, Lagrangian
\input{macros/alma-metrics}   % estimators, \plim, \convd, Avar, matrices
\input{macros/alma-macro}     % aggregates, rates, steady state, IS/LM/PC
```

---

## Fonts

Nothing changes `\familydefault`. Slides use Beamer's default family, notes
the article class default; everything is styled by size, weight and colour
only.

`\hand` is the one deliberate exception, and it is a *scoped* switch — the
Augie handwriting font applies only inside the group you put it in, never to
the document. If Augie is missing, `\hand` degrades to italic with a warning
instead of failing.

## Colours

One accent — a dark blue, defined once as `almaaccent` in `almacore.sty`.
Change it there and slides, notes and the problem-set template all follow.

Handwritten comments and their arrows use their own ink (`almanoteink`, an
amber), because an annotation is someone talking *about* the document rather
than part of it, and should not read as a heading. Override per comment with
`\handnote[almaalert]{...}`. Alert blocks are the only other colour; `\memo`
and `\NB` are grey and disappear under `hidememo`. Tints are mixed explicitly against the theme background
(`svaccent!12!svbg`, not `svaccent!12`) so night mode stays dark.

---

## Repository layout

```
tex/
  almacore.sty                  shared core (authored in the problem-set repo)
  svnotes.sty                   lecture-notes wrapper
  beamerthemeSaintVincent.sty   the slide theme
macros/                         notation modules
templates/
  beamer/                       self-contained demo deck
  notes/                        self-contained demo notes
tools/sync-templates.sh         mirrors tex/ + macros/ into templates/, with a drift check
```

`almacore.sty` is authored in the problem-set repository and vendored here.
`tools/sync-templates.sh --check` fails CI if the vendored copies drift, and
warns if a sibling clone of the problem-set repo has a different version.

---

## Licence

[MIT](LICENSE).

The feature set — pencil annotations, shaded call-outs, the draft-memo system —
is inspired by Ambrogio Cesa-Bianchi's
[JambroBeamerTheme](https://github.com/ambropo/JambroBeamerTheme) and
[JambroNotesTheme](https://github.com/ambropo/JambroNotesTheme). No code from
either project is used here; every macro is an independent implementation.
